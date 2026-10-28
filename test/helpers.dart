import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/services/error_log.dart';
import 'package:expense_manager/services/file_gateway.dart';
import 'package:expense_manager/services/location.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wednesday, 28 Oct 2026, 9:41 PM.
final kNow = DateTime(2026, 10, 28, 21, 41);

class FakeFiles implements FileGateway {
  /// Shortcut: when set, [pickFile] returns it as `import.csv`.
  String? csv;

  /// Returned by [pickFile] when [csv] is null.
  PickedFile? picked;
  List<String>? lastExtensions;
  final saved = <(String, List<int>, String)>[];

  @override
  Future<PickedFile?> pickFile({List<String>? extensions}) async {
    lastExtensions = extensions;
    return csv != null ? PickedFile('import.csv', Uint8List.fromList(utf8.encode(csv!))) : picked;
  }

  @override
  Future<String> saveAndShare(String name, List<int> bytes, String mimeType) async {
    saved.add((name, bytes, mimeType));
    return '/tmp/$name';
  }

  final shared = <(String, String?)>[];

  @override
  Future<void> shareText(String text, {String? subject}) async => shared.add((text, subject));
}

class FakeLocation implements LocationService {
  Place? place;
  bool grant = true;
  int requests = 0;
  int lookups = 0;

  /// When set, [current] waits for this instead of returning [place].
  Completer<Place?>? pending;

  @override
  Future<Place?> current() async {
    lookups++;
    return pending != null ? pending!.future : place;
  }

  @override
  Future<bool> requestPermission() async {
    requests++;
    return grant;
  }
}

/// A fresh in-memory app. Onboarding is marked done unless [onboarded] is false.
AppState makeState({DateTime? now, FakeFiles? files, FakeLocation? location, ErrorLog? errorLog, bool onboarded = true}) {
  final s = AppState(db: openAppDatabase(null), files: files ?? FakeFiles(), location: location ?? FakeLocation(), errorLog: errorLog, clock: () => now ?? kNow);
  if (onboarded) s.settings.set('onboarded', '1');
  return s;
}

int catId(AppState s, String name) => s.catalog.findCategoryByName(name)!.id;

/// Populates a realistic dataset covering every transaction type.
({int hdfc, int card, int fd, int sip, int loan, int lent}) seed(AppState s) {
  final cash = s.catalog.defaultSource()!.id;
  final hdfc = s.catalog.addSource(name: 'HDFC Savings', kind: SourceKind.bank, last4: '42', makeDefault: true);
  final card = s.catalog.addSource(name: 'ICICI Card', kind: SourceKind.card, last4: '07', creditLimit: 15000000);
  final fd = s.planning.addInvestment(Investment(kind: InvestmentKind.fd, name: 'HDFC FD', institution: 'HDFC Bank', rate: 7.1, startAt: DateTime(2026, 3, 12), maturityAt: DateTime(2026, 11, 12)));
  final sip = s.planning.addInvestment(const Investment(kind: InvestmentKind.mutualFund, name: 'Nifty 50 Index'));
  final loan = s.planning.addDebt(
    const Debt(direction: DebtDirection.iOwe, kind: DebtKind.loan, name: 'Car loan', counterparty: 'HDFC', principal: 42000000, rate: 9.2, emi: 1240000, totalEmis: 36, dueDay: 5),
  );
  final lent = s.planning.addDebt(const Debt(direction: DebtDirection.owedToMe, kind: DebtKind.personal, name: 'Rahul', principal: 850000));
  final t = s.txns;
  t.insert(
    Txn(type: TxnType.income, amount: 11000000, categoryId: catId(s, 'Salary'), sourceId: hdfc, occurredAt: DateTime(2026, 10, 1, 9), merchant: 'Salary'),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.spend, amount: 1500000, categoryId: catId(s, 'Rent'), sourceId: hdfc, occurredAt: DateTime(2026, 10, 1, 10), merchant: 'Landlord'),
    now: kNow,
  );
  t.insert(
    Txn(
      type: TxnType.spend,
      amount: 48600,
      categoryId: catId(s, 'Food & dining'),
      sourceId: hdfc,
      occurredAt: DateTime(2026, 10, 28, 20),
      merchant: 'Swiggy',
      note: 'Team dinner after sprint demo',
      tags: const ['#work', '#split'],
      place: 'Indiranagar',
      lat: 12.97,
      lng: 77.64,
    ),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.spend, amount: 31200, categoryId: catId(s, 'Transport'), sourceId: card, occurredAt: DateTime(2026, 10, 27, 9), merchant: 'Uber'),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.invest, amount: 5000000, categoryId: catId(s, 'Fixed deposit'), sourceId: hdfc, occurredAt: DateTime(2026, 10, 27, 11), merchant: 'HDFC FD', investmentId: fd),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.invest, amount: 1000000, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: hdfc, occurredAt: DateTime(2026, 9, 5, 11), investmentId: sip),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.debt, amount: 1240000, categoryId: s.catalog.defaultCategory().id, sourceId: hdfc, occurredAt: DateTime(2026, 10, 5, 8), merchant: 'Car EMI', debtId: loan),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.debt, amount: 250000, categoryId: s.catalog.defaultCategory().id, sourceId: cash, occurredAt: DateTime(2026, 10, 25, 18), merchant: 'Rahul paid back', debtId: lent),
    now: kNow,
  );
  t.insert(
    Txn(type: TxnType.spend, amount: 420000, categoryId: catId(s, 'Food & dining'), sourceId: hdfc, occurredAt: DateTime(2026, 9, 14, 20), merchant: 'Toit', note: 'Birthday dinner'),
    now: kNow,
  );
  return (hdfc: hdfc, card: card, fd: fd, sip: sip, loan: loan, lent: lent);
}

/// Pumps [child] inside the app theme and scope on a tall phone-width view.
Future<void> pumpScreen(WidgetTester tester, AppState state, Widget child, {Brightness brightness = Brightness.light}) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(theme: buildTheme(brightness), home: child),
    ),
  );
  await tester.pump();
}

/// Wraps a tab body (no Scaffold of its own) for pumping.
Widget inScaffold(Widget body) => Scaffold(body: body);

Period month(DateTime d) => Period.of(PeriodKind.month, d);

/// Pumps a home route and pushes [child] on top, so screens can pop.
Future<void> pumpRoute(WidgetTester tester, AppState state, Widget child, {Brightness brightness = Brightness.light}) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final nav = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        navigatorKey: nav,
        theme: buildTheme(brightness),
        home: const Scaffold(body: Text('home')),
      ),
    ),
  );
  unawaited(nav.currentState!.push(MaterialPageRoute<void>(builder: (_) => child)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
