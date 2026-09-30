import 'dart:convert';
import 'package:path/path.dart' as p;

import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

import 'corpus_quality.dart';
import 'daily_quality.dart';
import 'daily_source.dart';
import 'puzzle_def.dart';
import 'quality_io.dart';

PuzzleDef puzzleDefinition(Puzzle p) => PuzzleDef(
    id: p.id,
    puzzleType: p.puzzleType,
    journeyLevelNumber: p.journeyLevelNumber,
    dailyDate: p.dailyDate,
    language: p.language,
    grid: p.grid,
    target: p.targetWord,
    locked: p.lockedCells,
    frozen: p.frozenCells,
    columns: p.columnMovesEnabled);

String _mask(EngineConfig c) => '${(c.lockedCells.toList()..sort()).join(';')}|'
    '${(c.frozenCells.toList()..sort()).join(';')}|${c.columnMovesEnabled}';
String _multiset(EngineConfig c) =>
    (TurkishCase.toLowerTr(c.initialGrid.expand((r) => r).join()).split('')
          ..sort())
        .join();
String _stateSignature(EngineConfig c, GridState s) =>
    '${_mask(c)}|${s.canonicalKey()}';

/// Compare both directions: solving is terminal and thaw is irreversible.
bool nearDuplicate(EngineConfig a, EngineConfig b, CorpusWords words) {
  if (_mask(a) != _mask(b) || _multiset(a) != _multiset(b)) return false;
  bool reaches(EngineConfig from, EngineConfig to) {
    final target = _stateSignature(to, GridState.initial(to, words));
    var frontier = [GridState.initial(from, words)];
    final seen = <String>{};
    for (var depth = 0; depth <= 2; depth++) {
      final next = <GridState>[];
      for (final state in frontier) {
        final key = _stateSignature(from, state);
        if (key == target) return true;
        if (!seen.add(key) || depth == 2) continue;
        for (final move in from.legalMoves(state)) {
          final step = state.applyMove(move, from, words);
          if (step.applied) next.add(step.state);
        }
      }
      frontier = next;
    }
    return false;
  }

  return reaches(a, b) || reaches(b, a);
}

Map<String, dynamic> poolRules(List<Map<String, dynamic>> days,
    {required bool pilot}) {
  final failures = <String>[];
  if (days.length != (pilot ? 8 : 60)) {
    failures.add('expected ${pilot ? 8 : 60} days');
  }
  final targets = days.map((d) => d['target']).toSet();
  if (targets.length != days.length) failures.add('targets must all differ');
  if (days.any((d) => d['accepted'] != true)) {
    failures.add('individual required rules failed or UNKNOWN');
  }
  final dates = days.map((d) => DateTime.parse(d['date'] as String)).toList()
    ..sort();
  if (dates.toSet().length != dates.length) {
    failures.add('calendar duplicate');
  }
  final heavy =
      days.where((d) => DateTime.parse(d['date'] as String).weekday >= 5);
  if (pilot) {
    for (final kind in ['open', 'locked', 'frozen', 'both']) {
      if (days.where((d) => d['mechanic'] == kind).length < 2) {
        failures.add('pilot needs two $kind');
      }
    }
    if (heavy
        .where((d) =>
            jsonValue(d, 'difficulty.label') == 'hard' &&
            jsonValue(d, 'regression.status') == 'PASS')
        .isEmpty) {
      failures.add('pilot needs hard heavy day with proven regression');
    }
  } else if (dates.length == 60) {
    for (var i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays != 1) {
        failures.add('calendar gap/duplicate');
      }
    }
    final weeks = <String, List<Map<String, dynamic>>>{};
    for (final day in days) {
      final date = DateTime.parse(day['date'] as String);
      final monday = date
          .subtract(Duration(days: date.weekday - 1))
          .toIso8601String()
          .substring(0, 10);
      weeks.putIfAbsent(monday, () => []).add(day);
    }
    for (final entry in weeks.entries) {
      if (entry.value.length != 7) continue; // partial week: daily rules only
      if (entry.value
              .where((d) => jsonValue(d, 'regression.status') == 'PASS')
              .length <
          2) {
        failures.add('${entry.key}: need two proven regression days');
      }
      if (!entry.value.any((d) =>
          DateTime.parse(d['date'] as String).weekday >= 5 &&
          jsonValue(d, 'difficulty.label') == 'hard' &&
          jsonValue(d, 'regression.status') == 'PASS')) {
        failures
            .add('${entry.key}: need hard heavy day with proven regression');
      }
    }
  }
  final frozen =
      days.where((d) => d['mechanic'] == 'frozen' || d['mechanic'] == 'both');
  final useful =
      frozen.where((d) => jsonValue(d, 'rules.Q7.status') == 'PASS').length;
  if (useful * 2 < frozen.length) {
    failures.add('Q7 useful thaw below half of frozen days');
  }
  return verdict(failures.isEmpty ? 'PASS' : 'FAIL', {
    'failures': failures,
    'days': days.length,
    'targets': targets.length,
    'frozenDays': frozen.length,
    'usefulThawDays': useful
  });
}

