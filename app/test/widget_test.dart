import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/main.dart';
import 'package:looplet_app/persistence/daily_result_sync_service.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/sync_providers.dart';

import 'support/widget_test_database.dart';

/// Overrides for the external edges the widget tree touches at bootstrap:
/// an in-memory DB, a no-op sync sender, and no connectivity stream. Firebase
/// init inside `appBootstrapProvider` is fire-and-forget and self-catches when
/// there is no platform app.
List<Override> _overrides() => <Override>[
  appDatabaseProvider.overrideWithValue(widgetTestDatabase()),
  syncSenderProvider.overrideWithValue(
    (Map<String, Object?> _) async => SyncSendResult.retryable,
  ),
  connectivityRegainedProvider.overrideWithValue(const Stream<bool>.empty()),
];

void main() {
  testWidgets('app bootstraps and shows the home shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _overrides(), child: const LoopletApp()),
    );

    // Splash while the local bootstrap (DB open + migrations + snapshot) runs.
    expect(find.text('LOOPLET'), findsOneWidget);

    await tester.pumpAndSettle();

    // Bootstrap resolved to ready → the placeholder home (still 'LOOPLET').
    expect(find.text('LOOPLET'), findsOneWidget);
    expect(find.text('Couldn’t open your saved data'), findsNothing);
  });
}
