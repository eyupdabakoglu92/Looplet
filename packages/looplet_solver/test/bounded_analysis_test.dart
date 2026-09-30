import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

void main() {
  final puzzle = EngineConfig(initialGrid: [
    ['b', 'a'],
    ['c', 'd']
  ], targetWord: 'ab');
  const words = NeverValidWordValidator();
  test('invalid resource limits are rejected before even trivial success', () {
    expect(
        () => Solver.solve(puzzle, words,
            budget: const SearchBudget(maxNodes: 0)),
        throwsArgumentError);
    expect(
        () => Solver.solve(puzzle, words,
            budget: const SearchBudget(timeBudget: Duration.zero)),
        throwsArgumentError);
  });
  test('enumeration resource exhaustion is not an empty complete solution set',
      () {
    expect(
        () => Solver.enumerateOptimalSolutionsWithCoverage(puzzle, words,
            budget: const SearchBudget(maxNodes: 1)),
        throwsA(isA<SearchLimitExceeded>()));
  });
  test('scorer propagates UNKNOWN, never partial difficulty', () {
    expect(
        () => DifficultyScorer.score(puzzle, words,
            budget: const SearchBudget(maxNodes: 1)),
        throwsA(isA<SearchLimitExceeded>()));
  });
  test('cap reports truncation; a full set reports completeness', () {
    final truncated =
        Solver.enumerateOptimalSolutionsWithCoverage(puzzle, words, cap: 1);
    expect(truncated.sequences, hasLength(1));
    expect(
        truncated.complete, false); // Left and right both solve a two-cell row.
    final all =
        Solver.enumerateOptimalSolutionsWithCoverage(puzzle, words, cap: 2);
    expect(all.sequences, hasLength(2));
    expect(all.complete, true);
  });
  test('nonpositive enumeration cap is an argument error', () {
    expect(
        () =>
            Solver.enumerateOptimalSolutionsWithCoverage(puzzle, words, cap: 0),
        throwsArgumentError);
  });
  test('scorer labels its sampled enumeration explicitly', () {
    final score = DifficultyScorer.score(puzzle, words, optimalSolutionCap: 1);
    expect(score.breakdown['optimalEnumerationComplete'], 0);
    expect(
        DifficultyScorer.score(puzzle, words)
            .breakdown['optimalEnumerationComplete'],
        1);
  });
}
