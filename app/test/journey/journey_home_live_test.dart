// F05-FE3-HOME (F05-QA-STRICT-3) — the home read-model is live on BOTH of its
// sources (`architecture.md §6/§10/§15`, amended 2026-09-26). The home stays
// mounted under the pushed `/play` route, so an active-session snapshot that
// `/play` writes, changes or clears must reach the mounted home — and the same
// persisted state must render the same home warm (mounted) or cold (a fresh
// ProviderScope, i.e. a relaunch).

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

import '../support/widget_test_database.dart';

void main() {
  late AppDatabase db;
  PlaySessionArgs? lastPlayArgs;

  setUp(() {
    db = widgetTestDatabase();
    lastPlayArgs = null;
  });
  tearDown(() => db.close());

  // The in-progress node breathes via a repeating controller; reduced motion
  // keeps `pumpAndSettle` deterministic (same as journey_home_test.dart).
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

  Future<String> seedCompleted(int upTo) async {
    final guestId = await PlayerRepo(db).currentGuestId();
    for (var n = 1; n <= upTo; n++) {
      await JourneyProgressRepo(db).markCompleted(guestId, n);
    }
    return guestId;
  }

  ActiveSessionSnapshot snapshot(
    String puzzleId, {
    ActiveSessionStatus status = ActiveSessionStatus.inProgress,
  }) => ActiveSessionSnapshot(
    puzzleId: puzzleId,
    puzzleSource: PuzzleSource.journey,
    lang: 'tr',
    appliedMoves: const <String>['R1'],
    undosRemaining: 3,
    restartCount: 0,
    elapsedMsAccumulated: 4200,
    thawedFrozenCells: const <String>[],
    status: status,
    startedAtUtcMs: 1757145000000,
    lastPersistedAtUtcMs: 1757145004200,
  );

  /// The CONTINUE caption(s) currently rendered ("Seviye N" / "… · sürüyor").
  List<String> captions(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .where((s) => s.startsWith('Seviye '))
      .toList();

  /// Remounts the app under a fresh ProviderScope on the same DB — the
  /// relaunch ("cold") derivation of the current persisted state.
  Future<List<String>> coldCaptions(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    return captions(tester);
  }

  testWidgets('warm frontier: a level started while the home is mounted shows '
      'its in-progress state on return', (tester) async {
    reduceMotion(tester);
    await seedCompleted(1);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(captions(tester), <String>['Seviye 2']);

    // `/play` persists a fresh session the moment level 2 opens.
    await ActiveSessionRepo(db).save(snapshot('journey-tr-02'));
    await tester.pumpAndSettle();

    expect(captions(tester), <String>['Seviye 2 · sürüyor']);
    await tester.tap(find.text('DEVAM ET'));
    await tester.pumpAndSettle();
    expect(lastPlayArgs?.journeyLevel, 2);
  });

  testWidgets('warm replay: a completed level replayed in-session is the '
      'CONTINUE target (§6), not the frontier', (tester) async {
    reduceMotion(tester);
    await seedCompleted(2);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(captions(tester), <String>['Seviye 3']);

    // Win panel → "Yeniden" on level 2 → a fresh level-2 session is persisted.
    await ActiveSessionRepo(db).save(snapshot('journey-tr-02'));
    await tester.pumpAndSettle();

    expect(captions(tester), <String>['Seviye 2 · sürüyor']);
    await tester.tap(find.text('DEVAM ET'));
    await tester.pumpAndSettle();
    expect(lastPlayArgs?.journeyLevel, 2);
  });

  testWidgets('warm win: completing the in-progress level clears the '
      'in-progress state and advances CONTINUE', (tester) async {
    reduceMotion(tester);
    final guestId = await seedCompleted(1);
    await ActiveSessionRepo(db).save(snapshot('journey-tr-02'));
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(captions(tester), <String>['Seviye 2 · sürüyor']);

    // The controller's win order: snapshot → completed, cleared; then unlock.
    final repo = ActiveSessionRepo(db);
    await repo.save(
      snapshot('journey-tr-02', status: ActiveSessionStatus.completed),
    );
    await repo.clear();
    await JourneyProgressRepo(db).markCompleted(guestId, 2);
    await tester.pumpAndSettle();

    expect(captions(tester), <String>['Seviye 3']);
    await tester.tap(find.text('DEVAM ET'));
    await tester.pumpAndSettle();
    expect(lastPlayArgs?.journeyLevel, 3);
  });

  testWidgets('warm == cold: the same persisted state renders the same home '
      'mounted or after a relaunch', (tester) async {
    reduceMotion(tester);
    await seedCompleted(2);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final repo = ActiveSessionRepo(db);
    final steps = <String, Future<void> Function()>{
      'frontier level 3 started': () => repo.save(snapshot('journey-tr-03')),
      'completed level 1 replayed': () => repo.save(snapshot('journey-tr-01')),
      'session cleared': repo.clear,
    };
    for (final step in steps.entries) {
      await step.value();
      await tester.pumpAndSettle();
      final warm = captions(tester);
      final cold = await coldCaptions(tester);
      expect(warm, cold, reason: step.key);
    }
  });

  testWidgets('a corrupt snapshot written while mounted is discarded; the home '
      'falls back to the next unlocked level', (tester) async {
    reduceMotion(tester);
    await seedCompleted(1);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await db
        .into(db.kvRows)
        .insertOnConflictUpdate(
          KvRowsCompanion.insert(
            key: ActiveSessionSnapshot.kvKey,
            valueJson: '{not json',
            schemaVersion: ActiveSessionSnapshot.currentSnapshotVersion,
          ),
        );
    await tester.pumpAndSettle();

    expect(captions(tester), <String>['Seviye 2']);
    expect(await ActiveSessionRepo(db).read(), isNull);
  });
}
