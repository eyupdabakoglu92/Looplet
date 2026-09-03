import 'package:looplet_core/looplet_core.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeTurkish', () {
    test('lower-cases and trims valid input', () {
      expect(normalizeTurkish('  MASAL  '), 'masal');
      expect(normalizeTurkish('KiTaP'), 'kitap');
    });

    test('casing does not change the result for the same letters', () {
      expect(normalizeTurkish('masal'), normalizeTurkish('MASAL'));
      expect(normalizeTurkish('MaSaL'), normalizeTurkish('masal'));
    });

    test('İ and I produce distinct keys', () {
      expect(normalizeTurkish('İL'), 'il');
      expect(normalizeTurkish('IL'), 'ıl');
      expect(normalizeTurkish('İL') == normalizeTurkish('IL'), isFalse);
    });

    test('accepts every Turkish letter', () {
      expect(normalizeTurkish('abcçdefgğhıijklmnoöprsştuüvyz'),
          'abcçdefgğhıijklmnoöprsştuüvyz');
    });

    test('keeps circumflex vowels', () {
      expect(normalizeTurkish('KÂĞIT'), 'kâğıt');
      expect(normalizeTurkish('kâr') == normalizeTurkish('kar'), isFalse);
    });

    test('rejects non-letters with null (never empty, never throws)', () {
      expect(normalizeTurkish(''), isNull);
      expect(normalizeTurkish('   '), isNull);
      expect(normalizeTurkish('ma sal'), isNull);
      expect(normalizeTurkish('ma-sal'), isNull);
      expect(normalizeTurkish('masal1'), isNull);
      expect(normalizeTurkish('masal!'), isNull);
    });

    test('rejects letters outside the Turkish alphabet', () {
      expect(normalizeTurkish('WXQ'), isNull); // no w x q in Turkish
      expect(normalizeTurkish('café'), isNull); // é is not Turkish
    });
  });

  group('normalizeLatin', () {
    test('lower-cases ASCII and trims', () {
      expect(normalizeLatin('  TABLE '), 'table');
    });

    test('rejects empty, whitespace, and non-ASCII letters', () {
      expect(normalizeLatin(''), isNull);
      expect(normalizeLatin('  '), isNull);
      expect(normalizeLatin('masör'), isNull); // ö not ASCII
      expect(normalizeLatin('two words'), isNull);
    });
  });
}
