import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../l10n/l10n.dart';
import '../core/dates.dart';
import '../core/money.dart';
import '../data/transactions_repo.dart';
import '../state/app_state.dart';
import 'csv.dart';

/// What the user can export as CSV.
enum ExportKind { transactions, investments, debts, budgets }

String exportKindLabel(ExportKind k) => switch (k) {
  ExportKind.transactions => currentL10n.transactionsTitle,
  ExportKind.investments => currentL10n.investmentsTitle,
  ExportKind.debts => currentL10n.navDebts,
  ExportKind.budgets => currentL10n.budgetsTitle,
};

String _rupees(int? paise) => paise == null ? '' : (paise / paisePerRupee).toStringAsFixed(2);

String _date(DateTime? d) => d == null ? '' : isoDateTime(d).substring(0, 10);

/// Investments with what was put in (no market value).
String encodeInvestmentsCsv(AppState app) => encodeTable(
  ['kind', 'name', 'institution', 'rate', 'start', 'maturity', 'status', 'invested', 'entries', 'note'],
  [
    for (final h in app.planning.holdings(activeOnly: false))
      [
        h.investment.kind.name,
        h.investment.name,
        h.investment.institution,
        h.investment.rate?.toString() ?? '',
        _date(h.investment.startAt),
        _date(h.investment.maturityAt),
        h.investment.status.name,
        _rupees(h.invested),
        '${h.entries}',
        h.investment.note,
      ],
  ],
);

/// Open and settled debts with what has been paid so far.
String encodeDebtsCsv(AppState app) => encodeTable(
  ['direction', 'kind', 'name', 'counterparty', 'principal', 'rate', 'emi', 'total_emis', 'due_day', 'paid', 'remaining', 'settled'],
  [
    for (final s in [...app.planning.debts(), ...app.planning.debts(settled: true)])
      [
        s.debt.direction.name,
        s.debt.kind.name,
        s.debt.name,
        s.debt.counterparty,
        _rupees(s.debt.principal),
        s.debt.rate?.toString() ?? '',
        _rupees(s.debt.emi),
        s.debt.totalEmis?.toString() ?? '',
        s.debt.dueDay?.toString() ?? '',
        _rupees(s.paid),
        _rupees(s.remaining),
        s.debt.settled ? 'yes' : 'no',
      ],
  ],
);

/// Budgets and goals with their categories by name.
String encodeBudgetsCsv(AppState app) {
  final names = {for (final c in app.catalog.categories(includeArchived: true)) c.id: c.name};
  return encodeTable(
    ['name', 'period', 'limit', 'categories', 'goal', 'rollover', 'alert_80', 'alert_100'],
    [
      for (final b in app.planning.budgets())
        [
          b.name,
          b.period.name,
          _rupees(b.limit),
          b.categoryIds.isEmpty ? 'All spending' : b.categoryIds.map((id) => names[id] ?? '#$id').join('; '),
          b.isGoal ? 'yes' : 'no',
          b.rollover ? 'yes' : 'no',
          b.alert80 ? 'yes' : 'no',
          b.alert100 ? 'yes' : 'no',
        ],
    ],
  );
}

String encodeExport(AppState app, ExportKind k) => switch (k) {
  ExportKind.transactions => encodeCsv(app.txns.list(const TxnFilter(), limit: 1 << 30)),
  ExportKind.investments => encodeInvestmentsCsv(app),
  ExportKind.debts => encodeDebtsCsv(app),
  ExportKind.budgets => encodeBudgetsCsv(app),
};

/// One file to share: a single CSV, or a zip when several kinds are picked.
({String name, Uint8List bytes, String mime}) buildExport(AppState app, Set<ExportKind> kinds) {
  final day = isoDateTime(app.now()).substring(0, 10);
  final picked = ExportKind.values.where(kinds.contains).toList();
  if (picked.length == 1) {
    return (name: '${picked.single.name}-$day.csv', bytes: Uint8List.fromList(utf8.encode(encodeExport(app, picked.single))), mime: 'text/csv');
  }
  final archive = Archive();
  for (final k in picked) {
    archive.add(ArchiveFile.bytes('${k.name}.csv', utf8.encode(encodeExport(app, k))));
  }
  return (name: 'expense-manager-export-$day.zip', bytes: ZipEncoder().encodeBytes(archive), mime: 'application/zip');
}
