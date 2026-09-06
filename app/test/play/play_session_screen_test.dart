import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/completion_sheet.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_engine/looplet_engine.dart';

List<Override> _overrides() => <Override>[
  appDatabaseProvider.overrideWithValue(
    AppDatabase.forTesting(NativeDatabase.memory()),
  ),
  // The play screen needs a WordValidator; the smoke puzzles used here have no
  // frozen tiles so a never-valid validator is sufficient and avoids the asset
  // bundle.
  wordValidatorProvider.overrideWith(
    (ref) async => const NeverValidWordValidator(),
  ),
];

Widget _app(PlaySessionArgs args) => ProviderScope(
  overrides: _overrides(),
  child: MaterialApp(home: PlaySessionScreen(args: args)),
);

const _level01 = PlaySessionArgs(
  source: PuzzleSource.journey,
  debugPuzzleId: 'smoke-tr-01',
);

/// Drag row 0 to the right — `A S A L M` → `M A S A L` (MASAL), a 1-move win.
Future<void> _solveRow0(WidgetTester tester) async {
  final box = tester.getRect(find.byType(PuzzleBoard));
  final start = Offset(
    box.left + box.width * 0.18,
    box.top + box.height * 0.12,
  );
  await tester.dragFrom(start, Offset(box.width * 0.6, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the target, board, and MOVES 0 (AC1)', (tester) async {
    await tester.pumpWidget(_app(_level01));
    await tester.pumpAndSettle();

    expect(find.text('HEDEF'), findsOneWidget);
    expect(find.text('HAMLE'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // MOVES
    expect(find.byType(PuzzleBoard), findsOneWidget);
    // The target rail shows the 5 letters of MASAL.
    expect(find.text('M'), findsWidgets);
  });

  testWidgets(
    'a legal swipe that forms the target → completion sheet (AC2/AC8)',
    (tester) async {
      await tester.pumpWidget(_app(_level01));
      await tester.pumpAndSettle();

      await _solveRow0(tester);

      expect(find.text('ÇÖZÜLDÜ'), findsOneWidget);
      expect(find.text('Yeniden'), findsOneWidget);
      expect(find.text('Kapat'), findsOneWidget);
      // MOVES ticked to 1 (HUD) — the sheet also shows a "1" stat, so scope it.
      expect(
        find.descendant(
          of: find.byType(CompletionSheet),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      // The formed word is shown in the sheet.
      expect(
        find.descendant(
          of: find.byType(CompletionSheet),
          matching: find.text('MASAL'),
        ),
        findsOneWidget,
      );
      // The back chevron is hidden in the won state.
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
    },
  );

  testWidgets('Retry from the completion sheet resets the board (AC7)', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_level01));
    await tester.pumpAndSettle();
    await _solveRow0(tester);
    expect(find.text('ÇÖZÜLDÜ'), findsOneWidget);

    await tester.tap(find.text('Yeniden'));
    await tester.pumpAndSettle();

    expect(find.text('ÇÖZÜLDÜ'), findsNothing);
    expect(find.text('0'), findsOneWidget); // MOVES reset
    expect(
      find.byIcon(Icons.chevron_left_rounded),
      findsOneWidget,
    ); // back is back
  });

  testWidgets('a sub-threshold tap does not change MOVES (AC4)', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_level01));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(PuzzleBoard));
    await tester.dragFrom(center, const Offset(6, 4));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('ÇÖZÜLDÜ'), findsNothing);
  });

  testWidgets('an unsupported source shows the load-error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PlaySessionArgs(source: PuzzleSource.daily)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bu bulmaca yüklenemedi'), findsOneWidget);
    expect(find.text('Geri'), findsOneWidget);
  });
}
