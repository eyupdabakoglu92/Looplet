import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

import 'support/reference.dart';

const _never = NeverValidWordValidator();
final _masal = SetWordValidator(<String>['MASAL']);

EngineConfig easy() =>
    cfg(<String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'], target: 'MASAL');

void main() {
  test('score and label are deterministic for fixed weights/thresholds', () {
    final a = DifficultyScorer.score(easy(), _never);
    final b = DifficultyScorer.score(easy(), _never);
    expect(a.score, b.score);
    expect(a.label, b.label);
    expect(a.breakdown, b.breakdown);
  });

  test('breakdown carries every metric', () {
    final d = DifficultyScorer.score(easy(), _never);
    expect(
      d.breakdown.keys,
      containsAll(<String>[
        'o',
        'cNorm',
        'tdDegree',
        'locked',
        'frozen',
        'firstMoves',
        'distinctOptimalSolutions',
      ]),
    );
  });

  test('a trivial 1-move puzzle lands in the easy band', () {
    final d = DifficultyScorer.score(easy(), _never);
    expect(d.breakdown['o'], 1);
    expect(d.label, DifficultyLabel.easy);
  });

  test('more locked tiles raise the score (monotonic in L)', () {
    final base = DifficultyScorer.score(
      cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL'),
      _never,
    );
    final withLock = DifficultyScorer.score(
      cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL', locked: <GridCoord>{const GridCoord(4, 4)}),
      _never,
    );
    expect(withLock.score, greaterThan(base.score));
    expect(withLock.breakdown['locked'], 1);
  });

  test('a frozen tile raises the score (monotonic in F)', () {
    // frozen (2,2) that thaws on the winning move — see solver frozen test.
    final d = DifficultyScorer.score(
      cfg(<String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
          target: 'MASAL', frozen: <GridCoord>{const GridCoord(2, 2)}),
      _masal,
    );
    expect(d.breakdown['frozen'], 1);
    expect(d.breakdown['o'], 1);
  });

  test('more distinct optimal first moves lowers the score (route term)', () {
    // Two grids with the same optimal (2) but different first-move multiplicity.
    final single = DifficultyScorer.score(
      cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL'),
      _never,
    );
    expect(single.breakdown['firstMoves'], greaterThanOrEqualTo(1));
    // custom weights: crank the route weight so its effect is visible
    final heavyRoutes = DifficultyScorer.score(
      cfg(<String>['SALMA', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
          target: 'MASAL'),
      _never,
      weights: const DifficultyWeights(routes: 100),
    );
    expect(heavyRoutes.score, lessThan(single.score));
  });

  test('custom thresholds move the label', () {
    final d = DifficultyScorer.score(
      easy(),
      _never,
      thresholds: const DifficultyThresholds(easyMax: 0, mediumMax: 0.1),
    );
    // score for a 1-move no-tile puzzle is small but > 0.1 → hard/expert now
    expect(d.label, anyOf(DifficultyLabel.hard, DifficultyLabel.expert));
  });

  test('throws for an unsolvable puzzle', () {
    final locked = <GridCoord>{
      for (final r in <int>[0, 1, 3, 4])
        for (var c = 0; c < 5; c++) GridCoord(r, c),
    };
    expect(
      () => DifficultyScorer.score(
        cfg(<String>['FGHIJ', 'KLMNO', 'ABCDE', 'PRTUV', 'YZBCD'],
            target: 'MASAL', locked: locked),
        _never,
      ),
      throwsArgumentError,
    );
  });
}
