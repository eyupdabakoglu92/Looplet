import 'dart:collection';

import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

import 'solve_result.dart';
import 'solver.dart';

/// Weights for the difficulty score. `const` defaults; override from the CLI
/// (via a small JSON) to recalibrate without a code change. The score formula
/// shape is fixed by the F06 contract; only these numbers are tunable.
final class DifficultyWeights {
  const DifficultyWeights({
    this.optimal = 1.0,
    this.correctLooking = 3.0,
    this.tempDisplacement = 2.0,
    this.locked = 0.8,
    this.frozen = 1.2,
    this.routes = 1.5,
  });

  final double optimal;
  final double correctLooking;
  final double tempDisplacement;
  final double locked;
  final double frozen;
  final double routes;
}

/// Score → label cut points. `[easy) [medium) [hard) [expert]`.
final class DifficultyThresholds {
  const DifficultyThresholds({
    this.easyMax = 4.0,
    this.mediumMax = 8.0,
    this.hardMax = 13.0,
  });

  final double easyMax;
  final double mediumMax;
  final double hardMax;
}

/// A computed difficulty.
final class Difficulty {
  const Difficulty({
    required this.score,
    required this.label,
    required this.breakdown,
  });

  final double score;
  final DifficultyLabel label;
  final Map<String, num> breakdown;
}

/// Deterministic difficulty scoring from the solver's search tree.
/// Definitions per `ai-system/features/f06-.../architecture.md` "Difficulty Score".
abstract final class DifficultyScorer {
  static Difficulty score(
    EngineConfig config,
    WordValidator validator, {
    DifficultyWeights weights = const DifficultyWeights(),
    DifficultyThresholds thresholds = const DifficultyThresholds(),
    int optimalSolutionCap = 1000,
  }) {
    final result = Solver.solve(config, validator);
    if (result is! Optimal) {
      throw ArgumentError(
        'DifficultyScorer needs a solvable puzzle; solve() returned $result',
      );
    }

    final o = result.moves;
    final lockedCount = config.lockedCells.length;
    final frozenCount = config.frozenCells.length;
    final solutions = Solver.enumerateOptimalSolutions(
      config,
      validator,
      cap: optimalSolutionCap,
    );

    final cNorm = _correctLookingNorm(config, validator, o);
    final tdDegree = _tempDisplacementDegree(config, validator, solutions);
    final firstMoves =
        solutions.where((s) => s.isNotEmpty).map((s) => s.first).toSet().length;
    final distinctOptimal = solutions.length; // ≤ cap

    final routeTerm = (firstMoves < 8 ? firstMoves : 8) / 8.0;
    final score = weights.optimal * o +
        weights.correctLooking * cNorm +
        weights.tempDisplacement * tdDegree +
        weights.locked * lockedCount +
        weights.frozen * frozenCount -
        weights.routes * routeTerm;

    return Difficulty(
      score: score,
      label: _labelFor(score, thresholds),
      breakdown: <String, num>{
        'o': o,
        'cNorm': double.parse(cNorm.toStringAsFixed(4)),
        'tdDegree': tdDegree,
        'locked': lockedCount,
        'frozen': frozenCount,
        'firstMoves': firstMoves,
        'distinctOptimalSolutions': distinctOptimal,
      },
    );
  }

  static DifficultyLabel _labelFor(double score, DifficultyThresholds t) {
    if (score < t.easyMax) return DifficultyLabel.easy;
    if (score < t.mediumMax) return DifficultyLabel.medium;
    if (score < t.hardMax) return DifficultyLabel.hard;
    return DifficultyLabel.expert;
  }

  /// Distinct states at BFS depth `0 < d < o` where some row has ≥ 3 target
  /// letters correctly placed but the puzzle is not solved, over the count of
  /// distinct states within depth `o`.
  static double _correctLookingNorm(
    EngineConfig config,
    WordValidator validator,
    int optimal,
  ) {
    if (optimal <= 1) return 0;
    final target = _targetChars(config);
    final start = GridState.initial(config, validator);
    final dist = <String, int>{start.canonicalKey(): 0};
    final queue = Queue<GridState>()..add(start);
    var correctLooking = 0;
    var totalWithinOptimal = 1; // the start state

    while (queue.isNotEmpty) {
      final state = queue.removeFirst();
      final depth = dist[state.canonicalKey()]!;
      if (depth == optimal) continue;
      for (final move in config.legalMoves(state)) {
        final step = state.applyMove(move, config, validator);
        if (!step.applied) continue;
        final key = step.state.canonicalKey();
        if (dist.containsKey(key)) continue;
        dist[key] = depth + 1;
        totalWithinOptimal++;
        if (depth + 1 < optimal && _looksClose(target, step.state)) {
          correctLooking++;
        }
        queue.add(step.state);
      }
    }
    return correctLooking / totalWithinOptimal;
  }

  /// For each optimal solution, count the steps where the best row's correct
  /// count decreases; return the minimum over solutions (0 if none).
  static int _tempDisplacementDegree(
    EngineConfig config,
    WordValidator validator,
    List<List<Move>> solutions,
  ) {
    if (solutions.isEmpty) return 0;
    final target = _targetChars(config);
    var minDecreases = 1 << 30;
    for (final solution in solutions) {
      var state = GridState.initial(config, validator);
      var previous = _maxCorrect(target, state);
      var decreases = 0;
      for (final move in solution) {
        state = state.applyMove(move, config, validator).state;
        final current = _maxCorrect(target, state);
        if (current < previous) decreases++;
        previous = current;
      }
      if (decreases < minDecreases) minDecreases = decreases;
    }
    return minDecreases;
  }

  static List<String> _targetChars(EngineConfig config) => <String>[
        for (final rune in config.targetWord.runes)
          TurkishCase.toLowerTr(String.fromCharCode(rune)),
      ];

  static bool _looksClose(List<String> target, GridState state) {
    if (state.isSolved) return false;
    for (final row in state.letters) {
      if (_correctInRow(target, row) >= 3) return true;
    }
    return false;
  }

  static int _maxCorrect(List<String> target, GridState state) {
    var best = 0;
    for (final row in state.letters) {
      final count = _correctInRow(target, row);
      if (count > best) best = count;
    }
    return best;
  }

  static int _correctInRow(List<String> target, List<String> row) {
    var count = 0;
    final n = target.length < row.length ? target.length : row.length;
    for (var c = 0; c < n; c++) {
      if (TurkishCase.toLowerTr(row[c]) == target[c]) count++;
    }
    return count;
  }
}
