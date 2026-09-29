import 'dart:convert';
import 'dart:io';

import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:test/test.dart';

// Tests run with CWD = tools/looplet_authoring.
const _repoRoot = '../..';
const _devSource = 'test/fixtures/daily_dev/daily/tr';
const _golden = 'test/fixtures/daily_pack_tr.dev.golden.json';

Future<(int, String, String)> run(List<String> args) async {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = await buildRunner(out: out, err: err).run(args) ?? 0;
  return (code, out.toString(), err.toString());
}

/// A fresh copy of the dev source under `<root>/daily/tr/`; returns its
/// manifest path. [days] keeps only the first N days (smoke-based, fast to
/// solve) in the manifest and the pool.
String devSourceIn(Directory root, {int? days}) {
  final manifest = writeDailyDevFixture(outDir: root.path, repoRoot: _repoRoot);
  if (days != null) {
    final json = readJson(manifest);
    final kept = (json['assignments']! as Map).entries.take(days);
    json['assignments'] = <String, Object?>{
      for (final e in kept) '${e.key}': e.value,
    };
    writeJson(manifest, json);
    final keep = kept.map((e) => '${e.value}.json').toSet();
    for (final f in Directory('${File(manifest).parent.path}/pool')
        .listSync()
        .whereType<File>()) {
      if (!keep.contains(f.uri.pathSegments.last)) f.deleteSync();
    }
  }
  return manifest;
}

