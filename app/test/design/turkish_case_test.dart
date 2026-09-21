import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/turkish_case.dart';

/// The Turkish casing rule (design-foundation §7): locale-blind uppercasing turns
/// `i` into `I` and breaks the game's labels.
void main() {
  group('turkishUpper', () {
    test('the game labels come out right', () {
      expect(turkishUpper('harika'), 'HARİKA');
      expect(turkishUpper('yeni en iyi'), 'YENİ EN İYİ');
      expect(turkishUpper('optimal'), 'OPTİMAL');
      expect(turkishUpper('seviye'), 'SEVİYE');
      expect(turkishUpper('ilk'), 'İLK');
      expect(turkishUpper('hedef döngü'), 'HEDEF DÖNGÜ');
    });

    test('dotless ı becomes I, ş ğ ç ö ü keep their capitals', () {
      expect(turkishUpper('ılık'), 'ILIK');
      expect(turkishUpper('şğçöü'), 'ŞĞÇÖÜ');
    });

    test('already-uppercase text, digits and punctuation are untouched', () {
      expect(turkishUpper('HARİKA'), 'HARİKA');
      expect(turkishUpper('3 / 30 · Seviye 5'), '3 / 30 · SEVİYE 5');
    });

    test('the plain toUpperCase is wrong — that is why this helper exists', () {
      expect('harika'.toUpperCase(), isNot('HARİKA'));
      expect('yeni en iyi'.toUpperCase(), isNot('YENİ EN İYİ'));
    });
  });

  group('turkishLower', () {
    test('I → ı and İ → i', () {
      expect(turkishLower('ILIK'), 'ılık');
      expect(turkishLower('HARİKA'), 'harika');
      expect(turkishLower('ŞĞÇÖÜ'), 'şğçöü');
    });

    test('round trip on lowercase Turkish text', () {
      const text = 'sıradaki döngüyü çöz';
      expect(turkishLower(turkishUpper(text)), text);
    });
  });
}
