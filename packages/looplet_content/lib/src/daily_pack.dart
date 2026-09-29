import 'package:looplet_core/looplet_core.dart';

import 'calendar_date.dart';
import 'puzzle.dart';

/// The rules a served Daily pack must satisfy (F07 `architecture.md` D2 (2)).
/// Every [DailyPackViolation] names exactly one of them.
enum DailyPackRule {
  /// The pack envelope: `schemaVersion`, `contentVersion`, `lang`,
  /// `numberingEpoch`, and a non-empty `days` list of
  /// `{dailyDate, dailyNumber, puzzle}` objects.
  format,

  /// `days` is sorted by `dailyDate`.
  datesSorted,

  /// `days` has no missing date between its first and last day.
  datesContiguous,

  /// No `dailyDate` appears twice.
  datesUnique,

  /// The day's `puzzle` parses as a [Puzzle].
  puzzleParses,

  /// The day's puzzle is solved: `optimalMoves >= 1`.
  puzzleSolved,

  /// `puzzle.puzzleType == daily`.
  puzzleType,

  /// `puzzle.dailyDate == dailyDate`.
  puzzleDate,

  /// `puzzle.id == "daily-{lang}-{dailyDate}"`.
  puzzleId,

  /// `dailyNumber` == calendar days since `numberingEpoch`, plus 1 — so no
  /// day comes before the epoch.
  dailyNumber,

  /// No puzzle definition repeats within the no-repeat window.
  noRepeat,

  /// `puzzle.language == lang`.
  lang,
}

/// One broken [DailyPackRule], with the day it concerns when there is one.
final class DailyPackViolation {
  const DailyPackViolation(this.rule, this.message, {this.dailyDate});

  final DailyPackRule rule;
  final String message;

  /// The `dailyDate` of the offending day, as written in the pack.
  final String? dailyDate;

  @override
  String toString() =>
      '[${rule.name}] ${dailyDate == null ? '' : '$dailyDate: '}$message';
}

/// Thrown by [DailyPack.fromJson] for a pack that breaks any D2 (2) rule.
final class DailyPackFormatException implements Exception {
  DailyPackFormatException(List<DailyPackViolation> violations)
      : violations = List<DailyPackViolation>.unmodifiable(violations);

  final List<DailyPackViolation> violations;

  @override
  String toString() => 'DailyPackFormatException: ${violations.join('; ')}';
}

/// One day of a [DailyPack].
final class DailyPackDay {
  const DailyPackDay({
    required this.dailyDate,
    required this.dailyNumber,
    required this.puzzle,
  });

  /// `YYYY-MM-DD`.
  final String dailyDate;

  /// The stable day number (`LOOPLET #N`): days since the pack's
  /// `numberingEpoch`, plus 1.
  final int dailyNumber;

  final Puzzle puzzle;

  CalendarDate get date => CalendarDate.tryParse(dailyDate)!;

  Map<String, Object?> toJson() => <String, Object?>{
        'dailyDate': dailyDate,
        'dailyNumber': dailyNumber,
        'puzzle': puzzle.toJson(),
      };
}

/// The served Daily artifact, one self-contained pack per language
/// (`daily_pack_{lang}.json`, F07 `architecture.md` D2).
///
/// Built by `looplet_authoring pack-daily`; validated by the same [validate]
/// at build time and by the app at fetch time (D9).
final class DailyPack {
  DailyPack({
    required this.schemaVersion,
    required this.contentVersion,
    required this.lang,
    required this.numberingEpoch,
    required List<DailyPackDay> days,
  }) : days = List<DailyPackDay>.unmodifiable(days);

  static const int currentSchemaVersion = 1;
  static const int defaultNoRepeatWindowDays = 30;

  final int schemaVersion;
  final String contentVersion;

  /// `'tr'` | `'en'`.
  final String lang;

  /// `YYYY-MM-DD` — the date of day #1.
  final String numberingEpoch;

  /// Sorted, contiguous, one entry per date.
  final List<DailyPackDay> days;

  /// The puzzle id every day of [lang] carries on [dailyDate].
  static String dailyIdFor(String lang, String dailyDate) =>
      'daily-$lang-$dailyDate';

  /// The day number of [date] for a pack numbered from [epoch].
  static int dailyNumberFor(CalendarDate epoch, CalendarDate date) =>
      epoch.daysUntil(date) + 1;

  /// The day for [dailyDate] (`YYYY-MM-DD`), or `null` when the pack has
  /// none.
  DailyPackDay? dayFor(String dailyDate) {
    for (final day in days) {
      if (day.dailyDate == dailyDate) return day;
    }
    return null;
  }

