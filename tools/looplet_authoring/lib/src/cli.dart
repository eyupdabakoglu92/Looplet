import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

import 'content_check.dart';
import 'daily_source.dart';
import 'dictionary_validator.dart';
import 'move_shorthand.dart';
import 'puzzle_def.dart';
import 'turkish_frequency.dart';

/// Builds the CLI. `out` / `err` are injectable so tests can capture output.
CommandRunner<int> buildRunner({StringSink? out, StringSink? err}) {
  final stdOut = out ?? stdout;
  final stdErr = err ?? stderr;
  return CommandRunner<int>(
      'looplet_authoring', 'Build-time level-authoring toolchain for LOOPLET.')
    ..addCommand(_SolveCommand(stdOut, stdErr))
    ..addCommand(_PlaytestCommand(stdOut, stdErr))
    ..addCommand(_ExportCommand(stdOut, stdErr))
    ..addCommand(_CheckCommand(stdOut, stdErr))
    ..addCommand(_PackDailyCommand(stdOut, stdErr))
    ..addCommand(_FillCommand(stdOut, stdErr));
}

const String _contentVersionDefault = 'dev';

abstract class _BaseCommand extends Command<int> {
  _BaseCommand(this.out, this.err);
  final StringSink out;
  final StringSink err;

  String get repoRoot => argResults?['repo-root'] as String? ?? '.';

  /// Turns domain exceptions into a non-zero exit + a stderr message instead of
  /// an uncaught crash. Argument-usage errors still propagate to the runner.
  @override
  Future<int> run() async {
    try {
      return await execute();
    } on UsageException {
      rethrow;
    } on Object catch (e) {
      err.writeln('error: $e');
      return 1;
    }
  }

  Future<int> execute();
}

// --- solve -------------------------------------------------------------------

class _SolveCommand extends _BaseCommand {
  _SolveCommand(super.out, super.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('cap', defaultsTo: '1000');
  }

  @override
  String get name => 'solve';
  @override
  String get description =>
      'Solve a puzzle definition: optimal moves + difficulty + one solution.';

  @override
  Future<int> execute() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      err.writeln('usage: solve <def.json>');
      return 64;
    }
    final def = PuzzleDef.fromFile(rest.first);
    final validator = await loadDictionaryValidator(
        language: def.language, repoRoot: repoRoot);
    final config = def.toEngineConfig();
    final result = Solver.solve(config, validator);

    switch (result) {
      case Optimal(:final moves, :final sequence):
        final difficulty = DifficultyScorer.score(config, validator);
        out.writeln('solvable: yes');
        out.writeln('optimalMoves: $moves');
        out.writeln('sequence: ${formatMoves(sequence)}');
        out.writeln('difficultyScore: '
            '${difficulty.score.toStringAsFixed(3)} (${difficulty.label.name})');
        out.writeln('breakdown: ${jsonEncode(difficulty.breakdown)}');
        return 0;
      case Unsolvable():
        out.writeln('solvable: no (unsolvable)');
        return 0;
      case BudgetExceeded(:final budget):
        out.writeln(
            'solvable: unknown (budgetExceeded: depth ${budget.maxDepth} '
            '/ ${budget.maxNodes} nodes / ${budget.timeBudget.inSeconds}s)');
        return 0;
    }
  }
}

// --- playtest --------------------------------------------------------------

class _PlaytestCommand extends _BaseCommand {
  _PlaytestCommand(super.out, super.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('moves', mandatory: true, help: 'e.g. "R0 D2 L4"');
  }

  @override
  String get name => 'playtest';
  @override
  String get description =>
      'Apply a move sequence to a puzzle and report each step.';

