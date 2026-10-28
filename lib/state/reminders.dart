import 'package:sqlite3/sqlite3.dart';

import '../core/dates.dart';
import '../core/money.dart';
import '../data/models.dart';
import '../data/planning_repo.dart';
import '../data/settings_repo.dart';
import '../services/notifications.dart';

/// What the user can switch on or off under Settings › Reminders & alerts.
enum ReminderType { budget, dues, sip, maturity, followUp }

String reminderTypeLabel(ReminderType t) => switch (t) {
  ReminderType.budget => 'Budget alerts (80% and 100%)',
  ReminderType.dues => 'EMI and card due dates',
  ReminderType.sip => 'SIP reminders',
  ReminderType.maturity => 'FD maturity',
  ReminderType.followUp => 'Follow-ups on money owed to me',
};

/// A notification to schedule: [at] is local wall-clock time.
class PlannedReminder {
  const PlannedReminder(this.id, this.at, this.title, this.body);

  final int id;
  final DateTime at;
  final String title;
  final String body;

  @override
  String toString() => '$id @ $at: $title — $body';
}

/// Hour of the day reminders are delivered at.
const reminderHour = 9;

/// How far ahead reminders are scheduled. They are re-planned on every app
/// open, after edits and by the daily background task.
const reminderWindowDays = 45;

/// iOS keeps at most 64 pending notifications per app; stay under that.
const maxScheduled = 48;

/// Ids below this are scheduled reminders; budget alerts and the test
/// notification use ids above it so a resync never cancels them.
const _alertIdBase = 100000;
const testNotificationId = 99999;

/// Decides what to notify about and keeps the OS schedule in sync with the
/// data. A pure function of the database, the clock and the [service], so it
/// runs the same in the app and in the background task.
class Reminders {
  Reminders({required this.db, required this.service, required this.clock}) : settings = SettingsRepo(db), planning = PlanningRepo(db);

  final Database db;
  final NotificationService service;
  final DateTime Function() clock;
  final SettingsRepo settings;
  final PlanningRepo planning;

  // ---- Preferences ---------------------------------------------------------

  /// Master switch; off until the user turns it on (onboarding or Settings).
  bool get enabled => settings.get('notif_on') == '1';

  bool isOn(ReminderType t) => settings.get('notif_${t.name}') != 'off';

  void setOn(ReminderType t, bool on) => settings.set('notif_${t.name}', on ? 'on' : 'off');

  /// Days before an FD matures to remind the user.
  int get maturityLeadDays => int.tryParse(settings.get('notif_fd_days') ?? '') ?? 3;

  set maturityLeadDays(int days) => settings.set('notif_fd_days', '$days');

  /// Turns reminders on after asking for permission. Returns whether they are on.
  Future<bool> enable() async {
    final granted = await service.requestPermission();
    settings.set('notif_on', granted ? '1' : '0');
    if (granted) await refresh();
    return granted;
  }

  /// Turns reminders off and removes everything scheduled.
  Future<void> disable() async {
    settings.set('notif_on', '0');
    await _cancelScheduled();
  }

  // ---- Planning ------------------------------------------------------------

  static DateTime _at(DateTime day) => DateTime(day.year, day.month, day.day, reminderHour);

