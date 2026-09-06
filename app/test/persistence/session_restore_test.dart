import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/content/puzzle_engine_config.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/session_restore.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// `ASALM` shifted right once → `MASAL` (target). optimalMoves 1.
Puzzle noTilesPuzzle() => Puzzle.fromJson(<String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 't',
  'id': 'journey-tr-1',
  'puzzleType': 'journey',
  'journeyLevelNumber': 1,
  'language': 'tr',
  'grid': <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  'targetWord': 'MASAL',
  'lockedCells': <String>[],
  'frozenCells': <String>[],
  'columnMovesEnabled': false,
  'optimalMoves': 1,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': <String, Object?>{'o': 1},
});

ActiveSessionSnapshot snapshot({
  required String puzzleId,
  required List<String> moves,
  ActiveSessionStatus status = ActiveSessionStatus.inProgress,
}) => ActiveSessionSnapshot(
  puzzleId: puzzleId,
  puzzleSource: PuzzleSource.journey,
  lang: 'tr',
  appliedMoves: moves,
  undosRemaining: 2,
  restartCount: 1,
  elapsedMsAccumulated: 41200,
  thawedFrozenCells: const <String>[],
  status: status,
  startedAtUtcMs: 1757145000000,
  lastPersistedAtUtcMs: 1757145041200,
);

void main() {
  const validator = NeverValidWordValidator();

  group('toEngineConfig', () {
    test('maps grid / target / flags', () {
      final config = toEngineConfig(noTilesPuzzle());
      expect(config.gridSize, 5);
      expect(config.targetWord, 'MASAL');
      expect(config.columnMovesEnabled, isFalse);
      expect(config.lockedCells, isEmpty);
      expect(config.frozenCells, isEmpty);
    });

    test('throws EngineConfigError on a structurally invalid puzzle', () {
      final bad = Puzzle.fromJson(<String, Object?>{
        'schemaVersion': 1,
        'contentVersion': 't',
        'id': 'x',
        'puzzleType': 'journey',
        'journeyLevelNumber': 1,
        'language': 'tr',
        'grid': <String>['ABC', 'DEF'], // not 5x5
        'targetWord': 'MASAL',
        'lockedCells': <String>[],
        'frozenCells': <String>[],
        'columnMovesEnabled': true,
        'optimalMoves': 1,
        'difficultyScore': 1,
        'difficultyLabel': 'easy',
        'difficultyBreakdown': <String, Object?>{'o': 1},
      });
      expect(() => toEngineConfig(bad), throwsA(isA<EngineConfigError>()));
    });
  });

  group('restoreSession', () {
    test('rebuilds the engine and replays applied moves', () {
      final restored = restoreSession(
        snapshot(puzzleId: 'journey-tr-1', moves: <String>['R0']),
        noTilesPuzzle(),
        validator,
      );
      expect(restored.engine.moveCount, 1);
      expect(restored.engine.isSolved, isTrue);
      expect(restored.undosRemaining, 2);
      expect(restored.restartCount, 1);
      expect(restored.timer.elapsedMs, 41200);
      expect(restored.puzzleSource, PuzzleSource.journey);
    });

    test('an unsolved partial session restores without winning', () {
      final restored = restoreSession(
        snapshot(puzzleId: 'journey-tr-1', moves: <String>['L0']),
        noTilesPuzzle(),
        validator,
      );
      expect(restored.engine.moveCount, 1);
      expect(restored.engine.isSolved, isFalse);
    });

    test('empty move list → fresh engine at t=0', () {
      final restored = restoreSession(
        snapshot(puzzleId: 'journey-tr-1', moves: const <String>[]),
        noTilesPuzzle(),
        validator,
      );
      expect(restored.engine.moveCount, 0);
      expect(restored.engine.isSolved, isFalse);
    });

    test('throws when the puzzle id does not match the snapshot', () {
      expect(
        () => restoreSession(
          snapshot(puzzleId: 'journey-tr-999', moves: <String>['R0']),
          noTilesPuzzle(),
          validator,
        ),
        throwsA(isA<SessionRestoreException>()),
      );
    });

    test('throws when a persisted move no longer applies', () {
      // Column move on a columns-disabled puzzle is rejected by the engine.
      expect(
        () => restoreSession(
          snapshot(puzzleId: 'journey-tr-1', moves: <String>['D0']),
          noTilesPuzzle(),
          validator,
        ),
        throwsA(isA<SessionRestoreException>()),
      );
    });
  });
}
