/// Plain immutable domain models backed by SQLite rows.
library;

import 'package:sqlite3/sqlite3.dart';

enum TxnType { spend, invest, income, debt }

enum CategoryKind { spend, invest, income }

enum SourceKind { bank, card, cash, wallet }

enum BudgetPeriod { weekly, monthly }

enum InvestmentKind { fd, mutualFund, stock, gold, retirement, other }

enum InvestmentStatus { active, matured, closed }

enum DebtDirection { iOwe, owedToMe }

enum DebtKind { loan, card, personal }

T enumByName<T extends Enum>(List<T> values, Object? name) => values.firstWhere((e) => e.name == name);

DateTime _ms(Object? v) => DateTime.fromMillisecondsSinceEpoch(v! as int);
DateTime? _msOrNull(Object? v) => v == null ? null : _ms(v);

class Category {
  const Category({required this.id, required this.name, required this.kind, required this.icon, required this.color, this.sortOrder = 0, this.isDefault = false, this.archived = false, this.parentId});

  factory Category.fromRow(Row r) => Category(
    id: r['id'] as int,
    name: r['name'] as String,
    kind: enumByName(CategoryKind.values, r['kind']),
    icon: r['icon'] as String,
    color: r['color'] as int,
    sortOrder: r['sort_order'] as int,
    isDefault: r['is_default'] == 1,
    archived: r['archived'] == 1,
    parentId: r['parent_id'] as int?,
  );

  final int id;
  final String name;
  final CategoryKind kind;
  final String icon;
  final int color;
  final int sortOrder;
  final bool isDefault;
  final bool archived;

  /// Parent category for a sub-category; null for a top-level category.
  final int? parentId;

  bool get isChild => parentId != null;
}

class PaymentSource {
  const PaymentSource({required this.id, required this.name, required this.kind, this.last4, this.creditLimit, this.openingBalance = 0, this.isDefault = false, this.archived = false});

  factory PaymentSource.fromRow(Row r) => PaymentSource(
    id: r['id'] as int,
    name: r['name'] as String,
    kind: enumByName(SourceKind.values, r['kind']),
    last4: r['last4'] as String?,
    creditLimit: r['credit_limit'] as int?,
    openingBalance: r['opening_balance'] as int,
    isDefault: r['is_default'] == 1,
    archived: r['archived'] == 1,
  );

  final int id;
  final String name;
  final SourceKind kind;
  final String? last4;
  final int? creditLimit;

  /// Balance before the first tracked transaction. For cards this is the
  /// outstanding amount, stored negative.
  final int openingBalance;
  final bool isDefault;
  final bool archived;

  String get display => last4 == null || last4!.isEmpty ? name : '$name ••$last4';
}

/// A transaction as written by the user.
class Txn {
  const Txn({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.sourceId,
    required this.occurredAt,
    this.merchant = '',
    this.note = '',
    this.tags = const [],
    this.place,
    this.lat,
    this.lng,
    this.investmentId,
    this.debtId,
    this.receipt,
    this.recurringId,
  });

  final int? id;
  final TxnType type;

  /// Positive amount in paise.
  final int amount;
  final int categoryId;
  final int? sourceId;
  final DateTime occurredAt;
  final String merchant;
  final String note;
  final List<String> tags;
  final String? place;
  final double? lat;
  final double? lng;
  final int? investmentId;
  final int? debtId;

  /// Path of an attached receipt (photo or PDF) in the app documents directory.
  final String? receipt;

  /// The recurring rule that created this transaction, if any.
  final int? recurringId;

  Txn copyWith({int? id, int? amount, DateTime? occurredAt, int? categoryId, String? Function()? receipt, int? Function()? recurringId}) => Txn(
    id: id ?? this.id,
    type: type,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    sourceId: sourceId,
    occurredAt: occurredAt ?? this.occurredAt,
    merchant: merchant,
    note: note,
    tags: tags,
    place: place,
    lat: lat,
    lng: lng,
    investmentId: investmentId,
    debtId: debtId,
    receipt: receipt == null ? this.receipt : receipt(),
    recurringId: recurringId == null ? this.recurringId : recurringId(),
  );

  /// Title shown in lists: merchant, else note, else category name.
  String titleOr(String fallback) => merchant.isNotEmpty ? merchant : (note.isNotEmpty ? note : fallback);
}

/// A transaction joined with display data.
class TxnView {
  const TxnView({required this.txn, required this.category, this.source, required this.inflow, this.parentName});

