import 'package:sqlite3/sqlite3.dart';

import '../l10n/l10n.dart';

/// Current schema version. Bump and add a step to [_migrations] for changes.
const schemaVersion = 6;

final List<void Function(Database)> _migrations = [_v1, _v2, _v3, _v4, _v5, _v6];

/// Opens (or creates) the app database and runs pending migrations.
/// [key] unlocks a database encrypted from Settings → Security.
Database openAppDatabase(String? path, {String? key}) {
  final db = path == null ? sqlite3.openInMemory() : sqlite3.open(path);
  if (key != null) db.execute("PRAGMA key = '${key.replaceAll("'", "''")}'");
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

/// Starter categories as (name, kind, icon, color, is default), named in [l].
List<(String, String, String, int, int)> _seedCategories(AppLocalizations l) => [
  (l.seedFood, 'spend', 'food', 0xFFF43F5E, 0),
  (l.seedRent, 'spend', 'home', 0xFF8B5CF6, 0),
  (l.seedShopping, 'spend', 'bag', 0xFFEC4899, 0),
  (l.seedTransport, 'spend', 'car', 0xFFF59E0B, 0),
  (l.seedBills, 'spend', 'bolt', 0xFFF97316, 0),
  (l.seedHealth, 'spend', 'heart', 0xFFEF4444, 0),
  (l.seedEntertainment, 'spend', 'play', 0xFF6366F1, 0),
  (l.seedTravel, 'spend', 'plane', 0xFF0EA5E9, 0),
  (l.seedOthers, 'spend', 'grid', 0xFF64748B, 1),
  (l.seedFd, 'invest', 'bank', 0xFF10B981, 0),
  (l.seedMutualFunds, 'invest', 'coins', 0xFF14B8A6, 0),
  (l.investKindStock, 'invest', 'trend', 0xFF65A30D, 0),
  (l.investKindGold, 'invest', 'gem', 0xFFCA8A04, 0),
  (l.seedRetirement, 'invest', 'shield', 0xFF4D7C0F, 0),
  (l.seedSalary, 'income', 'wallet', 0xFF0EA5E9, 0),
  (l.seedOtherIncome, 'income', 'gift', 0xFF0284C7, 0),
];

/// Seeds the starter categories and the Cash source in the device's language.
void _seed(Database db) {
  final l = lookupAppLocalizations(resolveLocale(null));
  final stmt = db.prepare('INSERT INTO categories(name, kind, icon, color, sort_order, is_default) VALUES (?, ?, ?, ?, ?, ?)');
  for (final (i, (name, kind, icon, color, isDefault)) in _seedCategories(l).indexed) {
    stmt.execute([name, kind, icon, color, i, isDefault]);
  }
  stmt.close();
  db.execute('INSERT INTO sources(name, kind, is_default) VALUES (?, ?, 1)', [l.sourceKindCash, 'cash']);
}

/// Renames starter categories and the Cash source still named as in [from]
/// to their names in [to] (the language was changed before setup finished).
void relabelSeed(Database db, AppLocalizations from, AppLocalizations to) {
  final pairs = [for (final (i, c) in _seedCategories(from).indexed) (c.$1, _seedCategories(to)[i].$1, 'categories'), (from.sourceKindCash, to.sourceKindCash, 'sources')];
  for (final (old, renamed, table) in pairs) {
    db.execute('UPDATE $table SET name = ? WHERE name = ?', [renamed, old]);
  }
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

/// v5: receipts and recurring rules on transactions, recurring rules, templates.
void _v5(Database db) {
  db.execute('''
ALTER TABLE transactions ADD COLUMN receipt TEXT;
ALTER TABLE transactions ADD COLUMN recurring_id INTEGER;
CREATE TABLE recurring_rules (
  id INTEGER PRIMARY KEY,
  type TEXT NOT NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  category_id INTEGER NOT NULL REFERENCES categories(id),
  source_id INTEGER REFERENCES sources(id),
  merchant TEXT NOT NULL DEFAULT '',
  note TEXT NOT NULL DEFAULT '',
  tags TEXT NOT NULL DEFAULT '',
  place TEXT,
  lat REAL,
  lng REAL,
  investment_id INTEGER REFERENCES investments(id),
  debt_id INTEGER REFERENCES debts(id),
  frequency TEXT NOT NULL,
  start_at INTEGER NOT NULL,
  end_at INTEGER,
  count INTEGER NOT NULL DEFAULT 0,
  next_run INTEGER NOT NULL,
  paused INTEGER NOT NULL DEFAULT 0,
  auto_create INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX idx_txn_recurring ON transactions(recurring_id);
CREATE TABLE templates (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  amount INTEGER NOT NULL,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  source_id INTEGER REFERENCES sources(id),
  merchant TEXT NOT NULL DEFAULT '',
  note TEXT NOT NULL DEFAULT '',
  tags TEXT NOT NULL DEFAULT ''
);
''');
}

/// Transactions detected in bank SMS, waiting for the user to add or ignore them.
void _v6(Database db) {
  db.execute('''
CREATE TABLE sms_captures (
  id INTEGER PRIMARY KEY,
  received_at INTEGER NOT NULL,
  sender TEXT NOT NULL,
  body TEXT NOT NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  credit INTEGER NOT NULL,
  merchant TEXT NOT NULL DEFAULT '',
  last4 TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  txn_id INTEGER
);
CREATE INDEX idx_sms_status ON sms_captures(status, received_at);
''');
}
