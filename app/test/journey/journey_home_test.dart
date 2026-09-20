// F05-FE.HOME — the journey home surface (`ui-design.md` "The loop, filling").
// Renders the LOOPLET wordmark, the 30-tick progress ring, and the single
// CONTINUE CTA; CONTINUE routes to the resolved next level. Covers the
// new / mid / in-progress / terminal variants.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_app/home_screen.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
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

  // The in-progress node breathes via a repeating controller; disabling
  // animations keeps `pumpAndSettle` deterministic and makes the terminal
  // bloom instant (`ui-design.md §13`).
  void reduceMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

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

  Future<String> seedCompleted(int upTo) async {
    final guestId = await PlayerRepo(db).currentGuestId();
    for (var n = 1; n <= upTo; n++) {
      await JourneyProgressRepo(db).markCompleted(guestId, n);
    }
    return guestId;
  }

  ActiveSessionSnapshot journeySnapshot(String puzzleId) =>
      ActiveSessionSnapshot(
        puzzleId: puzzleId,
        puzzleSource: PuzzleSource.journey,
        lang: 'tr',
        appliedMoves: const <String>['R1'],
        undosRemaining: 3,
        restartCount: 0,
        elapsedMsAccumulated: 4200,
        thawedFrozenCells: const <String>[],
        status: ActiveSessionStatus.inProgress,
        startedAtUtcMs: 1757145000000,
        lastPersistedAtUtcMs: 1757145004200,
      );

  testWidgets('a new player → 0 / 30 ring, CONTINUE resolves to level 1', (
    tester,
  ) async {
    reduceMotion(tester);
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
    reduceMotion(tester);
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

  testWidgets('an in-progress Journey level → "· sürüyor" caption, CONTINUE '
      'resumes that level', (tester) async {
    reduceMotion(tester);
    final guestId = await seedCompleted(1); // level 1 done → level 2 unlocked
    await ActiveSessionRepo(db).save(journeySnapshot('journey-tr-02'));
    // sanity: the snapshot is for this guest's active session
    expect(guestId, isNotEmpty);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('DEVAM ET'), findsOneWidget);
    expect(find.text('Seviye 2 · sürüyor'), findsOneWidget);
    expect(
      hasSemanticsLabel(tester, '1 / 30 seviye tamamlandı — Seviye 2'),
      isTrue,
    );

    await tester.tap(find.text('DEVAM ET'));
    await tester.pumpAndSettle();
    expect(lastPlayArgs?.journeyLevel, 2);
  });

  testWidgets('all 30 complete → terminal ring + REPLAY from level 1', (
    tester,
  ) async {
    reduceMotion(tester);
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

  /// Level 1 done + an active session on level 2 → the ring's in-progress node
  /// (the only thing that pulses).
  Future<void> seedInProgress() async {
    await seedCompleted(1);
    await ActiveSessionRepo(db).save(journeySnapshot('journey-tr-02'));
  }

  // F03-QA-04: iOS Reduce Motion arrives as `reduceMotion` (iOS-only), Android
  // "Remove animations" as `disableAnimations`; the ring honours either.
  void motion(WidgetTester tester, FakeAccessibilityFeatures features) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = features;
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  final signals = <String, FakeAccessibilityFeatures>{
    'iOS reduceMotion': const FakeAccessibilityFeatures(reduceMotion: true),
    'Android disableAnimations': const FakeAccessibilityFeatures(
      disableAnimations: true,
    ),
  };

  testWidgets('control — no OS signal: the in-progress node keeps breathing', (
    tester,
  ) async {
    motion(tester, const FakeAccessibilityFeatures());
    await seedInProgress();
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 6)); // past any one-shot
    expect(tester.hasRunningAnimations, isTrue); // the repeating pulse
  });

  testWidgets('control — no OS signal: the terminal bloom plays for ~620 ms', (
    tester,
  ) async {
    motion(tester, const FakeAccessibilityFeatures());
    await seedCompleted(30);
    await tester.pumpWidget(buildApp());
    final frames = await tester.pumpAndSettle(const Duration(milliseconds: 16));
    expect(frames, greaterThan(20));
  });

  for (final signal in signals.entries) {
    testWidgets('${signal.key}: no pulse while a level is in progress', (
      tester,
    ) async {
      motion(tester, signal.value);
      await seedInProgress();
      await tester.pumpWidget(buildApp());
      // `pumpAndSettle` throws if the repeating pulse is still running.
      await tester.pumpAndSettle();
    });

    testWidgets('${signal.key}: no bloom when all 30 are complete', (
      tester,
    ) async {
      motion(tester, signal.value);
      await seedCompleted(30);
      await tester.pumpWidget(buildApp());
      final frames = await tester.pumpAndSettle(
        const Duration(milliseconds: 16),
      );
      expect(frames, lessThan(20)); // settled at once, no 620 ms bloom
    });
  }
}
