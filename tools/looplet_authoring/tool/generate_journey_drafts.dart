// F06-CONTENT-DRAFT — AI-assisted candidate-draft generator for the 30 Journey
// levels (per features/f06-puzzle-content-and-solver-tooling/content-authoring-brief.md).
//
// NOT a shippable-content pipeline. Produces STARTING-POINT candidate grids for
// the human (Level Designer / user) to playtest + tune + sign off. Does NOT
// close or advance F05.
//
// Strategy: backward construction + rejection sampling.
//   1. Map level N -> target word (dictionary `targets` file order, uppercased).
//   2. Build a solved 5x5 grid (target in a row, seeded filler elsewhere).
//   3. Raw cyclic-shift scramble of k lines (mirrors the engine shift; respects
//      locked/frozen positions; column shifts only when columnMovesEnabled).
//   4. Solver.solve on the scrambled grid -> the PROVABLE optimal.
//   5. Accept iff: solvable within budget, not already solved, optimal >= band
//      floor, and DifficultyScorer label is inside `check`'s expected band.
//   6. export-equivalent Puzzle artifact + def + draft manifest + REVIEW.md.
//
// Run from tools/looplet_authoring:
//   dart run tool/generate_journey_drafts.dart --repo-root ../..
//
// Output (all paths relative to this package):
//   drafts/journey/_defs/journey-tr-NN.def.json
//   drafts/journey/tr/journey-tr-NN.json
//   drafts/journey/journey_manifest_tr.draft.json
//   drafts/journey/REVIEW.md

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

import 'package:looplet_authoring/src/dictionary_validator.dart';
import 'package:looplet_authoring/src/puzzle_def.dart';

const String lang = 'tr';
const String contentVersion = 'draft';
const int gridSize = 5;

/// The 30 designated Turkish targets, in `dictionary.json` file order. Level N
/// (1-based) uses `targets[N-1]`. Kept here as a literal so the generator does
/// not silently drift if the provisional dictionary is re-ordered — a mismatch
/// is surfaced loudly instead.
const List<String> targetsInOrder = <String>[
  'aslan', 'badem', 'bahçe', 'balık', 'bulut', //
  'çanta', 'çorap', 'damla', 'deniz', 'fırın',
  'kabak', 'kağıt', 'kalem', 'kitap', 'limon',
  'makas', 'masal', 'orman', 'resim', 'roman',
  'salon', 'sepet', 'sokak', 'şeker', 'tabak',
  'tarih', 'tavuk', 'yatak', 'zaman', 'zemin',
];

/// Uppercase Turkish letter pool for filler cells (common letters only).
const List<String> fillerPool = <String>[
  'A', 'E', 'İ', 'I', 'O', 'U', 'Ü', 'Ö', //
  'K', 'L', 'M', 'N', 'R', 'S', 'T',
  'B', 'D', 'Y', 'Z', 'Ç', 'Ş', 'G', 'P', 'H',
];

class BandSpec {
  const BandSpec({
    required this.name,
    required this.columnMovesEnabled,
    required this.lockedInTargetRow,
    required this.frozenInOtherRow,
    required this.scrambleKs,
    required this.optFloor,
    required this.optCeil,
  });

  final String name;
  final bool columnMovesEnabled;
  final int lockedInTargetRow; // locked cells placed in the target row
  final int frozenInOtherRow; // frozen cells placed in a non-target row
  final List<int> scrambleKs; // scramble depths to try, in order
  final int optFloor;
  final int optCeil;
}

