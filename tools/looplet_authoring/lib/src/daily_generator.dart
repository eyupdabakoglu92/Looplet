import 'dart:io';
import 'dart:math';

import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

import 'corpus_quality.dart';
import 'daily_quality.dart';
import 'move_shorthand.dart';
import 'puzzle_def.dart';
import 'quality_io.dart';
import 'quality_search.dart';

Map<String, dynamic> defJson(PuzzleDef def) => def.toJson();

Move inverseMove(Move move) => switch (move.direction) {
      MoveDirection.left => Move.rowRight(move.index),
      MoveDirection.right => Move.rowLeft(move.index),
      MoveDirection.up => Move.columnDown(move.index),
      MoveDirection.down => Move.columnUp(move.index),
    };

/// Raw authoring operation, deliberately not GridState.applyMove on a terminal
/// solved state. This produces a candidate only; its inverse must replay in
/// the actual engine, with its irreversible thaw and terminal rules.
List<List<String>> rawRotate(
    List<List<String>> grid, Set<GridCoord> fixed, Move move) {
  final result = [for (final row in grid) List<String>.of(row)];
  final coords = <GridCoord>[
    for (var i = 0; i < grid.length; i++)
      if (!fixed.contains(move.axis == MoveAxis.row
          ? GridCoord(move.index, i)
          : GridCoord(i, move.index)))
        move.axis == MoveAxis.row
            ? GridCoord(move.index, i)
            : GridCoord(i, move.index),
  ];
  for (var i = 0; i < coords.length; i++) {
    final source = coords[(move.isForward ? i - 1 : i + 1) % coords.length];
    result[coords[i].row][coords[i].col] = grid[source.row][source.col];
  }
  return result;
}

