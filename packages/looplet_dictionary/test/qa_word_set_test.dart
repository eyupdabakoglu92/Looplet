import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

/// Golden set exercised against the real shipped `assets/tr/dictionary.json`.
/// F01 success metric: 0 must-accept rejected, 0 must-reject accepted.
void main() {
  late DictionaryService service;

  setUpAll(() async {
    service = await DictionaryService.load(
      language: LanguageCode.tr,
      assetSource: FileAssetSource(),
    );
  });

  test('the shipped Turkish asset loads and is not fail-safe', () {
    expect(service.isFailSafe, isFalse);
  });

  test('must-accept words validate (>= 4 letters), any casing', () {
    const mustAccept = <String>[
      'masal',
      'MASAL',
      'Kitap',
      'deniz',
      'balık',
      'BALIK',
      'çanta',
      'orman',
      'şeker',
      'kağıt',
      'yatak',
      'zemin',
      'kırmızı',
      'kelime',
      'sandal',
    ];
    for (final word in mustAccept) {
      expect(service.isValidWord(word, minLength: 4), isTrue, reason: word);
    }
  });

  test('must-reject strings do not validate', () {
    const mustReject = <String>[
      'zzzz', 'qwxk', 'lorem', 'asdff', // not Turkish words
      'ma sal', 'kalem!', 'abc123', '', '   ', // malformed
      'kir', // 3-letter word present, but fails minLength 4
    ];
    for (final word in mustReject) {
      expect(service.isValidWord(word, minLength: 4), isFalse, reason: word);
    }
  });

  test('every shipped target is an eligible target and a valid word', () {
    const targets = <String>[
      'aslan',
      'badem',
      'bahçe',
      'balık',
      'bulut',
      'çanta',
      'çorap',
      'damla',
      'deniz',
      'fırın',
      'kabak',
      'kağıt',
      'kalem',
      'kitap',
      'limon',
      'makas',
      'masal',
      'orman',
      'resim',
      'roman',
      'salon',
      'sepet',
      'sokak',
      'şeker',
      'tabak',
      'tarih',
      'tavuk',
      'yatak',
      'zaman',
      'zemin',
    ];
    for (final target in targets) {
      expect(service.isEligibleTarget(target), isTrue, reason: target);
      expect(service.isValidWord(target, minLength: 5), isTrue, reason: target);
      expect(target.runes.length, 5, reason: '$target should be 5 letters');
    }
  });

  test('a plain word is not an eligible target', () {
    expect(service.isValidWord('kelime', minLength: 4), isTrue);
    expect(service.isEligibleTarget('kelime'), isFalse);
  });
}
