import 'package:flutter/services.dart' show rootBundle;
import 'package:looplet_dictionary/looplet_dictionary.dart';

/// [DictionaryAssetSource] backed by the Flutter asset bundle. The dictionary
/// files are declared under `flutter/assets` in `pubspec.yaml`.
class RootBundleDictionaryAssetSource implements DictionaryAssetSource {
  const RootBundleDictionaryAssetSource();

  @override
  Future<String> readAsset(String path) => rootBundle.loadString(path);
}
