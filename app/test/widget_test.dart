import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/home_screen.dart';
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
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(overrides: _overrides(), child: const LoopletApp()),
    );

    // The splash while the local bootstrap (DB open + migrations + snapshot)
    // runs: the Foundation ground and the `Looplet` wordmark only.
    expect(find.byType(LoopletWordmark), findsOneWidget);
    expect(find.byType(LimePill), findsNothing);

    await tester.pumpAndSettle();

    // Bootstrap resolved to ready → the D3 Home, the wordmark in place.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoopletWordmark), findsOneWidget);
    expect(find.text('Devam et'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsNothing);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Looplet');
    expect(app.theme!.scaffoldBackgroundColor, LoopColors.groundMid);
  });
}
