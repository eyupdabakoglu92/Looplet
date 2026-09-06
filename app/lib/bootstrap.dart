import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'persistence/daily_result_sync_service.dart';
import 'persistence/migration_guard.dart';
import 'persistence/persistence_providers.dart';
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

/// A Drift migration failed. The store is left at the old schema (no partial
/// apply, no wipe); the user sees a recoverable error screen (F08 AC9).
class AppBootstrapMigrationError extends AppBootstrap {
  const AppBootstrapMigrationError(this.message);
  final String message;
}

/// F08 app-init sequence (`architecture.md → App Init Sequence`):
/// 1. open `AppDatabase` + run migrations (never-drop guard) — a failure here is
///    the only thing that blocks the app (→ [AppBootstrapMigrationError]);
/// 2. warm the active-session snapshot read (corrupt → self-heals to null);
/// 3. construct the session-level [DailyResultSyncService] once;
/// 4. kick off Firebase init **without awaiting** — best-effort, never fatal.
final appBootstrapProvider = FutureProvider<AppBootstrap>((ref) async {
  try {
    // The first query triggers `onCreate` (seed) / `onUpgrade` (guarded steps).
    await ref.watch(playerRepoProvider).current();
    // Warm + self-heal the snapshot; a corrupt row is discarded here.
    await ref.watch(activeSessionRepoProvider).read();
  } on MigrationDataLossError catch (error) {
    return AppBootstrapMigrationError(error.message);
  } catch (error) {
    return AppBootstrapMigrationError(error.toString());
  }

  // Session-level, app-scoped, never screen-owned.
  final sync = ref.watch(dailyResultSyncServiceProvider);
  unawaited(_bootstrapFirebase(ref, sync));

  return const AppBootstrapReady();
});

/// Best-effort Firebase chain. Every step is caught + logged and never rethrown:
/// play and local persistence must not depend on connectivity or attestation
/// (`architecture.md → App Init Sequence`; App Check is soft-enforce).
Future<void> _bootstrapFirebase(Ref ref, DailyResultSyncService sync) async {
  try {
    if (Firebase.apps.isEmpty) {
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
  // build; because enforcement is monitor-only that is a logged no-op.
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

  try {
    final credential = await FirebaseAuth.instance.signInAnonymously();
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