/// A single deterministic candidate (seed+attempt), not a quality claim.
(PuzzleDef, List<Move>, List<String>) buildCandidate(
    CorpusWords words, String target, DateTime date, int seed,
    {bool thawPrefix = false}) {
  final random = Random(seed);
  final kind = scheduledMechanic(date);
  final frozen = kind == 'frozen' || kind == 'both';
  final locked = kind == 'locked' || kind == 'both';
  final targetRow = random.nextInt(5);
  final otherRows = [
    for (var r = 0; r < 5; r++)
      if (r != targetRow) r
  ]..shuffle(random);
  final frostRows = frozen && !thawPrefix
      ? otherRows.take(kind == 'both' ? 2 : 1).toSet()
      : <int>{};
  final pool = words.words
      .where((w) =>
          w.length >= 4 &&
          w.length <= 5 &&
          w != target &&
          !('$target$target').contains(w) &&
          (!thawPrefix ||
              (!w.contains(target[0]) &&
                  !w.contains(target[4]) &&
                  [for (var c = 0; c < w.length; c++) w[c] != target[c]]
                      .every((b) => b))))
      .toList()
    ..sort();
  int overlap(String word) =>
      word.split('').toSet().intersection(target.split('').toSet()).length;
  final sharing = pool
      .where((w) => thawPrefix ? overlap(w) >= 2 : overlap(w) == 2)
      .toList();
  final four = pool.where((w) => w.length == 4).toList();
  if (sharing.length < 2 || four.isEmpty) {
    throw StateError('insufficient candidate vocabulary');
  }
  final chosen = <String>{target};
  final filler = <String>[];
  var shared = 0;
  final build = <List<String>>[];
  for (var r = 0; r < 5; r++) {
    if (r == targetRow) {
      build.add(target.split(''));
      continue;
    }
    final eligible = (frostRows.contains(r)
            ? four
            : shared < 2
                ? sharing
                : pool)
        .where((w) => !chosen.contains(w))
        .toList();
    if (eligible.isEmpty) {
      throw StateError('insufficient distinct filler vocabulary');
    }
    final word = eligible[random.nextInt(eligible.length)];
    chosen.add(word);
    filler.add(word);
    if (overlap(word) >= 2) shared++;
    final padding = thawPrefix
        ? word
            .split('')
            .firstWhere((c) => c != target[4], orElse: () => target[3])
        : target[random.nextInt(5)];
    build.add((word.length == 5 ? word : '$word$padding').split(''));
  }
  // Sharing is checked even when the dedicated thaw row used the last slot.
  if (shared < 2) throw StateError('construction lacks two sharing fillers');
  if (thawPrefix && kind == 'both') {
    if (!words.words.contains(target.substring(0, 4))) {
      throw StateError(
          'thaw-prefix construction requires a real four-letter prefix');
    }
    // The prefix forms before the last letter can move. The row's temporary
    // pivot changes which end wraps around; removing either mechanic changes
    // that route. Both ablations and regression still need solver proofs.
    final prefixLocks = {
      GridCoord(targetRow, 3),
      GridCoord((targetRow + 1) % 5, 2)
    };
    final prefixFrost = {GridCoord(targetRow, 4)};
    var candidate = rawRotate(build, prefixLocks, const Move.columnUp(4));
    final backwards = [
      const Move.columnUp(4),
      const Move.columnDown(1),
      Move.rowLeft(targetRow),
      const Move.columnUp(2),
      Move.rowRight(targetRow)
    ];
    for (final move in backwards.skip(1)) {
      candidate = rawRotate(candidate, {...prefixLocks, ...prefixFrost}, move);
    }
    final stamp = date.toIso8601String().substring(0, 10);
    return (
      PuzzleDef(
          id: 'daily-tr-$stamp',
          puzzleType: PuzzleType.daily,
          dailyDate: stamp,
          language: 'tr',
          grid: candidate.map((r) => r.join()).toList(),
          target: target,
          locked: prefixLocks,
          frozen: prefixFrost,
          columns: true),
      backwards.reversed.map(inverseMove).toList(),
      filler
    );
  }
  final locks = <GridCoord>{
    if (locked)
      for (final row in otherRows
          .where((r) => !frostRows.contains(r))
          .take(kind == 'both' ? 2 : 1))
        GridCoord(row, 4),
  };
  if (kind == 'locked' && date.weekday < DateTime.friday) {
    // Buffer-row construction: three disturbed target columns, followed by a
    // pivoted buffer-row rotation. A fresh solve/ablation must establish both
    // optimality and relevance; this is not a pre-approved template.
    final firstColumn = random.nextInt(4);
    final otherColumns = [
      for (var c = 0; c < 4; c++)
        if (c != firstColumn) c
    ];
    final secondColumn = otherColumns[random.nextInt(otherColumns.length)];
    final backwards = [
      const Move.columnDown(4),
      Move.columnUp(firstColumn),
      Move.columnDown(secondColumn),
      Move.rowRight(locks.first.row)
    ];
    var candidate = build;
    for (final move in backwards) {
      candidate = rawRotate(candidate, locks, move);
    }
    final stamp = date.toIso8601String().substring(0, 10);
    return (
      PuzzleDef(
          id: 'daily-tr-$stamp',
          puzzleType: PuzzleType.daily,
          dailyDate: stamp,
          language: 'tr',
          grid: candidate.map((r) => r.join()).toList(),
          target: target,
          locked: locks,
          frozen: {},
          columns: true),
      backwards.reversed.map(inverseMove).toList(),
      filler
    );
  }
  var grid = build;
  final backwards = <Move>[];
  final frost = <GridCoord>{};
  // Five moves plus two mechanics is the first heavy construction profile.
  // This is a construction heuristic only; the same optimum/score/Q5 gates apply.
  final depth = date.weekday >= DateTime.friday ? 5 : 4 + random.nextInt(2);
  final seen = <String>{grid.expand((r) => r).join()};
  int correct(List<List<String>> g) => g
      .map((r) => [for (var c = 0; c < 5; c++) r[c] == target[c] ? 1 : 0]
          .reduce((a, b) => a + b))
      .reduce(max);
  for (var i = 0; i < depth; i++) {
    final options = <Move>[
      if (i == 0)
        const Move.columnDown(4)
      else if (i == 1 && frozen)
        for (var c = 0; c < 4; c++) Move.columnDown(c)
      else
        for (var line = 0; line < 5; line++) ...[
          Move.rowLeft(line),
          Move.rowRight(line),
          Move.columnUp(line),
          Move.columnDown(line),
        ],
    ];
    final possible = <(Move, List<List<String>>)>[];
    for (final move in options) {
      final next = rawRotate(grid, {...locks, ...frost}, move);
      if (seen.contains(next.expand((r) => r).join())) continue;
      // Do not waste steps on a line carrying no target letters.
      final affected = move.axis == MoveAxis.row
          ? grid[move.index]
          : [for (var r = 0; r < 5; r++) grid[r][move.index]];
      if (!affected.any(target.contains)) continue;
      if (correct(next) == 5) continue;
      possible.add((move, next));
    }
    if (possible.isEmpty) {
      throw StateError('no productive non-cyclic scramble move');
    }
    var choices = possible;
    if (i == 2) {
      final rows = possible
          .where((p) =>
              p.$1.axis == MoveAxis.row &&
              grid[p.$1.index].where(target.contains).length >= 2)
          .toList();
      if (rows.isNotEmpty) choices = rows;
    } else if (i == 3) {
      // Try to create a reverse increase: its forward inverse is a regression
      // candidate. Only exhaustive nondecreasing-path analysis can prove it.
      final increases =
          possible.where((p) => correct(p.$2) > correct(grid)).toList();
      if (increases.isNotEmpty) choices = increases;
    }
    if (kind == 'both' && i == 3) {
      final lowAlignment = possible.where((p) => correct(p.$2) <= 1).toList();
      if (lowAlignment.isEmpty) {
        throw StateError(
            'no low-alignment buffer state for heavy regression candidate');
      }
      choices = lowAlignment;
    }
    if (kind == 'both' && i == 4) {
      final misleading = possible.where((p) => correct(p.$2) == 2).toList();
      if (misleading.isEmpty) {
        throw StateError(
            'no two-letter misleading start for heavy regression candidate');
      }
      choices = misleading;
    } else if (i == 4 && backwards[2].axis == MoveAxis.row) {
      // Restore the earlier row around an intervening column shift. This
      // creates a buffer manoeuvre candidate, still subject to the all-path
      // regression proof and real thaw replay.
      final restore =
          possible.where((p) => p.$1 == inverseMove(backwards[2])).toList();
      if (restore.isNotEmpty) choices = restore;
    }
    final selected = choices[random.nextInt(choices.length)];
    grid = selected.$2;
    backwards.add(selected.$1);
    seen.add(grid.expand((r) => r).join());
    if (i == 0) {
      for (final row in frostRows) {
        frost.add(GridCoord(row, 4));
      }
    }
  }
  final stamp = date.toIso8601String().substring(0, 10);
  final def = PuzzleDef(
      id: 'daily-tr-$stamp',
      puzzleType: PuzzleType.daily,
      dailyDate: stamp,
      language: 'tr',
      grid: [for (final row in grid) row.join()],
      target: target,
      locked: locks,
      frozen: frost,
      columns: true);
  return (def, backwards.reversed.map(inverseMove).toList(), filler);
}

