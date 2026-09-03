import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

MapAssetSource _bothLanguages() => MapAssetSource(<String, String>{
      LanguageCode.tr.assetPath: assetJson(
        language: 'tr',
        words: <String>['masal', 'çanta'],
        targets: <String>['masal'],
      ),
      LanguageCode.en.assetPath: assetJson(
        language: 'en',
        words: <String>['table', 'chair'],
        targets: <String>['table'],
      ),
    });

void main() {
  test('en service consults only the English list', () async {
    final service = await DictionaryService.load(
      language: LanguageCode.en,
      assetSource: _bothLanguages(),
    );
    expect(service.isValidWord('table', minLength: 4), isTrue);
    expect(
        service.isValidWord('masal', minLength: 4), isFalse); // Turkish entry
    expect(service.isEligibleTarget('table'), isTrue);
  });

  test('en uses ordinary lowercasing, not the Turkish map', () async {
    final service = await DictionaryService.load(
      language: LanguageCode.en,
      assetSource: _bothLanguages(),
    );
    // 'I'.toLowerCase() == 'i' for English; a Turkish map would give 'ı'.
    expect(service.normalize('TABLE'), 'table');
    expect(service.normalize('CHAIR'), 'chair');
  });

  test('switchLanguage swaps the active index with no residue', () async {
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: _bothLanguages(),
    );
    expect(service.isValidWord('masal', minLength: 4), isTrue);

    await service.switchLanguage(LanguageCode.en);
    expect(service.language, LanguageCode.en);
    expect(service.isValidWord('table', minLength: 4), isTrue);
    expect(
        service.isValidWord('masal', minLength: 4), isFalse); // no tr residue
    expect(service.isEligibleTarget('masal'), isFalse);

    await service.switchLanguage(LanguageCode.tr);
    expect(service.isValidWord('masal', minLength: 4), isTrue);
    expect(
        service.isValidWord('table', minLength: 4), isFalse); // no en residue
  });

  test('switchLanguage to the active language is a no-op', () async {
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: _bothLanguages(),
    );
    await service.switchLanguage(LanguageCode.tr);
    expect(service.language, LanguageCode.tr);
    expect(service.isValidWord('masal', minLength: 4), isTrue);
  });

  test('switching to a missing language yields a fail-safe index', () async {
    final service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: MapAssetSource(<String, String>{
        LanguageCode.tr.assetPath: assetJson(
          language: 'tr',
          words: <String>['masal'],
          targets: <String>['masal'],
        ),
      }),
    );
    await service.switchLanguage(LanguageCode.en);
    expect(service.isFailSafe, isTrue);
    expect(service.isValidWord('table'), isFalse);
  });
}
