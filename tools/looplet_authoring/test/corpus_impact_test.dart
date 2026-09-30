import 'package:looplet_authoring/src/corpus_impact.dart';
import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

void main() {
  final puzzle = Puzzle(
      schemaVersion: 1,
      contentVersion: 'test',
      id: 'journey-test',
      puzzleType: PuzzleType.journey,
      journeyLevelNumber: 1,
      language: 'tr',
      grid: const ['asalm', 'bcdfg', 'hjkln', 'prtuv', 'yzbcd'],
      targetWord: 'masal',
      lockedCells: {},
      frozenCells: {},
      columnMovesEnabled: true,
      optimalMoves: 1,
      difficultyScore: 0,
      difficultyLabel: DifficultyLabel.easy,
      difficultyBreakdown: const {});
  final words = CorpusWords({'words': <String>[], 'targets': <String>[]});

  test('identical corpora produce no solve/score impact', () {
    final result = analyzePuzzleImpact(
        puzzle, words, words, const SearchBudget(maxDepth: 3));
    expect(result['storedOptimalMatchesBaseline'], true);
    expect(result['requiresReexport'], false);
    expect((result['baseline'] as Map)['status'], 'PASS');
    expect((result['candidate'] as Map)['status'], 'PASS');
  });

  test('budget exhaustion stays UNKNOWN and cannot look promotion-ready', () {
    final result = analyzePuzzleImpact(
        puzzle, words, words, const SearchBudget(maxDepth: 3, maxNodes: 1));
    expect((result['baseline'] as Map)['status'], 'UNKNOWN');
    expect((result['candidate'] as Map)['status'], 'UNKNOWN');
    expect(result['storedOptimalMatchesBaseline'], false);
    expect(result['requiresReexport'], false);
  });
}
