import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/recurring_repo.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Txn rent(DateTime at, {int amount = 1500000}) =>
    Txn(type: TxnType.spend, amount: amount, categoryId: 2, sourceId: 1, occurredAt: at, merchant: 'Landlord', note: 'flat', tags: const ['#home'], place: 'HSR', lat: 1, lng: 2);

void main() {
  test('occurrence clamps month ends and keeps the anchor day', () {
    final jan31 = DateTime(2026, 1, 31, 9, 30);
    expect(occurrence(jan31, Frequency.daily, 1), DateTime(2026, 2, 1, 9, 30));
    expect(occurrence(jan31, Frequency.weekly, 2), DateTime(2026, 2, 14, 9, 30));
    expect(occurrence(jan31, Frequency.monthly, 1), DateTime(2026, 2, 28, 9, 30));
    expect(occurrence(jan31, Frequency.monthly, 2), DateTime(2026, 3, 31, 9, 30));
    expect(occurrence(jan31, Frequency.monthly, 11), DateTime(2026, 12, 31, 9, 30));
    expect(occurrence(jan31, Frequency.monthly, 13), DateTime(2027, 2, 28, 9, 30));
    expect(occurrence(DateTime(2028, 1, 31), Frequency.monthly, 1), DateTime(2028, 2, 29));
    expect(occurrence(DateTime(2028, 2, 29), Frequency.yearly, 1), DateTime(2029, 2, 28));
    expect(occurrence(DateTime(2028, 2, 29), Frequency.yearly, 4), DateTime(2032, 2, 29));
    expect(Frequency.values.map(frequencyLabel), ['Daily', 'Weekly', 'Monthly', 'Yearly']);
  });

  test('createFrom saves occurrence 0 and links it', () {
    final s = makeState();
    final id = s.recurring.createFrom(rent(DateTime(2026, 7, 31, 10)), Frequency.monthly, now: kNow);
    final t = s.txns.byId(id)!.txn;
    final rule = s.recurring.byId(t.recurringId!)!;
    expect([rule.count, rule.nextRun, rule.paused, rule.autoCreate, rule.ended, rule.endAt], [1, DateTime(2026, 8, 31, 10), false, true, false, null]);
    expect(
      [rule.template.merchant, rule.template.note, rule.template.tags, rule.template.place, rule.template.lat, rule.template.lng],
      [
        'Landlord',
        'flat',
        ['#home'],
        'HSR',
        1.0,
        2.0,
      ],
    );
    expect(s.recurring.byId(999), isNull);
  });

  test('run catches up missed periods once and respects end, pause and reminders', () {
    final s = makeState();
    s.recurring.createFrom(rent(DateTime(2026, 7, 31, 10)), Frequency.monthly, now: kNow);
    // weekly, ends 14 Oct: occurrences 7 Oct and 14 Oct only
    s.recurring.add(RecurringRule(template: rent(DateTime(2026, 9, 30), amount: 100), frequency: Frequency.weekly, startAt: DateTime(2026, 9, 30), count: 1, endAt: DateTime(2026, 10, 14, 23, 59)));
    final paused = s.recurring.add(RecurringRule(template: rent(DateTime(2026, 1, 1), amount: 200), frequency: Frequency.daily, startAt: DateTime(2026, 1, 1), paused: true));
    final reminder = s.recurring.add(RecurringRule(template: rent(DateTime(2026, 9, 5, 9), amount: 300), frequency: Frequency.monthly, startAt: DateTime(2026, 9, 5, 9), autoCreate: false));

    expect(s.recurring.run(kNow), 2 + 2);
    final created = s.txns.list(const TxnFilter(search: 'landlord')).map((v) => (v.txn.occurredAt, v.txn.amount)).toList();
    expect(created, [(DateTime(2026, 10, 14), 100), (DateTime(2026, 10, 7), 100), (DateTime(2026, 9, 30, 10), 1500000), (DateTime(2026, 8, 31, 10), 1500000), (DateTime(2026, 7, 31, 10), 1500000)]);
    expect(s.recurring.run(kNow), 0, reason: 'idempotent');
    expect(s.recurring.rules().where((r) => r.ended).length, 1);
    expect(s.recurring.byId(paused)!.count, 0);
    expect(s.recurring.byId(reminder)!.nextRun, DateTime(2026, 11, 5, 9));
    expect(s.txns.list(const TxnFilter()).where((v) => v.txn.amount == 300), isEmpty);
  });

  test('resuming skips occurrences missed while paused; delete unlinks', () {
    final s = makeState();
    final txn = s.recurring.createFrom(rent(DateTime(2026, 1, 15)), Frequency.monthly, now: kNow);
    final id = s.txns.byId(txn)!.txn.recurringId!;
    s.recurring.setPaused(id, true, now: kNow);
    expect(s.recurring.run(kNow), 0);
    s.recurring.setPaused(id, false, now: kNow);
    expect(s.recurring.byId(id)!.nextRun, DateTime(2026, 11, 15));
    expect(s.recurring.run(kNow), 0);
    s.recurring.delete(id);
    expect(s.recurring.byId(id), isNull);
    expect(s.txns.byId(txn)!.txn.recurringId, isNull);
  });

  test('forInvestment and upcoming', () {
    final s = makeState();
    final ids = seed(s);
    expect(s.recurring.forInvestment(ids.sip), isNull);
    final sip = Txn(type: TxnType.invest, amount: 500000, categoryId: catId(s, 'Mutual funds / SIP'), sourceId: ids.hdfc, occurredAt: DateTime(2026, 11, 5, 9), investmentId: ids.sip);
    final sipId = s.recurring.add(RecurringRule(template: sip, frequency: Frequency.monthly, startAt: sip.occurredAt, autoCreate: false));
    expect(s.recurring.forInvestment(ids.sip)!.id, sipId);
    s.recurring.add(RecurringRule(template: rent(DateTime(2026, 10, 30)), frequency: Frequency.yearly, startAt: DateTime(2026, 10, 30)));
    s.recurring.add(RecurringRule(template: rent(DateTime(2027, 1, 1)), frequency: Frequency.yearly, startAt: DateTime(2027, 1, 1)));
    s.recurring.add(RecurringRule(template: rent(DateTime(2026, 10, 29)), frequency: Frequency.daily, startAt: DateTime(2026, 10, 29), paused: true));
    s.recurring.add(RecurringRule(template: rent(DateTime(2026, 10, 1)), frequency: Frequency.daily, startAt: DateTime(2026, 10, 1)));
    final up = s.recurring.upcoming(kNow, days: 10);
    expect(up.map((u) => u.at), [DateTime(2026, 10, 30), DateTime(2026, 11, 5, 9)]);
    expect(up.last.rule.template.investmentId, ids.sip);
    expect(s.recurring.upcoming(kNow).length, 2);
  });

  test('copyWith keeps or replaces fields', () {
    final r = RecurringRule(template: rent(DateTime(2026)), frequency: Frequency.daily, startAt: DateTime(2026), endAt: DateTime(2027));
    final same = r.copyWith();
    expect([same.frequency, same.startAt, same.endAt, same.count, same.paused, same.autoCreate], [Frequency.daily, DateTime(2026), DateTime(2027), 0, false, true]);
    final changed = r.copyWith(endAt: () => null, autoCreate: false, paused: true, template: rent(DateTime(2026), amount: 5));
    expect([changed.endAt, changed.autoCreate, changed.paused, changed.template.amount], [null, false, true, 5]);
  });
}
