import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  test('missing asset -> fail-safe, warns dictionary.asset.missing', () async {
    final logger = RecordingLogger();
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: MapAssetSource(<String, String>{}), // nothing registered
      logger: logger,
    );

    expect(service.isFailSafe, isTrue);
    expect(service.isValidWord('masal', minLength: 4), isFalse);
    expect(service.isEligibleTarget('masal'), isFalse);
    expect(logger.warns, contains('dictionary.asset.missing'));
    expect(logger.errors, isEmpty);
  });

  test('corrupt JSON -> fail-safe, errors dictionary.asset.corrupt', () async {
    final logger = RecordingLogger();
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: MapAssetSource(<String, String>{
        LanguageCode.tr.assetPath: '{ this is not json',
      }),
      logger: logger,
    );

    expect(service.isFailSafe, isTrue);
    expect(service.isValidWord('masal', minLength: 4), isFalse);
    expect(logger.errors, contains('dictionary.asset.corrupt'));
  });

  test('wrong-shape JSON (schema/language/array) -> corrupt', () async {
    Future<bool> failsafeFor(String json) async {
      final s = await DictionaryService.load(
        language: LanguageCode.tr,
        assetSource:
            MapAssetSource(<String, String>{LanguageCode.tr.assetPath: json}),
      );
      return s.isFailSafe;
    }

    expect(
        await failsafeFor(
            '{"schemaVersion":2,"language":"tr","words":[],"targets":[]}'),
        isTrue);
    expect(
        await failsafeFor(
            '{"schemaVersion":1,"language":"en","words":[],"targets":[]}'),
        isTrue);
    expect(
        await failsafeFor(
            '{"schemaVersion":1,"language":"tr","words":"nope","targets":[]}'),
        isTrue);
    expect(
        await failsafeFor(
            '{"schemaVersion":1,"language":"tr","words":[1,2],"targets":[]}'),
        isTrue);
    expect(await failsafeFor('[]'), isTrue);
  });

  test('valid but empty words -> fail-safe, warns dictionary.asset.empty',
      () async {
    final logger = RecordingLogger();
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: MapAssetSource(<String, String>{
        LanguageCode.tr.assetPath:
            assetJson(language: 'tr', words: <String>[], targets: <String>[]),
      }),
      logger: logger,
    );

    expect(service.isFailSafe, isTrue);
    expect(logger.warns, contains('dictionary.asset.empty'));
  });

  test('no logger passed -> still loads fail-safe without throwing', () async {
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: MapAssetSource(<String, String>{}),
    );
    expect(service.isFailSafe, isTrue);
  });
}
