import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/active_session_repo.dart';
import 'package:looplet_app/persistence/repositories/personal_best_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_controller.dart';
import 'package:looplet_app/play/play_session_providers.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/rating/completion_panel.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

Widget _app(AppDatabase db, String id) => ProviderScope(
  overrides: <Override>[
    appDatabaseProvider.overrideWithValue(db),
    wordValidatorProvider.overrideWith(
      (ref) async => const NeverValidWordValidator(),
    ),
  ],
  child: MaterialApp(
    home: PlaySessionScreen(
      args: PlaySessionArgs(source: PuzzleSource.journey, debugPuzzleId: id),
    ),
  ),
);

Offset _rowStart(WidgetTester tester, int row) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  const plate = 10.0;
  const gap = 8.0;
  final tile = (box.width - 2 * plate - 4 * gap) / 5;
  final stride = tile + gap;
  return Offset(
    box.left + plate + tile * 0.5,
    box.top + plate + row * stride + tile * 0.5,
  );
}

Future<void> _shift(WidgetTester tester, int row) async {
  await tester.dragFrom(_rowStart(tester, row), const Offset(140, 0));
  await tester.pumpAndSettle();
}

Future<void> _boot(WidgetTester tester, AppDatabase db, String id) async {
  await tester.pumpWidget(_app(db, id));
  await tester.pumpAndSettle();
  expect(find.byType(PuzzleBoard), findsOneWidget);
}

void _phoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Reads `Semantics` widget properties directly — no `ensureSemantics` handle
/// (which would need explicit disposal before the end-of-test check).
bool _hasSemanticsLabel(WidgetTester tester, Pattern label) {
  return tester.widgetList<Semantics>(find.byType(Semantics)).any((s) {
    final value = s.properties.label;
    if (value == null) return false;
    return label is RegExp ? label.hasMatch(value) : value == label;
  });
}

/// A puzzle that is solvable in one row-0 right shift (`A S A L M` → `M A S A L`)
/// but carries `optimalMoves: 0` — the defensive "no usable optimal" case
/// (`architecture.md §6`; F06's export gate makes this unreachable for shipped
/// content, so it can only be built by hand).
Puzzle _noOptimalPuzzle() => Puzzle(
  schemaVersion: 1,
  contentVersion: 'test',
  id: 'no-optimal-test',
  puzzleType: PuzzleType.journey,
  journeyLevelNumber: 1,
  language: 'tr',
  grid: const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  targetWord: 'MASAL',
  lockedCells: const <GridCoord>{},
  frozenCells: const <GridCoord>{},
  columnMovesEnabled: false,
  optimalMoves: 0,
  difficultyScore: 1,
  difficultyLabel: DifficultyLabel.easy,
  difficultyBreakdown: const <String, num>{},
);

