import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_emulator.dart';
import 'firebase_options.dart';
import 'persistence/app_database.dart';
import 'persistence/daily_result_sync_service.dart';
import 'persistence/persistence_providers.dart';
import 'persistence/store_recovery.dart';
import 'persistence/sync_providers.dart';

/// Outcome of the app's local bootstrap (DB open + migrations + snapshot read).
sealed class AppBootstrap {
  const AppBootstrap();
}

/// Everything local is ready; the app tree can render. Firebase init runs in the
/// background (fire-and-forget) and never gates this.
class AppBootstrapReady extends AppBootstrap {
  const AppBootstrapReady();
}

/// The local store is not usable: a migration failed ([StoreFailureKind
/// .migration] — the store is left at the old schema, no partial apply, no
/// wipe, F08 AC9), the store could not be opened ([StoreFailureKind.other]), or
/// an unreadable store was already recreated once in this launch (the loop
/// guard). The player sees the recoverable store-error screen; Retry re-runs
/// the bootstrap on a fresh connection.
class AppBootstrapStoreError extends AppBootstrap {
  const AppBootstrapStoreError(this.kind, this.message);
  final StoreFailureKind kind;
  final String message;
}

/// F08 app-init sequence (`architecture.md → App Init Sequence`, Activation
/// 2026-09-29 A1 / A2):
/// 1. open `AppDatabase` + run migrations (never-drop guard) and warm the
///    active-session snapshot (corrupt JSON → self-heals to null). A failure is
///    classified ([classifyStoreFailure]):
///    * unreadable (`SQLITE_NOTADB` / `SQLITE_CORRUPT`) → quarantine the file,
///      recreate (a new guest), log `db_reinitialized`, continue — at most once
///      per launch;
///    * migration / other → [AppBootstrapStoreError] (the store-error screen);
/// 2. construct the session-level [DailyResultSyncService] once;
/// 3. kick off Firebase init **without awaiting** — best-effort, never fatal.
///
/// A run that ends without a ready store marks the connection stale, so the
/// next run — Retry is the only trigger — closes it and opens a fresh one: a
/// store that became readable in the meantime recovers without a relaunch.
///
/// The store providers are **read**, not watched: this run replaces the
/// connection itself and must not be restarted by that.
final appBootstrapProvider = FutureProvider<AppBootstrap>((ref) async {
  final launch = ref.read(storeLaunchStateProvider);
  var ready = false;
  try {
    if (launch.connectionStale) {
      await _replaceConnection(ref);
      launch.connectionStale = false;
    }

    final failure = await _openStore(ref);
    if (failure != null) {
      final error = await _recoverStore(ref, launch, failure);
      if (error != null) return error;
    }

    // Session-level, app-scoped, never screen-owned.
    final sync = ref.watch(dailyResultSyncServiceProvider);
    unawaited(_bootstrapFirebase(ref, sync));

    ready = true;
    return const AppBootstrapReady();
  } finally {
    if (!ready) launch.connectionStale = true;
  }
});

/// The first queries: the player row triggers `onCreate` (seed) / `onUpgrade`
/// (guarded steps); the snapshot read discards a corrupt row. Null = usable.
Future<StoreFailure?> _openStore(Ref ref) async {
  try {
    await ref.read(playerRepoProvider).current();
    await ref.read(activeSessionRepoProvider).read();
    return null;
  } catch (error) {
    return classifyStoreFailure(error);
  }
}

/// Null when the store is usable again (recreated), otherwise the error state.
Future<AppBootstrapStoreError?> _recoverStore(
  Ref ref,
  StoreLaunchState launch,
  StoreFailure failure,
) async {
  switch (failure.kind) {
    case StoreFailureKind.migration:
      debugPrint('store: migration_failed — ${failure.error}');
      return AppBootstrapStoreError(failure.kind, '${failure.error}');
    case StoreFailureKind.other:
      return AppBootstrapStoreError(failure.kind, '${failure.error}');
    case StoreFailureKind.unreadable:
      if (launch.recreatedThisLaunch) {
        debugPrint(
          'store: unreadable after db_reinitialized — ${failure.codeLabel}; '
          'no second recreate in this launch',
        );
        return AppBootstrapStoreError(failure.kind, '${failure.error}');
      }
      launch.recreatedThisLaunch = true;

      final String quarantined;
      try {
        await _closeQuietly(ref.read(appDatabaseProvider));
        final store = await ref.read(appStoreFileProvider)();
        final file = await quarantineStoreFile(
          store,
          utcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
        );
        quarantined = file.path;
        ref.invalidate(appDatabaseProvider);
      } catch (error) {
        return AppBootstrapStoreError(
          StoreFailureKind.other,
          'quarantine failed: $error (store: ${failure.error})',
        );
      }

      final again = await _openStore(ref);
      if (again != null) {
        debugPrint('store: recreate failed — ${again.error}');
        return AppBootstrapStoreError(again.kind, '${again.error}');
      }
      debugPrint(
        'store: db_reinitialized — ${failure.codeLabel}; '
        'quarantined as $quarantined',
      );
      return null;
  }
}

/// Closes the current connection (awaited) and drops it; the next read opens
/// a fresh one (F08-RETRY-STORE-CONNECTION).
Future<void> _replaceConnection(Ref ref) async {
  await _closeQuietly(ref.read(appDatabaseProvider));
  ref.invalidate(appDatabaseProvider);
}

/// A broken connection may fail to close; it is dropped either way.
Future<void> _closeQuietly(AppDatabase db) async {
  try {
    await db.close();
  } catch (error) {
    debugPrint('store: closing the failed connection threw — $error');
  }
}

/// Best-effort Firebase chain. Every step is caught + logged and never rethrown:
/// play and local persistence must not depend on connectivity or attestation
/// (`architecture.md → App Init Sequence`; App Check is soft-enforce).
Future<void> _bootstrapFirebase(Ref ref, DailyResultSyncService sync) async {
  final emulatorHost = firebaseEmulatorHost(debugBuild: kDebugMode);
  try {
    if (emulatorHost != null) {
      await initializeEmulatorFirebaseApp(emulatorHost);
    } else if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error) {
    debugPrint('firebase init failed (non-fatal): $error');
    return;
  }

  // App Check: debug provider in debug/profile/simulator; Play Integrity /
  // App Attest in release. iOS production App Attest is not provisioned yet
  // (no Apple Developer Program membership) — activation may fail on a release
  // build; because enforcement is monitor-only that is a logged no-op. Against
  // the emulators it is skipped: they do not attest, and a debug-token exchange
  // would reach the real App Check backend.
  if (emulatorHost == null) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        appleProvider: kReleaseMode
            ? AppleProvider.appAttest
            : AppleProvider.debug,
      );
    } catch (error) {
      debugPrint('app check activate failed (non-fatal): $error');
    }
  }

  try {
    final credential = await FirebaseAuth.instanceFor(
      app: loopletFirebaseApp(),
    ).signInAnonymously();
    final uid = credential.user?.uid;
    if (uid != null) {
      await ref.read(playerRepoProvider).setFirebaseUid(uid);
    }
  } catch (error) {
    debugPrint('anonymous sign-in failed (non-fatal): $error');
  }

  // Now that (a possible) firebaseUid exists, retry parked items once and drain.
  try {
    await sync.reviveParkedOnAppStart();
    await sync.drain();
  } catch (error) {
    debugPrint('initial sync drain failed (non-fatal): $error');
  }
}
