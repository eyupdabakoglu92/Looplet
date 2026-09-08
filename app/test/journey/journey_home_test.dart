// F05-FE.HOME — the journey home surface (`ui-design.md` "The loop, filling").
// Renders the LOOPLET wordmark, the 30-tick progress ring, and the single
// CONTINUE CTA, and CONTINUE routes to the resolved next level.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_app/home_screen.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/journey_progress_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';

void main() {
  late AppDatabase db;
  PlaySessionArgs? lastPlayArgs;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    lastPlayArgs = null;
  });
  tearDown(() => db.close());

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/play',
          builder: (context, state) {
            lastPlayArgs = state.extra as PlaySessionArgs?;
            return const Scaffold(body: Center(child: Text('PLAY ROUTE')));
          },
        ),
      ],
    );
    return ProviderScope(
      overrides: <Override>[appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  /// Reads `Semantics` widget properties directly — no `ensureSemantics` handle.
  bool hasSemanticsLabel(WidgetTester tester, String needle) {
    return tester.widgetList<Semantics>(find.byType(Semantics)).any((s) {
      final value = s.properties.label;
      return value != null && value.contains(needle);
    });
  }

  Future<void> seedCompleted(int upTo) async {
    final guestId = await PlayerRepo(db).currentGuestId();
    for (var n = 1; n <= upTo; n++) {
      await JourneyProgressRepo(db).markCompleted(guestId, n);
    }
  }

  testWidgets('a new player → 0 / 30 ring, CONTINUE resolves to level 1', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('LOOPLET'), findsOneWidget);
    expect(find.text('SEVİYE'), findsOneWidget); // ring kicker (not terminal)
    expect(find.text('DEVAM ET'), findsOneWidget);
    expect(find.text('Seviye 1'), findsOneWidget);
    expect(
      hasSemanticsLabel(tester, '0 / 30 seviye tamamlandı — Seviye 1'),
      isTrue,
    );

    await tester.tap(find.text('DEVAM ET'));
    await tester.pumpAndSettle();

    expect(find.text('PLAY ROUTE'), findsOneWidget);
    expect(lastPlayArgs?.source, PuzzleSource.journey);
    expect(lastPlayArgs?.journeyLevel, 1);
  });

  testWidgets('mid progression → count reflects clears, CONTINUE targets the '
      'next gap', (tester) async {
    await seedCompleted(3);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('DEVAM ET'), findsOneWidget);
    expect(find.text('Seviye 4'), findsOneWidget);
    expect(
      hasSemanticsLabel(tester, '3 / 30 seviye tamamlandı — Seviye 4'),
      isTrue,
    );

    await tester.tap(find.text('DEVAM ET'));
    await tester.pumpAndSettle();
    expect(lastPlayArgs?.journeyLevel, 4);
  });

  testWidgets('all 30 complete → terminal ring + REPLAY from level 1', (
    tester,
  ) async {
    await seedCompleted(30);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('TAMAMLANDI'), findsOneWidget); // terminal kicker
    expect(find.text('TEKRAR OYNA'), findsOneWidget);
    expect(find.text('DEVAM ET'), findsNothing);
    expect(hasSemanticsLabel(tester, '30 / 30 seviye tamamlandı'), isTrue);

    await tester.tap(find.text('TEKRAR OYNA'));
    await tester.pumpAndSettle();
    expect(lastPlayArgs?.journeyLevel, 1);
  });
}