  @override
  Future<int> execute() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      err.writeln('usage: playtest <def.json> --moves "R0 D2 L4"');
      return 64;
    }
    final def = PuzzleDef.fromFile(rest.first);
    final validator = await loadDictionaryValidator(
        language: def.language, repoRoot: repoRoot);
    final config = def.toEngineConfig();
    final engine = GridEngine(config, validator: validator);
    final moves = parseMoves(argResults!['moves'] as String);

    for (var i = 0; i < moves.length; i++) {
      final step = engine.applyMove(moves[i]);
      final tag =
          step.applied ? 'applied' : 'rejected(${step.rejectedReason?.name})';
      out.writeln('step ${i + 1} ${formatMove(moves[i])}: $tag'
          '${step.thawedThisStep ? ' +thaw' : ''}'
          '${step.solvedThisStep ? ' +solved' : ''}');
    }
    out.writeln('moveCount: ${engine.moveCount}');
    out.writeln('solved: ${engine.isSolved}');
    return 0;
  }
}

// --- export --------------------------------------------------------------

class _ExportCommand extends _BaseCommand {
  _ExportCommand(super.out, super.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('out', mandatory: true, help: 'artifact path')
      ..addOption('content-version', defaultsTo: _contentVersionDefault);
  }

  @override
  String get name => 'export';
  @override
  String get description =>
      'Solve + rate a puzzle and write a validated Puzzle artifact. Refuses '
      'unsolvable / budget-exceeded / trivial puzzles.';

  @override
  Future<int> execute() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      err.writeln('usage: export <def.json> --out <path>');
      return 64;
    }
    final def = PuzzleDef.fromFile(rest.first);
    final validator = await loadDictionaryValidator(
        language: def.language, repoRoot: repoRoot);
    final config = def.toEngineConfig();
    final result = Solver.solve(config, validator);

    switch (result) {
      case Unsolvable():
        err.writeln('refusing to export "${def.id}": unsolvable');
        return 1;
      case BudgetExceeded():
        err.writeln('refusing to export "${def.id}": budgetExceeded');
        return 1;
      case Optimal(:final moves):
        if (moves == 0) {
          err.writeln(
              'refusing to export "${def.id}": trivial (optimalMoves 0)');
          return 1;
        }
        final difficulty = DifficultyScorer.score(config, validator);
        final puzzle = def.toPuzzle(
          optimalMoves: moves,
          difficulty: difficulty,
          contentVersion: argResults!['content-version'] as String,
        );
        final outPath = argResults!['out'] as String;
        final file = File(outPath);
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(
            const JsonEncoder.withIndent('  ').convert(puzzle.toJson()));
        out.writeln(
            'wrote $outPath (optimalMoves $moves, ${difficulty.label.name})');
        return 0;
    }
  }
}

// --- check --------------------------------------------------------------

class _CheckCommand extends _BaseCommand {
  _CheckCommand(super.out, super.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('window-days', defaultsTo: '30');
  }

  @override
  String get name => 'check';
  @override
  String get description =>
      'Validate every Puzzle artifact under a directory (the CI content gate).';

  @override
  Future<int> execute() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      err.writeln('usage: check <dir>');
      return 64;
    }
    final failures = await runContentCheck(
      root: rest.first,
      repoRoot: repoRoot,
      noRepeatWindowDays: int.parse(argResults!['window-days'] as String),
    );
    if (failures.isEmpty) {
      out.writeln('check: OK');
      return 0;
    }
    for (final failure in failures) {
      err.writeln('check FAIL: $failure');
    }
    err.writeln('check: ${failures.length} failure(s)');
    return 1;
  }
}

// --- pack-daily ------------------------------------------------------------

class _PackDailyCommand extends _BaseCommand {
  _PackDailyCommand(super.out, super.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption(
        'out',
        help: 'the served pack to write (default: '
            '<repo-root>/build/daily/daily_pack_<lang>.json)',
      )
      ..addOption('window-days', defaultsTo: '30');
  }

