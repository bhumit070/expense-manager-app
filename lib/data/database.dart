import 'package:sqlite3/sqlite3.dart';

/// Current schema version. Bump and add a step to [_migrations] for changes.
const schemaVersion = 4;

final List<void Function(Database)> _migrations = [_v1, _v2, _v3, _v4];

/// Opens (or creates) the app database and runs pending migrations.
Database openAppDatabase(String? path) {
  final db = path == null ? sqlite3.openInMemory() : sqlite3.open(path);
  db.execute('PRAGMA foreign_keys = ON');
  db.execute('PRAGMA journal_mode = WAL');
  migrate(db);
  return db;
}

void migrate(Database db, {List<void Function(Database)>? steps}) {
  final all = steps ?? _migrations;
  final current = db.userVersion;
  for (var v = current; v < all.length; v++) {
    db.execute('BEGIN');
    all[v](db);
    db.userVersion = v + 1;
    db.execute('COMMIT');
  }
}

void _v1(Database db) {
  db.execute('''
CREATE TABLE categories (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  kind TEXT NOT NULL,
  icon TEXT NOT NULL,
  color INTEGER NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_default INTEGER NOT NULL DEFAULT 0,
  archived INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE sources (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  kind TEXT NOT NULL,
  last4 TEXT,
  credit_limit INTEGER,
  is_default INTEGER NOT NULL DEFAULT 0,
  archived INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE investments (
  id INTEGER PRIMARY KEY,
  kind TEXT NOT NULL,
  name TEXT NOT NULL,
  institution TEXT NOT NULL DEFAULT '',
  rate REAL,
  start_at INTEGER,
  maturity_at INTEGER,
  note TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'active'
);
CREATE TABLE debts (
  id INTEGER PRIMARY KEY,
  direction TEXT NOT NULL,
  kind TEXT NOT NULL,
  name TEXT NOT NULL,
  counterparty TEXT NOT NULL DEFAULT '',
  principal INTEGER NOT NULL,
  rate REAL,
  emi INTEGER,
  total_emis INTEGER,
  due_day INTEGER,
  settled INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY,
  type TEXT NOT NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  inflow INTEGER NOT NULL DEFAULT 0,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  source_id INTEGER REFERENCES sources(id),
  occurred_at INTEGER NOT NULL,
  merchant TEXT NOT NULL DEFAULT '',
  note TEXT NOT NULL DEFAULT '',
  tags TEXT NOT NULL DEFAULT '',
  place TEXT,
  lat REAL,
  lng REAL,
  investment_id INTEGER REFERENCES investments(id),
  debt_id INTEGER REFERENCES debts(id),
  created_at INTEGER NOT NULL,
  deleted INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_txn_time ON transactions(deleted, occurred_at);
CREATE INDEX idx_txn_type_time ON transactions(type, occurred_at);
CREATE INDEX idx_txn_category ON transactions(category_id, occurred_at);
CREATE INDEX idx_txn_investment ON transactions(investment_id);
CREATE INDEX idx_txn_debt ON transactions(debt_id);
CREATE VIRTUAL TABLE txn_fts USING fts5(merchant, note, tags, place, content='transactions', content_rowid='id', tokenize='unicode61');
CREATE TRIGGER txn_ai AFTER INSERT ON transactions BEGIN
  INSERT INTO txn_fts(rowid, merchant, note, tags, place) VALUES (new.id, new.merchant, new.note, new.tags, coalesce(new.place, ''));
END;
CREATE TRIGGER txn_ad AFTER DELETE ON transactions BEGIN
  INSERT INTO txn_fts(txn_fts, rowid, merchant, note, tags, place) VALUES ('delete', old.id, old.merchant, old.note, old.tags, coalesce(old.place, ''));
END;
CREATE TRIGGER txn_au AFTER UPDATE ON transactions BEGIN
  INSERT INTO txn_fts(txn_fts, rowid, merchant, note, tags, place) VALUES ('delete', old.id, old.merchant, old.note, old.tags, coalesce(old.place, ''));
  INSERT INTO txn_fts(rowid, merchant, note, tags, place) VALUES (new.id, new.merchant, new.note, new.tags, coalesce(new.place, ''));
END;
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  period TEXT NOT NULL,
  limit_amount INTEGER NOT NULL,
  category_ids TEXT NOT NULL DEFAULT '',
  rollover INTEGER NOT NULL DEFAULT 0,
  alert80 INTEGER NOT NULL DEFAULT 1,
  alert100 INTEGER NOT NULL DEFAULT 1,
  is_goal INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
''');
  _seed(db);
}

void _seed(Database db) {
  const spend = [
    ['Food & dining', 'food', 0xFFF43F5E],
    ['Rent', 'home', 0xFF8B5CF6],
    ['Shopping', 'bag', 0xFFEC4899],
    ['Transport', 'car', 0xFFF59E0B],
    ['Bills & utilities', 'bolt', 0xFFF97316],
    ['Health', 'heart', 0xFFEF4444],
    ['Entertainment', 'play', 0xFF6366F1],
    ['Travel', 'plane', 0xFF0EA5E9],
  ];
  const invest = [
    ['Fixed deposit', 'bank', 0xFF10B981],
    ['Mutual funds / SIP', 'coins', 0xFF14B8A6],
    ['Stocks', 'trend', 0xFF65A30D],
    ['Gold', 'gem', 0xFFCA8A04],
    ['PPF / EPF / NPS', 'shield', 0xFF4D7C0F],
  ];
  const income = [
    ['Salary', 'wallet', 0xFF0EA5E9],
    ['Other income', 'gift', 0xFF0284C7],
  ];
  final stmt = db.prepare('INSERT INTO categories(name, kind, icon, color, sort_order, is_default) VALUES (?, ?, ?, ?, ?, ?)');
  var order = 0;
  for (final c in spend) {
    stmt.execute([c[0], 'spend', c[1], c[2], order++, 0]);
  }
  stmt.execute(['Others', 'spend', 'grid', 0xFF64748B, order++, 1]);
  for (final c in invest) {
    stmt.execute([c[0], 'invest', c[1], c[2], order++, 0]);
  }
  for (final c in income) {
    stmt.execute([c[0], 'income', c[1], c[2], order++, 0]);
  }
  stmt.close();
  db.execute("INSERT INTO sources(name, kind, is_default) VALUES ('Cash', 'cash', 1)");
}

/// v2: opening balance per payment source (paise; negative = card outstanding).
void _v2(Database db) {
  db.execute('ALTER TABLE sources ADD COLUMN opening_balance INTEGER NOT NULL DEFAULT 0');
}

/// v3: one level of sub-categories.
void _v3(Database db) {
  db.execute('ALTER TABLE categories ADD COLUMN parent_id INTEGER REFERENCES categories(id)');
  db.execute('CREATE INDEX idx_cat_parent ON categories(parent_id)');
}

/// v4: credit-card statement amount and due date on debts.
void _v4(Database db) {
  db.execute('ALTER TABLE debts ADD COLUMN statement_amount INTEGER');
  db.execute('ALTER TABLE debts ADD COLUMN statement_due_at INTEGER');
}
