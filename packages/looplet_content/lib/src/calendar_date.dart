/// A calendar date (`YYYY-MM-DD`) with no time of day and no time zone.
///
/// Date arithmetic works on the date parts, never on 24-hour spans (F07
/// `architecture.md` D4), so it holds on DST days, leap days and year
/// boundaries. Internally the date is a UTC midnight, where every day is
/// exactly 24 hours long.
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(int year, int month, int day)
      : _utc = DateTime.utc(year, month, day);

  CalendarDate._(this._utc);

  /// The device-local calendar date of [moment].
  factory CalendarDate.fromLocal(DateTime moment) {
    final local = moment.toLocal();
    return CalendarDate(local.year, local.month, local.day);
  }

  static final RegExp _iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Parses a strict `YYYY-MM-DD` string. Returns `null` for any other shape
  /// or for a date that does not exist (`2026-02-30`).
  static CalendarDate? tryParse(String? raw) {
    if (raw == null) return null;
    final match = _iso.firstMatch(raw);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = CalendarDate(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  final DateTime _utc;

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// This date moved by [days] calendar days (negative moves back).
  CalendarDate addDays(int days) =>
      CalendarDate._(DateTime.utc(year, month, day + days));

  /// The number of calendar days from this date to [other] (negative when
  /// [other] is earlier).
  int daysUntil(CalendarDate other) => other._utc.difference(_utc).inDays;

  @override
  int compareTo(CalendarDate other) => _utc.compareTo(other._utc);

  bool isBefore(CalendarDate other) => compareTo(other) < 0;
  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) => other is CalendarDate && other._utc == _utc;

  @override
  int get hashCode => _utc.hashCode;

  /// `YYYY-MM-DD`.
  @override
  String toString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
