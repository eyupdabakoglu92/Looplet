import 'package:looplet_dictionary/looplet_dictionary.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

Future<DictionaryService> _trService({
  List<String> words = const <String>['masal', 'kır', 'göl', 'iğne'],
  List<String> targets = const <String>['masal'],
}) {
  final source = MapAssetSource(<String, String>{
    LanguageCode.tr.assetPath:
        assetJson(language: 'tr', words: words, targets: targets),
  });
  return DictionaryService.load(
    language: LanguageCode.tr,
    assetSource: source,
  );
}

void main() {
  test('loads a real asset and is not fail-safe', () async {
    final service = await _trService();
    expect(service.isFailSafe, isFalse);
    expect(service.language, LanguageCode.tr);
  });

  group('isValidWord', () {
    test('accepts a listed word regardless of casing', () async {
      final service = await _trService();
      for (final form in <String>['masal', 'MASAL', 'MaSaL', '  masal ']) {
        expect(service.isValidWord(form, minLength: 4), isTrue, reason: form);
      }
    });

    test('rejects a word that is not in the list', () async {
      final service = await _trService();
      expect(service.isValidWord('zebra', minLength: 4), isFalse);
    });

    test('İ and I are different keys (kır listed, kir not)', () async {
      final service =
          await _trService(words: <String>['kır'], targets: <String>[]);
      expect(service.isValidWord('KIR'), isTrue); // -> kır
      expect(service.isValidWord('KİR'), isFalse); // -> kir, absent
    });

    test('length rule rejects short candidates without a list hit', () async {
      final service =
          await _trService(words: <String>['göl'], targets: <String>[]);
      expect(service.isValidWord('göl'), isTrue); // default minLength 1
      expect(service.isValidWord('göl', minLength: 4), isFalse);
    });

    test('malformed candidates return false, never throw', () async {
      final service = await _trService();
      for (final bad in <String>[
        '',
        '   ',
        'ma sal',
        'ma-sal',
        'masal1',
        'qwx'
      ]) {
        expect(service.isValidWord(bad, minLength: 1), isFalse, reason: bad);
      }
    });
  });

  group('isEligibleTarget', () {
    test('true for a curated target, false for a plain word', () async {
      final service = await _trService(
        words: <String>['masal', 'göl'],
        targets: <String>['masal'],
      );
      expect(service.isEligibleTarget('MASAL'), isTrue);
      expect(service.isEligibleTarget('göl'), isFalse);
    });

    test('a target missing from words is dropped', () async {
      final service = await _trService(
        words: <String>['masal'],
        targets: <String>['masal', 'orphan'],
      );
      expect(service.isEligibleTarget('orphan'), isFalse);
    });
  });

  group('normalize', () {
    test('exposes the Turkish normalization', () async {
      final service = await _trService();
      expect(service.normalize('  KİTAP '), 'kitap');
      expect(service.normalize('KIRMIZI'), 'kırmızı');
      expect(service.normalize('12'), isNull);
    });
  });

  test('queries after dispose throw StateError', () async {
    final service = await _trService();
    await service.dispose();
    expect(() => service.isValidWord('masal'), throwsStateError);
    expect(() => service.isEligibleTarget('masal'), throwsStateError);
    expect(() => service.normalize('masal'), throwsStateError);
  });
}