  /// Parses and validates [json]. Unknown keys are ignored. Throws
  /// [DailyPackFormatException] naming every broken D2 (2) rule.
  static DailyPack fromJson(
    Map<String, Object?> json, {
    int noRepeatWindowDays = defaultNoRepeatWindowDays,
  }) {
    final violations = validate(json, noRepeatWindowDays: noRepeatWindowDays);
    if (violations.isNotEmpty) throw DailyPackFormatException(violations);

    final rawDays = json['days']! as List;
    return DailyPack(
      schemaVersion: json['schemaVersion']! as int,
      contentVersion: json['contentVersion']! as String,
      lang: json['lang']! as String,
      numberingEpoch: json['numberingEpoch']! as String,
      days: <DailyPackDay>[
        for (final raw in rawDays.cast<Map<Object?, Object?>>())
          DailyPackDay(
            dailyDate: raw['dailyDate']! as String,
            dailyNumber: raw['dailyNumber']! as int,
            puzzle: Puzzle.fromJson(
                (raw['puzzle']! as Map).cast<String, Object?>()),
          ),
      ],
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'contentVersion': contentVersion,
        'lang': lang,
        'numberingEpoch': numberingEpoch,
        'days': <Map<String, Object?>>[for (final day in days) day.toJson()],
      };

  /// Every D2 (2) rule [json] breaks, in pack order; empty when the pack is
  /// valid. Never throws.
  static List<DailyPackViolation> validate(
    Object? json, {
    int noRepeatWindowDays = defaultNoRepeatWindowDays,
  }) {
    final violations = <DailyPackViolation>[];
    void fail(DailyPackRule rule, String message, {String? dailyDate}) =>
        violations.add(DailyPackViolation(rule, message, dailyDate: dailyDate));

    if (json is! Map) {
      fail(DailyPackRule.format, 'the pack root is not a JSON object');
      return violations;
    }

    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != currentSchemaVersion) {
      fail(DailyPackRule.format,
          '"schemaVersion" must be $currentSchemaVersion, got $schemaVersion');
    }
    final contentVersion = json['contentVersion'];
    if (contentVersion is! String || contentVersion.isEmpty) {
      fail(DailyPackRule.format, '"contentVersion" must be a non-empty string');
    }
    final rawLang = json['lang'];
    final lang =
        rawLang is String && Puzzle.supportedLanguages.contains(rawLang)
            ? rawLang
            : null;
    if (lang == null) {
      fail(DailyPackRule.format,
          '"lang" must be one of ${Puzzle.supportedLanguages}, got $rawLang');
    }
    final rawEpoch = json['numberingEpoch'];
    final epoch = CalendarDate.tryParse(rawEpoch is String ? rawEpoch : null);
    if (epoch == null) {
      fail(DailyPackRule.format,
          '"numberingEpoch" must be a YYYY-MM-DD date, got $rawEpoch');
    }
    final rawDays = json['days'];
    if (rawDays is! List || rawDays.isEmpty) {
      fail(DailyPackRule.format, '"days" must be a non-empty array');
      return violations;
    }

    // Per-day rules; collect what the cross-day rules need.
    final dated = <({CalendarDate date, String raw, Puzzle? puzzle})>[];
    for (var i = 0; i < rawDays.length; i++) {
      final entry = rawDays[i];
      if (entry is! Map) {
        fail(DailyPackRule.format, 'days[$i] is not an object');
        continue;
      }
      final rawDate = entry['dailyDate'];
      final date = CalendarDate.tryParse(rawDate is String ? rawDate : null);
      if (date == null) {
        fail(DailyPackRule.format,
            'days[$i].dailyDate must be a YYYY-MM-DD date, got $rawDate');
        continue;
      }
      final dailyDate = rawDate! as String;

      final number = entry['dailyNumber'];
      if (number is! int) {
        fail(DailyPackRule.format, '"dailyNumber" must be an int',
            dailyDate: dailyDate);
      } else if (epoch != null) {
        final expected = dailyNumberFor(epoch, date);
        if (expected < 1) {
          fail(
            DailyPackRule.dailyNumber,
            'the day is before numberingEpoch $epoch (no day number)',
            dailyDate: dailyDate,
          );
        } else if (number != expected) {
          fail(
            DailyPackRule.dailyNumber,
            'dailyNumber $number != $expected '
            '(days since numberingEpoch $epoch, plus 1)',
            dailyDate: dailyDate,
          );
        }
      }

      Puzzle? puzzle;
      final rawPuzzle = entry['puzzle'];
      if (rawPuzzle is! Map) {
        fail(DailyPackRule.puzzleParses, '"puzzle" must be an object',
            dailyDate: dailyDate);
      } else {
        try {
          puzzle = Puzzle.fromJson(rawPuzzle.cast<String, Object?>());
        } on PuzzleFormatException catch (e) {
          fail(DailyPackRule.puzzleParses, e.message, dailyDate: dailyDate);
        }
      }
      if (puzzle != null) {
        if (puzzle.optimalMoves < 1) {
          fail(
            DailyPackRule.puzzleSolved,
            'optimalMoves must be >= 1, got ${puzzle.optimalMoves}',
            dailyDate: dailyDate,
          );
        }
        if (puzzle.puzzleType != PuzzleType.daily) {
          fail(
            DailyPackRule.puzzleType,
            'puzzleType must be daily, got ${puzzle.puzzleType.name}',
            dailyDate: dailyDate,
          );
        }
        if (puzzle.dailyDate != dailyDate) {
          fail(
            DailyPackRule.puzzleDate,
            'puzzle.dailyDate ${puzzle.dailyDate} != the day',
            dailyDate: dailyDate,
          );
        }
        if (lang != null) {
          final expectedId = dailyIdFor(lang, dailyDate);
          if (puzzle.id != expectedId) {
            fail(
              DailyPackRule.puzzleId,
              'puzzle.id "${puzzle.id}" != "$expectedId"',
              dailyDate: dailyDate,
            );
          }
          if (puzzle.language != lang) {
            fail(
              DailyPackRule.lang,
              'puzzle.language "${puzzle.language}" != pack lang "$lang"',
              dailyDate: dailyDate,
            );
          }
        }
      }
      dated.add((date: date, raw: dailyDate, puzzle: puzzle));
    }

    // Sorted, in pack order.
    for (var i = 1; i < dated.length; i++) {
      if (dated[i].date.isBefore(dated[i - 1].date)) {
        fail(
          DailyPackRule.datesSorted,
          'comes after ${dated[i - 1].raw}',
          dailyDate: dated[i].raw,
        );
      }
    }

    // Unique.
    final counts = <CalendarDate, int>{};
    for (final day in dated) {
      counts[day.date] = (counts[day.date] ?? 0) + 1;
    }
    counts.forEach((date, count) {
      if (count > 1) {
        fail(DailyPackRule.datesUnique, 'appears $count times',
            dailyDate: '$date');
      }
    });

    // Contiguous, over the distinct dates.
    final distinct = counts.keys.toList()..sort();
    for (var i = 1; i < distinct.length; i++) {
      final gap = distinct[i - 1].daysUntil(distinct[i]);
      if (gap > 1) {
        fail(
          DailyPackRule.datesContiguous,
          'missing ${distinct[i - 1].addDays(1)} … '
          '${distinct[i].addDays(-1)} (${gap - 1} day(s))',
          dailyDate: '${distinct[i]}',
        );
      }
    }

    // No repeat of a puzzle definition within the window.
    final withPuzzle = dated.where((d) => d.puzzle != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (var i = 0; i < withPuzzle.length; i++) {
      for (var j = i + 1; j < withPuzzle.length; j++) {
        final days = withPuzzle[i].date.daysUntil(withPuzzle[j].date);
        if (days >= noRepeatWindowDays) break;
        if (days == 0) continue; // the same date is datesUnique's case
        if (definitionKey(withPuzzle[i].puzzle!) ==
            definitionKey(withPuzzle[j].puzzle!)) {
          fail(
            DailyPackRule.noRepeat,
            'repeats the puzzle of ${withPuzzle[i].raw} within '
            '$noRepeatWindowDays days',
            dailyDate: withPuzzle[j].raw,
          );
        }
      }
    }

    return violations;
  }

  /// What makes two puzzles the same puzzle to a player: the grid, the
  /// target, the locked and frozen cells, and whether columns move. Ids,
  /// dates and metadata are not part of it.
  static String definitionKey(Puzzle p) {
    String coords(Set<GridCoord> cells) =>
        (cells.toList()..sort()).map((c) => '${c.row},${c.col}').join(';');
    return '${p.grid.join('|')}#${p.targetWord}#${coords(p.lockedCells)}'
        '#${coords(p.frozenCells)}#${p.columnMovesEnabled}';
  }
}
