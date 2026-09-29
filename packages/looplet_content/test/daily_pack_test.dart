import 'dart:convert';

import 'package:looplet_content/looplet_content.dart';
import 'package:test/test.dart';

const _letters = 'ABCDEFGHIJKLMNOPRSTUVYZ';

/// A distinct, well-formed daily Puzzle JSON for [dailyDate]; [variant]
/// changes the definition (the last grid row).
Map<String, Object?> puzzleJson(String dailyDate,
        {int variant = 0, String lang = 'tr'}) =>
    <String, Object?>{
      'schemaVersion': 1,
      'contentVersion': 'test',
      'id': 'daily-$lang-$dailyDate',
      'puzzleType': 'daily',
      'dailyDate': dailyDate,
      'language': lang,
      'grid': <String>[
        'ASALM',
        'BCDFG',
        'HJKLN',
        'PRTUV',
        'YZB${_letters[variant ~/ _letters.length]}'
            '${_letters[variant % _letters.length]}',
      ],
      'targetWord': 'MASAL',
      'lockedCells': <String>[],
      'frozenCells': <String>[],
      'columnMovesEnabled': true,
      'optimalMoves': 1,
      'difficultyScore': 0.5,
      'difficultyLabel': 'easy',
      'difficultyBreakdown': <String, Object?>{'o': 1},
    };

/// A valid pack of [count] days from [first], numbered from [epoch]; every
/// day has its own definition.
Map<String, Object?> packJson({
  String epoch = '2026-10-01',
  String first = '2026-10-01',
  int count = 5,
}) {
  final epochDate = CalendarDate.tryParse(epoch)!;
  final firstDate = CalendarDate.tryParse(first)!;
  return <String, Object?>{
    'schemaVersion': 1,
    'contentVersion': '2026-10-01.1',
    'lang': 'tr',
    'numberingEpoch': epoch,
    'days': <Map<String, Object?>>[
      for (var i = 0; i < count; i++)
        <String, Object?>{
          'dailyDate': '${firstDate.addDays(i)}',
          'dailyNumber':
              DailyPack.dailyNumberFor(epochDate, firstDate.addDays(i)),
          'puzzle': puzzleJson('${firstDate.addDays(i)}', variant: i),
        },
    ],
  };
}

/// A deep, independent copy (the negatives mutate it).
Map<String, Object?> copy(Map<String, Object?> json) =>
    (jsonDecode(jsonEncode(json)) as Map).cast<String, Object?>();

List<Map<String, Object?>> daysOf(Map<String, Object?> pack) =>
    (pack['days']! as List).cast<Map<String, Object?>>();

Map<String, Object?> puzzleOf(Map<String, Object?> pack, int day) =>
    (daysOf(pack)[day]['puzzle']! as Map).cast<String, Object?>();

Set<DailyPackRule> rulesOf(Object? json, {int window = 30}) =>
    DailyPack.validate(json, noRepeatWindowDays: window)
        .map((v) => v.rule)
        .toSet();