  factory TxnView.fromRow(Row r) {
    final tags = (r['tags'] as String);
    return TxnView(
      txn: Txn(
        id: r['id'] as int,
        type: enumByName(TxnType.values, r['type']),
        amount: r['amount'] as int,
        categoryId: r['category_id'] as int,
        sourceId: r['source_id'] as int?,
        occurredAt: _ms(r['occurred_at']),
        merchant: r['merchant'] as String,
        note: r['note'] as String,
        tags: tags.isEmpty ? const [] : tags.split(' '),
        place: r['place'] as String?,
        lat: r['lat'] as double?,
        lng: r['lng'] as double?,
        investmentId: r['investment_id'] as int?,
        debtId: r['debt_id'] as int?,
        receipt: r['receipt'] as String?,
        recurringId: r['recurring_id'] as int?,
      ),
      category: Category(
        id: r['category_id'] as int,
        name: r['c_name'] as String,
        kind: enumByName(CategoryKind.values, r['c_kind']),
        icon: r['c_icon'] as String,
        color: r['c_color'] as int,
        parentId: r['c_parent_id'] as int?,
      ),
      parentName: r['c_parent_name'] as String?,
      source: r['source_id'] == null ? null : PaymentSource(id: r['source_id'] as int, name: r['s_name'] as String, kind: enumByName(SourceKind.values, r['s_kind']), last4: r['s_last4'] as String?),
      inflow: r['inflow'] == 1,
    );
  }

  final Txn txn;
  final Category category;
  final PaymentSource? source;

  /// Name of the parent category when [category] is a sub-category.
  final String? parentName;

  /// "Parent / Child" for sub-categories, otherwise the category name.
  String get categoryPath => parentName == null ? category.name : '$parentName / ${category.name}';

  /// True when money came in (income, or repayment of money owed to you).
  final bool inflow;

  int get signedAmount => inflow ? txn.amount : -txn.amount;
}

class Budget {
  const Budget({
    this.id,
    required this.name,
    required this.period,
    required this.limit,
    this.categoryIds = const [],
    this.rollover = false,
    this.alert80 = true,
    this.alert100 = true,
    this.isGoal = false,
  });

  factory Budget.fromRow(Row r) {
    final ids = r['category_ids'] as String;
    return Budget(
      id: r['id'] as int,
      name: r['name'] as String,
      period: enumByName(BudgetPeriod.values, r['period']),
      limit: r['limit_amount'] as int,
      categoryIds: ids.isEmpty ? const [] : ids.split(',').map(int.parse).toList(),
      rollover: r['rollover'] == 1,
      alert80: r['alert80'] == 1,
      alert100: r['alert100'] == 1,
      isGoal: r['is_goal'] == 1,
    );
  }

  final int? id;
  final String name;
  final BudgetPeriod period;
  final int limit;

  /// Empty means "all spending" (or all investing for goals).
  final List<int> categoryIds;
  final bool rollover;
  final bool alert80;
  final bool alert100;

  /// Goals track investment targets instead of spend caps.
  final bool isGoal;
}

class BudgetProgress {
  const BudgetProgress({required this.budget, required this.used, required this.limit, required this.daysLeft, required this.elapsed});

  final Budget budget;
  final int used;

  /// Effective limit including rollover.
  final int limit;
  final int daysLeft;
  final double elapsed;

  double get fraction => limit <= 0 ? 0 : used / limit;
  int get remaining => limit - used;
  bool get isOver => !budget.isGoal && used > limit;
  bool get isNear => !isOver && fraction >= 0.8;

  /// Spending faster than time is passing.
  bool get aheadOfPace => fraction > elapsed;
  int get perDayLeft => daysLeft <= 0 || remaining <= 0 ? 0 : remaining ~/ daysLeft;
}

class Investment {
  const Investment({this.id, required this.kind, required this.name, this.institution = '', this.rate, this.startAt, this.maturityAt, this.note = '', this.status = InvestmentStatus.active});

  factory Investment.fromRow(Row r) => Investment(
    id: r['id'] as int,
    kind: enumByName(InvestmentKind.values, r['kind']),
    name: r['name'] as String,
    institution: r['institution'] as String,
    rate: r['rate'] as double?,
    startAt: _msOrNull(r['start_at']),
    maturityAt: _msOrNull(r['maturity_at']),
    note: r['note'] as String,
    status: enumByName(InvestmentStatus.values, r['status']),
  );

  final int? id;
  final InvestmentKind kind;
  final String name;
  final String institution;

