import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'callable_sync_sender.dart';
import 'daily_result_sync_service.dart';
import 'persistence_providers.dart';

/// `submitDailyResultV1` transport. Overridable in tests / when Firebase is not
/// yet initialised.
final firebaseFunctionsProvider = Provider<FirebaseFunctions>(
  (ref) => FirebaseFunctions.instance,
);

/// The real callable-backed [SyncSender].
final syncSenderProvider = Provider<SyncSender>(
  (ref) => callableSyncSender(ref.watch(firebaseFunctionsProvider)),
);

/// Remote-Config `daily_sync_enabled` kill-switch (`release.md` §6). F07 wires
/// the real Remote Config read; until then the switch is on.
final dailySyncEnabledProvider = Provider<Future<bool> Function()>(
  (ref) =>
      () async => true,
);

/// Emits `true` whenever connectivity is (re)gained — the trigger for a queue
/// drain. `connectivity_plus` 6.x reports a `List<ConnectivityResult>`.
final connectivityRegainedProvider = Provider<Stream<bool>>((ref) {
  final controller = StreamController<bool>.broadcast();
  final sub = Connectivity().onConnectivityChanged.listen((results) {
    final hasConnection =
        results.any((r) => r != ConnectivityResult.none) && results.isNotEmpty;
    if (hasConnection) controller.add(true);
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// The session-level [DailyResultSyncService] — constructed **once** at app
/// start and disposed only when the root `ProviderScope` is (app termination).
/// It is never owned or cancelled by a screen (`platform.md` §7,
/// `architecture.md → Ownership & Lifecycle`). Lifecycle hooks (`paused` flush /
/// `resumed` drain) are wired in `main.dart`.
final dailyResultSyncServiceProvider = Provider<DailyResultSyncService>((ref) {
  final service = DailyResultSyncService(
    db: ref.watch(appDatabaseProvider),
    queue: ref.watch(syncQueueRepoProvider),
    daily: ref.watch(dailyRepoProvider),
    player: ref.watch(playerRepoProvider),
    sender: ref.watch(syncSenderProvider),
    isSyncEnabled: ref.watch(dailySyncEnabledProvider),
    connectivityRegained: ref.watch(connectivityRegainedProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
