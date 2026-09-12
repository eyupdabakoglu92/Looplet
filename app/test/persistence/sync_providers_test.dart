import 'package:drift/native.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/daily_result_sync_service.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/sync_providers.dart';

/// F08-FE12 regression: `appBootstrapProvider` (`bootstrap.dart`) constructs
/// `dailyResultSyncServiceProvider` *before* `Firebase.initializeApp()` ever
/// runs. Before this fix, `firebaseFunctionsProvider` resolved
/// `FirebaseFunctions.instance` eagerly at provider-build time, which throws
/// `[core/no-app]` whenever `Firebase.apps` is empty — crashing every cold
/// app boot. These tests exercise the REAL provider chain (unlike
/// `widget_test.dart`, which overrides `syncSenderProvider` directly and so
/// never touches `firebaseFunctionsProvider` at all — that override is why
/// this bug shipped unnoticed) with `Firebase.apps` deliberately left empty,
/// exactly as it is on every real cold launch before init completes.
void main() {
  test('Firebase.apps is empty in this test process (the exact precondition '
      'that crashed app boot before F08-FE12)', () {
    expect(Firebase.apps, isEmpty);
  });

  test('dailyResultSyncServiceProvider (the REAL chain, not overridden) builds '
      'without throwing even though Firebase was never initialised', () {
    final container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(
          AppDatabase.forTesting(NativeDatabase.memory()),
        ),
        connectivityRegainedProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        // firebaseFunctionsProvider / syncSenderProvider are intentionally
        // NOT overridden here — this is the real chain that used to crash.
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(dailyResultSyncServiceProvider),
      returnsNormally,
    );
  });

  test('the real syncSenderProvider, invoked while Firebase is uninitialised, '
      'resolves to retryable instead of throwing', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(
          AppDatabase.forTesting(NativeDatabase.memory()),
        ),
        connectivityRegainedProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final sender = container.read(syncSenderProvider);
    final result = await sender(<String, Object?>{});
    expect(result, SyncSendResult.retryable);
  });
}
