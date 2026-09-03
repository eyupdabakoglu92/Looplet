import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looplet_dictionary/looplet_dictionary.dart';

import 'root_bundle_asset_source.dart';

/// Where dictionary assets are read from. Overridden in tests.
final dictionaryAssetSourceProvider = Provider<DictionaryAssetSource>(
  (ref) => const RootBundleDictionaryAssetSource(),
);

/// Session-level dictionary service. Loaded once; disposed with the scope.
///
/// Starts on Turkish (the launch language). Language switching will re-resolve
/// this provider once the settings/localization layer lands.
final dictionaryServiceProvider = FutureProvider<DictionaryService>((
  ref,
) async {
  final source = ref.watch(dictionaryAssetSourceProvider);
  final service = await DictionaryService.load(
    language: LanguageCode.tr,
    assetSource: source,
  );
  ref.onDispose(service.dispose);
  return service;
});
