import 'dart:io';

import 'package:expense_manager/data/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('in-memory database is migrated and seeded', () {
    final db = openAppDatabase(null);
    expect(db.userVersion, schemaVersion);
    final cats = db.select('SELECT kind, count(*) AS n FROM categories GROUP BY kind ORDER BY kind');
    expect({for (final r in cats) r['kind']: r['n']}, {'income': 2, 'invest': 5, 'spend': 9});
    expect(db.select('SELECT name FROM categories WHERE is_default = 1').single['name'], 'Others');
    expect(db.select('SELECT name FROM sources WHERE is_default = 1').single['name'], 'Cash');
    db.close();
  });

  test('file database persists and is not re-seeded on reopen', () {
    final dir = Directory.systemTemp.createTempSync('em');
    final path = '${dir.path}/t.db';
    openAppDatabase(path).close();
    final again = openAppDatabase(path);
    expect(again.select('SELECT count(*) AS n FROM sources').single['n'], 1);
    again.close();
    dir.deleteSync(recursive: true);
  });

  test('a v1 database upgrades with a zero opening balance', () {
    final dir = Directory.systemTemp.createTempSync('em');
    final path = '${dir.path}/v1.db';
    final old = sqlite3.open(path);
    old.execute(
      'CREATE TABLE sources (id INTEGER PRIMARY KEY, name TEXT NOT NULL, kind TEXT NOT NULL, last4 TEXT, credit_limit INTEGER, is_default INTEGER NOT NULL DEFAULT 0, archived INTEGER NOT NULL DEFAULT 0)',
    );
    old.execute("INSERT INTO sources(name, kind) VALUES ('Old', 'bank')");
    old.execute(
      "CREATE TABLE debts (id INTEGER PRIMARY KEY, direction TEXT NOT NULL, kind TEXT NOT NULL, name TEXT NOT NULL, counterparty TEXT NOT NULL DEFAULT '', principal INTEGER NOT NULL, rate REAL, emi INTEGER, total_emis INTEGER, due_day INTEGER, settled INTEGER NOT NULL DEFAULT 0)",
    );
    old.execute("INSERT INTO debts(direction, kind, name, principal) VALUES ('iOwe', 'card', 'ICICI', 100)");
    old.userVersion = 1;
    old.close();
    final db = openAppDatabase(path);
    expect(db.userVersion, schemaVersion);
    expect(db.select('SELECT opening_balance FROM sources').single['opening_balance'], 0);
    expect(db.select('SELECT statement_amount, statement_due_at FROM debts').single.values, [null, null]);
    db.close();
    dir.deleteSync(recursive: true);
  });

  test('migrate runs only pending steps in order', () {
    final db = sqlite3.openInMemory();
    final ran = <int>[];
    migrate(db, steps: [(_) => ran.add(1), (_) => ran.add(2)]);
    expect(ran, [1, 2]);
    expect(db.userVersion, 2);
    migrate(db, steps: [(_) => ran.add(1), (_) => ran.add(2), (_) => ran.add(3)]);
    expect(ran, [1, 2, 3]);
    db.close();
  });

  test('amount must be positive', () {
    final db = openAppDatabase(null);
    expect(() => db.execute("INSERT INTO transactions(type, amount, category_id, occurred_at, created_at) VALUES ('spend', 0, 1, 0, 0)"), throwsA(isA<SqliteException>()));
  });
}
