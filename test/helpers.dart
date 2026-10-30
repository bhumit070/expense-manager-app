import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/services/error_log.dart';
import 'package:expense_manager/services/file_gateway.dart';
import 'package:expense_manager/services/location.dart';
import 'package:expense_manager/services/notifications.dart';
import 'package:expense_manager/services/receipts.dart';
import 'package:expense_manager/services/sms_capture.dart';
import 'package:expense_manager/state/app_state.dart';
import 'package:expense_manager/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  /// Results for [search], keyed by query.
  final results = <String, List<Place>>{};

  @override
  Future<List<Place>> search(String query) async => results[query] ?? const [];

  @override
  Future<String> describe(double lat, double lng) async => 'Pin ${coordinates(lat, lng)}';
}

class FakeReceipts implements ReceiptStore {
  /// Path returned by the next [pick]; null means the user cancelled.
  String? next;
  final picked = <ReceiptSource>[];
  final opened = <String>[];
  final deleted = <String>[];

  @override
  Future<String?> pick(ReceiptSource source) async {
    picked.add(source);
    return next;
  }

  @override
  Future<void> open(String path) async => opened.add(path);

  @override
  Future<void> delete(String path) async => deleted.add(path);
}

/// A fresh in-memory app. Onboarding is marked done unless [onboarded] is false.
/// Records notifications instead of posting them.
class FakeNotifications extends NotificationService {
  FakeNotifications({this.grant = true});

  /// Answer to [requestPermission].
  bool grant;
  int permissionRequests = 0;
  final shown = <(int, String, String)>[];
  final scheduled = <int, (DateTime, String, String)>{};
  final cancelled = <int>[];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> show(int id, String title, String body) async => shown.add((id, title, body));

  @override
  Future<void> schedule(int id, DateTime at, String title, String body) async => scheduled[id] = (at, title, body);

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  /// Notifications with buttons: id → (title, body, payload, comma-joined action ids).
  final prompts = <int, (String, String, String, String)>{};
  void Function(NotificationTap tap)? handler;
  NotificationTap? launch;

  @override
  Future<void> prompt(int id, String title, String body, {required String payload, List<NotificationActionSpec> actions = const []}) async =>
      prompts[id] = (title, body, payload, actions.map((a) => a.id).join(','));

  @override
  void listen(void Function(NotificationTap tap) handler) => this.handler = handler;

  @override
  Future<NotificationTap?> launchTap() async => launch;
}

/// SMS permission without a platform channel.
class FakeSmsPlatform extends SmsPlatform {
  FakeSmsPlatform({this.granted = false, this.grant = true, this.isSupported = true});

  bool granted;

  /// Answer to [requestPermission].
  bool grant;
  bool isSupported;
  int requests = 0;

  @override
  bool get supported => isSupported;

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    requests++;
    return granted = granted || grant;
  }
}

AppState makeState({
  DateTime? now,
  FakeFiles? files,
  FakeLocation? location,
  FakeReceipts? receipts,
  FakeNotifications? notifications,
  FakeSmsPlatform? sms,
  ErrorLog? errorLog,
  bool onboarded = true,
}) {
  final s = AppState(
    db: openAppDatabase(null),
    files: files ?? FakeFiles(),
    location: location ?? FakeLocation(),
    receipts: receipts ?? FakeReceipts(),
    notifications: notifications,
    errorLog: errorLog,
    clock: () => now ?? kNow,
    smsPlatform: sms ?? FakeSmsPlatform(),
  );
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
  tester.view.physicalSize = const Size(1170, 9000);
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
  tester.view.physicalSize = const Size(1170, 9000);
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

/// Types [amount] (e.g. `1250.5` or `100+20`) on the amount keypad.
Future<void> typeAmount(WidgetTester tester, String amount) async {
  for (final ch in amount.split('')) {
    final name = switch (ch) {
      '+' => 'plus',
      '−' || '-' => 'minus',
      _ => ch,
    };
    await tester.tap(find.byKey(Key('key-$name')));
  }
  await tester.pump();
}

/// The amount shown above the keypad.
String amountShown(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('amount'))).data!;

/// A 1×1 transparent PNG.
final kPng = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

/// Offline map tiles for widget tests.
class FakeTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) => MemoryImage(kPng);
}