/// Writes only individually audited candidates into the explicit staging dir.
/// Does not replace canonical content or claim pilot/pool/editorial acceptance.
Map<String, dynamic> generateDaily({
  required CorpusWords words,
  required Set<String> banned,
  required Set<String> journeyTargets,
  required List<DateTime> dates,
  required int seed,
  required int attemptsPerDay,
  required String outDir,
  required SearchBudget budget,
  required String inputHash,
  required Set<String> regressionDates,
  void Function(String)? progress,
}) {
  for (final dir in ['pool', 'defs', 'proofs']) {
    Directory('$outDir/$dir').createSync(recursive: true);
  }
  final reportPath = '$outDir/generation.json';
  final old = File(reportPath).existsSync() ? readObject(reportPath) : null;
  if (old != null &&
      (old['inputHash'] != inputHash ||
          old['seed'] != seed ||
          old['regressionDates'].toString() !=
              (regressionDates.toList()..sort()).toString() ||
          old['dates'].toString() !=
              dates
                  .map((d) => d.toIso8601String().substring(0, 10))
                  .toList()
                  .toString())) {
    throw StateError('checkpoint inputs changed; use a new staging directory');
  }
  final report = old ??
      <String, dynamic>{
        'schemaVersion': 1,
        'inputHash': inputHash,
        'seed': seed,
        'regressionDates': regressionDates.toList()..sort(),
        'dates': [for (final d in dates) d.toIso8601String().substring(0, 10)],
        'attempts': <dynamic>[],
        'accepted': <String, dynamic>{},
        'status': 'INCOMPLETE'
      };
  final targets = words.targets.difference(journeyTargets).toList()..sort();
  if (targets.length < 60) {
    throw StateError('need at least 60 non-Journey targets');
  }
  final accepted = jsonMap(report['accepted']);
  final attempts = jsonMaps(report['attempts']);
  report['attempts'] = attempts;
  final used = accepted.values.map((v) => jsonValue(v, 'target')).toSet();
  for (final entry in accepted.values) {
    final hashes = jsonMap(jsonValue(entry, 'fileHashes'));
    for (final file in hashes.entries) {
      if (fileHash('$outDir/${file.key}') != file.value) {
        throw StateError(
            'checkpoint artifact changed: ${file.key}; rerun audit or use a new staging directory');
      }
    }
  }
  void checkpoint() {
    final entries = accepted.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    writeObject('$outDir/daily_manifest_tr.json', {
      'schemaVersion': 1,
      'lang': 'tr',
      'contentVersion': 'quality-candidate-v2',
      'numberingEpoch': dates.first.toIso8601String().substring(0, 10),
      'assignments': {
        for (final entry in entries) entry.key: 'daily-tr-${entry.key}'
      },
    });
    writeObject(reportPath, report);
  }

  for (var day = 0; day < dates.length; day++) {
    final date = dates[day];
    final stamp = date.toIso8601String().substring(0, 10);
    if (accepted.containsKey(stamp)) continue;
    final previous = attempts.where((a) => a['date'] == stamp).length;
    for (var attempt = previous; attempt < attemptsPerDay; attempt++) {
      final candidateSeed = seed + day * 1000003 + attempt * 7919;
      final requireRegression = regressionDates.contains(stamp);
      final prefixConstruction =
          requireRegression && scheduledMechanic(date) == 'both';
      final targetPool = targets
          .where((t) =>
              !used.contains(t) &&
              (!prefixConstruction ||
                  (words.words.contains(t.substring(0, 4)) &&
                      t.split('').toSet().length == 5)))
          .toList();
      if (targetPool.isEmpty) {
        throw StateError(
            'no unused prefix-thaw targets for this focused profile');
      }

      final target =
          targetPool[Random(candidateSeed).nextInt(targetPool.length)];
      final timer = Stopwatch()..start();
      Map<String, dynamic> audit;
      PuzzleDef? def;
      try {
        final built = buildCandidate(words, target, date, candidateSeed,
            thawPrefix: prefixConstruction);
        def = built.$1;
        if (replay(def.toEngineConfig(), words, built.$2) == null) {
          audit = {
            'accepted': false,
            'rules': {
              'construction': verdict(
                  'FAIL', 'inverse does not replay to win in actual engine')
            }
          };
        } else {
          audit = auditDay(def, words,
              banned: banned,
              journeyTargets: journeyTargets,
              proof: {'reference': formatMoves(built.$2)},
              budget: budget,
              findWitnesses: true,
              stopAtCheapFailure: true,
              requireRegression: requireRegression);
          audit['constructionFiller'] = built.$3;
          if (audit['accepted'] == true &&
              requireRegression &&
              (jsonValue(audit, 'regression.status') != 'PASS' ||
                  (date.weekday >= DateTime.friday &&
                      jsonValue(audit, 'difficulty.label') != 'hard'))) {
            jsonMap(audit['rules'])['profileRegression'] = verdict(
                jsonValue(audit, 'regression.status') == 'UNKNOWN'
                    ? 'UNKNOWN'
                    : 'FAIL',
                'focused slot requires proven regression, and hard on heavy days');
            audit['accepted'] = false;
          }
        }
      } on StateError catch (e) {
        audit = {
          'accepted': false,
          'rules': {'construction': verdict('FAIL', '$e')}
        };
      }
      final entry = {
        'date': stamp,
        'attempt': attempt,
        'seed': candidateSeed,
        'target': target,
        'elapsedMs': timer.elapsedMilliseconds,
        'audit': audit
      };
      attempts.add(entry);
      if (audit['accepted'] == true && def != null) {
        final scored = audit['difficulty'] as Map;
        final difficulty = Difficulty(
            score: (scored['score'] as num).toDouble(),
            label: DifficultyLabel.values.byName(scored['label'] as String),
            breakdown: (scored['breakdown'] as Map).cast<String, num>());
        writeObject('$outDir/defs/${def.id}.json', defJson(def));
        writeObject(
            '$outDir/pool/${def.id}.json',
            def
                .toPuzzle(
                    optimalMoves: audit['optimalMoves'] as int,
                    difficulty: difficulty,
                    contentVersion: 'quality-candidate-v2')
                .toJson());
        writeObject('$outDir/proofs/${def.id}.json', audit['proof'] as Object);
        entry['fileHashes'] = {
          for (final dir in ['defs', 'pool', 'proofs'])
            '$dir/${def.id}.json': fileHash('$outDir/$dir/${def.id}.json')
        };
        accepted[stamp] = entry;
        used.add(target);
      }
      checkpoint();
      final failures = jsonMap(audit['rules'])
          .entries
          .where(
              (e) => ['FAIL', 'UNKNOWN'].contains(jsonValue(e.value, 'status')))
          .map((e) => '${e.key}:${jsonValue(e.value, 'status')}')
          .join(',');
      progress?.call(
          '$stamp attempt ${attempt + 1}/$attemptsPerDay ${audit['accepted'] == true ? 'ACCEPTED' : failures} ${timer.elapsedMilliseconds}ms');
      if (audit['accepted'] == true) break;
    }
  }
  report['status'] = (report['accepted'] as Map).length == dates.length
      ? 'INDIVIDUAL_CANDIDATES_READY'
      : 'INCOMPLETE';
  checkpoint();
  return report;
}