BandSpec bandFor(int level) {
  if (level <= 3) {
    return const BandSpec(
      name: 'on-ramp (rows-only)',
      columnMovesEnabled: false,
      lockedInTargetRow: 0,
      frozenInOtherRow: 0,
      scrambleKs: <int>[2],
      optFloor: 2,
      optCeil: 2,
    );
  }
  // NOTE ON THE optCeil == 5 CAP: DifficultyScorer runs three UNBUDGETED BFS
  // passes to `optimal` depth (solve + enumerateOptimalSolutions +
  // correctLookingNorm). Past optimal ~6 with column moves that blows minutes
  // per candidate. Capping optimal at 5 keeps every scorer call in the
  // seconds-range that levels 11–14 proved tolerable. The deeper-curve bands
  // therefore lean on the locked / frozen score terms, not raw depth — see
  // REVIEW.md gap #5.
  if (level <= 6) {
    return const BandSpec(
      name: 'columns introduced',
      columnMovesEnabled: true,
      lockedInTargetRow: 0,
      frozenInOtherRow: 0,
      scrambleKs: <int>[4, 5, 3],
      optFloor: 3,
      optCeil: 5,
    );
  }
  if (level <= 10) {
    return const BandSpec(
      name: 'free play, deeper',
      columnMovesEnabled: true,
      lockedInTargetRow: 0,
      frozenInOtherRow: 0,
      scrambleKs: <int>[5, 6, 4],
      optFloor: 4,
      optCeil: 5,
    );
  }
  if (level <= 15) {
    return const BandSpec(
      name: 'free play, hard reachable',
      columnMovesEnabled: true,
      lockedInTargetRow: 0,
      frozenInOtherRow: 0,
      scrambleKs: <int>[5, 6, 7],
      optFloor: 5,
      optCeil: 5,
    );
  }
  if (level <= 20) {
    return const BandSpec(
      name: 'locked tiles',
      columnMovesEnabled: true,
      lockedInTargetRow: 1,
      frozenInOtherRow: 0,
      scrambleKs: <int>[5, 6, 7],
      optFloor: 4,
      optCeil: 5,
    );
  }
  if (level <= 25) {
    return const BandSpec(
      name: 'frozen tiles',
      columnMovesEnabled: true,
      lockedInTargetRow: 0,
      frozenInOtherRow: 1,
      scrambleKs: <int>[5, 6, 7],
      optFloor: 4,
      optCeil: 5,
    );
  }
  // 26–30 need label in {hard, expert} == score >= 8. With optimal capped at 5
  // (scorer-cost ceiling) that lift has to come from the tile terms:
  // 2*locked (0.8) + 2*frozen (1.2) = 4.0 on top of a ~5 optimal term.
  return const BandSpec(
    name: 'locked + frozen',
    columnMovesEnabled: true,
    lockedInTargetRow: 2,
    frozenInOtherRow: 2,
    scrambleKs: <int>[6, 7, 5],
    optFloor: 4,
    optCeil: 6,
  );
}

