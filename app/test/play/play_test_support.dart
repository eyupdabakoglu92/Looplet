// Shared helpers for the D1 Loop Glass Play widget tests (F03-FE-D1). Not a
// test suite itself — no `_test` suffix.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_providers.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// The canonical devices of the D1 evidence (ui-design §6).
const Size kIphone16 = Size(393, 852);
const Size kIphone16e = Size(390, 844);
const Size kIphone16ProMax = Size(440, 956);

/// The three canonical Play widths (390 / 393 / 440 pt).
const List<Size> kPlayDevices = <Size>[kIphone16e, kIphone16, kIphone16ProMax];

/// iOS content sizes as Flutter text scales — large (default), xL, xxL, the
/// 1.3× cap, xxxL, AX1, AX5 — plus two Android-style in-between steps
/// (F03-FE-D1R text sweep).
const List<double> kOsTextScales = <double>[
  1.0,
  1.059,
  1.118,
  1.176,
  1.235,
  1.3,
  1.353,
  1.647,
  3.118,
];

/// Loads the bundled Space Grotesk / Manrope so text metrics are real (widget
/// tests otherwise render the wide Ahem test font).
Future<void> loadAppFonts() async {
  for (final (family, asset) in <(String, String)>[
    ('SpaceGrotesk', 'assets/fonts/SpaceGrotesk.ttf'),
    ('Manrope', 'assets/fonts/Manrope.ttf'),
  ]) {
    final loader = FontLoader(family)..addFont(rootBundle.load(asset));
    await loader.load();
  }
}

/// A 5×5 test puzzle; the target `MASAL` is never formed unless the grid
/// says so.
Puzzle testPuzzle({
  required List<String> grid,
  String target = 'MASAL',
  Set<GridCoord> locked = const <GridCoord>{},
  Set<GridCoord> frozen = const <GridCoord>{},
  bool columns = true,
  String id = 'd1-test',
  int? level,
}) => Puzzle(
  schemaVersion: 1,
  contentVersion: 'test',
  id: id,
  puzzleType: PuzzleType.journey,
  journeyLevelNumber: level ?? 1,
  language: 'tr',
  grid: grid,
  targetWord: target,
  lockedCells: locked,
  frozenCells: frozen,
  columnMovesEnabled: columns,
  optimalMoves: 3,
  difficultyScore: 1,
  difficultyLabel: DifficultyLabel.easy,
  difficultyBreakdown: const <String, num>{},
);

/// Accepts exactly [words] (upper-case, as the grid spells them).
class SetWordValidator implements WordValidator {
  const SetWordValidator(this.words);

  final Set<String> words;

  @override
  bool isValidWord(String candidate, {int minLength = 1}) =>
      candidate.length >= minLength && words.contains(candidate);
}

/// Sizes the test view like a device (1 pt = 1 px) with its safe-area insets.
void setDevice(
  WidgetTester tester,
  Size size, {
  double top = 0,
  double bottom = 0,
  double textScale = 1,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
  tester.view.viewPadding = FakeViewPadding(top: top, bottom: bottom);
  addTearDown(tester.view.reset);
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
}

/// The Play screen for [puzzle] (setup provider overridden), inside a
/// `GoRouter` with a `/` home, so back / Home navigation is observable.
/// `/play` is pushed over `/` unless [direct].
Widget playApp({
  required AppDatabase db,
  required Puzzle? puzzle,
  PlaySessionArgs? args,
  WordValidator validator = const NeverValidWordValidator(),
  Future<PlaySessionSetup> Function()? setup,
  bool direct = false,
}) {
  final playArgs =
      args ??
      PlaySessionArgs(source: PuzzleSource.journey, debugPuzzleId: puzzle?.id);
  final router = GoRouter(
    initialLocation: direct ? '/play' : '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/play'),
              child: const Text('HOME'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/play',
        builder: (context, state) => PlaySessionScreen(args: playArgs),
      ),
    ],
  );
  return ProviderScope(
    overrides: <Override>[
      appDatabaseProvider.overrideWithValue(db),
      wordValidatorProvider.overrideWith((ref) async => validator),
      if (setup != null)
        playSessionSetupProvider.overrideWith((ref, args) => setup())
      else if (puzzle != null)
        playSessionSetupProvider.overrideWith(
          (ref, args) async =>
              PlaySessionSetup(puzzle: puzzle, validator: validator),
        ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Pumps [playApp], opens `/play` from Home (unless [direct]) and settles.
Future<AppDatabase> bootPlay(
  WidgetTester tester, {
  Puzzle? puzzle,
  PlaySessionArgs? args,
  WordValidator validator = const NeverValidWordValidator(),
  bool direct = false,
  bool settle = true,
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    playApp(
      db: db,
      puzzle: puzzle,
      args: args,
      validator: validator,
      direct: direct,
    ),
  );
  await tester.pump();
  if (!direct) {
    await tester.tap(find.text('HOME'));
  }
  if (settle) await tester.pumpAndSettle();
  return db;
}

/// Global centre of board cell (row, col).
Offset cellCenter(WidgetTester tester, int row, int col) {
  final box = tester.getRect(find.byType(PuzzleBoard));
  return box.topLeft + BoardGeometry.forWidth(box.width).cellCenter(row, col);
}

/// The HAMLE value — the only bare integer on the playing stage.
int movesShown(WidgetTester tester) {
  for (var n = 0; n <= 99; n++) {
    if (find.text('$n').evaluate().isNotEmpty) return n;
  }
  return -1;
}