Map<String, Object?> readJson(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

void writeJson(String path, Map<String, Object?> json) =>
    File(path).writeAsStringSync(jsonEncode(json));

String poolFile(String manifest, String date) =>
    '${File(manifest).parent.path}/pool/daily-tr-$date.json';

void editPool(String manifest, String date,
    void Function(Map<String, Object?> puzzle) edit) {
  final path = poolFile(manifest, date);
  final json = readJson(path);
  edit(json);
  writeJson(path, json);
}

void editManifest(
    String manifest, void Function(Map<String, Object?> json) edit) {
  final json = readJson(manifest);
  edit(json);
  writeJson(manifest, json);
}

Map<String, Object?> assignmentsOf(Map<String, Object?> manifest) =>
    (manifest['assignments']! as Map).cast<String, Object?>();

/// The `[rule]` tags of [failures].
Set<String> tagsOf(List<String> failures) => <String>{
      for (final f in failures) RegExp(r'\[(\w+)\]').firstMatch(f)!.group(1)!,
    };

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('looplet_daily'));
  tearDown(() => tmp.deleteSync(recursive: true));

  group('the dev fixture (a test source, not product content)', () {
    test('is reproducible: the generator rewrites it byte for byte', () {
      writeDailyDevFixture(outDir: tmp.path, repoRoot: _repoRoot);
      final committed = Directory(_devSource)
          .listSync(recursive: true)
          .whereType<File>()
          .toList();
      expect(committed, hasLength(23)); // manifest + 22 pool days
      for (final file in committed) {
        final rel = file.path.substring(_devSource.length);
        expect(File('${tmp.path}/daily/tr$rel').readAsStringSync(),
            file.readAsStringSync(),
            reason: rel);
      }
    });

    test('covers anchor − 14 … anchor + 7 as #1 … #22', () {
      final pack = buildDailyPack('$_devSource/daily_manifest_tr.json').pack!;
      expect(pack.days, hasLength(22));
      expect(pack.days.first.dailyDate, '2026-10-01');
      expect(pack.dayFor('2026-10-15')!.dailyNumber, 15); // the anchor
      expect(pack.days.last.dailyDate, '2026-10-22');
      expect(pack.days.map((d) => d.dailyNumber),
          List<int>.generate(22, (i) => i + 1));
    });

    test('shifts to another "today", keeping a given numbering epoch', () {
      final manifest = writeDailyDevFixture(
        outDir: tmp.path,
        repoRoot: _repoRoot,
        anchor: CalendarDate(2028, 3, 1), // a leap-year February inside
        epoch: CalendarDate(2026, 10, 1),
      );
      final result = buildDailyPack(manifest);
      expect(result.failures, isEmpty);
      final pack = result.pack!;
      expect(pack.days.first.dailyDate, '2028-02-16');
      expect(pack.dayFor('2028-02-29'), isNotNull);
      expect(pack.days.last.dailyDate, '2028-03-08');
      expect(
          pack.dayFor('2028-03-01')!.dailyNumber,
          DailyPack.dailyNumberFor(
              CalendarDate(2026, 10, 1), CalendarDate(2028, 3, 1)));
    });

    test(
      'passes check (schema, fresh solve, target eligibility, pack rules)',
      () async {
        final (code, out, err) = await run(<String>[
          'check',
          'test/fixtures/daily_dev',
          '--repo-root',
          _repoRoot,
        ]);
        expect(code, 0, reason: err);
        expect(out, contains('check: OK'));
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });

  group('pack-daily', () {
    test('writes the golden pack for the dev fixture, deterministically',
        () async {
      final first = '${tmp.path}/a/daily_pack_tr.json';
      final second = '${tmp.path}/b/daily_pack_tr.json';
      for (final out in <String>[first, second]) {
        final (code, stdout, stderr) = await run(<String>[
          'pack-daily',
          _devSource,
          '--repo-root',
          _repoRoot,
          '--out',
          out,
        ]);
        expect(code, 0, reason: stderr);
        expect(stdout, contains('22 days 2026-10-01 … 2026-10-22'));
      }
      final bytes = File(first).readAsBytesSync();
      expect(File(second).readAsBytesSync(), bytes);
      expect(File(_golden).readAsBytesSync(), bytes);
      // The served pack parses, and is valid, on the client side too.
      final pack = DailyPack.fromJson(readJson(first));
      expect(pack.days, hasLength(22));
    });

    test('writes to <repo-root>/build/daily/daily_pack_<lang>.json by default',
        () async {
      final (code, _, stderr) = await run(
          <String>['pack-daily', _devSource, '--repo-root', tmp.path]);
      expect(code, 0, reason: stderr);
      expect(File('${tmp.path}/build/daily/daily_pack_tr.json').existsSync(),
          true);
    });

    test('the manifest key order does not change the pack', () async {
      final manifest = devSourceIn(tmp);
      editManifest(manifest, (json) {
        final reversed = assignmentsOf(json).entries.toList().reversed;
        json['assignments'] = <String, Object?>{
          for (final e in reversed) e.key: e.value,
        };
        json['contentVersion'] = 'dev-fixture-2026-10-15';
      });
      final out = '${tmp.path}/pack.json';
      final (code, _, stderr) =
          await run(<String>['pack-daily', manifest, '--out', out]);
      expect(code, 0, reason: stderr);
      expect(File(out).readAsStringSync(), File(_golden).readAsStringSync());
    });

    test('refuses, naming the rule and writing nothing, on a broken source',
        () async {
      final manifest = devSourceIn(tmp);
      editPool(manifest, '2026-10-06', (p) => p['language'] = 'en');
      final out = '${tmp.path}/pack.json';
      final (code, _, stderr) =
          await run(<String>['pack-daily', manifest, '--out', out]);
      expect(code, 1);
      expect(stderr, contains('pack-daily FAIL: [lang] 2026-10-06'));
      expect(stderr, contains('nothing written'));
      expect(File(out).existsSync(), isFalse);
    });

    test('refuses to write into its own source directory', () async {
      final manifest = devSourceIn(tmp);
      final out = '${File(manifest).parent.path}/daily_pack_tr.json';
      final (code, _, stderr) =
          await run(<String>['pack-daily', manifest, '--out', out]);
      expect(code, 1);
      expect(stderr, contains('refusing to write into the source'));
      expect(File(out).existsSync(), isFalse);
    });

    test('a directory without a manifest is a usage failure', () async {
      final (code, _, stderr) = await run(<String>['pack-daily', tmp.path]);
      expect(code, 1);
      expect(stderr, contains('no daily_manifest_<lang>.json'));
    });
  });

  // Every D2 (2) rule fails on the source (manifest + pool), each for its
  // own reason and only that one. `datesSorted` cannot: the assignments are
  // an object, and the pack is sorted by construction (the key-order test
  // above); its negative is at the pack level (looplet_content).
  group('named negatives on the source (D2 (2))', () {
    late String manifest;
    setUp(() => manifest = devSourceIn(tmp));

    List<String> failures() => buildDailyPack(manifest).failures;

    test('the unedited source builds clean', () {
      expect(failures(), isEmpty);
    });

    test('datesUnique — a date assigned twice', () {
      // JSON objects keep the last of two equal keys, so the duplicate is
      // written as text.
      const entry = '"2026-10-05": "daily-tr-2026-10-05"';
      final text = File(manifest).readAsStringSync();
      final edited = text.replaceFirst(entry, '$entry,\n    $entry');
      expect(edited, isNot(text), reason: 'the duplicate must be planted');
      File(manifest).writeAsStringSync(edited);
      expect(
          failures(), <String>['[datesUnique] 2026-10-05: assigned 2 times']);
    });

    test('datesContiguous — a date left out', () {
      editManifest(
          manifest, (json) => assignmentsOf(json).remove('2026-10-10'));
      expect(tagsOf(failures()), <String>{'datesContiguous'});
      expect(failures().single, contains('missing 2026-10-10'));
    });

    test('puzzleParses — a pool puzzle that is not a Puzzle', () {
      editPool(manifest, '2026-10-03', (p) => p.remove('optimalMoves'));
      expect(failures(), hasLength(1));
      expect(failures().single,
          startsWith('[puzzleParses] 2026-10-03: pool/daily-tr-2026-10-03'));
    });

    test('puzzleSolved — optimalMoves 0', () {
      editPool(manifest, '2026-10-03', (p) => p['optimalMoves'] = 0);
      expect(tagsOf(failures()), <String>{'puzzleSolved'});
    });

    test('puzzleType — a journey puzzle in the pool', () {
      editPool(
          manifest,
          '2026-10-07',
          (p) => p
            ..['puzzleType'] = 'journey'
            ..['journeyLevelNumber'] = 7);
      expect(tagsOf(failures()), <String>{'puzzleType'});
    });

    test('puzzleDate — a pool puzzle dated for another day', () {
      editPool(manifest, '2026-10-08', (p) => p['dailyDate'] = '2026-11-08');
      expect(tagsOf(failures()), <String>{'puzzleDate'});
    });

    test('puzzleId — a pool puzzle whose id is not daily-{lang}-{date}', () {
      editPool(manifest, '2026-10-04', (p) => p['id'] = 'daily-tr-pool-04');
      editManifest(
          manifest,
          (json) => assignmentsOf(json)['2026-10-04'] =
              'daily-tr-2026-10-04.json'); // by file: the id no longer matches
      expect(tagsOf(failures()), <String>{'puzzleId'});
    });

    test('dailyNumber — assigned days before the numbering epoch', () {
      editManifest(manifest, (json) => json['numberingEpoch'] = '2026-10-05');
      final f = failures();
      expect(tagsOf(f), <String>{'dailyNumber'});
      expect(f, hasLength(4)); // 10-01 … 10-04
    });

    test('noRepeat — a definition back 10 days later', () {
      final original = readJson(poolFile(manifest, '2026-10-02'));
      editPool(manifest, '2026-10-12', (p) {
        for (final key in <String>[
          'grid',
          'targetWord',
          'lockedCells',
          'frozenCells',
          'columnMovesEnabled',
          'optimalMoves',
        ]) {
          p[key] = original[key];
        }
      });
      expect(failures(), <String>[
        '[noRepeat] 2026-10-12: repeats the puzzle of 2026-10-02 within '
            '30 days',
      ]);
    });

    test('lang — a pool puzzle in another language', () {
      editPool(manifest, '2026-10-06', (p) => p['language'] = 'en');
      expect(tagsOf(failures()), <String>{'lang'});
    });
  });

  group('manifest problems (source only)', () {
    late String manifest;
    setUp(() => manifest = devSourceIn(tmp));

    List<String> failures() => buildDailyPack(manifest).failures;

    test('an assignment that names no pool puzzle', () {
      editManifest(manifest,
          (json) => assignmentsOf(json)['2026-10-02'] = 'daily-tr-nope');
      expect(failures(), <String>[
        '[manifest] 2026-10-02: "daily-tr-nope" matches no pool puzzle '
            '(no pool puzzle has this id)',
      ]);
    });

    test('a missing numbering epoch, lang or contentVersion', () {
      for (final key in <String>['numberingEpoch', 'lang', 'contentVersion']) {
        final fresh = devSourceIn(Directory('${tmp.path}/$key'));
        editManifest(fresh, (json) => json.remove(key));
        final f = buildDailyPack(fresh).failures;
        expect(tagsOf(f), <String>{'manifest'}, reason: key);
        expect(f.join('\n'), contains('"$key"'), reason: key);
      }
    });

    test('a manifest not at <lang>/daily_manifest_<lang>.json', () {
      final moved = '${File(manifest).parent.path}/manifest.json';
      File(manifest).renameSync(moved);
      expect(buildDailyPack(moved).failures.single,
          contains('must be <lang>/daily_manifest_<lang>.json'));
    });

    test('one id in two pool files', () {
      File(poolFile(manifest, '2026-10-02'))
          .copySync('${File(manifest).parent.path}/pool/copy.json');
      expect(
          failures().single, contains('pool id "daily-tr-2026-10-02" is in'));
    });

    test('a broken pool file nobody assigns is still reported', () {
      File('${File(manifest).parent.path}/pool/draft.json')
          .writeAsStringSync('{"id": 1}');
      expect(failures().single, startsWith('[puzzleParses] pool/draft.json'));
    });
  });

  group('check runs the pack rules on every Daily manifest', () {
    test('a clean daily source under content/ passes', () async {
      devSourceIn(Directory('${tmp.path}/content'), days: 5);
      final failures = await runContentCheck(
          root: '${tmp.path}/content', repoRoot: _repoRoot);
      expect(failures, isEmpty);
    });

    test('a pack rule failure is named with the manifest path', () async {
      final manifest = devSourceIn(Directory('${tmp.path}/content'), days: 5);
      editPool(manifest, '2026-10-03', (p) => p['dailyDate'] = '2026-10-30');
      final failures = await runContentCheck(
          root: '${tmp.path}/content', repoRoot: _repoRoot);
      expect(failures, <String>[
        '$manifest: [puzzleDate] 2026-10-03: puzzle.dailyDate 2026-10-30 != '
            'the day',
      ]);
    });

    test('a date gap fails check, not only pack-daily', () async {
      final manifest = devSourceIn(Directory('${tmp.path}/content'), days: 5);
      editManifest(
          manifest, (json) => assignmentsOf(json).remove('2026-10-03'));
      final failures = await runContentCheck(
          root: '${tmp.path}/content', repoRoot: _repoRoot);
      expect(failures, hasLength(1));
      expect(failures.single, contains('[datesContiguous]'));
    });
  });
}
