import 'package:looplet_content/looplet_content.dart';

/// Temporary in-app puzzle source for the **debug** play entry only
/// (`architecture.md` §4). F05 (Journey) replaces this with real bundled-content
/// resolution and F07 (Daily) with the daily cache; this file is deleted then.
///
/// The maps below are verbatim copies of the F06 smoke set
/// (`content/smoke/tr/level0{1,2,4,5,6}.json`) — the source of truth. They cover
/// every tile state F03 must render: no-column (`01`,`02`), column-enabled
/// (`04`), a locked pivot (`05`), a frozen tile (`06`), and quick 1–2 move wins
/// for exercising the completion sequence.
class DebugPuzzleLibrary {
  const DebugPuzzleLibrary();

  static const String defaultPuzzleId = 'smoke-tr-01';

  /// Ordered ids for the debug chip row on the placeholder home.
  static const List<String> ids = <String>[
    'smoke-tr-01',
    'smoke-tr-02',
    'smoke-tr-04',
    'smoke-tr-05',
    'smoke-tr-06',
  ];

  /// Parses the requested puzzle. Throws [PuzzleFormatException] /
  /// [ArgumentError] for an unknown id — surfaced as the debug load-error state.
  Puzzle load(String puzzleId) {
    final json = _byId[puzzleId];
    if (json == null) {
      throw ArgumentError.value(puzzleId, 'puzzleId', 'unknown debug puzzle');
    }
    return Puzzle.fromJson(json);
  }

  static const Map<String, Map<String, Object?>> _byId =
      <String, Map<String, Object?>>{
        'smoke-tr-01': <String, Object?>{
          'schemaVersion': 1,
          'contentVersion': '2026.09-smoke',
          'id': 'smoke-tr-01',
          'puzzleType': 'journey',
          'journeyLevelNumber': 1,
          'language': 'tr',
          'grid': <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          'targetWord': 'MASAL',
          'lockedCells': <String>[],
          'frozenCells': <String>[],
          'columnMovesEnabled': false,
          'optimalMoves': 1,
          'difficultyScore': 0.813,
          'difficultyLabel': 'easy',
          'difficultyBreakdown': <String, Object?>{
            'o': 1,
            'cNorm': 0.0,
            'tdDegree': 0,
            'locked': 0,
            'frozen': 0,
            'firstMoves': 1,
            'distinctOptimalSolutions': 1,
          },
        },
        'smoke-tr-02': <String, Object?>{
          'schemaVersion': 1,
          'contentVersion': '2026.09-smoke',
          'id': 'smoke-tr-02',
          'puzzleType': 'journey',
          'journeyLevelNumber': 2,
          'language': 'tr',
          'grid': <String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          'targetWord': 'MASAL',
          'lockedCells': <String>[],
          'frozenCells': <String>[],
          'columnMovesEnabled': false,
          'optimalMoves': 2,
          'difficultyScore': 3.813,
          'difficultyLabel': 'easy',
          'difficultyBreakdown': <String, Object?>{
            'o': 2,
            'cNorm': 0.0,
            'tdDegree': 1,
            'locked': 0,
            'frozen': 0,
            'firstMoves': 1,
            'distinctOptimalSolutions': 1,
          },
        },
        'smoke-tr-04': <String, Object?>{
          'schemaVersion': 1,
          'contentVersion': '2026.09-smoke',
          'id': 'smoke-tr-04',
          'puzzleType': 'journey',
          'journeyLevelNumber': 4,
          'language': 'tr',
          'grid': <String>['DABCF', 'XENİZ', 'HJKLN', 'PRTUV', 'YZBCD'],
          'targetWord': 'DENİZ',
          'lockedCells': <String>[],
          'frozenCells': <String>[],
          'columnMovesEnabled': true,
          'optimalMoves': 1,
          'difficultyScore': 0.813,
          'difficultyLabel': 'easy',
          'difficultyBreakdown': <String, Object?>{
            'o': 1,
            'cNorm': 0.0,
            'tdDegree': 0,
            'locked': 0,
            'frozen': 0,
            'firstMoves': 1,
            'distinctOptimalSolutions': 1,
          },
        },
        'smoke-tr-05': <String, Object?>{
          'schemaVersion': 1,
          'contentVersion': '2026.09-smoke',
          'id': 'smoke-tr-05',
          'puzzleType': 'journey',
          'journeyLevelNumber': 5,
          'language': 'tr',
          'grid': <String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          'targetWord': 'MASAL',
          'lockedCells': <String>['3,3'],
          'frozenCells': <String>[],
          'columnMovesEnabled': true,
          'optimalMoves': 2,
          'difficultyScore': 4.612,
          'difficultyLabel': 'medium',
          'difficultyBreakdown': <String, Object?>{
            'o': 2,
            'cNorm': 0.0,
            'tdDegree': 1,
            'locked': 1,
            'frozen': 0,
            'firstMoves': 1,
            'distinctOptimalSolutions': 1,
          },
        },
        'smoke-tr-06': <String, Object?>{
          'schemaVersion': 1,
          'contentVersion': '2026.09-smoke',
          'id': 'smoke-tr-06',
          'puzzleType': 'journey',
          'journeyLevelNumber': 6,
          'language': 'tr',
          'grid': <String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
          'targetWord': 'MASAL',
          'lockedCells': <String>[],
          'frozenCells': <String>['2,2'],
          'columnMovesEnabled': true,
          'optimalMoves': 1,
          'difficultyScore': 2.013,
          'difficultyLabel': 'easy',
          'difficultyBreakdown': <String, Object?>{
            'o': 1,
            'cNorm': 0.0,
            'tdDegree': 0,
            'locked': 0,
            'frozen': 1,
            'firstMoves': 1,
            'distinctOptimalSolutions': 1,
          },
        },
      };
}
