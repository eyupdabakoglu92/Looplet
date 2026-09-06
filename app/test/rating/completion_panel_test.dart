import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/rating/completion_panel.dart';
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
}
