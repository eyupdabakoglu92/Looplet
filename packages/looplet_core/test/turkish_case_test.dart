import 'package:looplet_core/looplet_core.dart';
import 'package:test/test.dart';

void main() {
  group('TurkishCase.toLowerTr', () {
    test('maps the full Ç Ğ İ I Ö Ş Ü set', () {
      expect(TurkishCase.toLowerTr('ÇĞİIÖŞÜ'), 'çğiıöşü');
    });

    test('İ and I lower-case to different code points', () {
      expect(TurkishCase.toLowerTr('İ'), 'i');
      expect(TurkishCase.toLowerTr('I'), 'ı');
      expect(TurkishCase.toLowerTr('İ') == TurkishCase.toLowerTr('I'), isFalse);
    });

    test('does not use Dart default rules for I', () {
      // Dart default: 'I'.toLowerCase() == 'i' (wrong for Turkish).
      expect(TurkishCase.toLowerTr('IL'), 'ıl');
      expect(TurkishCase.toLowerTr('İL'), 'il');
    });

    test('lower-cases ordinary letters normally', () {
      expect(TurkishCase.toLowerTr('MASAL'), 'masal');
      expect(TurkishCase.toLowerTr('KiTaP'), 'kitap');
    });

    test('keeps circumflex vowels as distinct letters', () {
      expect(TurkishCase.toLowerTr('Â'), 'â');
      expect(TurkishCase.toLowerTr('KÂR'), 'kâr');
      expect(TurkishCase.toLowerTr('KÂR') == TurkishCase.toLowerTr('KAR'),
          isFalse);
    });

    test('is idempotent on already-lower text', () {
      expect(TurkishCase.toLowerTr('çığ'), 'çığ');
    });
  });

  group('TurkishCase.toUpperTr', () {
    test('maps the full ç ğ i ı ö ş ü set', () {
      expect(TurkishCase.toUpperTr('çğiıöşü'), 'ÇĞİIÖŞÜ');
    });

    test('i and ı upper-case to different code points', () {
      expect(TurkishCase.toUpperTr('i'), 'İ');
      expect(TurkishCase.toUpperTr('ı'), 'I');
    });

    test('round-trips with toLowerTr across the special set', () {
      const samples = <String>['ışık', 'iğne', 'çöl', 'şükür', 'ürün', 'ığdır'];
      for (final s in samples) {
        expect(TurkishCase.toLowerTr(TurkishCase.toUpperTr(s)), s);
      }
    });
  });
}