  /// Annual interest rate in percent, informational only.
  final double? rate;
  final DateTime? startAt;
  final DateTime? maturityAt;
  final String note;
  final InvestmentStatus status;
}

/// Investment with the amount the user has put in. No market value.
class Holding {
  const Holding({required this.investment, required this.invested, required this.entries});

  final Investment investment;
  final int invested;
  final int entries;
}

class Debt {
  const Debt({
    this.id,
    required this.direction,
    required this.kind,
    required this.name,
    this.counterparty = '',
    required this.principal,
    this.rate,
    this.emi,
    this.totalEmis,
    this.dueDay,
    this.settled = false,
    this.statementAmount,
    this.statementDueAt,
  });

  factory Debt.fromRow(Row r) => Debt(
    id: r['id'] as int,
    direction: enumByName(DebtDirection.values, r['direction']),
    kind: enumByName(DebtKind.values, r['kind']),
    name: r['name'] as String,
    counterparty: r['counterparty'] as String,
    principal: r['principal'] as int,
    rate: r['rate'] as double?,
    emi: r['emi'] as int?,
    totalEmis: r['total_emis'] as int?,
    dueDay: r['due_day'] as int?,
    settled: r['settled'] == 1,
    statementAmount: r['statement_amount'] as int?,
    statementDueAt: _msOrNull(r['statement_due_at']),
  );

  final int? id;
  final DebtDirection direction;
  final DebtKind kind;
  final String name;
  final String counterparty;
  final int principal;
  final double? rate;
  final int? emi;
  final int? totalEmis;
  final int? dueDay;
  final bool settled;

  /// Latest credit-card statement total and its due date (cards only).
  final int? statementAmount;
  final DateTime? statementDueAt;
}

class DebtStatus {
  const DebtStatus({required this.debt, required this.paid, required this.payments, this.statementPaid = 0});

  final Debt debt;
  final int paid;
  final int payments;

  /// Payments made in the statement's cycle (the 30 days before its due date onward).
  final int statementPaid;

  /// What is still unpaid on the current statement; 0 when there is none.
  int get statementLeft => debt.statementAmount == null ? 0 : (debt.statementAmount! - statementPaid).clamp(0, debt.statementAmount!);

  /// Days until the unpaid statement is due (negative when overdue), or null
  /// when nothing is due.
  int? statementDueIn(DateTime now) {
    final due = debt.statementDueAt;
    if (due == null || statementLeft == 0) return null;
    return DateTime.utc(due.year, due.month, due.day).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }

  /// Due within 3 days or overdue.
  bool isUrgent(DateTime now) => (statementDueIn(now) ?? 99) <= 3;

  int get remaining => (debt.principal - paid).clamp(0, debt.principal);
  double get fraction => debt.principal == 0 ? 1 : (paid / debt.principal).clamp(0, 1).toDouble();
}

/// Money totals for a period, in paise.
class Totals {
  const Totals({this.spend = 0, this.invest = 0, this.income = 0, this.debtOut = 0, this.debtIn = 0, this.count = 0});

  final int spend;
  final int invest;
  final int income;
  final int debtOut;
  final int debtIn;
  final int count;

  /// Spend + invest: what left the wallet excluding debt payments.
  int get moneyOut => spend + invest;
  int get allOut => spend + invest + debtOut;
  int get allIn => income + debtIn;
  int get left => income - moneyOut - debtOut;
  double get savingsRate => income <= 0 ? 0 : ((income - spend - debtOut) / income).clamp(0, 1).toDouble();
}

class CategoryTotal {
  const CategoryTotal({required this.category, required this.total, required this.count, this.subCount = 0});

  final Category category;
  final int total;
  final int count;

  /// Number of sub-categories rolled up into this total.
  final int subCount;
}

class Bucket {
  const Bucket({required this.start, required this.spend, required this.invest});

  final DateTime start;
  final int spend;
  final int invest;
}

/// What an [Upcoming] item is about. Add new kinds here and a matching
/// generator in `PlanningRepo.upcoming`.
/// [sip] is a reminder-only SIP; [followUp] a "remind me" date the user set on
/// money owed to them.
enum UpcomingKind { emi, cardDue, maturity, sip, followUp }

/// A dated obligation or event the user should know about.
class Upcoming {
  const Upcoming({required this.kind, required this.date, required this.title, this.amount, this.debtId, this.investmentId});

  final UpcomingKind kind;
  final DateTime date;
  final String title;
  final int? amount;
  final int? debtId;
  final int? investmentId;
}
