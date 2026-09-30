import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:path/path.dart' as p;

import 'corpus_quality.dart';
import 'corpus_impact.dart';
import 'daily_generator.dart';
import 'daily_pool_quality.dart';
import 'daily_quality.dart';
import 'quality_io.dart';

/// Outer time ceiling per bounded analysis. The node and depth bounds decide
/// an accepted verdict; the ceiling only stops a runaway on a slow host.
const maxAnalysisSeconds = 300;

int analysisSeconds(String raw) {
  final seconds = int.parse(raw);
  if (seconds < 1 || seconds > maxAnalysisSeconds) {
    throw ArgumentError(
        'seconds must be 1..$maxAnalysisSeconds (F07 A7 ruling 1)');
  }
  return seconds;
}

Set<String> plannedRegressionDates(List<DateTime> dates,
    {required bool pilot, bool forceAll = false}) {
  String stamp(DateTime date) => date.toIso8601String().substring(0, 10);
  if (forceAll) return dates.map(stamp).toSet();
  if (pilot) {
    final hardCombined = dates
        .where((date) =>
            date.weekday >= DateTime.friday &&
            scheduledMechanic(date) == 'both')
        .toList()
      ..sort();
    return hardCombined.isEmpty ? {} : {stamp(hardCombined.last)};
  }
  final selected = dates.map(stamp).toSet();
  final weeks = <String, List<DateTime>>{};
  for (final date in dates) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    weeks.putIfAbsent(stamp(monday), () => []).add(date);
  }
  return {
    for (final week in weeks.values)
      if (week.length == 7 &&
          week.every((date) => selected.contains(stamp(date))))
        for (final date in week)
          if (date.weekday == DateTime.monday ||
              date.weekday == DateTime.saturday)
            stamp(date),
  };
}

class CorpusCommand extends Command<int> {
  CorpusCommand(this.action, this.out, this.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('asset')
      ..addOption('out');
  }
  final String action;
  final StringSink out, err;
  @override
  String get name => '$action-corpus';
  @override
  String get description =>
      '$action the versioned sourced Turkish corpus; no quality approval implied.';
  @override
  Future<int> run() async {
    try {
      final root = argResults!['repo-root'] as String;
      final dir = '$root/tools/looplet_authoring/data/tr';
      if (action == 'import') {
        final destination = argResults!['out'] as String?;
        if (destination == null) {
          throw ArgumentError(
              '--out is required (use staging until corpus acceptance)');
        }
        final asset = importCorpus(dir);
        writeObject(destination, asset);
        out.writeln(
            'wrote $destination: ${(asset['words'] as List).length} words; ${(asset['targets'] as List).length} targets; independent QA pending');
        return 0;
      }
      final assetPath = argResults!['asset'] as String? ??
          '$root/packages/looplet_dictionary/assets/tr/dictionary.json';
      final errors = auditCorpus(dir, readObject(assetPath));
      for (final error in errors) {
        err.writeln('corpus FAIL: $error');
      }
      out.writeln('audit-corpus: ${errors.isEmpty ? 'PASS' : 'FAIL'}');
      return errors.isEmpty ? 0 : 1;
    } on Object catch (e) {
      err.writeln('$name: $e');
      return 1;
    }
  }
}

class CorpusImpactCommand extends Command<int> {
  CorpusImpactCommand(this.out, this.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('baseline')
      ..addOption('candidate', mandatory: true)
      ..addOption('out', mandatory: true)
      ..addOption('seconds',
          defaultsTo: '$maxAnalysisSeconds',
          help:
              'Per-analysis time safety ceiling (1..$maxAnalysisSeconds); nodes/depth decide (F07 A7)')
      ..addOption('nodes', defaultsTo: '5000000')
      ..addOption('depth', defaultsTo: '16');
  }
  final StringSink out, err;
  @override
  String get name => 'audit-corpus-impact';
  @override
  String get description =>
      'Compare every Journey/smoke/Daily solve and score under current and candidate corpora.';
  @override
  Future<int> run() async {
    try {
      final root = argResults!['repo-root'] as String;
      final baseline = argResults!['baseline'] as String? ??
          '$root/packages/looplet_dictionary/assets/tr/dictionary.json';
      final candidate = argResults!['candidate'] as String;
      final output = argResults!['out'] as String;
      final budget = SearchBudget(
          timeBudget: Duration(
              seconds: analysisSeconds(argResults!['seconds'] as String)),
          maxNodes: int.parse(argResults!['nodes'] as String),
          maxDepth: int.parse(argResults!['depth'] as String));
      SearchGuard(budget, 'arguments');
      final report = auditCorpusImpact(
          repoRoot: root,
          baselineAsset: baseline,
          candidateAsset: candidate,
          budget: budget,
          progress: out.writeln);
      writeObject(output, report);
      out.writeln(
          'audit-corpus-impact: ${report['result']}; promotionReady=${report['promotionReady']} → $output');
      return report['promotionReady'] == true ? 0 : 1;
    } on Object catch (e) {
      err.writeln('audit-corpus-impact: $e');
      return 1;
    }
  }
}

