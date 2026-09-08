// F05-FE.UNLOCK — the win-path Journey unlock, end to end: solving a Journey
// level through the real `/play` screen drives `JourneyProgressRepo.markCompleted`
// against a real in-memory DB, and a Retry + re-solve stays idempotent
// (`architecture.md §7`).

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/engine/engine_providers.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/persistence/repositories/journey_progress_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_screen.dart';
import 'package:looplet_app/play/widgets/puzzle_board.dart';
import 'package:looplet_app/rating/completion_panel.dart';
import 'package:looplet_engine/looplet_engine.dart';

Map<String, Object?> _levelJson(
  int n, {
  required List<String> grid,
  int optimal = 1,
}) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'test',
  'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
  'puzzleType': 'journey',
  'journeyLevelNumber': n,
  'language': 'tr',
  'grid': grid,
  'targetWord': 'MASAL',
  'lockedCells': const <String>[],
  'frozenCells': const <String>[],
  'columnMovesEnabled': false,
  'optimalMoves': optimal,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': const <String, Object?>{},
};

Map<String, Object?> _manifestJson(int count) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'test',
  'lang': 'tr',
  'mode': 'smoke',
  'levels': <Map<String, Object?>>[
    for (var n = 1; n <= count; n++)
      <String, Object?>{
        'n': n,
        'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
        'asset': 'tr/journey-tr-${n.toString().padLeft(2, '0')}.json',
        'difficultyLabel': 'easy',
      },
  ],
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

// journey-tr-01 row 0 = A S A L M → one cell right = M A S A L (MASAL): a
// 1-move, optimal-1 (Perfect) win, mirroring the F03 smoke set.
final JourneyAssetSource _source = _MapAssetSource(<String, String>{
  'tr/journey_manifest_tr.json': jsonEncode(_manifestJson(3)),
  'tr/journey-tr-01.json': jsonEncode(
    _levelJson(
      1,
      grid: const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
    ),
  ),
});

Widget _app(AppDatabase db) => ProviderScope(
  overrides: <Override>[
    appDatabaseProvider.overrideWithValue(db),
    wordValidatorProvider.overrideWith(
      (ref) async => const NeverValidWordValidator(),
    ),
    journeyAssetSourceProvider.overrideWithValue(_source),
  ],
  child: const MaterialApp(
    home: PlaySessionScreen(
      args: PlaySessionArgs(source: PuzzleSource.journey, journeyLevel: 1),
    ),
  ),
);

Future<void> _solveRow0(WidgetTester tester) async {
  final box = tester.getRect(find.byType(PuzzleBoard));
  await tester.dragFrom(
    Offset(box.left + box.width * 0.18, box.top + box.height * 0.12),
    Offset(box.width * 0.6, 0),
  );
  await tester.pumpAndSettle();
}

void _phoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets(
    'solving a Journey level marks it complete and unlocks the next',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(_app(db));
      await tester.pumpAndSettle();
      expect(find.byType(PuzzleBoard), findsOneWidget);

      await _solveRow0(tester);
      expect(find.byType(CompletionPanel), findsOneWidget);

      final guestId = await PlayerRepo(db).currentGuestId();
      final row = await JourneyProgressRepo(db).read(guestId);
      expect(row.completedLevelsCsv.split(',').contains('1'), isTrue);
      expect(row.highestUnlockedLevel, 2);
    },
  );

  testWidgets(
    'Retry + re-solve is idempotent — progress does not double-count',
    (tester) async {
      _phoneSurface(tester);
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(_app(db));
      await tester.pumpAndSettle();

      await _solveRow0(tester);
      expect(find.byType(CompletionPanel), findsOneWidget);

      await tester.tap(find.text('Yeniden'));
      await tester.pumpAndSettle();
      expect(find.byType(CompletionPanel), findsNothing);

      await _solveRow0(tester);
      expect(find.byType(CompletionPanel), findsOneWidget);

      final guestId = await PlayerRepo(db).currentGuestId();
      final row = await JourneyProgressRepo(db).read(guestId);
      expect(
        row.completedLevelsCsv.split(',').where((s) => s == '1').length,
        1,
      );
      expect(row.highestUnlockedLevel, 2);
    },
  );
}
