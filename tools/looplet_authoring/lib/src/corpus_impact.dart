import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:path/path.dart' as p;

import 'corpus_quality.dart';
import 'quality_io.dart';

EngineConfig _config(Puzzle puzzle) => EngineConfig(
      initialGrid: [for (final row in puzzle.grid) row.split('')],
      targetWord: puzzle.targetWord,
      lockedCells: puzzle.lockedCells,
      frozenCells: puzzle.frozenCells,
      columnMovesEnabled: puzzle.columnMovesEnabled,
    );

Map<String, dynamic> _measure(
    EngineConfig config, CorpusWords words, SearchBudget budget) {
  final solved = Solver.solve(config, words, budget: budget);
  if (solved is BudgetExceeded) return {'status': 'UNKNOWN'};
  if (solved is Unsolvable) return {'status': 'UNSOLVABLE'};
  try {
    final difficulty = DifficultyScorer.score(config, words, budget: budget);
    return {
      'status': 'PASS',
      'optimalMoves': (solved as Optimal).moves,
      'difficultyScore': double.parse(difficulty.score.toStringAsFixed(3)),
      'difficultyLabel': difficulty.label.name,
      'difficultyBreakdown': difficulty.breakdown,
    };
  } on SearchLimitExceeded {
    return {'status': 'UNKNOWN'};
  }
}

Map<String, dynamic> analyzePuzzleImpact(Puzzle puzzle, CorpusWords baseline,
    CorpusWords candidate, SearchBudget budget) {
  final config = _config(puzzle);
  final before = _measure(config, baseline, budget);
  // The dictionary is consulted only by frozen-cell thaw checks. With no
  // frozen cells, replay/search/score are byte-for-byte corpus-independent.
  final after = config.frozenCells.isEmpty
      ? Map<String, dynamic>.of(before)
      : _measure(config, candidate, budget);
  final comparable = before['status'] == 'PASS' && after['status'] == 'PASS';
  final changed = comparable &&
      (before['optimalMoves'] != after['optimalMoves'] ||
          before['difficultyScore'] != after['difficultyScore'] ||
          before['difficultyLabel'] != after['difficultyLabel'] ||
          !jsonEquivalent(
              before['difficultyBreakdown'], after['difficultyBreakdown']));
  return {
    'id': puzzle.id,
    'puzzleType': puzzle.puzzleType.name,
    'baseline': before,
    'candidate': after,
    'storedOptimalMatchesBaseline': before['status'] == 'PASS' &&
        before['optimalMoves'] == puzzle.optimalMoves,
    'requiresReexport': changed,
  };
}

Map<String, dynamic> auditCorpusImpact({
  required String repoRoot,
  required String baselineAsset,
  required String candidateAsset,
  required SearchBudget budget,
  void Function(String)? progress,
}) {
  final candidateJson = readObject(candidateAsset);
  final errors = <String>[
    for (final error in auditCorpus(
        '$repoRoot/tools/looplet_authoring/data/tr', candidateJson))
      'candidate corpus: $error'
  ];
  final baseline = CorpusWords(readObject(baselineAsset));
  final candidate = CorpusWords(candidateJson);
  final contentFiles = <String, String>{};
  final impacts = <Map<String, dynamic>>[];
  for (final directory in [
    'content/journey/tr',
    'content/smoke/tr',
    'content/daily/tr/pool'
  ]) {
    for (final file in jsonFiles('$repoRoot/$directory')) {
      final raw = readObject(file.path);
      if (raw['puzzleType'] == null) continue;
      final relative = p.relative(file.path, from: repoRoot);
      contentFiles[relative] = fileHash(file.path);
      try {
        final impact = analyzePuzzleImpact(
            Puzzle.fromJson(raw), baseline, candidate, budget);
        impact['path'] = relative;
        impacts.add(impact);
        if (impact['storedOptimalMatchesBaseline'] != true) {
          errors.add('$relative: stored optimum differs from current corpus');
        }
        if (jsonValue(impact, 'baseline.status') != 'PASS' ||
            jsonValue(impact, 'candidate.status') != 'PASS') {
          errors.add(
              '$relative: solve/score incomplete under baseline/candidate');
        }
        progress?.call(
            '${impact['id']}: ${impact['requiresReexport'] == true ? 'CHANGED' : 'UNCHANGED'}');
      } on Object catch (e) {
        errors.add('$relative: $e');
      }
    }
  }
  impacts.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  final files = qualityFingerprint(repoRoot, null)
    ..['candidate-corpus'] = fileHash(candidateAsset)
    ..['baseline-corpus'] = fileHash(baselineAsset)
    ..addAll(contentFiles);
  final changed = impacts.where((entry) => entry['requiresReexport'] == true);
  final result = errors.isEmpty ? 'PASS' : 'FAIL';
  return {
    'schemaVersion': 1,
    'result': result,
    'promotionReady': result == 'PASS' && changed.isEmpty,
    'baselineAsset': baselineAsset,
    'candidateAsset': candidateAsset,
    'budget': {
      'seconds': budget.timeBudget.inSeconds,
      'nodes': budget.maxNodes,
      'depth': budget.maxDepth,
    },
    'summary': {
      'analyzed': impacts.length,
      'requiresReexport': changed.length,
      'errors': errors.length,
    },
    'errors': errors,
    'impacts': impacts,
    'files': files,
    'inputHash': sha256.convert(utf8.encode(jsonEncode(files))).toString(),
  };
}
