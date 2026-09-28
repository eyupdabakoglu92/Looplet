// F05-QA-1 — AC12: the `Next Level` ("Sonraki bölüm") CTA on the full-screen
// result (F03 architecture §20)
// must actually navigate — `pushReplacement` to level N+1's `/play` (no
// back-stack growth), or `context.go('/')` → the terminal home when there is no
// next level. Exercised through a real `GoRouter` + `PlaySessionScreen`, not the
// pure `nextJourneyLevel` routing fn (`architecture.md §8` / §15).

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/play/widgets/result_view.dart';
import 'package:looplet_engine/looplet_engine.dart';

// journey-tr-0N: row 0 = A S A L M → one cell right = M A S A L (MASAL), an
// optimal-1 (Perfect / 3★) win — so "Sonraki bölüm" is the primary lime pill.
Map<String, Object?> _level(int n) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'nav-test',
  'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
  'puzzleType': 'journey',
  'journeyLevelNumber': n,
  'language': 'tr',
  'grid': const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  'targetWord': 'MASAL',
  'lockedCells': const <String>[],
  'frozenCells': const <String>[],
  'columnMovesEnabled': false,
  'optimalMoves': 1,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': const <String, Object?>{},
};

class _MapAssetSource implements JourneyAssetSource {
  _MapAssetSource(this._files);
  final Map<String, String> _files;
  @override
  Future<String> readString(String assetKey) async {
    final v = _files[assetKey];
    if (v == null) throw StateError('missing asset "$assetKey"');
    return v;
  }
}

// A 2-level interim manifest — level 2 is the LAST available level.
final JourneyAssetSource _source = _MapAssetSource(<String, String>{
  'tr/journey_manifest_tr.json': jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'contentVersion': 'nav-test',
    'lang': 'tr',
    'mode': 'smoke',
    'levels': <Map<String, Object?>>[
      for (var n = 1; n <= 2; n++)
        <String, Object?>{
          'n': n,
          'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
          'asset': 'tr/journey-tr-${n.toString().padLeft(2, '0')}.json',
          'difficultyLabel': 'easy',
        },
    ],
  }),
  'tr/journey-tr-01.json': jsonEncode(_level(1)),
  'tr/journey-tr-02.json': jsonEncode(_level(2)),
});

late GoRouter _router;
final List<int?> _routeLog = <int?>[];

Widget _app(AppDatabase db) {
  _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HOME ROUTE'))),
      ),
      GoRoute(
        path: '/play',
        builder: (context, state) {
          final args =
              state.extra as PlaySessionArgs? ??
              const PlaySessionArgs(
                source: PuzzleSource.journey,
                journeyLevel: 1,
              );
          _routeLog.add(args.journeyLevel);
          return PlaySessionScreen(args: args);
        },
      ),
    ],
  );
  return ProviderScope(
    overrides: <Override>[
      appDatabaseProvider.overrideWithValue(db),
      wordValidatorProvider.overrideWith(
        (ref) async => const NeverValidWordValidator(),
      ),
      journeyAssetSourceProvider.overrideWithValue(_source),
    ],
    child: MaterialApp.router(routerConfig: _router),
  );
}

Future<void> _solveRow0(WidgetTester tester) async {
  final box = tester.getRect(find.byType(PuzzleBoard));
  await tester.dragFrom(
    Offset(box.left + box.width * 0.18, box.top + box.height * 0.12),
    Offset(box.width * 0.6, 0),
  );
  await tester.pumpAndSettle();
}

Future<void> _openLevel(WidgetTester tester, AppDatabase db, int level) async {
  await tester.pumpWidget(_app(db));
  await tester.pumpAndSettle();
  _router.go(
    '/play',
    extra: PlaySessionArgs(source: PuzzleSource.journey, journeyLevel: level),
  );
  await tester.pumpAndSettle();
  expect(find.byType(PuzzleBoard), findsOneWidget);
}

void _phoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(_routeLog.clear);

  testWidgets(
    'Sonraki bölüm on level N (N+1 present) → level N+1 via pushReplacement, '
    'no back-stack growth',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _openLevel(tester, db, 1);
      await _solveRow0(tester);
      expect(find.byType(ResultView), findsOneWidget);
      expect(
        find.text('Sonraki bölüm'),
        findsOneWidget,
      ); // primary lime pill at 3★

      await tester.tap(find.text('Sonraki bölüm'));
      await tester.pumpAndSettle();

      expect(_routeLog, <int?>[1, 2]); // opened level 1, then replaced with 2
      expect(find.byType(PuzzleBoard), findsOneWidget); // on level 2's /play
      expect(find.byType(ResultView), findsNothing); // a fresh session
      // `pushReplacement`, not `push` — the /play frame was swapped, not stacked.
      expect(
        GoRouter.of(tester.element(find.byType(PuzzleBoard))).canPop(),
        isFalse,
      );
    },
  );

  testWidgets(
    'Sonraki bölüm on the last available level → context.go(/) → terminal '
    'home',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _openLevel(
        tester,
        db,
        2,
      ); // level 2 = last available in the manifest
      await _solveRow0(tester);
      expect(find.byType(ResultView), findsOneWidget);

      await tester.tap(find.text('Sonraki bölüm'));
      await tester.pumpAndSettle();

      expect(find.text('HOME ROUTE'), findsOneWidget);
      expect(find.byType(PuzzleBoard), findsNothing);
      expect(find.byType(ResultView), findsNothing);
      expect(_routeLog, <int?>[2]); // never navigated to a level 3
    },
  );
}