  /// Every reminder that should be pending right now, soonest first.
  List<PlannedReminder> plan() {
    final now = clock();
    final lead = maturityLeadDays;
    final out = <(DateTime, String, String)>[];
    for (final u in planning.upcoming(now, days: reminderWindowDays + lead)) {
      final amount = u.amount == null ? '' : formatInr(u.amount!);
      switch (u.kind) {
        case UpcomingKind.emi || UpcomingKind.cardDue when isOn(ReminderType.dues):
          final what = u.kind == UpcomingKind.emi ? 'EMI' : 'Card bill';
          final due = amount.isEmpty ? 'is due' : 'of $amount is due';
          out.add((_at(u.date.subtract(const Duration(days: 1))), '$what due tomorrow', '${u.title}: $what $due tomorrow.'));
          out.add((_at(u.date), '$what due today', '${u.title}: $what $due today.'));
        case UpcomingKind.sip when isOn(ReminderType.sip):
          out.add((_at(u.date), 'SIP due today', '${u.title}: invest $amount today.'));
        case UpcomingKind.maturity when isOn(ReminderType.maturity):
          final when = lead == 0 ? 'today' : (lead == 1 ? 'tomorrow' : 'in $lead days');
          out.add((_at(u.date.subtract(Duration(days: lead))), 'FD matures $when', '${u.title} ($amount invested) matures on ${shortDate(u.date)}.'));
        case UpcomingKind.followUp when isOn(ReminderType.followUp):
          out.add((_at(u.date), 'Follow up with ${u.title}', '${u.title} still owes you $amount.'));
        default:
          break;
      }
    }
    final future = out.where((r) => r.$1.isAfter(now) && r.$1.isBefore(now.add(const Duration(days: reminderWindowDays)))).toList()..sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final (i, r) in future.take(maxScheduled).indexed) PlannedReminder(i + 1, r.$1, r.$2, r.$3)];
  }

  List<int> get _scheduledIds => [for (final s in (settings.get('notif_ids') ?? '').split(',')) ?int.tryParse(s)];

  Future<void> _cancelScheduled() async {
    for (final id in _scheduledIds) {
      await service.cancel(id);
    }
    settings.set('notif_ids', '');
  }

  /// Replaces the OS schedule with [plan]. Does nothing while reminders are off.
  Future<List<PlannedReminder>> sync() async {
    if (!enabled) return const [];
    await _cancelScheduled();
    final planned = plan();
    for (final r in planned) {
      await service.schedule(r.id, r.at, r.title, r.body);
    }
    settings.set('notif_ids', planned.map((r) => r.id).join(','));
    return planned;
  }

  // ---- Budget alerts -------------------------------------------------------

  /// Posts an alert for each budget that crossed 80% or 100% in its current
  /// cycle, once per level per cycle. Returns the alert titles sent.
  Future<List<String>> checkBudgets() async {
    if (!enabled || !isOn(ReminderType.budget)) return const [];
    final now = clock();
    final sent = <String>[];
    for (final b in planning.budgets()) {
      if (b.isGoal) continue;
      final p = planning.progress(b, now);
      final level = p.fraction >= 1 && b.alert100 ? 100 : (p.fraction >= 0.8 && b.alert80 ? 80 : 0);
      if (level == 0) continue;
      final cycle = planning.cycleFor(b, now).start.millisecondsSinceEpoch;
      final key = 'budget_alert:${b.id}';
      final last = (settings.get(key) ?? '').split(':');
      if (last.length == 2 && last[0] == '$cycle' && int.parse(last[1]) >= level) continue;
      final title = level == 100 ? '${b.name} budget used up' : '80% of ${b.name} budget used';
      final left = p.daysLeft == 1 ? '1 day left' : '${p.daysLeft} days left';
      await service.show(_alertIdBase + b.id! * 2 + (level == 100 ? 1 : 0), title, '${formatInr(p.used)} of ${formatInr(p.limit)} spent · $left');
      settings.set(key, '$cycle:$level');
      sent.add(title);
    }
    return sent;
  }

  /// Budget check plus schedule resync: run on app open, after edits and in
  /// the background.
  Future<void> refresh() async {
    await checkBudgets();
    await sync();
  }

  /// Lets the user confirm notifications work on their phone.
  Future<void> sendTest() => service.show(testNotificationId, 'Reminders are on', 'You will hear about budgets, due dates, SIPs and maturities here. Nothing leaves your phone.');
}

/// Day label used next to the "Remind me" button: "5 Nov".
String followUpLabel(DateTime day) => '${day.day} ${monthsShort[day.month - 1]}';
