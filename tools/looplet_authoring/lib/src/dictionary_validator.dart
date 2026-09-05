import 'dart:io';

import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// Reads the shipped `packages/looplet_dictionary/assets/<lang>/dictionary.json`
/// from disk, relative to [repoRoot].
class _FileDictionaryAssetSource implements DictionaryAssetSource {
  _FileDictionaryAssetSource(this.repoRoot);

  final String repoRoot;

  @override
  Future<String> readAsset(String path) =>
      File('$repoRoot/$path').readAsString();
}

/// Adapts F01's [DictionaryService] to the engine's [WordValidator] port —
/// exactly what the app uses at runtime, so a shipped `optimalMoves` matches
/// in-game reality.
class DictionaryWordValidator implements WordValidator {
  DictionaryWordValidator(this.service);

  final DictionaryService service;

  @override
  bool isValidWord(String candidate, {int minLength = 1}) =>
      service.isValidWord(candidate, minLength: minLength);
}

/// Loads the production dictionary for [language] and returns the validator plus
/// the underlying service (for target-eligibility checks in `check`).
Future<DictionaryWordValidator> loadDictionaryValidator({
  required String language,
  required String repoRoot,
}) async {
  final code = LanguageCode.fromCode(language);
  if (code == null) {
    throw ArgumentError('unsupported language "$language"');
  }
  final service = await DictionaryService.load(
    language: code,
    assetSource: _FileDictionaryAssetSource(repoRoot),
  );
  return DictionaryWordValidator(service);
}
