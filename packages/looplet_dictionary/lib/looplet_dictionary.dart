/// Language-scoped word validation for LOOPLET (feature F01).
///
/// Entry point: [DictionaryService.load]. See
/// `ai-system/features/f01-dictionary-service/architecture.md` for the contract.
library looplet_dictionary;

export 'src/dictionary_asset.dart' show DictionaryAsset;
export 'src/dictionary_asset_source.dart';
export 'src/dictionary_logger.dart';
export 'src/dictionary_service.dart';
export 'src/language_code.dart';
