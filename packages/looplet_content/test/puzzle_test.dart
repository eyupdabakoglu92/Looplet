import 'dart:convert';

import 'package:looplet_content/looplet_content.dart';
import 'package:test/test.dart';

Map<String, Object?> validJson({Map<String, Object?> overrides = const {}}) =>
    <String, Object?>{
      'schemaVersion': 1,
      'contentVersion': '2026.09-a',
      'id': 'journey-tr-14',
      'puzzleType': 'journey',
      'journeyLevelNumber': 14,
      'language': 'tr',
      'grid': <String>['KAMEL', 'SİRAT', 'DONUK', 'BEYAZ', 'TAŞIT'],
      'targetWord': 'MASAL',
      'lockedCells': <String>['0,0', '2,3'],
      'frozenCells': <String>['4,4'],
      'columnMovesEnabled': true,
      'optimalMoves': 7,
      'difficultyScore': 9.4,
      'difficultyLabel': 'hard',
      'difficultyBreakdown': <String, Object?>{
        'o': 7,
        'cNorm': 0.31,
        'locked': 2
      },
      ...overrides,
    };

void main() {
  test('round-trips losslessly through JSON', () {
    final original = Puzzle.fromJson(validJson());
    final again = Puzzle.fromJson(
      jsonDecode(jsonEncode(original.toJson())) as Map<String, Object?>,
    );

    expect(again.schemaVersion, original.schemaVersion);
    expect(again.contentVersion, original.contentVersion);
    expect(again.id, original.id);
    expect(again.puzzleType, PuzzleType.journey);
    expect(again.journeyLevelNumber, 14);
    expect(again.dailyDate, isNull);
    expect(again.language, 'tr');
    expect(again.grid, original.grid);
    expect(again.targetWord, 'MASAL');
    expect(again.lockedCells, original.lockedCells);
    expect(again.frozenCells, <GridCoord>{const GridCoord(4, 4)});
    expect(again.columnMovesEnabled, isTrue);
    expect(again.optimalMoves, 7);
    expect(again.difficultyScore, 9.4);
    expect(again.difficultyLabel, DifficultyLabel.hard);
    expect(again.difficultyBreakdown, original.difficultyBreakdown);
  });

  test('a daily puzzle carries dailyDate, not journeyLevelNumber', () {
    final p = Puzzle.fromJson(validJson(overrides: <String, Object?>{
      'puzzleType': 'daily',
      'id': 'daily-tr-2026-09-14',
      'dailyDate': '2026-09-14',
      'journeyLevelNumber': null,
    }));
    expect(p.puzzleType, PuzzleType.daily);
    expect(p.dailyDate, '2026-09-14');
    expect(p.journeyLevelNumber, isNull);
    expect(p.toJson().containsKey('journeyLevelNumber'), isFalse);
  });

  test('ignores unknown keys', () {
    final p = Puzzle.fromJson(validJson(overrides: <String, Object?>{
      '_note': 'authored 2026-09-05',
      'futureField': 42,
    }));
    expect(p.id, 'journey-tr-14');
  });

  group('rejects malformed input', () {
    void expectRejects(Map<String, Object?> json, {String? because}) {
      expect(() => Puzzle.fromJson(json), throwsA(isA<PuzzleFormatException>()),
          reason: because);
    }

    test('missing optimalMoves', () {
      final j = validJson()..remove('optimalMoves');
      expectRejects(j);
    });
    test('null optimalMoves', () {
      expectRejects(
          validJson(overrides: <String, Object?>{'optimalMoves': null}));
    });
    test('optimalMoves not an int', () {
      expectRejects(
          validJson(overrides: <String, Object?>{'optimalMoves': '7'}));
    });
    test('unsupported schemaVersion', () {
      expectRejects(
          validJson(overrides: <String, Object?>{'schemaVersion': 2}));
    });
    test('missing grid', () {
      final j = validJson()..remove('grid');
      expectRejects(j);
    });
    test('missing targetWord', () {
      final j = validJson()..remove('targetWord');
      expectRejects(j);
    });
    test('unknown puzzleType', () {
      expectRejects(
          validJson(overrides: <String, Object?>{'puzzleType': 'weekly'}));
    });
    test('unknown difficultyLabel', () {
      expectRejects(
          validJson(overrides: <String, Object?>{'difficultyLabel': 'brutal'}));
    });
    test('unsupported language', () {
      expectRejects(validJson(overrides: <String, Object?>{'language': 'de'}));
    });
    test('malformed coordinate', () {
      expectRejects(validJson(overrides: <String, Object?>{
        'lockedCells': <String>['0-0']
      }));
      expectRejects(validJson(overrides: <String, Object?>{
        'frozenCells': <String>['x,1']
      }));
      expectRejects(validJson(overrides: <String, Object?>{
        'frozenCells': <String>['-1,0']
      }));
    });
    test('journey without journeyLevelNumber', () {
      final j = validJson()..remove('journeyLevelNumber');
      expectRejects(j);
    });
    test('daily without dailyDate', () {
      expectRejects(validJson(overrides: <String, Object?>{
        'puzzleType': 'daily',
        'journeyLevelNumber': null,
      }));
    });
    test('difficultyBreakdown not an object', () {
      expectRejects(
          validJson(overrides: <String, Object?>{'difficultyBreakdown': 5}));
    });
  });

  test('exposed collections are unmodifiable', () {
    final p = Puzzle.fromJson(validJson());
    expect(() => p.grid.add('XXXXX'), throwsUnsupportedError);
    expect(
        () => p.lockedCells.add(const GridCoord(1, 1)), throwsUnsupportedError);
    expect(() => p.difficultyBreakdown['x'] = 1, throwsUnsupportedError);
  });
}