  @override
  String get name => 'pack-daily';
  @override
  String get description =>
      'Build the served Daily pack (daily_pack_<lang>.json) from a '
      'daily/<lang>/ source: the manifest + pool/. Refuses, naming each broken '
      'rule, unless every F07 D2 (2) rule holds.';

  @override
  Future<int> execute() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      err.writeln('usage: pack-daily <daily/<lang> dir | manifest.json> '
          '[--out <path>]');
      return 64;
    }
    final manifestPath = _manifestPathFor(rest.first);
    if (manifestPath == null) {
      err.writeln('pack-daily: no daily_manifest_<lang>.json in ${rest.first}');
      return 1;
    }
    final result = buildDailyPack(
      manifestPath,
      noRepeatWindowDays: int.parse(argResults!['window-days'] as String),
    );
    final pack = result.pack;
    if (pack == null) {
      for (final failure in result.failures) {
        err.writeln('pack-daily FAIL: $failure');
      }
      err.writeln('pack-daily: ${result.failures.length} failure(s); '
          'nothing written');
      return 1;
    }

    final outPath = argResults!['out'] as String? ??
        '$repoRoot/build/daily/daily_pack_${pack.lang}.json';
    final outFile = File(outPath).absolute;
    final sourceDir = File(manifestPath).absolute.parent.path;
    if (outFile.path.startsWith('$sourceDir${Platform.pathSeparator}')) {
      err.writeln('pack-daily: refusing to write into the source ($outPath); '
          'the pack is build output');
      return 1;
    }
    outFile.parent.createSync(recursive: true);
    outFile.writeAsStringSync(encodeDailyPack(pack));
    out.writeln('wrote $outPath (${pack.lang}, ${pack.days.length} days '
        '${pack.days.first.dailyDate} … ${pack.days.last.dailyDate}, '
        '#${pack.days.first.dailyNumber} … #${pack.days.last.dailyNumber}, '
        'contentVersion ${pack.contentVersion})');
    return 0;
  }

  /// [arg] itself when it is a file, else the one `daily_manifest_*.json` in
  /// the directory [arg].
  static String? _manifestPathFor(String arg) {
    if (FileSystemEntity.isFileSync(arg)) return arg;
    final dir = Directory(arg);
    if (!dir.existsSync()) return null;
    final manifests = dir
        .listSync()
        .whereType<File>()
        .where(
            (f) => RegExp(r'daily_manifest_[a-z]{2}\.json$').hasMatch(f.path))
        .toList();
    return manifests.length == 1 ? manifests.single.path : null;
  }
}

// --- fill --------------------------------------------------------------

class _FillCommand extends _BaseCommand {
  _FillCommand(super.out, super.err) {
    argParser
      ..addOption('seed', mandatory: true)
      ..addOption('size', defaultsTo: '5')
      ..addOption('target')
      ..addFlag('avoid-near-target', defaultsTo: false)
      ..addFlag('frozen-safe', defaultsTo: false, help: 'reserved');
  }

  @override
  String get name => 'fill';
  @override
  String get description =>
      'Print a seeded Turkish-letter-frequency candidate grid.';

  @override
  Future<int> execute() async {
    final seed = int.parse(argResults!['seed'] as String);
    final size = int.parse(argResults!['size'] as String);
    final target = argResults!['target'] as String?;
    final avoidNear = argResults!['avoid-near-target'] as bool;

    const maxAttempts = 200;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final sampler = SeededLetterSampler(seed + attempt);
      final grid = sampler.grid(size);
      if (target != null) {
        final normalizedTarget = TurkishCase.toLowerTr(target);
        final alreadySolved =
            grid.any((row) => TurkishCase.toLowerTr(row) == normalizedTarget);
        if (alreadySolved) continue;
        if (avoidNear && hasNearTargetRun(grid, target)) continue;
      }
      for (final row in grid) {
        out.writeln(row);
      }
      return 0;
    }
    err.writeln('fill: could not generate a valid grid for seed $seed');
    return 1;
  }
}