Map<String, dynamic> auditDailyPool(
    {required String repoRoot,
    required String sourceDir,
    required CorpusWords words,
    required Set<String> banned,
    required SearchBudget budget,
    required bool pilot,
    void Function(String)? progress}) {
  final report = <String, dynamic>{
    'schemaVersion': 1,
    'scope': pilot ? 'pilot' : 'full',
    'result': 'FAIL',
    'independentQa': false,
    'sourceDir': p.normalize(p.absolute(sourceDir)),
    'days': <dynamic>[],
    'errors': <String>[]
  };
  final errors = report['errors'] as List<String>;
  final references = <PuzzleDef>[];
  for (final directory in ['content/journey/tr', 'content/smoke/tr']) {
    for (final file in jsonFiles('$repoRoot/$directory')) {
      final json = readObject(file.path);
      if (json['puzzleType'] == null) continue;
      references.add(puzzleDefinition(Puzzle.fromJson(json)));
    }
  }
  final journeyTargets = references
      .where((d) => d.puzzleType == PuzzleType.journey)
      .map((d) => TurkishCase.toLowerTr(d.target))
      .toSet();
  final days = <Map<String, dynamic>>[];
  final definitions = <PuzzleDef>[];
  final poolFiles = jsonFiles('$sourceDir/pool');
  final expectedNames = poolFiles.map((f) => p.basename(f.path)).toSet();
  for (final dir in ['defs', 'proofs']) {
    final names =
        jsonFiles('$sourceDir/$dir').map((f) => p.basename(f.path)).toSet();
    if (names.difference(expectedNames).isNotEmpty ||
        expectedNames.difference(names).isNotEmpty) {
      errors.add(
          '$dir must contain exactly one matching sidecar per pool artifact');
    }
  }
  for (final file in poolFiles) {
    try {
      final exportJson = readObject(file.path);
      final puzzle = Puzzle.fromJson(exportJson);
      final id = puzzle.id;
      if (!RegExp(r'^daily-tr-\d{4}-\d{2}-\d{2}$').hasMatch(id) ||
          p.basename(file.path) != '$id.json') {
        throw const FormatException('noncanonical daily file/id');
      }
      // Never trust an export to stand in for its authoring definition/proof.
      final definitionJson = readObject('$sourceDir/defs/$id.json');
      final def = PuzzleDef.fromJson(definitionJson);
      final proof = readObject('$sourceDir/proofs/$id.json');
      final day = auditDay(def, words,
          banned: banned,
          journeyTargets: journeyTargets,
          proof: proof,
          exported: puzzle,
          definitionJson: definitionJson,
          exportJson: exportJson,
          budget: budget);
      definitions.add(def);
      days.add(day);
      progress?.call(
          '$id: ${day['accepted'] == true ? 'PASS' : 'FAIL'} (${day['elapsedMs']}ms)');
    } on Object catch (e) {
      errors.add('${file.path}: $e');
    }
  }
  final duplicates = <String>[];
  for (var i = 0; i < definitions.length; i++) {
    final def = definitions[i];
    for (final other in [...references, ...definitions.take(i)]) {
      if (nearDuplicate(def.toEngineConfig(), other.toEngineConfig(), words)) {
        duplicates.add('${def.id} ~ ${other.id}');
      }
    }
  }
  final q12 = verdict(
      duplicates.isEmpty &&
              definitions
                      .map((d) => TurkishCase.toLowerTr(d.target))
                      .toSet()
                      .length ==
                  definitions.length
          ? 'PASS'
          : 'FAIL',
      {
        'duplicates': duplicates,
        'scope': 'all pool + Journey/smoke; masks and <=2 actual moves'
      });
  for (final day in days) {
    jsonMap(day['rules'])['Q12'] = q12;
  }
  report['days'] = days;
  report['Q12'] = q12;
  report['pool'] = poolRules(days, pilot: pilot);
  if (pilot) {
    try {
      final manifest = readObject('$sourceDir/daily_manifest_tr.json');
      final assignments = jsonMap(manifest['assignments']);
      if (manifest['schemaVersion'] != 1 ||
          manifest['lang'] != 'tr' ||
          manifest['contentVersion'] != 'quality-candidate-v2' ||
          assignments.length != days.length ||
          days.any((d) => assignments[d['date']] != d['id'])) {
        errors.add(
            'pilot manifest must match exactly the audited candidate dates/ids');
      }
    } on Object catch (e) {
      errors.add('invalid pilot manifest: $e');
    }
  } else {
    final pack = buildDailyPack('$sourceDir/daily_manifest_tr.json');
    if (pack.pack == null) errors.addAll(pack.failures);
    // Strict corpus readiness; pilot can use a prospective corpus separately.
    final asset = readObject(
        '$repoRoot/packages/looplet_dictionary/assets/tr/dictionary.json');
    errors.addAll(
        auditCorpus('$repoRoot/tools/looplet_authoring/data/tr', asset));
    final productionWords = CorpusWords(asset);
    if (words.words.difference(productionWords.words).isNotEmpty ||
        productionWords.words.difference(words.words).isNotEmpty ||
        words.targets.difference(productionWords.targets).isNotEmpty ||
        productionWords.targets.difference(words.targets).isNotEmpty) {
      errors.add('full audit must use the exact runtime corpus');
    }
  }
  try {
    final fingerprint = qualityFingerprint(repoRoot, sourceDir);
    report['files'] = fingerprint;
    report['inputHash'] = fingerprintHash(fingerprint);
  } on Object catch (e) {
    errors.add('fingerprint incomplete: $e');
  }
  report['result'] = errors.isEmpty &&
          q12['status'] == 'PASS' &&
          jsonValue(report, 'pool.status') == 'PASS'
      ? 'PASS'
      : 'FAIL';
  return report;
}

