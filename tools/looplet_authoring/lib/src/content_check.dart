import 'dart:convert';
import 'dart:io';

import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

import 'dictionary_validator.dart';

/// Runs every content rule over the `.json` artifacts under [root]. Returns a
/// list of human-readable failures (empty = OK). This is the CI content gate.
Future<List<String>> runContentCheck({
  required String root,
  required String repoRoot,
  int noRepeatWindowDays = 30,
}) async {
  final failures = <String>[];
  final dir = Directory(root);
  if (!dir.existsSync()) {
    return <String>['no such directory: $root'];
  }

  final puzzles = <String, Puzzle>{}; // path -> puzzle
  final manifests = <String, Map<String, Object?>>{};

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.json')) continue;
    final rel = entity.path;
    final Object? decoded;
    try {
      decoded = jsonDecode(entity.readAsStringSync());
    } on FormatException catch (e) {
      failures.add('$rel: not valid JSON (${e.message})');
      continue;
    }
    if (decoded is! Map) {
      failures.add('$rel: root is not a JSON object');
      continue;
    }
    final map = decoded.cast<String, Object?>();
    if (map.containsKey('assignments')) {
      manifests[rel] = map;
      continue;
    }
    if (map.containsKey('levels')) {
      // A Journey content manifest (F05's schema — `schemaVersion`/`mode`/
      // `lang`/`levels`). Not a Puzzle artifact and not a Daily assignments
      // manifest; F05 owns its own structural gate for this shape
      // (`journey_manifest_gate_test.dart`). Nothing to check here.
      continue;
    }
    try {
      puzzles[rel] = Puzzle.fromJson(map);
    } on PuzzleFormatException catch (e) {
      failures.add('$rel: ${e.message}');
    }
  }

  // Per-puzzle rules.
  final validatorByLang = <String, DictionaryWordValidator>{};
  Future<DictionaryWordValidator> validatorFor(String lang) async =>
      validatorByLang[lang] ??=
          await loadDictionaryValidator(language: lang, repoRoot: repoRoot);

  for (final entry in puzzles.entries) {
    final path = entry.key;
    final puzzle = entry.value;
    final validator = await validatorFor(puzzle.language);

    final config = _toEngineConfig(puzzle);
    if (config == null) {
      failures.add('$path: grid/target is structurally invalid');
      continue;
    }

    // re-verify optimalMoves
    final result = Solver.solve(config, validator);
    switch (result) {
      case Optimal(:final moves):
        if (moves != puzzle.optimalMoves) {
          failures.add('$path: stored optimalMoves ${puzzle.optimalMoves} != '
              'fresh solve $moves');
        }
        if (moves == 0) {
          failures.add('$path: trivial (optimalMoves 0)');
        }
      case Unsolvable():
        failures.add('$path: unsolvable (stored ${puzzle.optimalMoves})');
      case BudgetExceeded():
        failures.add('$path: budgetExceeded on re-solve');
    }

    // target eligibility
    if (!validator.service.isEligibleTarget(puzzle.targetWord)) {
      failures.add('$path: targetWord "${puzzle.targetWord}" is not an '
          'eligible dictionary target');
    }

    // Journey band consistency
    if (puzzle.puzzleType == PuzzleType.journey) {
      final level = puzzle.journeyLevelNumber!;
      if (level >= 1 && level <= 3 && puzzle.columnMovesEnabled) {
        failures.add('$path: Journey level $level must have '
            'columnMovesEnabled == false');
      }
      final allowed = _expectedBands(level);
      if (!allowed.contains(puzzle.difficultyLabel)) {
        failures.add('$path: Journey level $level label '
            '${puzzle.difficultyLabel.name} not in expected '
            '{${allowed.map((b) => b.name).join(", ")}}');
      }
    }
  }

  // Dedup rules.
  final signatures = <String, List<String>>{};
  for (final entry in puzzles.entries) {
    signatures
        .putIfAbsent(_signature(entry.value), () => <String>[])
        .add(entry.key);
  }
  signatures.forEach((sig, paths) {
    if (paths.length > 1) {
      failures.add('duplicate puzzle definition across: ${paths.join(", ")}');
    }
  });

  // Daily manifest no-repeat-window.
  for (final entry in manifests.entries) {
    final assignments = entry.value['assignments'];
    if (assignments is! Map) {
      failures.add('${entry.key}: "assignments" must be an object');
      continue;
    }
    final byDate = <DateTime, String>{};
    for (final a in assignments.entries) {
      final date = DateTime.tryParse('${a.key}');
      if (date == null) {
        failures.add('${entry.key}: bad date "${a.key}"');
        continue;
      }
      byDate[date] = '${a.value}';
    }
    final dates = byDate.keys.toList()..sort();
    for (var i = 0; i < dates.length; i++) {
      for (var j = i + 1; j < dates.length; j++) {
        if (dates[j].difference(dates[i]).inDays >= noRepeatWindowDays) break;
        if (byDate[dates[i]] == byDate[dates[j]]) {
          failures
              .add('${entry.key}: puzzle "${byDate[dates[i]]}" repeats within '
                  '$noRepeatWindowDays days (${dates[i]} & ${dates[j]})');
        }
      }
    }
  }

  return failures;
}

EngineConfig? _toEngineConfig(Puzzle p) {
  try {
    return EngineConfig(
      initialGrid: <List<String>>[for (final row in p.grid) row.split('')],
      targetWord: p.targetWord,
      lockedCells: p.lockedCells,
      frozenCells: p.frozenCells,
      columnMovesEnabled: p.columnMovesEnabled,
    );
  } on EngineConfigError {
    return null;
  }
}

String _signature(Puzzle p) {
  String coords(Set<GridCoord> s) =>
      (s.toList()..sort()).map((c) => '${c.row},${c.col}').join(';');
  return '${p.grid.join("|")}#${p.targetWord}#${coords(p.lockedCells)}'
      '#${coords(p.frozenCells)}#${p.columnMovesEnabled}';
}

Set<DifficultyLabel> _expectedBands(int level) {
  if (level <= 6) {
    return const <DifficultyLabel>{
      DifficultyLabel.easy,
      DifficultyLabel.medium
    };
  }
  if (level <= 15) {
    return const <DifficultyLabel>{
      DifficultyLabel.easy,
      DifficultyLabel.medium,
      DifficultyLabel.hard,
    };
  }
  if (level <= 25) {
    return const <DifficultyLabel>{
      DifficultyLabel.medium,
      DifficultyLabel.hard,
      DifficultyLabel.expert,
    };
  }
  return const <DifficultyLabel>{DifficultyLabel.hard, DifficultyLabel.expert};
}