class DailyQualityCommand extends Command<int> {
  DailyQualityCommand(this.action, this.out, this.err) {
    argParser
      ..addOption('repo-root', defaultsTo: '.')
      ..addOption('corpus')
      ..addOption('out', mandatory: true)
      ..addOption('seconds',
          defaultsTo: '$maxAnalysisSeconds',
          help:
              'Per-analysis time safety ceiling (1..$maxAnalysisSeconds); nodes/depth decide (F07 A7)')
      ..addOption('nodes', defaultsTo: '5000000')
      ..addOption('depth', defaultsTo: '16')
      ..addFlag('pilot', defaultsTo: true)
      ..addOption('seed', defaultsTo: '20260930')
      ..addOption('dates',
          help:
              'Focused pilot feasibility dates, comma-separated; never a full-pool override')
      ..addFlag('require-regression', defaultsTo: false)
      ..addOption('attempts', defaultsTo: '200')
      ..addOption('pilot-report')
      ..addOption('pilot-acceptance');
  }
  final String action;
  final StringSink out, err;
  @override
  String get name => '$action-daily';
  @override
  String get description => action == 'audit'
      ? 'Fresh real-engine quality proofs. Failed/UNKNOWN/missing rules return nonzero.'
      : 'Bounded reproducible candidate generation into staging, with rejection checkpoints.';
  @override
  Future<int> run() async {
    try {
      final root = argResults!['repo-root'] as String;
      final corpusPath = argResults!['corpus'] as String? ??
          '$root/packages/looplet_dictionary/assets/tr/dictionary.json';
      final output = argResults!['out'] as String;
      final pilot = argResults!['pilot'] as bool;
      final budget = SearchBudget(
          timeBudget: Duration(
              seconds: analysisSeconds(argResults!['seconds'] as String)),
          maxNodes: int.parse(argResults!['nodes'] as String),
          maxDepth: int.parse(argResults!['depth'] as String));
      SearchGuard(budget, 'arguments'); // validates even an empty pool
      final corpusAsset = readObject(corpusPath);
      final corpusFailures =
          auditCorpus('$root/tools/looplet_authoring/data/tr', corpusAsset);
      final words = CorpusWords(corpusAsset);

      final banned = loadExclusions(
          '$root/tools/looplet_authoring/data/tr/exclusions.json');
      final inputHash = sha256
          .convert(utf8.encode(jsonEncode({
            'files': qualityFingerprint(root, null),
            'corpus': fileHash(corpusPath),
            'budget': {
              'seconds': budget.timeBudget.inSeconds,
              'nodes': budget.maxNodes,
              'depth': budget.maxDepth
            },
          })))
          .toString();
      if (action == 'audit') {
        if (argResults!.rest.length != 1) {
          throw ArgumentError('audit-daily <source-dir> --out <report.json>');
        }
        final source = argResults!.rest.single;
        if (p.isWithin(p.absolute(source), p.absolute(output))) {
          throw ArgumentError('report must be outside source directory');
        }
        final report = auditDailyPool(
            repoRoot: root,
            sourceDir: source,
            words: words,
            banned: banned,
            budget: budget,
            pilot: pilot,
            progress: out.writeln);
        if (corpusFailures.isNotEmpty) {
          (report['errors'] as List).addAll(corpusFailures);
          report['result'] = 'FAIL';
        }
        report['analysisInputHash'] = inputHash;
        report['budget'] = {
          'seconds': budget.timeBudget.inSeconds,
          'nodes': budget.maxNodes,
          'depth': budget.maxDepth
        };
        writeObject(output, report);
        out.writeln(
            'audit-daily ${report['scope']}: ${report['result']} → $output');
        return report['result'] == 'PASS' ? 0 : 1;
      }
      if (corpusFailures.isNotEmpty) {
        throw StateError(
            'generation requires source-checked curated corpus: ${corpusFailures.join('; ')}');
      }
      if (p.isWithin(p.absolute('$root/content'), p.absolute(output)) ||
          p.equals(p.absolute('$root/content'), p.absolute(output))) {
        throw ArgumentError(
            'generate into a staging directory outside canonical content');
      }
      if (!pilot) {
        final pilotPath = argResults!['pilot-report'] as String?;
        final acceptancePath = argResults!['pilot-acceptance'] as String?;
        if (pilotPath == null || acceptancePath == null) {
          throw ArgumentError(
              'batch needs --pilot-report and --pilot-acceptance');
        }
        final passed = readObject(pilotPath);
        final checkpoint = readObject(acceptancePath);
        final pilotSource = resolveReportSource(root, passed['sourceDir']);
        if (passed['inputHash'] !=
            fingerprintHash(qualityFingerprint(root, pilotSource))) {
          throw StateError('pilot source changed or fingerprint missing');
        }

        if (passed['scope'] != 'pilot' ||
            passed['result'] != 'PASS' ||
            passed['analysisInputHash'] != inputHash ||
            checkpoint['pilotReportSha256'] != fileHash(pilotPath) ||
            checkpoint['decision'] != 'accepted' ||
            checkpoint['owner'] != 'Tech Lead' ||
            (checkpoint['editorialRationale'] as String? ?? '').length < 40) {
          throw StateError(
              'batch needs current accepted pilot + documented Tech Lead editorial checkpoint');
        }
      }
      final journeyTargets = <String>{};
      for (final file in jsonFiles('$root/content/journey/tr')) {
        final json = readObject(file.path);
        if (json['targetWord'] is String) {
          journeyTargets
              .add(TurkishCase.toLowerTr(json['targetWord'] as String));
        }
      }
      var dates = pilot
          ? [2, 3, 4, 7, 9, 10, 11, 14]
              .map((d) => DateTime.utc(2026, 11, d))
              .toList()
          : List.generate(
              60, (i) => DateTime.utc(2026, 11, 1).add(Duration(days: i)));
      final requestedDates = argResults!['dates'] as String?;
      if (requestedDates != null) {
        if (!pilot) {
          throw ArgumentError('--dates is restricted to pilot feasibility');
        }
        final tokens = requestedDates.split(',');
        dates = tokens.map((token) {
          final date = DateTime.tryParse(token);
          if (date == null ||
              date.toIso8601String().substring(0, 10) != token) {
            throw ArgumentError('invalid date: $token');
          }
          return DateTime.utc(date.year, date.month, date.day);
        }).toList()
          ..sort();
        if (dates.isEmpty ||
            dates.length > 8 ||
            dates.toSet().length != dates.length) {
          throw ArgumentError('focused dates must be 1..8 unique dates');
        }
      }
      final attempts = int.parse(argResults!['attempts'] as String);
      if (attempts < 1 || attempts > 200) {
        throw ArgumentError(
            'attempts must be 1..200; justify budget changes in the contract');
      }
      final result = generateDaily(
          words: words,
          banned: banned,
          journeyTargets: journeyTargets,
          dates: dates,
          seed: int.parse(argResults!['seed'] as String),
          attemptsPerDay: attempts,
          outDir: output,
          budget: budget,
          inputHash: inputHash,
          regressionDates: plannedRegressionDates(dates,
              pilot: pilot,
              forceAll: argResults!['require-regression'] as bool),
          progress: out.writeln);
      out.writeln(
          'generate-daily: ${result['status']}; ${(result['accepted'] as Map).length}/${dates.length} candidates');
      return result['status'] == 'INDIVIDUAL_CANDIDATES_READY' ? 0 : 1;
    } on Object catch (e) {
      err.writeln('$name: $e');
      return 1;
    }
  }
}
