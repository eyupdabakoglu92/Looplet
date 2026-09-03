import 'dart:io';

import 'package:looplet_dictionary/looplet_dictionary.dart';

/// Serves in-memory asset text keyed by bundle path. Throws (like a missing
/// bundle asset) when a path is not registered.
class MapAssetSource implements DictionaryAssetSource {
  MapAssetSource(this._files);

  final Map<String, String> _files;

  @override
  Future<String> readAsset(String path) async {
    final content = _files[path];
    if (content == null) {
      throw StateError('no fake asset registered for "$path"');
    }
    return content;
  }
}

/// Reads the real shipped `assets/` files from disk. `dart test` runs with the
/// package root as CWD.
class FileAssetSource implements DictionaryAssetSource {
  @override
  Future<String> readAsset(String path) {
    final local = path.replaceFirst('packages/looplet_dictionary/', '');
    return File(local).readAsString();
  }
}

/// Records the diagnostic codes the service emits.
class RecordingLogger implements DictionaryLogger {
  final List<String> warns = <String>[];
  final List<String> errors = <String>[];

  @override
  void warn(String code,
      {Map<String, Object?> data = const <String, Object?>{}}) {
    warns.add(code);
  }

  @override
  void error(
    String code, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    errors.add(code);
  }
}

/// A minimal valid `dictionary.json` string for [language].
String assetJson({
  required String language,
  required List<String> words,
  required List<String> targets,
  int schemaVersion = 1,
}) {
  String arr(List<String> xs) => xs.map((String w) => '"$w"').join(',');
  return '{"schemaVersion":$schemaVersion,"language":"$language",'
      '"words":[${arr(words)}],"targets":[${arr(targets)}]}';
}
