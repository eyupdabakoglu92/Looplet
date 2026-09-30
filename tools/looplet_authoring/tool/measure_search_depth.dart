// Read-only feasibility measurement for F07 A7 ruling 2 (F07-TOOL-DAILY-R1):
// can every audit-daily analysis finish within the node/depth bounds for
// heavy-day optima 6 and 7? It never writes content or grants acceptance.
//
// Candidates: the real generator construction for a Fri/Sat/Sun date, deepened
// by 1..--max-extra further raw pivot-preserving rotations, then solved. Candidates whose
// fresh optimum is 6 or 7 run the full auditDay (with witness search, as
// generate-daily does) and report per-phase peak nodes, stop cause and time.
//
// usage: dart run tool/measure_search_depth.dart <corpus.json> <out.json>
//            [--per-optimum 2] [--attempts 400] [--seed 20260930]
//            [--max-extra 3]
import 'dart:io';
import 'dart:math';

import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/daily_generator.dart';
import 'package:looplet_authoring/src/daily_quality.dart';
import 'package:looplet_authoring/src/move_shorthand.dart';
import 'package:looplet_authoring/src/puzzle_def.dart';
import 'package:looplet_authoring/src/quality_cli.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('usage: measure_search_depth.dart <corpus.json> <out.json> '
        '[--per-optimum N] [--attempts N] [--seed N]');
    exit(64);
  }
  String option(String name, String fallback) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : fallback;
  }

  final perOptimum = int.parse(option('per-optimum', '2'));
  final attempts = int.parse(option('attempts', '400'));
  final seed = int.parse(option('seed', '20260930'));
  final maxExtra = int.parse(option('max-extra', '3'));
  final budget =
      SearchBudget(timeBudget: Duration(seconds: maxAnalysisSeconds));
  final words = CorpusWords(readObject(args[0]));
  final banned = loadExclusions('data/tr/exclusions.json');
  final journey = <String>{
    for (final file in jsonFiles('../../content/journey/tr'))
      if (readObject(file.path)['targetWord'] case final String t)
        TurkishCase.toLowerTr(t)
  };
  final targets = (words.targets.difference(journey).toList()..sort());
  final dates = [
    DateTime.utc(2026, 11, 6), // Friday: locked
    DateTime.utc(2026, 11, 7), // Saturday: both
    DateTime.utc(2026, 11, 8), // Sunday: frozen
  ];
  final random = Random(seed);
  final found = <int, List<Map<String, dynamic>>>{6: [], 7: []};
  final optimaSeen = <String, int>{};
  var tried = 0;
  final wall = Stopwatch()..start();

  while (tried < attempts &&
      found.values.any((list) => list.length < perOptimum)) {
    tried++;
    final date = dates[tried % dates.length];
    final target = targets[random.nextInt(targets.length)];
    final candidateSeed = random.nextInt(1 << 30);
    final PuzzleDef base;
    try {
      base = buildCandidate(words, target, date, candidateSeed).$1;
    } on StateError {
      continue;
    }
    final fixed = {...base.locked, ...base.frozen};
    var grid = [for (final row in base.grid) row.split('')];
    final extra = 1 + random.nextInt(maxExtra);
    for (var i = 0; i < extra; i++) {
      final index = random.nextInt(5);
      final move = [
        Move.rowLeft(index),
        Move.rowRight(index),
        Move.columnUp(index),
        Move.columnDown(index)
      ][random.nextInt(4)];
      grid = rawRotate(grid, fixed, move);
    }
    final def = PuzzleDef(
        id: base.id,
        puzzleType: PuzzleType.daily,
        dailyDate: base.dailyDate,
        language: 'tr',
        grid: [for (final row in grid) row.join()],
        target: base.target,
        locked: base.locked,
        frozen: base.frozen,
        columns: true);
    final config = def.toEngineConfig();
    final start = GridState.initial(config, words);
    if (start.isSolved || start.thawedCells.isNotEmpty) continue;
    final solveWatch = Stopwatch()..start();
    final solveStats = SearchStats();
    final solved =
        Solver.solve(config, words, budget: budget, stats: solveStats);
    final solveMs = solveWatch.elapsedMilliseconds;
    final label = solved is Optimal ? '${solved.moves}' : solved.runtimeType;
    optimaSeen['$label'] = (optimaSeen['$label'] ?? 0) + 1;
    if (solved is! Optimal) continue;
    final list = found[solved.moves];
    if (list == null || list.length >= perOptimum) continue;
    final stats = SearchStats();
    final auditWatch = Stopwatch()..start();
    final report = auditDay(def, words,
        banned: banned,
        journeyTargets: journey,
        proof: {'reference': formatMoves(solved.sequence)},
        budget: budget,
        findWitnesses: true,
        stats: stats);
    list.add({
      'date': def.dailyDate,
      'mechanic': mechanic(config),
      'target': def.target,
      'candidateSeed': candidateSeed,
      'extraRawMoves': extra,
      'grid': def.grid,
      'optimalMoves': solved.moves,
      'solveMs': solveMs,
      'solvePeakNodes': solveStats.toJson().first['peakNodes']!,
      'auditMs': auditWatch.elapsedMilliseconds,
      'rules': {
        for (final entry in jsonMap(report['rules']).entries)
          entry.key: {
            'status': jsonValue(entry.value, 'status'),
            if (jsonValue(entry.value, 'evidence.stop') case final Object stop)
              'stop': stop,
          }
      },
      'regression': jsonValue(report, 'regression.status'),
      'phases': stats.toJson(),
    });
    stdout.writeln('o=${solved.moves} ${def.dailyDate} ${mechanic(config)} '
        '${def.target}: ${auditWatch.elapsedMilliseconds} ms, Q4 '
        '${jsonValue(report, 'rules.Q4.status')}, Q5 '
        '${jsonValue(report, 'rules.Q5.status')}');
  }
  writeObject(args[1], {
    'schemaVersion': 1,
    'scope': 'R1 feasibility measurement; not content, not acceptance',
    'budget': {
      'seconds': budget.timeBudget.inSeconds,
      'nodes': budget.maxNodes,
      'depth': budget.maxDepth
    },
    'seed': seed,
    'attempts': tried,
    'optimaSeen': optimaSeen,
    'elapsedMs': wall.elapsedMilliseconds,
    'candidates': {for (final e in found.entries) '${e.key}': e.value},
  });
  stdout.writeln('attempts $tried; optima seen $optimaSeen → ${args[1]}');
}