void main() {
  testWidgets(
    'smoke-tr-01 solved in 1 (optimal 1) → Perfect + first-clear panel with '
    'every AC7 element',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _boot(tester, db, 'smoke-tr-01');
      await _shift(tester, 0); // A S A L M → M A S A L (MASAL), a 1-move win

      expect(find.byType(CompletionPanel), findsOneWidget);

      // AC7: target word / player moves / optimal moves / stars / personal
      // best / Retry / Next Level.
      expect(
        find.descendant(
          of: find.byType(CompletionPanel),
          matching: find.text('MASAL'),
        ),
        findsOneWidget,
      );
      expect(find.text('SEN'), findsOneWidget);
      expect(find.text('OPTİMAL'), findsOneWidget);
      expect(find.text('EN İYİ'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget); // star caption
      expect(find.text('HARİKA'), findsOneWidget); // Perfect marker
      expect(find.text('='), findsOneWidget); // gap connective on Perfect
      expect(find.text('Yeniden'), findsOneWidget); // Retry
      expect(find.text('SONRAKİ'), findsOneWidget); // Next Level
      expect(
        find.text('yakında'),
        findsOneWidget,
      ); // [PENDING — F05] affordance

      expect(_hasSemanticsLabel(tester, 'SEN: 1'), isTrue);
      expect(_hasSemanticsLabel(tester, 'OPTİMAL: 1'), isTrue);
      expect(_hasSemanticsLabel(tester, RegExp('EN İYİ: 1')), isTrue);
      // The star count is conveyed non-visually.
      expect(_hasSemanticsLabel(tester, '3 / 3 yıldız — Harika'), isTrue);
      expect(find.text('YENİ REKOR'), findsNothing); // not on a first clear
      expect(
        find.text('İLK'),
        findsOneWidget,
      ); // firstClear tag on the best cell
    },
  );

  testWidgets(
    'Retry → solve again in 1 → matched best, still Perfect, no "new best"',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _boot(tester, db, 'smoke-tr-01');
      await _shift(tester, 0);
      expect(find.byType(CompletionPanel), findsOneWidget);

      await tester.tap(find.text('Yeniden'));
      await tester.pumpAndSettle();
      expect(find.byType(CompletionPanel), findsNothing);

      await _shift(tester, 0);
      expect(find.byType(CompletionPanel), findsOneWidget);
      expect(find.text('HARİKA'), findsOneWidget);
      expect(find.text('YENİ REKOR'), findsNothing); // matched, not beaten
      // matchedBest is the silent variant — no best-cell tag at all.
      expect(find.text('İLK'), findsNothing);
      expect(find.text('daha iyi'), findsNothing);
      expect(_hasSemanticsLabel(tester, RegExp('EN İYİ: 1')), isTrue);
    },
  );

  testWidgets(
    'smoke-tr-02 solved in 3 (optimal 2) → 2 stars, not Perfect, +1 gap',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _boot(tester, db, 'smoke-tr-02');
      await _shift(tester, 1); // waste one move (B C D F G → G B C D F)
      await _shift(tester, 0); // S A L M A → A S A L M
      await _shift(tester, 0); // A S A L M → M A S A L (win, 3 moves total)

      expect(find.byType(CompletionPanel), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('HARİKA'), findsNothing);
      expect(find.text('+1'), findsOneWidget); // 3 player − 2 optimal
      expect(_hasSemanticsLabel(tester, 'SEN: 3'), isTrue);
      expect(_hasSemanticsLabel(tester, 'OPTİMAL: 2'), isTrue);
    },
  );

  testWidgets('a beaten prior best → "new best" treatment (▲ + YENİ REKOR)', (
    tester,
  ) async {
    _phoneSurface(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // Seed a worse prior best for smoke-tr-01 under the seeded guest id,
    // exactly as F08's repo would have.
    final guestId = await PlayerRepo(db).currentGuestId();
    await PersonalBestRepo(db).recordCompletion(
      guestId: guestId,
      levelId: 'smoke-tr-01',
      moveCount: 4,
      stars: 1,
      optimalMoves: 1,
      completedAtUtcMs: 1757100000000,
    );

    await _boot(tester, db, 'smoke-tr-01');
    await _shift(tester, 0); // solve in 1 → beats the seeded 4

    expect(find.byType(CompletionPanel), findsOneWidget);
    expect(find.text('YENİ REKOR'), findsOneWidget);
    expect(find.text('▲'), findsOneWidget);
    expect(_hasSemanticsLabel(tester, RegExp('EN İYİ: 1')), isTrue);
  });

  testWidgets('a restored-solved session lands on the panel without crashing', (
    tester,
  ) async {
    _phoneSurface(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // A completed snapshot that failed to clear (edge) — smoke-tr-01 solved
    // by one R0.
    await ActiveSessionRepo(db).save(
      ActiveSessionSnapshot(
        puzzleId: 'smoke-tr-01',
        puzzleSource: PuzzleSource.journey,
        lang: 'tr',
        appliedMoves: const <String>['R0'],
        undosRemaining: 3,
        restartCount: 0,
        elapsedMsAccumulated: 5000,
        thawedFrozenCells: const <String>[],
        status: ActiveSessionStatus.completed,
        startedAtUtcMs: 1757145000000,
        lastPersistedAtUtcMs: 1757145005000,
      ),
    );

    await _boot(tester, db, 'smoke-tr-01');
    await tester.pumpAndSettle();

    expect(find.byType(CompletionPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a worse-than-best result → noImprovement variant (this-run stars + '
    'retained better best + "daha iyi", no "new best")',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Seed a *better* prior best (2 = optimal) for smoke-tr-02.
      final guestId = await PlayerRepo(db).currentGuestId();
      await PersonalBestRepo(db).recordCompletion(
        guestId: guestId,
        levelId: 'smoke-tr-02',
        moveCount: 2,
        stars: 3,
        optimalMoves: 2,
        completedAtUtcMs: 1757100000000,
      );

      await _boot(tester, db, 'smoke-tr-02');
      await _shift(tester, 1); // wasted move (B C D F G → G B C D F)
      await _shift(tester, 0); // S A L M A → A S A L M
      await _shift(tester, 0); // A S A L M → M A S A L (win, 3 moves total)

      expect(find.byType(CompletionPanel), findsOneWidget);
      // This run: 3 moves vs optimal 2 → 2 stars, +1 gap, not Perfect.
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('HARİKA'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
      // The retained better best is shown, tagged "daha iyi", no celebration.
      expect(find.text('daha iyi'), findsOneWidget);
      expect(find.text('YENİ REKOR'), findsNothing);
      expect(find.text('▲'), findsNothing);
      expect(_hasSemanticsLabel(tester, 'SEN: 3'), isTrue);
      expect(_hasSemanticsLabel(tester, RegExp('EN İYİ: 2')), isTrue);
      // Best is still Perfect (2 == optimal) → the ★ marker on the best cell.
      expect(find.text('★'), findsOneWidget);
    },
  );

  testWidgets('no-optimal puzzle → CompletionPanel renders the bare fallback '
      '(no stars / triptych, "Puan yok"), Retry still available', (
    tester,
  ) async {
    _phoneSurface(tester);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final app = ProviderScope(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        wordValidatorProvider.overrideWith(
          (ref) async => const NeverValidWordValidator(),
        ),
        playSessionSetupProvider.overrideWith(
          (ref, args) async => PlaySessionSetup(
            puzzle: _noOptimalPuzzle(),
            validator: const NeverValidWordValidator(),
          ),
        ),
      ],
      child: const MaterialApp(
        home: PlaySessionScreen(
          args: PlaySessionArgs(
            source: PuzzleSource.journey,
            debugPuzzleId: 'no-optimal-test',
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleBoard), findsOneWidget);

    await _shift(tester, 0); // A S A L M → M A S A L — a 1-move win

    expect(find.byType(CompletionPanel), findsOneWidget);
    // Bare fallback: the completion + a muted "rating unavailable" line.
    expect(find.text('ÇÖZÜLDÜ'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CompletionPanel),
        matching: find.text('MASAL'),
      ),
      findsOneWidget,
    );
    expect(find.text('Puan yok'), findsOneWidget);
    // No rating surface.
    expect(find.text('3 / 3'), findsNothing); // no star caption
    expect(find.text('HARİKA'), findsNothing);
    expect(find.text('OPTİMAL'), findsNothing); // no triptych
    expect(find.text('EN İYİ'), findsNothing);
    // CTAs are still there.
    expect(find.text('Yeniden'), findsOneWidget);
    expect(find.text('SONRAKİ'), findsOneWidget);
  });

  test('PlaySessionController with optimalMoves < 1 → ratingUnavailable, no '
      'CompletionResult, logs rating_blocked_no_optimal', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ActiveSessionRepo(db);
    final guestId = await PlayerRepo(db).currentGuestId();

    final logs = <String?>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logs.add(message);
    addTearDown(() => debugPrint = previousDebugPrint);

    final controller = PlaySessionController(
      puzzle: _noOptimalPuzzle(),
      source: PuzzleSource.journey,
      validator: const NeverValidWordValidator(),
      activeSessionRepo: repo,
      personalBestRepo: PersonalBestRepo(db),
      guestId: guestId,
      clock: () => DateTime.utc(2026, 9, 7, 12),
    );
    addTearDown(controller.dispose);
    await controller.whenPersisted;

    controller.beginDrag(startRow: 0, startCol: 0);
    controller.updateDrag(const Offset(40, 0));
    expect(controller.endDrag(const Offset(40, 0)), DragResolution.shift);
    expect(controller.commitShift(), isTrue); // solved

    expect(controller.phase, PlaySessionPhase.won);
    expect(controller.ratingUnavailable, isTrue);
    expect(controller.ratingResolved, isTrue);
    expect(controller.completion, isNull);
    await controller.whenRatingResolved;
    expect(controller.completion, isNull);
    expect(
      logs.any((m) => m != null && m.contains('rating_blocked_no_optimal')),
      isTrue,
    );
  });
}
