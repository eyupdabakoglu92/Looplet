import 'package:looplet_core/looplet_core.dart';

import 'dictionary_asset.dart';
import 'dictionary_asset_source.dart';
import 'dictionary_logger.dart';
import 'language_code.dart';

/// Validates words against a curated, language-scoped list.
///
/// Contract: `ai-system/features/f01-dictionary-service/architecture.md`.
///
/// * Construct with [load]; it never throws for a missing/corrupt/empty asset —
///   it returns a fail-safe service ([isFailSafe] `true`) whose queries all
///   return `false`.
/// * [isValidWord] / [isEligibleTarget] / [normalize] are pure and synchronous.
/// * [switchLanguage] atomically replaces the active language index.
/// * Calling a query after [dispose] throws [StateError].
class DictionaryService {
  DictionaryService._(this._assetSource, this._logger, this._index);

  final DictionaryAssetSource _assetSource;
  final DictionaryLogger _logger;

  _LanguageIndex _index;
  bool _disposed = false;

  /// Loads and indexes the [language] asset via [assetSource].
  static Future<DictionaryService> load({
    required LanguageCode language,
    required DictionaryAssetSource assetSource,
    DictionaryLogger? logger,
  }) async {
    final effectiveLogger = logger ?? const NoopDictionaryLogger();
    final index = await _buildIndex(language, assetSource, effectiveLogger);
    return DictionaryService._(assetSource, effectiveLogger, index);
  }

  /// The active language.
  LanguageCode get language => _index.language;

  /// `true` when the active language's asset was missing, corrupt, or empty and
  /// every lookup therefore returns `false`.
  bool get isFailSafe => _index.isFailSafe;

  /// Replaces the active language index with [language]'s. A no-op (still a
  /// completed future) when [language] is already active. Leaves no entries
  /// from the previous language.
  Future<void> switchLanguage(LanguageCode language) async {
    _ensureUsable();
    if (language == _index.language) return;
    _index = await _buildIndex(language, _assetSource, _logger);
  }

  /// `true` iff [candidate] normalizes to a letters-only word of at least
  /// [minLength] letters that exists in the active language's list. The length
  /// rule is checked without consulting the list.
  bool isValidWord(String candidate, {int minLength = 1}) {
    _ensureUsable();
    assert(minLength >= 1, 'minLength must be >= 1');
    final normalized = _index.normalize(candidate);
    if (normalized == null) return false;
    if (normalized.runes.length < minLength) return false;
    return _index.words.contains(normalized);
  }

  /// `true` iff [candidate] normalizes to an entry in the active language's
  /// curated target list.
  bool isEligibleTarget(String candidate) {
    _ensureUsable();
    final normalized = _index.normalize(candidate);
    if (normalized == null) return false;
    return _index.targets.contains(normalized);
  }

  /// The normalization used internally, exposed so callers (F02 frozen-tile
  /// checks, F06 content) build candidates the same way. Returns `null` when
  /// [input] contains a non-letter.
  String? normalize(String input) {
    _ensureUsable();
    return _index.normalize(input);
  }

  /// Releases in-memory structures. After this, queries throw [StateError].
  Future<void> dispose() async {
    _disposed = true;
    _index = _LanguageIndex.empty(_index.language);
  }

  void _ensureUsable() {
    if (_disposed) {
      throw StateError('DictionaryService used after dispose()');
    }
  }

  static Future<_LanguageIndex> _buildIndex(
    LanguageCode language,
    DictionaryAssetSource assetSource,
    DictionaryLogger logger,
  ) async {
    final normalizeFn =
        language == LanguageCode.tr ? normalizeTurkish : normalizeLatin;

    final String raw;
    try {
      raw = await assetSource.readAsset(language.assetPath);
    } on Object catch (error) {
      // rootBundle throws an Error (not an Exception) for a missing asset, so
      // this must catch broadly.
      logger.warn('dictionary.asset.missing', data: <String, Object?>{
        'language': language.code,
        'path': language.assetPath,
        'error': error.toString(),
      });
      return _LanguageIndex.empty(language);
    }

    final DictionaryAsset asset;
    try {
      asset = DictionaryAsset.parse(raw, expectedLanguage: language);
    } on FormatException catch (error, stackTrace) {
      logger.error(
        'dictionary.asset.corrupt',
        error: error,
        stackTrace: stackTrace,
        data: <String, Object?>{'language': language.code},
      );
      return _LanguageIndex.empty(language);
    }

    final words = <String>{};
    for (final entry in asset.words) {
      final normalized = normalizeFn(entry);
      if (normalized != null) words.add(normalized);
    }

    final targets = <String>{};
    for (final entry in asset.targets) {
      final normalized = normalizeFn(entry);
      if (normalized != null && words.contains(normalized)) {
        targets.add(normalized);
      }
    }

    if (words.isEmpty) {
      logger.warn('dictionary.asset.empty',
          data: <String, Object?>{'language': language.code});
      return _LanguageIndex.empty(language);
    }

    return _LanguageIndex(
      language: language,
      words: words,
      targets: targets,
      isFailSafe: false,
      normalizeFn: normalizeFn,
    );
  }
}

/// Immutable per-language lookup. Swapped as one field assignment so a
/// synchronous query can never observe a half-built index.
class _LanguageIndex {
  _LanguageIndex({
    required this.language,
    required this.words,
    required this.targets,
    required this.isFailSafe,
    required this.normalizeFn,
  });

  factory _LanguageIndex.empty(LanguageCode language) => _LanguageIndex(
        language: language,
        words: const <String>{},
        targets: const <String>{},
        isFailSafe: true,
        normalizeFn:
            language == LanguageCode.tr ? normalizeTurkish : normalizeLatin,
      );

  final LanguageCode language;
  final Set<String> words;
  final Set<String> targets;
  final bool isFailSafe;
  final String? Function(String) normalizeFn;

  String? normalize(String input) => normalizeFn(input);
}
