import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_emulator.dart';
import 'callable_sync_sender.dart';
import 'daily_result_sync_service.dart';
import 'persistence_providers.dart';

/// `submitDailyResultV1` transport. **Lazy on purpose:** this provider hands out
/// a getter, not a resolved `FirebaseFunctions` instance — `FirebaseFunctions
/// .instance` is a FlutterFire call that throws `[core/no-app]` if
/// `Firebase.initializeApp()` hasn't completed yet, and `appBootstrapProvider`
/// constructs `dailyResultSyncServiceProvider` (which watches this) *before*
/// kicking off Firebase init (`bootstrap.dart`'s `_bootstrapFirebase` runs
/// after, `unawaited`). Resolving `.instance` here at provider-build time
/// crashed the app-boot gate on every cold launch (F08-FE12). The getter is
/// only ever invoked inside `callableSyncSender`'s returned closure, at actual
/// send-time — by then Firebase init has normally finished, and if it hasn't,
/// that closure's existing catch-all already treats "no Firebase app" as
/// transient/retryable. Overridable in tests.
///
/// The app is [loopletFirebaseApp] — the default app, or the debug-only
/// emulator app (`firebase_emulator.dart`); for the default app this is
/// exactly `FirebaseFunctions.instance`.
final firebaseFunctionsProvider = Provider<FirebaseFunctions Function()>(
  (ref) =>
      () => FirebaseFunctions.instanceFor(app: loopletFirebaseApp()),
);

/// The real callable-backed [SyncSender].
final syncSenderProvider = Provider<SyncSender>(
  (ref) => callableSyncSender(ref.watch(firebaseFunctionsProvider)),
);

/// Remote-Config `daily_sync_enabled` kill-switch (`release.md` §6). F07 wires
/// the real Remote Config read; until then the switch is on — except in a
/// debug build whose debug sync screen turned it off ([debugSyncDisabledProvider]).
final dailySyncEnabledProvider = Provider<Future<bool> Function()>(
  (ref) =>
      () async => !(kDebugMode && ref.read(debugSyncDisabledProvider)),
);

/// Debug builds only (the debug sync screen): stands in for
/// `daily_sync_enabled = false`, so the kill-switch case can be run against the
/// Firebase emulator (F08 `architecture.md` Activation A3 / A4). Ignored
/// outside `kDebugMode`.
final debugSyncDisabledProvider = StateProvider<bool>((ref) => false);

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
