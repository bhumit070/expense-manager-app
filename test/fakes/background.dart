import 'package:workmanager/workmanager.dart';

/// Records WorkManager calls; installed with [useFakeWorkmanager].
class FakeWorkmanager extends WorkmanagerPlatform {
  FakeWorkmanager({this.fail = false});

  final bool fail;
  final initialized = <Function>[];
  final periodic = <(String, String, Duration?, ExistingPeriodicWorkPolicy?)>[];

  @override
  Future<void> initialize(Function callbackDispatcher, {bool isInDebugMode = false}) async {
    if (fail) throw StateError('no workmanager');
    initialized.add(callbackDispatcher);
  }

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
    ForegroundServiceConfig? foregroundServiceConfig,
  }) async => periodic.add((uniqueName, taskName, frequency, existingWorkPolicy));
}

/// Swaps the WorkManager platform for [fake]. The Workmanager singleton picks
/// a platform when first created, so create it before swapping.
FakeWorkmanager useFakeWorkmanager([FakeWorkmanager? fake]) {
  Workmanager();
  return WorkmanagerPlatform.instance = fake ?? FakeWorkmanager();
}
