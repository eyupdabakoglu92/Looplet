import 'dart:convert';

import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

import 'corpus_quality.dart';
import 'move_shorthand.dart';
import 'puzzle_def.dart';
import 'quality_search.dart';
import 'quality_io.dart';
import 'turkish_frequency.dart';

Map<String, dynamic> verdict(String status, Object evidence) =>
    {'status': status, 'evidence': evidence};

String mechanic(EngineConfig c) => c.lockedCells.isEmpty
    ? (c.frozenCells.isEmpty ? 'open' : 'frozen')
    : (c.frozenCells.isEmpty ? 'locked' : 'both');

String scheduledMechanic(DateTime date) => [
      'open',
      'locked',
      'frozen',
      'open',
      'locked',
      'both',
      'frozen'
    ][date.weekday - 1];

EngineConfig ablate(EngineConfig c,
        {bool locked = false, bool frozen = false}) =>
    EngineConfig(
        initialGrid: c.initialGrid,
        targetWord: c.targetWord,
        lockedCells: locked ? {} : c.lockedCells,
        frozenCells: frozen ? {} : c.frozenCells,
        columnMovesEnabled: c.columnMovesEnabled);

List<String> rowWords(List<String> row, CorpusWords words) {
  final found = <String>{};
  for (var size = 4; size <= row.length; size++) {
    for (var at = 0; at + size <= row.length; at++) {
      final word = TurkishCase.toLowerTr(row.sublist(at, at + size).join());
      if (words.isValidWord(word, minLength: 4)) found.add(word);
    }
  }
  return found.toList()..sort();
}

List<String> bannedWindows(GridState state, Set<String> banned) {
  final grid = state.letters;
  final n = grid.length;
  final lines = <String>[
    for (final row in grid) TurkishCase.toLowerTr(row.join()),
    for (var c = 0; c < n; c++)
      TurkishCase.toLowerTr([for (var r = 0; r < n; r++) grid[r][c]].join()),
  ];
  final found = <String>{};
  for (final line in lines) {
    final reverse = line.split('').reversed.join();
    for (final word in banned) {
      if (line.contains(word) || reverse.contains(word)) found.add(word);
    }
  }
  return found.toList()..sort();
}