/// Production pack gate. Dev packs have a separate explicit CLI opt-in and
/// contentVersion marker; a pilot/partial/stale report is never production proof.
void verifyQualityReport(String repoRoot, String sourceDir, String reportPath) {
  final report = readObject(reportPath);
  final days = report['days'];
  if (report['schemaVersion'] != 1 ||
      report['scope'] != 'full' ||
      report['result'] != 'PASS' ||
      jsonValue(report, 'pool.status') != 'PASS' ||
      jsonValue(report, 'Q12.status') != 'PASS' ||
      days is! List ||
      days.length != 60 ||
      (report['errors'] as List?)?.isNotEmpty != false) {
    throw StateError('missing or failed full 60-day quality evidence');
  }
  final ids = days.map((d) => jsonValue(d, 'id')).toSet();
  final poolIds = jsonFiles('$sourceDir/pool')
      .map((f) => p.basenameWithoutExtension(f.path))
      .toSet();
  if (ids.length != 60 ||
      ids.difference(poolIds).isNotEmpty ||
      poolIds.difference(ids).isNotEmpty) {
    throw StateError('report does not cover the exact source pool');
  }
  final expected = qualityFingerprint(repoRoot, sourceDir);
  if (jsonEncode(report['files']) != jsonEncode(expected) ||
      report['inputHash'] != fingerprintHash(expected)) {
    throw StateError(
        'stale quality evidence: source/corpus/engine/tool/config changed');
  }
  if (poolRules(jsonMaps(days), pilot: false)['status'] != 'PASS') {
    throw StateError('pool aggregate evidence is incomplete or inconsistent');
  }
  for (final rawDay in days) {
    final day = jsonMap(rawDay);
    final rules = day['rules'] is Map ? jsonMap(day['rules']) : null;
    final kind = day['mechanic'];
    if (day['accepted'] != true ||
        rules == null ||
        !['open', 'locked', 'frozen', 'both'].contains(kind) ||
        !['Q1', 'Q2', 'Q3', 'Q4', 'Q8', 'Q10', 'Q11', 'Q12']
            .every((key) => jsonValue(rules[key], 'status') == 'PASS') ||
        jsonValue(rules['Q5'], 'status') != (kind == 'open' ? 'N/A' : 'PASS') ||
        jsonValue(rules['Q6'], 'status') !=
            (kind == 'open' || kind == 'locked' ? 'N/A' : 'PASS')) {
      throw StateError('incomplete day evidence or invalid N/A');
    }
  }
}
