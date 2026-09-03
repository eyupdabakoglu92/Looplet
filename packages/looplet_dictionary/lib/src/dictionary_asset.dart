import 'dart:convert';

import 'language_code.dart';

/// Parsed form of a `dictionary.json` asset.
///
/// Source shape (contract — see
/// `ai-system/features/f01-dictionary-service/architecture.md`):
/// ```json
/// {
///   "schemaVersion": 1,
///   "language": "tr",
///   "words": ["masal", "kitap", ...],
///   "targets": ["masal", ...],
///   "exclusionsApplied": ["proper-nouns", "profanity", ...]
/// }
/// ```
class DictionaryAsset {
  DictionaryAsset({
    required this.schemaVersion,
    required this.language,
    required this.words,
    required this.targets,
    required this.exclusionsApplied,
  });

  /// The only schema version this build understands.
  static const int supportedSchemaVersion = 1;

  final int schemaVersion;
  final String language;
  final List<String> words;
  final List<String> targets;
  final List<String> exclusionsApplied;

  /// Parses [source]. Throws [FormatException] for any malformed input — bad
  /// JSON, wrong root type, unsupported `schemaVersion`, a `language` that does
  /// not match [expectedLanguage], or `words` / `targets` that are not string
  /// arrays. Callers turn that into a fail-safe service.
  static DictionaryAsset parse(
    String source, {
    required LanguageCode expectedLanguage,
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw FormatException('dictionary asset is not valid JSON: ${e.message}');
    }

    if (decoded is! Map) {
      throw const FormatException(
          'dictionary asset root must be a JSON object');
    }
    final map = decoded.cast<String, Object?>();

    final schemaVersion = map['schemaVersion'];
    if (schemaVersion is! int || schemaVersion != supportedSchemaVersion) {
      throw FormatException('unsupported schemaVersion: $schemaVersion');
    }

    final language = map['language'];
    if (language is! String || language != expectedLanguage.code) {
      throw FormatException(
        'asset language "$language" does not match expected "${expectedLanguage.code}"',
      );
    }

    final words = _stringList(map['words'], 'words');
    final targets = _stringList(map['targets'], 'targets');
    final exclusions = map.containsKey('exclusionsApplied')
        ? _stringList(map['exclusionsApplied'], 'exclusionsApplied')
        : const <String>[];

    return DictionaryAsset(
      schemaVersion: schemaVersion,
      language: language,
      words: words,
      targets: targets,
      exclusionsApplied: exclusions,
    );
  }

  static List<String> _stringList(Object? value, String field) {
    if (value is! List) {
      throw FormatException('"$field" must be a JSON array');
    }
    final result = <String>[];
    for (final entry in value) {
      if (entry is! String) {
        throw FormatException('"$field" must contain only strings');
      }
      result.add(entry);
    }
    return result;
  }
}