/// All successful output has a forward, optimal reference path. A supplied
/// witness is untrusted input; the real engine and fresh solver validate it.
Map<String, dynamic> auditDay(
  PuzzleDef def,
  CorpusWords words, {
  required Set<String> banned,
  required Set<String> journeyTargets,
  required Map<String, dynamic> proof,
  Puzzle? exported,
  Map<String, dynamic>? definitionJson,
  Map<String, dynamic>? exportJson,
  SearchBudget budget = const SearchBudget(),
  bool findWitnesses = false,
  bool stopAtCheapFailure = false,
  bool requireRegression = false,
  SearchStats? stats,
}) {
  final watch = Stopwatch()..start();
  final rules = <String, Map<String, dynamic>>{};
  final thawProofs = <String, String>{};
  final generatedProof = <String, dynamic>{'thaw': thawProofs};
  final report = <String, dynamic>{
    'id': def.id,
    'date': def.dailyDate,
    'target': TurkishCase.toLowerTr(def.target),
    'rules': rules,
    'proof': generatedProof
  };
  final config = def.toEngineConfig();
  final date = DateTime.tryParse(def.dailyDate ?? '');
  final start = GridState.initial(config, words);
  report['mechanic'] = mechanic(config);
  final target = TurkishCase.toLowerTr(def.target);
  final validDate =
      date != null && date.toIso8601String().substring(0, 10) == def.dailyDate;
  rules['Q1'] = verdict(
      config.gridSize == 5 &&
              def.language == 'tr' &&
              def.columns &&
              def.puzzleType == PuzzleType.daily &&
              validDate &&
              def.id == 'daily-tr-${def.dailyDate}' &&
              words.targets.contains(target) &&
              !journeyTargets.contains(target) &&
              def.grid.every((row) => normalizeTurkish(row)?.length == 5) &&
              (definitionJson == null ||
                  jsonEquivalent(definitionJson, def.toJson()))
          ? 'PASS'
          : 'FAIL',
      '5x5/TR/date/id/columns/eligible non-Journey target');
  final close = maxCorrect(config, start);
  rules['Q8'] = verdict(
      !start.isSolved &&
              start.thawedCells.isEmpty &&
              close < 3 &&
              !hasNearTargetRun(def.grid, def.target)
          ? 'PASS'
          : 'FAIL',
      {
        'maxCorrect': close,
        'initialThawed': start.thawedCells.length,
        'initialWords': [for (final row in start.letters) rowWords(row, words)]
      });
  final initialBan = bannedWindows(start, banned);
  rules['Q11'] = verdict(initialBan.isEmpty ? 'PASS' : 'FAIL',
      {'found': initialBan, 'scope': 'initial state only so far'});
  if (stopAtCheapFailure && rules.values.any((v) => v['status'] == 'FAIL')) {
    report['accepted'] = false;
    report['elapsedMs'] = watch.elapsedMilliseconds;
    return report;
  }
  final solve = Solver.solve(config, words, budget: budget, stats: stats);
  if (solve is! Optimal) {
    rules['Q2'] = verdict(
        solve is BudgetExceeded ? 'UNKNOWN' : 'FAIL',
        solve is BudgetExceeded
            ? {
                'reason': 'optimal solve did not return a proof',
                'stop': {
                  'phase': 'solve',
                  'cause': solve.cause.name,
                  'nodes': solve.nodes,
                  'elapsedMs': solve.elapsed.inMilliseconds
                }
              }
            : 'optimal solve did not return a proof');
    for (final key in ['Q3', 'Q4', 'Q5', 'Q6', 'Q7', 'Q9', 'Q10']) {
      rules[key] = verdict('UNKNOWN', 'depends on a proven optimum');
    }
    report['accepted'] = false;
    report['elapsedMs'] = watch.elapsedMilliseconds;
    return report;
  }
  final o = solve.moves;
  report['optimalMoves'] = o;
  final allowedProofKeys = {'reference', 'thaw', 'usefulThaw'};
  final validProofShape = proof.keys.every(allowedProofKeys.contains) &&
      proof['reference'] is String &&
      (proof['usefulThaw'] == null || proof['usefulThaw'] is String) &&
      (proof['thaw'] == null ||
          (proof['thaw'] is Map &&
              (proof['thaw'] as Map).entries.every((entry) =>
                  entry.value is String &&
                  config.frozenCells.any((c) => '${c.row}' == entry.key))));
  List<Move> reference;
  try {
    reference = parseMoves(
        proof['reference'] as String? ?? formatMoves(solve.sequence));
  } on MoveShorthandException {
    reference = [];
  }
  final states = replay(config, words, reference);
  final refValid =
      validProofShape && states != null && reference.length == o && o > 0;
  generatedProof['reference'] = formatMoves(reference);
  rules['Q2'] = verdict(
      refValid && (exported == null || exported.optimalMoves == o)
          ? 'PASS'
          : 'FAIL',
      {
        'optimal': o,
        'referenceLength': reference.length,
        'forwardReplay': refValid
      });
  final heavy = date != null && date.weekday >= DateTime.friday;
  final requiredMechanic = date == null ? null : scheduledMechanic(date);
  rules['Q3'] = verdict(
      o >= (heavy ? 5 : 4) &&
              o <= (heavy ? 7 : 5) &&
              mechanic(config) == requiredMechanic &&
              config.lockedCells.length <= 2 &&
              config.frozenCells.length <= 2
          ? 'PASS'
          : 'FAIL',
      {'heavy': heavy, 'expectedMechanic': requiredMechanic});
  final winningRow = refValid
      ? states.last.letters
          .indexWhere((r) => TurkishCase.toLowerTr(r.join()) == target)
      : -1;
  final fillers = <List<String>>[
    if (refValid)
      for (var r = 0; r < 5; r++)
        if (r != winningRow) rowWords(states.last.letters[r], words),
  ];
  rules['Q10'] = verdict(
      fillers.where((w) => w.isNotEmpty).length >= 3 ? 'PASS' : 'FAIL',
      {'finalFillerWords': fillers});
  if (stopAtCheapFailure && rules.values.any((v) => v['status'] == 'FAIL')) {
    report['accepted'] = false;
    report['elapsedMs'] = watch.elapsedMilliseconds;
    return report;
  }
  WitnessSearch regressionSearch() {
    if (refValid &&
        [
          for (var i = 1; i < states.length; i++)
            maxCorrect(config, states[i]) >= maxCorrect(config, states[i - 1])
        ].every((b) => b)) {
      return WitnessSearch('FOUND', reference, 0);
    }
    return searchWitness(config, words,
        maxDepth: o,
        budget: budget,
        nondecreasingOnly: true,
        stats: stats,
        phase: 'regression');
  }

  Map<String, dynamic> regressionVerdict(WitnessSearch found) => verdict(
          found.status == 'ABSENT_WITHIN_DEPTH'
              ? 'PASS'
              : found.status == 'UNKNOWN'
                  ? 'UNKNOWN'
                  : 'FAIL',
          {
            'nondecreasingPath': formatMoves(found.moves),
            'nodes': found.nodes,
            'depth': o,
            if (found.stop != null) 'stop': found.stop!.toJson()
          });
  WitnessSearch? regression;
  if (requireRegression && stopAtCheapFailure) {
    regression = regressionSearch();
    report['regression'] = regressionVerdict(regression);
    if (regression.status != 'ABSENT_WITHIN_DEPTH') {
      rules['profileRegression'] = regressionVerdict(regression);
      report['accepted'] = false;
      report['elapsedMs'] = watch.elapsedMilliseconds;
      return report;
    }
  }
  try {
    final difficulty =
        DifficultyScorer.score(config, words, budget: budget, stats: stats);
    final expected = def
        .toPuzzle(
            optimalMoves: o,
            difficulty: difficulty,
            contentVersion: exported?.contentVersion ?? 'candidate')
        .toJson();
    report['difficulty'] = {
      'score': difficulty.score,
      'label': difficulty.label.name,
      'breakdown': difficulty.breakdown
    };
    rules['Q4'] = verdict(
        (difficulty.label == DifficultyLabel.medium ||
                    difficulty.label == DifficultyLabel.hard) &&
                (exportJson != null
                    ? jsonEquivalent(exportJson, expected)
                    : exported == null ||
                        jsonEncode(exported.toJson()) == jsonEncode(expected))
            ? 'PASS'
            : 'FAIL',
        {
          'score': difficulty.score,
          'label': difficulty.label.name,
          'exportMatches': exportJson != null
              ? jsonEquivalent(exportJson, expected)
              : exported == null ||
                  jsonEncode(exported.toJson()) == jsonEncode(expected)
        });
    rules['Q9'] = verdict('PASS', {
      'advisory': true,
      'firstMovesLowerBound': difficulty.breakdown['firstMoves'],
      'enumerationComplete':
          difficulty.breakdown['optimalEnumerationComplete'] == 1
    });
  } on SearchLimitExceeded catch (e) {
    rules['Q4'] = verdict('UNKNOWN', {'stop': e.toJson()});
    rules['Q9'] = verdict('UNKNOWN', {'advisory': true, 'stop': e.toJson()});
  }
  if (stopAtCheapFailure && rules['Q4']!['status'] != 'PASS') {
    report['accepted'] = false;
    report['elapsedMs'] = watch.elapsedMilliseconds;
    return report;
  }
  final allStates = <GridState>[start, if (states != null) ...states];
  final groups = <String, Map<String, dynamic>>{};
  for (final group in ['locked', 'frozen']) {
    if ((group == 'locked' ? config.lockedCells : config.frozenCells).isEmpty) {
      groups[group] = verdict('N/A', 'mechanic absent');
      continue;
    }
    final ablated =
        ablate(config, locked: group == 'locked', frozen: group == 'frozen');
    // Only paths through the proven normal optimum matter. Exhaustive
    // absence through o proves a strictly larger optimum (or unsolvability),
    // without claiming an exact ablated optimum or searching deeper.
    final alternative = searchWitness(ablated, words,
        maxDepth: o, budget: budget, stats: stats, phase: 'Q5 $group ablated');
    if (alternative.status == 'UNKNOWN') {
      groups[group] = verdict('UNKNOWN',
          {'reason': 'ablation search', 'stop': alternative.stop?.toJson()});
    } else if (alternative.status == 'ABSENT_WITHIN_DEPTH') {
      groups[group] = verdict('PASS', {
        'normalOptimal': o,
        'ablatedOptimalLowerBound': o + 1,
        'absenceThroughDepth': o,
        'nodes': alternative.nodes,
        'direction':
            'removing mechanic requires more moves or makes unsolvable',
      });
    } else if (alternative.status == 'FOUND') {
      allStates.addAll(replay(ablated, words, alternative.moves)!);
      if (alternative.moves.length != o) {
        groups[group] = verdict('PASS', {
          'normalOptimal': o,
          'ablatedOptimal': alternative.moves.length,
          'ablatedReference': formatMoves(alternative.moves)
        });
      } else {
        // A single shared reference is enough to refute the universal claim.
        final commonRef = refValid ? replay(ablated, words, reference) : null;
        final common = commonRef != null
            ? WitnessSearch('FOUND', reference, 0)
            : searchWitness(config, words,
                maxDepth: o,
                budget: budget,
                commonWith: ablated,
                stats: stats,
                phase: 'Q5 $group common');
        if (common.status == 'FOUND') {
          allStates.addAll(replay(config, words, common.moves)!);
          allStates.addAll(replay(ablated, words, common.moves)!);
        }
        groups[group] = verdict(
            common.status == 'UNKNOWN'
                ? 'UNKNOWN'
                : common.status == 'FOUND'
                    ? 'FAIL'
                    : 'PASS',
            {
              'normalOptimal': o,
              'ablatedOptimal': o,
              'commonOptimal': common.status,
              'commonReference': formatMoves(common.moves),
              'nodes': common.nodes,
              if (common.stop != null) 'stop': common.stop!.toJson()
            });
      }
    }
  }
  rules['Q5'] = verdict(
      groups.values.any((v) => v['status'] == 'FAIL')
          ? 'FAIL'
          : groups.values.any((v) => v['status'] == 'UNKNOWN')
              ? 'UNKNOWN'
              : groups.values.every((v) => v['status'] == 'N/A')
                  ? 'N/A'
                  : 'PASS',
      groups);
  if (stopAtCheapFailure && !['PASS', 'N/A'].contains(rules['Q5']!['status'])) {
    report['accepted'] = false;
    report['elapsedMs'] = watch.elapsedMilliseconds;
    return report;
  }
  final thawRows = config.frozenCells.map((c) => c.row).toSet().toList()
    ..sort();
  final thawResults = <String, Map<String, dynamic>>{};
  for (final row in thawRows) {
    bool validThaw(List<Move> path) {
      final played = replay(config, words, path);
      return path.length <= o + 2 &&
          played != null &&
          start.thawedCells.isEmpty &&
          played.any(
              (s) => !s.isSolved && s.thawedCells.any((c) => c.row == row));
    }

    List<Move> path = [];
    SearchLimitExceeded? thawStop;
    try {
      path = parseMoves((proof['thaw'] as Map?)?['$row'] as String? ??
          formatMoves(reference));
    } on MoveShorthandException {/* invalid witness fails below */}
    String status = validThaw(path) ? 'PASS' : 'FAIL';
    if (status != 'PASS' && findWitnesses) {
      final found = searchWitness(config, words,
          maxDepth: o + 2,
          budget: budget,
          thawRowBeforeWin: row,
          stats: stats,
          phase: 'Q6 row $row');
      thawStop = found.stop;
      path = found.moves;
      status = found.status == 'UNKNOWN'
          ? 'UNKNOWN'
          : validThaw(path)
              ? 'PASS'
              : 'FAIL';
    }
    if (status == 'PASS') {
      thawProofs['$row'] = formatMoves(path);
      allStates.addAll(replay(config, words, path)!);
    }
    thawResults['$row'] = verdict(status, {
      'path': formatMoves(path),
      'maxLength': o + 2,
      if (thawStop != null) 'stop': thawStop.toJson()
    });
  }
  rules['Q6'] = verdict(
      thawResults.isEmpty
          ? 'N/A'
          : thawResults.values.every((v) => v['status'] == 'PASS')
              ? 'PASS'
              : thawResults.values.any((v) => v['status'] == 'FAIL')
                  ? 'FAIL'
                  : 'UNKNOWN',
      thawResults);
  bool useful(List<Move> path) {
    final played = replay(config, words, path);
    return path.length == o &&
        played != null &&
        start.thawedCells.isEmpty &&
        [
          for (var i = 0; i < path.length; i++)
            movedThawedLetter(played[i], played[i + 1], path[i])
        ].any((b) => b);
  }

  List<Move> usefulPath = reference;
  try {
    usefulPath =
        parseMoves(proof['usefulThaw'] as String? ?? formatMoves(reference));
  } on MoveShorthandException {
    usefulPath = [];
  }
  var usefulStatus = useful(usefulPath) ? 'PASS' : 'FAIL';
  SearchLimitExceeded? usefulStop;
  if (config.frozenCells.isNotEmpty &&
      usefulStatus != 'PASS' &&
      findWitnesses) {
    final found = searchWitness(config, words,
        maxDepth: o,
        budget: budget,
        requireUsefulThaw: true,
        stats: stats,
        phase: 'Q7 useful thaw');
    usefulStop = found.stop;
    usefulPath = found.moves;
    usefulStatus = found.status == 'UNKNOWN'
        ? 'UNKNOWN'
        : useful(usefulPath)
            ? 'PASS'
            : 'FAIL';
  }
  if (usefulStatus == 'PASS') {
    generatedProof['usefulThaw'] = formatMoves(usefulPath);
    allStates.addAll(replay(config, words, usefulPath)!);
  }
  rules['Q7'] = verdict(
      config.frozenCells.isEmpty ? 'N/A' : usefulStatus,
      usefulStop == null
          ? 'individual measure; required ratio is checked at pool scope'
          : {
              'reason':
                  'individual measure; required ratio is checked at pool scope',
              'stop': usefulStop.toJson()
            });
  regression ??= regressionSearch();
  report['regression'] = regressionVerdict(regression);
  if (regression.status == 'FOUND') {
    allStates.addAll(replay(config, words, regression.moves)!);
  }
  final violations = <String>{
    for (final state in allStates) ...bannedWindows(state, banned)
  }.toList()
    ..sort();
  rules['Q11'] = verdict(violations.isEmpty ? 'PASS' : 'FAIL', {
    'found': violations,
    'statesScanned': allStates.length,
    'directions': 'horizontal/vertical, forward/reverse',
    'scope':
        'stored reference/thaw/counterfactual/diagnostic paths; exact versioned list only'
  });
  report['accepted'] = ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q8', 'Q10', 'Q11']
      .every((key) => ['PASS', 'N/A'].contains(rules[key]?['status']));
  report['elapsedMs'] = watch.elapsedMilliseconds;
  return report;
}