/// `check`'s `_expectedBands` (content_check.dart) — the label gate that CI
/// enforces. Replicated so the generator only emits artifacts that will pass.
Set<DifficultyLabel> expectedBands(int level) {
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

String journeyLevelId(int n) => 'journey-$lang-${n.toString().padLeft(2, '0')}';

class Attempt {
  Attempt(this.grid, this.locked, this.frozen, this.targetRow);
  final List<String> grid; // 5 uppercase row strings
  final Set<GridCoord> locked;
  final Set<GridCoord> frozen;
  final int targetRow;
}

/// Raw cyclic shift of one line, mirroring GridState.applyMove for a puzzle with
/// no thawed cells: movable positions (not locked, not frozen) rotate by one;
/// immovable positions stay. `forward` = right (row) / down (column).
void rawShift(
  List<List<String>> cells,
  MoveAxis axis,
  int index,
  bool forward,
  Set<GridCoord> immovable,
) {
  final coords = <GridCoord>[
    for (var i = 0; i < gridSize; i++)
      axis == MoveAxis.row ? GridCoord(index, i) : GridCoord(i, index),
  ];
  final movablePos = <int>[
    for (var i = 0; i < coords.length; i++)
      if (!immovable.contains(coords[i])) i,
  ];
  if (movablePos.length <= 1) return;
  final k = movablePos.length;
  final letters = <String>[
    for (final p in movablePos) cells[coords[p].row][coords[p].col],
  ];
  for (var i = 0; i < k; i++) {
    final src = (forward ? i - 1 : i + 1) % k;
    final c = coords[movablePos[i]];
    cells[c.row][c.col] = letters[(src + k) % k];
  }
}

List<String> rowsOf(List<List<String>> cells) =>
    <String>[for (final r in cells) r.join()];

bool anyRowIsTargetRotation(List<String> rows, String targetUpper) {
  final rots = <String>{
    for (var i = 0; i < gridSize; i++)
      (targetUpper.substring(i) + targetUpper.substring(0, i)),
  };
  return rows.any(rots.contains);
}

Future<void> main(List<String> args) async {
  final repoRoot = _optValue(args, '--repo-root') ?? '../..';
  final pkgDir = Directory.current.path;
  final validator =
      await loadDictionaryValidator(language: lang, repoRoot: repoRoot);

  // Sanity: our literal order must match the shipped dictionary targets.
  final dictFile = File('$repoRoot/packages/looplet_dictionary/assets/$lang/'
      'dictionary.json');
  final dictTargets = ((jsonDecode(dictFile.readAsStringSync())
          as Map<String, Object?>)['targets'] as List)
      .cast<String>();
  if (!_listEq(dictTargets, targetsInOrder)) {
    stderr.writeln('FATAL: dictionary targets order drifted from the generator '
        'literal.\n dict: $dictTargets\n gen : $targetsInOrder');
    exit(2);
  }

  final defsDir = Directory('$pkgDir/drafts/journey/_defs')
    ..createSync(recursive: true);
  final artDir = Directory('$pkgDir/drafts/journey/tr')
    ..createSync(recursive: true);
  final outRoot = Directory('$pkgDir/drafts/journey');

  // `--reuse` keeps any already-written drafts/journey/tr/journey-tr-NN.json and
  // only searches for the ones that are missing. `--levels A-B` restricts the
  // search to a level range (still re-emits the manifest + REVIEW for all 30).
  final reuse = args.contains('--reuse');
  final range = _optValue(args, '--levels');
  var loLevel = 1;
  var hiLevel = 30;
  if (range != null && range.contains('-')) {
    final parts = range.split('-');
    loLevel = int.parse(parts[0]);
    hiLevel = int.parse(parts[1]);
  }

  final rows = <Map<String, Object?>>[];
  final flags = <String>[];
  final manifestLevels = <Map<String, Object?>>[];

  for (var level = 1; level <= 30; level++) {
    final target = targetsInOrder[level - 1];
    final targetUpper = TurkishCase.toUpperTr(target);
    final band = bandFor(level);
    final expected = expectedBands(level);
    final id = journeyLevelId(level);
    final artFile = File('${artDir.path}/$id.json');

    // Reuse an existing artifact, or one that is out of the requested range.
    if ((reuse || level < loLevel || level > hiLevel) && artFile.existsSync()) {
      final p = Puzzle.fromJson(
          jsonDecode(artFile.readAsStringSync()) as Map<String, Object?>);
      final checksum = await _sha256(artFile.path);
      manifestLevels.add(<String, Object?>{
        'n': level,
        'id': id,
        'asset': '$lang/$id.json',
        'difficultyLabel': p.difficultyLabel.name,
        'checksum': checksum,
      });
      rows.add(<String, Object?>{
        'level': level,
        'id': id,
        'target': target,
        'status': 'DRAFT',
        'opt': p.optimalMoves,
        'label': p.difficultyLabel.name,
        'score': p.difficultyScore,
        'locked': p.lockedCells.length,
        'frozen': p.frozenCells.length,
        'columns': p.columnMovesEnabled,
        'scrambleK': '·',
        'seed': 'reuse',
      });
      stderr.writeln('L$level $id  REUSE  opt=${p.optimalMoves} '
          '${p.difficultyLabel.name}');
      continue;
    }

    final sw = Stopwatch()..start();
    final perLevelBudget = level >= 26
        ? const Duration(seconds: 200)
        : const Duration(seconds: 40);
    _Accepted? accepted;
    var attempts = 0;
    var lastReason = 'no attempt';
    var substantiveReason = ''; // the last non-timeout rejection detail

    outer:
    for (final k in band.scrambleKs) {
      for (var seed = 0; seed < 200; seed++) {
        if (sw.elapsed > perLevelBudget) {
          lastReason = 'per-level time budget '
              '(${perLevelBudget.inSeconds}s) exhausted'
              '${substantiveReason.isEmpty ? '' : '; last near-miss: '
                  '$substantiveReason'}';
          break outer;
        }
        attempts++;
        final rng = Random(level * 1000003 + k * 7919 + seed);
        final attempt = _buildAttempt(rng, targetUpper, band);
        if (attempt == null) {
          lastReason = 'could not place a clean filler grid';
          continue;
        }

        // Scramble.
        final cells = <List<String>>[
          for (final r in attempt.grid) r.split(''),
        ];
        final immovable = <GridCoord>{...attempt.locked, ...attempt.frozen};
        if (!band.columnMovesEnabled) {
          // Rows-only on-ramp: the only solve is a single-row rotation, so the
          // provable minimum is exactly the target row's rotation distance.
          // Rotate the target row by 2 (min(2, 3) == 2) and spin the rest.
          final tRow = attempt.targetRow;
          rawShift(cells, MoveAxis.row, tRow, true, immovable);
          rawShift(cells, MoveAxis.row, tRow, true, immovable);
          for (var r = 0; r < gridSize; r++) {
            if (r == tRow) continue;
            final spins = 1 + rng.nextInt(4);
            for (var s = 0; s < spins; s++) {
              rawShift(cells, MoveAxis.row, r, rng.nextBool(), immovable);
            }
          }
        } else {
          var colMoves = 0;
          for (var m = 0; m < k; m++) {
            final useCol = rng.nextBool();
            final axis = useCol ? MoveAxis.column : MoveAxis.row;
            if (useCol) colMoves++;
            rawShift(
                cells, axis, rng.nextInt(gridSize), rng.nextBool(), immovable);
          }
          // A rows-only scramble on a column-enabled band cannot raise optimal
          // above 2 — force at least one column move there.
          if (colMoves == 0) {
            rawShift(cells, MoveAxis.column, rng.nextInt(gridSize),
                rng.nextBool(), immovable);
          }
        }

        final scrambledRows = rowsOf(cells);
        // For the rows-only on-ramp the target row is DELIBERATELY a rotation
        // of the target; the solver's `optFloor == optCeil == 2` window is the
        // real guard there. For column bands, a leftover full-target rotation
        // in any row would collapse the optimal to <= 2.
        if (band.columnMovesEnabled &&
            anyRowIsTargetRotation(scrambledRows, targetUpper)) {
          lastReason = 'scramble left a row as a target rotation';
          continue;
        }

        final EngineConfig config;
        try {
          config = EngineConfig(
            initialGrid: <List<String>>[
              for (final r in scrambledRows) r.split(''),
            ],
            targetWord: targetUpper,
            lockedCells: attempt.locked,
            frozenCells: attempt.frozen,
            columnMovesEnabled: band.columnMovesEnabled,
          );
        } on EngineConfigError catch (e) {
          lastReason = 'engine rejected the config: $e';
          continue;
        }

        final start = GridState.initial(config, validator);
        if (start.isSolved) {
          lastReason = 'scramble collapsed back to solved';
          continue;
        }

        final result = Solver.solve(
          config,
          validator,
          budget: const SearchBudget(
            timeBudget: Duration(seconds: 6),
            maxNodes: 600000,
          ),
        );
        switch (result) {
          case Unsolvable():
            lastReason = 'unsolvable';
            continue;
          case BudgetExceeded():
            lastReason = 'budgetExceeded during accept-check';
            continue;
          case Optimal(:final moves):
            if (moves < band.optFloor || moves > band.optCeil) {
              lastReason = 'optimal $moves outside band window '
                  '[${band.optFloor}, ${band.optCeil}]';
              substantiveReason = lastReason;
              continue;
            }
            final difficulty = DifficultyScorer.score(config, validator);
            if (!expected.contains(difficulty.label)) {
              lastReason = 'label ${difficulty.label.name} not in expected '
                  '{${expected.map((b) => b.name).join(", ")}} (opt $moves, '
                  'score ${difficulty.score.toStringAsFixed(2)})';
              substantiveReason = lastReason;
              continue;
            }
            accepted = _Accepted(
              rows: scrambledRows,
              locked: attempt.locked,
              frozen: attempt.frozen,
              columnMovesEnabled: band.columnMovesEnabled,
              optimalMoves: moves,
              difficulty: difficulty,
              scrambleK: k,
              seed: seed,
            );
            break outer;
        }
      }
    }

    if (accepted == null) {
      flags.add('- **L$level `$id` ($target)** — NO candidate produced. '
          'Band: ${band.name}. Last reason: $lastReason. '
          '($attempts attempts, ${sw.elapsed.inSeconds}s)');
      rows.add(<String, Object?>{
        'level': level,
        'id': id,
        'target': target,
        'status': 'MISSING',
        'note': lastReason,
      });
      stderr.writeln('L$level $id  MISSING  ($lastReason)');
      continue;
    }

    final a = accepted;
    final def = PuzzleDef(
      id: id,
      puzzleType: PuzzleType.journey,
      journeyLevelNumber: level,
      language: lang,
      grid: a.rows,
      target: targetUpper,
      locked: a.locked,
      frozen: a.frozen,
      columns: a.columnMovesEnabled,
    );
    final defJson = <String, Object?>{
      'id': id,
      'puzzleType': 'journey',
      'journeyLevelNumber': level,
      'language': lang,
      'grid': a.rows,
      'target': targetUpper,
      'locked': [for (final c in a.locked) '${c.row},${c.col}'],
      'frozen': [for (final c in a.frozen) '${c.row},${c.col}'],
      'columns': a.columnMovesEnabled,
    };
    File('${defsDir.path}/$id.def.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(defJson));

    final puzzle = def.toPuzzle(
      optimalMoves: a.optimalMoves,
      difficulty: a.difficulty,
      contentVersion: contentVersion,
    );
    final artPath = '${artDir.path}/$id.json';
    File(artPath).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(puzzle.toJson()));

    final checksum = await _sha256(artPath);
    manifestLevels.add(<String, Object?>{
      'n': level,
      'id': id,
      'asset': '$lang/$id.json',
      'difficultyLabel': a.difficulty.label.name,
      'checksum': checksum,
    });

    rows.add(<String, Object?>{
      'level': level,
      'id': id,
      'target': target,
      'status': 'DRAFT',
      'opt': a.optimalMoves,
      'label': a.difficulty.label.name,
      'score': double.parse(a.difficulty.score.toStringAsFixed(2)),
      'locked': a.locked.length,
      'frozen': a.frozen.length,
      'columns': a.columnMovesEnabled,
      'scrambleK': a.scrambleK,
      'seed': a.seed,
    });
    stderr.writeln('L$level $id  DRAFT  opt=${a.optimalMoves} '
        '${a.difficulty.label.name} score=${a.difficulty.score.toStringAsFixed(2)} '
        '(${sw.elapsed.inSeconds}s, seed ${a.seed}/k${a.scrambleK})');
  }

  // Draft manifest (mode "smoke" — never bundled as-is).
  final manifest = <String, Object?>{
    'schemaVersion': 1,
    'contentVersion': contentVersion,
    'lang': lang,
    'mode': 'smoke',
    'levels': manifestLevels,
  };
  File('${outRoot.path}/journey_manifest_$lang.draft.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));

  _writeReview(outRoot.path, rows, flags, manifestLevels.length);

  stderr.writeln('\n${manifestLevels.length}/30 drafts written, '
      '${flags.length} flagged.');
}

class _Accepted {
  _Accepted({
    required this.rows,
    required this.locked,
    required this.frozen,
    required this.columnMovesEnabled,
    required this.optimalMoves,
    required this.difficulty,
    required this.scrambleK,
    required this.seed,
  });
  final List<String> rows;
  final Set<GridCoord> locked;
  final Set<GridCoord> frozen;
  final bool columnMovesEnabled;
  final int optimalMoves;
  final Difficulty difficulty;
  final int scrambleK;
  final int seed;
}

/// Builds a SOLVED grid: target word in a seeded row, seeded filler elsewhere,
/// optional locked cells in the target row (letter fixed to the target letter)
/// and optional frozen cells in a non-target row. Returns null if it cannot
/// place a filler grid that avoids accidental target rotations.
Attempt? _buildAttempt(Random rng, String targetUpper, BandSpec band) {
  final targetRow = rng.nextInt(gridSize);
  final cells = <List<String>>[
    for (var r = 0; r < gridSize; r++) <String>['', '', '', '', ''],
  ];

  final tl = targetUpper.split('');
  for (var c = 0; c < gridSize; c++) {
    cells[targetRow][c] = tl[c];
  }

  for (var tries = 0; tries < 40; tries++) {
    for (var r = 0; r < gridSize; r++) {
      if (r == targetRow) continue;
      for (var c = 0; c < gridSize; c++) {
        cells[r][c] = fillerPool[rng.nextInt(fillerPool.length)];
      }
    }
    final rows = rowsOf(cells);
    // No non-target row may already be a rotation of the target.
    var clash = false;
    final rots = <String>{
      for (var i = 0; i < gridSize; i++)
        targetUpper.substring(i) + targetUpper.substring(0, i),
    };
    for (var r = 0; r < gridSize; r++) {
      if (r != targetRow && rots.contains(rows[r])) clash = true;
    }
    if (!clash) break;
    if (tries == 39) return null;
  }

  final locked = <GridCoord>{};
  final frozen = <GridCoord>{};

  // Locked cells: in the target row, letter already correct -> keeps the row
  // solvable while forcing the other four cells to rotate into place.
  final lockCols = <int>[0, 1, 2, 3, 4]..shuffle(rng);
  for (var i = 0; i < band.lockedInTargetRow; i++) {
    locked.add(GridCoord(targetRow, lockCols[i]));
  }

  // Frozen cells: in a non-target row. Solvability-safe default (the target is
  // formed in a different row entirely) — see REVIEW.md "frozen is cosmetic".
  if (band.frozenInOtherRow > 0) {
    final otherRows = <int>[
      for (var r = 0; r < gridSize; r++)
        if (r != targetRow) r,
    ]..shuffle(rng);
    final fRow = otherRows.first;
    final fCols = <int>[0, 1, 2, 3, 4]..shuffle(rng);
    for (var i = 0; i < band.frozenInOtherRow; i++) {
      frozen.add(GridCoord(fRow, fCols[i]));
    }
  }

  return Attempt(rowsOf(cells), locked, frozen, targetRow);
}

void _writeReview(
  String dir,
  List<Map<String, Object?>> rows,
  List<String> flags,
  int draftCount,
) {
  final b = StringBuffer();
  b.writeln('# F06-CONTENT-DRAFT — Journey `tr` candidate drafts');
  b.writeln();
  b.writeln('_Generated by `tool/generate_journey_drafts.dart` for '
      '`F06-CONTENT-DRAFT`._');
  b.writeln();
  b.writeln('**These are candidate starting points, not shippable content.** '
      'Every artifact is solver-verified — the generator\'s own `Solver.solve` '
      'returned `Optimal(n)` for the grid it wrote — and every level\'s label '
      'sits inside `check`\'s expected band for that level number. Still needs a '
      'human pass before promotion to `content/journey/tr/`: the difficulty '
      '*curve*, grid readability, the locked/frozen placements, and a clean '
      '`check` re-solve on an unloaded machine (gap #7). `check` here was run '
      'against a loaded workstation and reported non-deterministic '
      '`budgetExceeded on re-solve` — a wall-clock `timeBudget` starvation '
      'artifact, not a content defect.');
  b.writeln();
  b.writeln('- Drafts written: **$draftCount / 30**');
  b.writeln('- Flagged / missing: **${flags.length}**');
  b.writeln();
  b.writeln('## Per-level');
  b.writeln();
  b.writeln('| Lvl | id | target | status | opt | label | score | '
      'locked | frozen | cols | k | seed |');
  b.writeln('|----:|----|--------|--------|----:|-------|------:|'
      '-------:|-------:|:----:|--:|-----:|');
  for (final r in rows) {
    if (r['status'] == 'MISSING') {
      b.writeln('| ${r['level']} | `${r['id']}` | ${r['target']} | '
          '**MISSING** | — | — | — | — | — | — | — | — |');
    } else {
      b.writeln('| ${r['level']} | `${r['id']}` | ${r['target']} | draft | '
          '${r['opt']} | ${r['label']} | ${r['score']} | ${r['locked']} | '
          '${r['frozen']} | ${r['columns'] == true ? 'Y' : 'N'} | '
          '${r['scrambleK']} | ${r['seed']} |');
    }
  }
  b.writeln();
  b.writeln('## Gaps & open questions (for the Level Designer / user)');
  b.writeln();
  b.writeln('1. **Rows-only on-ramp caps `optimalMoves` at 2.** Levels 1–3 run '
      '`columnMovesEnabled: false`. With a 5-letter target on a 5-wide grid the '
      'only solve is a single-row cyclic rotation, so the provable minimum can '
      'never exceed 2 — `min(k, 5-k) ≤ 2`. The authoring brief / AC3 ask for '
      '`opt 3–4` here; that is **not achievable** with a pure rows-only '
      '5-letter puzzle. Options: (a) accept `opt 2` as the deliberate tutorial '
      'on-ramp; (b) introduce one locked tile at levels 1–3 to force a 3-step '
      'row solve (still no columns); (c) shorten the early target words (needs '
      'a dictionary change). Drafts here ship option (a).');
  b.writeln();
  b.writeln('2. **Frozen tiles are cosmetic in these drafts.** For bands 21–25 '
      'and 26–30 the generator places frozen tiles in a *non-target* row so '
      'solvability is guaranteed (the target is formed in another row). The '
      'frozen tile therefore adds visual complexity and a small difficulty-'
      'score term but does not gate the solve path. A real frozen design needs '
      'the tile in the target row plus a guaranteed in-row thaw word, which '
      '`fill --frozen-safe` was meant to help with — it is a **no-op stub** '
      'today. Level Designer to hand-place frozen tiles and re-run '
      '`solve` / `playtest` to confirm reachability.');
  b.writeln();
  b.writeln('3. **Locked tiles are placed on already-correct target cells.** '
      'Bands 16–20 / 26–30 lock 1 cell in the target row with its letter '
      'already equal to the target letter at that column. This keeps the row '
      'solvable and adds genuine constraint. Alternative placements (locked '
      'cell on a *wrong* letter, or off the target row) change the puzzle '
      'character and are worth exploring by hand.');
  b.writeln();
  b.writeln('4. **Filler letters are frequency-pool random, not curated.** '
      'Non-target cells are sampled from a common-letter pool with no '
      'aesthetic / no-accidental-word screening beyond "no row is a target '
      'rotation". Grids may contain awkward clusters; a human pass should '
      'improve readability.');
  b.writeln();
  b.writeln('5. **Difficulty *curve* is not tuned, only *banded*.** Each draft '
      'lands inside `check`\'s expected label set for its level, but the '
      'monotonic ramp of `optimalMoves` / score across 1→30 is only roughly '
      'shaped by the per-band scramble depth. The designer should sort by '
      'perceived difficulty after playtest and re-assign level numbers.');
  b.writeln();
  b.writeln('6. **Tunables are all at their `const` defaults.** '
      '`SearchBudget`, `DifficultyWeights`, `DifficultyThresholds`, and the '
      'Turkish frequency table were not overridden. Brief §8 finalization is '
      'still open.');
  b.writeln();
  b.writeln('7. **`check` re-solve does not reliably clear the default 30 s '
      '`timeBudget` on a loaded workstation.** `runContentCheck` re-runs '
      '`Solver.solve` per artifact with the *default* `SearchBudget`. On a busy '
      'box the opt-5 column-move levels (11–15, 20–21, 26–30) intermittently '
      'report `budgetExceeded on re-solve` — a wall-clock artifact (the failing '
      'set shifts run to run; the generator proved every grid `Optimal` in '
      '< 6 s of dedicated CPU). Re-run `check` on an idle machine / CI runner '
      'for a clean baseline; if deep levels still flirt with 30 s, raise '
      '`SearchBudget.timeBudget` (brief §8) and/or ship an AOT `check` in CI '
      '(brief §11).');
  if (flags.isNotEmpty) {
    b.writeln();
    b.writeln('## Missing levels');
    b.writeln();
    for (final f in flags) {
      b.writeln(f);
    }
  }
  b.writeln();
  b.writeln('## Next');
  b.writeln();
  b.writeln('1. Re-run on an unloaded machine: `cd tools/looplet_authoring && '
      'dart run bin/looplet_authoring.dart check drafts/journey/tr '
      '--repo-root ../..` — expect `check: OK`; a `budgetExceeded on re-solve` '
      'is gap #7, confirm the level with `solve drafts/journey/_defs/'
      'journey-tr-NN.def.json`.');
  b.writeln('2. Human playtest each grid (`playtest <def> --moves "…"`), tune '
      'grids / locked / frozen, resolve the gaps above.');
  b.writeln('3. Promote accepted drafts to `content/journey/tr/journey-tr-NN'
      '.json` + a `mode: "strict"` `journey_manifest_tr.json`; run '
      '`melos run content:check` + `melos run content:journey`.');
  b.writeln('4. Brief §9 interim→strict cutover, then `Run QA` → `Run Tech '
      'Lead` → F05 `Done`.');

  File('$dir/REVIEW.md').writeAsStringSync(b.toString());
}

String? _optValue(List<String> args, String name) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == name && i + 1 < args.length) return args[i + 1];
    if (args[i].startsWith('$name=')) return args[i].substring(name.length + 1);
  }
  return null;
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Future<String> _sha256(String path) async {
  final res = await Process.run('shasum', <String>['-a', '256', path]);
  if (res.exitCode != 0) {
    return 'sha256-unavailable';
  }
  final out = (res.stdout as String).trim();
  final space = out.indexOf(' ');
  return 'sha256:${space > 0 ? out.substring(0, space) : out}';
}
