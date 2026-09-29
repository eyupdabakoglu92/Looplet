import 'package:looplet_content/looplet_content.dart';
import 'package:test/test.dart';

void main() {
  group('tryParse', () {
    test('parses a strict YYYY-MM-DD date', () {
      final date = CalendarDate.tryParse('2026-10-01')!;
      expect((date.year, date.month, date.day), (2026, 10, 1));
      expect('$date', '2026-10-01');
    });

    test('rejects every other shape and every date that does not exist', () {
      for (final raw in <String?>[
        null,
        '',
        '2026-10-1',
        '2026-1-01',
        '26-10-01',
        ' 2026-10-01',
        '2026-10-01T00:00:00',
        '2026/10/01',
        '2026-02-29', // 2026 is not a leap year
        '2026-02-30',
        '2026-13-01',
        '2026-00-10',
        '2026-10-00',
      ]) {
        expect(CalendarDate.tryParse(raw), isNull, reason: '$raw');
      }
      expect(CalendarDate.tryParse('2028-02-29'), isNotNull);
    });
  });

  group('calendar arithmetic (D4 — date parts, never 24-hour spans)', () {
    CalendarDate d(String raw) => CalendarDate.tryParse(raw)!;

    test('addDays crosses month, year and leap-day boundaries', () {
      expect('${d('2026-10-31').addDays(1)}', '2026-11-01');
      expect('${d('2026-12-31').addDays(1)}', '2027-01-01');
      expect('${d('2027-01-01').addDays(-1)}', '2026-12-31');
      expect('${d('2028-02-28').addDays(1)}', '2028-02-29');
      expect('${d('2028-02-29').addDays(1)}', '2028-03-01');
      expect('${d('2027-02-28').addDays(1)}', '2027-03-01');
    });

    test('daysUntil counts calendar days across DST changes', () {
      // EU DST starts 2026-03-29 and ends 2026-10-25; US 2026-03-08 / 11-01.
      expect(d('2026-03-28').daysUntil(d('2026-03-30')), 2);
      expect(d('2026-10-24').daysUntil(d('2026-10-26')), 2);
      expect(d('2026-03-07').daysUntil(d('2026-03-09')), 2);
      expect(d('2026-10-31').daysUntil(d('2026-11-02')), 2);
      expect(d('2026-01-01').daysUntil(d('2027-01-01')), 365);
      expect(d('2028-01-01').daysUntil(d('2029-01-01')), 366);
      expect(d('2026-10-05').daysUntil(d('2026-10-01')), -4);
    });

    test('fromLocal takes the local calendar date of a moment', () {
      final date = CalendarDate.fromLocal(DateTime(2026, 10, 25, 23, 59));
      expect('$date', '2026-10-25');
    });

    test('ordering, equality and hash follow the date', () {
      expect(d('2026-10-01'), d('2026-10-01'));
      expect(d('2026-10-01').hashCode, d('2026-10-01').hashCode);
      expect(d('2026-10-01').isBefore(d('2026-10-02')), isTrue);
      expect(d('2026-10-02').isAfter(d('2026-10-01')), isTrue);
      expect(
        (<CalendarDate>[d('2026-10-03'), d('2025-12-31'), d('2026-10-01')]
              ..sort())
            .map((c) => '$c'),
        <String>['2025-12-31', '2026-10-01', '2026-10-03'],
      );
    });
  });
}