void main() {
  group('a valid pack', () {
    test('validates clean and round-trips through fromJson / toJson', () {
      final json = packJson();
      expect(DailyPack.validate(json), isEmpty);

      final pack = DailyPack.fromJson(json);
      expect(pack.lang, 'tr');
      expect(pack.numberingEpoch, '2026-10-01');
      expect(pack.days.map((d) => d.dailyNumber), <int>[1, 2, 3, 4, 5]);
      expect(pack.days.first.puzzle.id, 'daily-tr-2026-10-01');
      expect(pack.toJson(), json);
      expect(jsonEncode(DailyPack.fromJson(pack.toJson()).toJson()),
          jsonEncode(json));
    });

    test('dayFor finds a day by date, or null', () {
      final pack = DailyPack.fromJson(packJson());
      expect(pack.dayFor('2026-10-03')!.dailyNumber, 3);
      expect(pack.dayFor('2026-10-06'), isNull);
    });

    test('dailyNumber is stable across packs that start later', () {
      final later = packJson(first: '2026-11-20', count: 3);
      expect(DailyPack.validate(later), isEmpty);
      expect(DailyPack.fromJson(later).days.first.dailyNumber, 51);
    });

    test('numbering and contiguity hold across DST, leap day and new year', () {
      for (final first in <String>[
        '2026-03-27', // EU DST start (03-29)
        '2026-10-23', // EU DST end (10-25)
        '2028-02-27', // leap day
        '2026-12-29', // year boundary
      ]) {
        final json = packJson(epoch: '2026-01-01', first: first, count: 5);
        expect(DailyPack.validate(json), isEmpty, reason: first);
      }
      final leap = DailyPack.fromJson(
          packJson(epoch: '2028-02-28', first: '2028-02-28', count: 3));
      expect(leap.days.map((d) => d.dailyDate),
          <String>['2028-02-28', '2028-02-29', '2028-03-01']);
      expect(leap.days.map((d) => d.dailyNumber), <int>[1, 2, 3]);
    });

    test('the same definition may come back exactly at the window edge', () {
      final json = packJson(count: 31);
      daysOf(json)[30]['puzzle'] = puzzleJson('2026-10-31', variant: 0);
      expect(DailyPack.validate(json), isEmpty);
    });
  });

  // One named negative per D2 (2) rule. Each asserts that the intended rule,
  // and only that rule, fails.
  group('named negatives (D2 (2))', () {
    test('datesSorted — two days out of order', () {
      final json = packJson();
      final days = daysOf(json);
      final second = days[1];
      days[1] = days[2];
      days[2] = second;
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.datesSorted});
      expect(DailyPack.validate(json).single.dailyDate, '2026-10-02');
    });

    test('datesContiguous — a missing day', () {
      final json = packJson();
      daysOf(json).removeAt(2);
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.datesContiguous});
      expect(DailyPack.validate(json).single.toString(),
          contains('missing 2026-10-03'));
    });

    test('datesUnique — a date twice', () {
      final json = packJson();
      daysOf(json).add(<String, Object?>{
        'dailyDate': '2026-10-05',
        'dailyNumber': 5,
        'puzzle': puzzleJson('2026-10-05', variant: 99),
      });
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.datesUnique});
    });

    test('puzzleDate — puzzle.dailyDate differs from the day', () {
      final json = packJson();
      puzzleOf(json, 1)['dailyDate'] = '2026-10-09';
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.puzzleDate});
    });

    test('puzzleType — a journey puzzle in a day', () {
      final json = packJson();
      puzzleOf(json, 1)
        ..['puzzleType'] = 'journey'
        ..['journeyLevelNumber'] = 3;
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.puzzleType});
    });

    test('puzzleId — an id that is not daily-{lang}-{dailyDate}', () {
      final json = packJson();
      puzzleOf(json, 1)['id'] = 'daily-tr-pool-07';
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.puzzleId});
    });

    test('puzzleParses — a puzzle that is not a Puzzle', () {
      final json = packJson();
      puzzleOf(json, 1).remove('optimalMoves');
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.puzzleParses});
      expect(DailyPack.validate(json).single.message, contains('optimalMoves'));
    });

    test('puzzleSolved — optimalMoves 0', () {
      final json = packJson();
      puzzleOf(json, 1)['optimalMoves'] = 0;
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.puzzleSolved});
    });

    test('dailyNumber — off by one', () {
      final json = packJson();
      daysOf(json)[3]['dailyNumber'] = 5;
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.dailyNumber});
      expect(DailyPack.validate(json).single.toString(),
          contains('dailyNumber 5 != 4'));
    });

    test('dailyNumber — a day before the numbering epoch', () {
      final json = packJson()..['numberingEpoch'] = '2026-10-03';
      final violations = DailyPack.validate(json);
      expect(violations.map((v) => v.rule).toSet(),
          <DailyPackRule>{DailyPackRule.dailyNumber});
      // 10-01 and 10-02 precede the epoch; 10-03…05 carry 3…5 against 1…3.
      expect(violations, hasLength(5));
      expect(
          violations
              .where((v) => v.message.contains('before numberingEpoch'))
              .map((v) => v.dailyDate),
          <String>['2026-10-01', '2026-10-02']);
    });

    test('dailyNumber — a day before the epoch even when numbered from it', () {
      // -1, 0, 1, 2, 3: consistent with the epoch, but #-1 / #0 do not exist.
      final json = packJson(epoch: '2026-10-03');
      final violations = DailyPack.validate(json);
      expect(violations.map((v) => v.rule).toSet(),
          <DailyPackRule>{DailyPackRule.dailyNumber});
      expect(violations.map((v) => v.dailyDate),
          <String>['2026-10-01', '2026-10-02']);
    });

    test('noRepeat — a definition back within 30 days', () {
      final json = packJson(count: 30);
      // 29 days apart: inside the window.
      daysOf(json)[29]['puzzle'] = puzzleJson('2026-10-30', variant: 0);
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.noRepeat});
      expect(DailyPack.validate(json).single.toString(),
          contains('repeats the puzzle of 2026-10-01'));
    });

    test('noRepeat — the window is a parameter', () {
      final json = packJson(count: 31);
      daysOf(json)[30]['puzzle'] = puzzleJson('2026-10-31', variant: 0);
      expect(
          rulesOf(json, window: 31), <DailyPackRule>{DailyPackRule.noRepeat});
    });

    test('lang — a puzzle in another language', () {
      final json = packJson();
      puzzleOf(json, 1)['language'] = 'en';
      expect(rulesOf(json), <DailyPackRule>{DailyPackRule.lang});
    });

    test('format — a broken envelope', () {
      Map<String, Object?> with_(String key, Object? value) =>
          copy(packJson())..[key] = value;

      for (final (label, json) in <(String, Object?)>[
        ('not an object', <Object?>[]),
        ('schemaVersion 2', with_('schemaVersion', 2)),
        ('no contentVersion', copy(packJson())..remove('contentVersion')),
        ('unknown lang', with_('lang', 'de')),
        ('bad epoch', with_('numberingEpoch', '2026-10-1')),
        ('empty days', with_('days', <Object?>[])),
      ]) {
        expect(rulesOf(json), <DailyPackRule>{DailyPackRule.format},
            reason: label);
      }

      final badDate = packJson();
      daysOf(badDate)[4]['dailyDate'] = '2026-10-5';
      expect(rulesOf(badDate), <DailyPackRule>{DailyPackRule.format});

      final badNumber = packJson();
      daysOf(badNumber)[4]['dailyNumber'] = '5';
      expect(rulesOf(badNumber), <DailyPackRule>{DailyPackRule.format});
    });
  });

  test('fromJson throws DailyPackFormatException naming every violation', () {
    final json = packJson();
    daysOf(json)[3]['dailyNumber'] = 9;
    puzzleOf(json, 1)['language'] = 'en';
    expect(
      () => DailyPack.fromJson(json),
      throwsA(isA<DailyPackFormatException>().having(
          (e) => e.violations.map((v) => v.rule).toSet(),
          'rules', <DailyPackRule>{
        DailyPackRule.dailyNumber,
        DailyPackRule.lang
      }).having((e) => '$e', 'toString', contains('[dailyNumber]'))),
    );
  });
}
