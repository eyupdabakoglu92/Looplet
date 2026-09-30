import 'dart:io';

import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

import 'quality_io.dart';

/// Same pure normalization and membership semantics as DictionaryService for
/// a prospective corpus, without overwriting the shipped runtime asset.
final class CorpusWords implements WordValidator {
  CorpusWords(Map<String, dynamic> asset)
      : words = (asset['words'] as List).cast<String>().toSet(),
        targets = (asset['targets'] as List).cast<String>().toSet();
  final Set<String> words;
  final Set<String> targets;
  @override
  bool isValidWord(String candidate, {int minLength = 1}) {
    final normalized = normalizeTurkish(candidate);
    return normalized != null &&
        normalized.length >= minLength &&
        words.contains(normalized);
  }
}

Map<String, dynamic> importCorpus(String dataDir) {
  final sourceDir = '$dataDir/sources/zemberek';
  final source = readObject('$sourceDir/source.json');
  for (final entry in jsonMaps(source['files'])) {
    final filename = (entry['path'] as String).split('/').last;
    final path = '$sourceDir/$filename';
    if (fileHash(path) != entry['sha256'] ||
        File(path).lengthSync() != entry['bytes']) {
      throw FormatException('source hash/length mismatch: $filename');
    }
  }
  final sourceWords = File('$sourceDir/master-dictionary.dict')
      .readAsLinesSync()
      .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
      .map((line) => line.split(RegExp(r'\s+')).first)
      .toSet();
  final legacy = readObject('$dataDir/legacy-dictionary.json');
  final curation = readObject('$dataDir/curation.json');
  final banned = loadExclusions('$dataDir/exclusions.json');
  final quarantined =
      jsonMaps(curation['quarantine']).map((e) => e['word']).toSet();
  final words = (legacy['words'] as List).cast<String>().toSet();
  final targets = (legacy['targets'] as List).cast<String>().toSet();
  final seen = <String>{};
  for (final entry in jsonMaps(curation['accepted'])) {
    final word = entry['word'] as String;
    if (!seen.add(word) || words.contains(word)) {
      throw FormatException('duplicate curation: $word');
    }
    if (normalizeTurkish(word) != word || word.length < 4 || word.length > 5) {
      throw FormatException('alphabet/length: $word');
    }
    if (!sourceWords.contains(word) || entry['source'] != 'zemberek-master') {
      throw FormatException('no exact source entry: $word');
    }
    if (banned.contains(word) || quarantined.contains(word)) {
      throw FormatException('excluded: $word');
    }
    if ((entry['review'] as String? ?? '').trim().length < 12 ||
        (entry['category'] as String? ?? '').isEmpty ||
        (entry['reviewMethod'] as String? ?? '').isEmpty) {
      throw FormatException('missing editorial rationale: $word');
    }
    words.add(word);
    if (entry['target'] == true) {
      if (word.length != 5) throw FormatException('target length: $word');
      targets.add(word);
    }
  }
  if (targets.length < 120 ||
      targets
              .difference((legacy['targets'] as List).cast<String>().toSet())
              .length <
          90) {
    throw const FormatException('coverage: need 120 targets including 90 new');
  }
  final sortedWords = words.toList()..sort();
  final sortedTargets = targets.toList()..sort();
  return {
    '_note':
        'Sourced AI-curated corpus; provenance/curation in tools/looplet_authoring/data/tr. Independent QA and pilot acceptance are separate evidence.',
    'schemaVersion': 1,
    'language': 'tr',
    'words': sortedWords,
    'targets': sortedTargets,
    'exclusionsApplied': legacy['exclusionsApplied'],
  };
}

List<String> auditCorpus(String dataDir, Map<String, dynamic> asset) {
  final failures = <String>[];
  final expected = importCorpus(dataDir);
  if (asset['schemaVersion'] != 1 || asset['language'] != 'tr') {
    failures.add('schema/language');
  }
  for (final key in ['words', 'targets']) {
    final actual = (asset[key] as List).cast<String>();
    final wanted = (expected[key] as List).cast<String>().toSet();
    if (actual.toSet().length != actual.length) failures.add('$key duplicate');
    if (actual.any((w) => normalizeTurkish(w) != w)) {
      failures.add('$key normalization');
    }
    if (wanted.difference(actual.toSet()).isNotEmpty ||
        actual.toSet().difference(wanted).isNotEmpty) {
      failures.add('$key differ from sourced curation/legacy preservation');
    }
  }
  return failures;
}

Set<String> loadExclusions(String path) {
  final json = readObject(path);
  final directions = (json['directions'] as List).cast<String>();
  const expected = {
    'horizontal-forward',
    'horizontal-reverse',
    'vertical-forward',
    'vertical-reverse'
  };
  final words = (json['words'] as List).cast<String>();
  if (json['schemaVersion'] != 1 ||
      (json['version'] as String? ?? '').isEmpty ||
      (json['source'] as String? ?? '').trim().length < 12 ||
      directions.length != 4 ||
      directions.toSet().difference(expected).isNotEmpty ||
      words.toSet().length != words.length ||
      words.any((w) => normalizeTurkish(w) != w || w.length < 3)) {
    throw const FormatException(
        'invalid versioned exclusions or scan directions');
  }
  return words.toSet();
}
