import 'package:expense_manager/data/database.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/recurring_repo.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/services/background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workmanager/workmanager.dart';

import '../fakes/background.dart';
import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('runDaily creates due recurring entries, alerts budgets and schedules reminders', () async {
    final n = FakeNotifications();
    final s = makeState(notifications: n);
    seed(s);
    s.settings.set('notif_on', '1');
    s.recurring.createFrom(
      Txn(type: TxnType.spend, amount: 10000, categoryId: catId(s, 'Food & dining'), sourceId: null, occurredAt: DateTime(2026, 10, 26, 8), merchant: 'Tea'),
      Frequency.daily,
      now: DateTime(2026, 10, 26, 8),
    );
    s.planning.addBudget(Budget(name: 'Food', period: BudgetPeriod.monthly, limit: 100, categoryIds: [catId(s, 'Food & dining')]));
    final before = s.txns.list(const TxnFilter(search: 'Tea')).length;
    await runDaily(s.db, kNow, n);
    expect(s.txns.list(const TxnFilter(search: 'Tea')).length, before + 2, reason: '27 and 28 Oct were due');
    expect(n.shown.single.$2, 'Food budget used up');
    expect(n.scheduled, isNotEmpty);
  });

  test('backgroundTask opens, runs and closes the database; failures return false', () async {
    final n = FakeNotifications();
    final db = openAppDatabase(null);
    expect(await backgroundTask(open: () async => db, service: n, clock: () => kNow), isTrue);
    expect(() => db.select('SELECT 1'), throwsA(anything), reason: 'closed after the run');
    expect(await backgroundTask(open: () async => throw StateError('no db'), service: n), isFalse);
    // Defaults: the device database is unavailable in tests, so it fails cleanly.
    expect(await backgroundTask(), isFalse);
  });

  test('scheduler registers one daily task on Android only', () async {
    final wm = useFakeWorkmanager();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(await BackgroundScheduler().ensureScheduled(), isFalse);
    expect(wm.periodic, isEmpty);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(await BackgroundScheduler(workmanager: Workmanager()).ensureScheduled(), isTrue);
    expect(wm.initialized.single, same(callbackDispatcher));
    expect(wm.periodic.single, (dailyTask, dailyTask, const Duration(hours: 24), ExistingPeriodicWorkPolicy.keep));
  });

  test('callbackDispatcher hands tasks to backgroundTask', () {
    callbackDispatcher();
  });
}
