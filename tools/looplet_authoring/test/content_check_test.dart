import 'dart:convert';
import 'dart:io';

import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:test/test.dart';

const _repoRoot = '../..';

/// Exports the solvable fixture and returns the artifact JSON as a map.
Future<Map<String, Object?>> goodArtifact(Directory tmp) async {
  final outPath = '${tmp.path}/level01.json';
  final code = await buildRunner(out: StringBuffer(), err: StringBuffer()).run(
    <String>[
      'export',
      'test/fixtures/solvable.json',
      '--repo-root',
      _repoRoot,
      '--out',
      outPath,
      '--content-version',
      '2026.09-test',
    ],
  );
  expect(code, 0);
  return jsonDecode(File(outPath).readAsStringSync()) as Map<String, Object?>;
}

void write(Directory dir, String name, Object json) {
  File('${dir.path}/$name').writeAsStringSync(jsonEncode(json));
}

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('looplet_check'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('a directory of valid artifacts passes', () async {
    final good = await goodArtifact(tmp);
    final content = Directory('${tmp.path}/content')..createSync();
    write(content, 'level01.json', good);

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
    );
    expect(failures, isEmpty);
  });

  test('catches a missing optimalMoves', () async {
    final good = await goodArtifact(tmp);
    final content = Directory('${tmp.path}/content')..createSync();
    write(content, 'bad.json',
        <String, Object?>{...good}..remove('optimalMoves'));

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
    );
    expect(failures, isNotEmpty);
    expect(failures.join('\n'), contains('optimalMoves'));
  });

  test('catches a level 1–3 puzzle with columns enabled', () async {
    final good = await goodArtifact(tmp);
    final content = Directory('${tmp.path}/content')..createSync();
    write(content, 'lvl2.json', <String, Object?>{
      ...good,
      'id': 'j-tr-2',
      'journeyLevelNumber': 2,
      'columnMovesEnabled': true,
    });

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
    );
    expect(failures.join('\n'), contains('columnMovesEnabled == false'));
  });

  test('catches a stored optimalMoves that disagrees with a fresh solve',
      () async {
    final good = await goodArtifact(tmp);
    final content = Directory('${tmp.path}/content')..createSync();
    write(content, 'drift.json', <String, Object?>{...good, 'optimalMoves': 9});

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
    );
    expect(failures.join('\n'), contains('!= fresh solve'));
  });

  test('catches a duplicate puzzle definition', () async {
    final good = await goodArtifact(tmp);
    final content = Directory('${tmp.path}/content')..createSync();
    write(content, 'a.json', good);
    write(content, 'b.json', <String, Object?>{...good, 'id': 'j-tr-copy'});

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
    );
    expect(failures.join('\n'), contains('duplicate puzzle definition'));
  });

  test('catches an ineligible target word', () async {
    final good = await goodArtifact(tmp);
    final content = Directory('${tmp.path}/content')..createSync();
    // "kelime" is a valid word but NOT a curated target in the shipped list.
    write(content, 'badtarget.json', <String, Object?>{
      ...good,
      'grid': <String>['ELIMK', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
      'targetWord': 'KELIME'.substring(0, 5), // "KELIM" - not eligible
      'optimalMoves': 1,
    });

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
    );
    // either an eligibility failure or a solve mismatch — both are check failures
    expect(failures, isNotEmpty);
  });

  test('catches a Daily manifest that repeats a puzzle within the window',
      () async {
    final content = Directory('${tmp.path}/content')..createSync();
    write(content, 'manifest.json', <String, Object?>{
      'language': 'tr',
      'assignments': <String, Object?>{
        '2026-09-01': 'daily-a',
        '2026-09-10': 'daily-a', // repeat within 30 days
        '2026-11-01': 'daily-a', // fine, > 30 days later
      },
    });

    final failures = await runContentCheck(
      root: content.path,
      repoRoot: _repoRoot,
      noRepeatWindowDays: 30,
    );
    expect(failures.join('\n'), contains('repeats within 30 days'));
  });

  test(
    'a Journey content manifest (levels shape) is recognised, not '
    'mistaken for a Puzzle artifact (F06-CONTENT-PROMOTE regression)',
    () async {
      final good = await goodArtifact(tmp);
      final content = Directory('${tmp.path}/content')..createSync();
      final journeyDir = Directory('${content.path}/journey/tr')
        ..createSync(recursive: true);
      write(journeyDir, 'journey-tr-01.json', good);
      write(journeyDir, 'journey_manifest_tr.json', <String, Object?>{
        'schemaVersion': 1,
        'contentVersion': '2026.09-v1',
        'lang': 'tr',
        'mode': 'strict',
        'levels': <Map<String, Object?>>[
          <String, Object?>{
            'n': 1,
            'id': good['id'],
            'asset': 'tr/journey-tr-01.json',
            'difficultyLabel': good['difficultyLabel'],
            'checksum': 'sha256:not-checked-by-this-gate',
          },
        ],
      });

      final failures = await runContentCheck(
        root: content.path,
        repoRoot: _repoRoot,
      );
      // The manifest itself must not be flagged (e.g. "puzzleType must be a
      // non-empty string") — only the real Puzzle rules apply, if any.
      expect(
        failures.where((f) => f.contains('journey_manifest_tr.json')),
        isEmpty,
      );
    },
  );

  group('Journey-manifest recognition is path + shape (F05-QA-STRICT-2)', () {
    late Directory journeyDir;
    late Map<String, Object?> good;

    setUp(() async {
      good = await goodArtifact(tmp);
      journeyDir = Directory('${tmp.path}/content/journey/tr')
        ..createSync(recursive: true);
    });

    Map<String, Object?> manifest(
            {String mode = 'strict', String lang = 'tr'}) =>
        <String, Object?>{
          'schemaVersion': 1,
          'contentVersion': '2026.09-v1',
          'lang': lang,
          'mode': mode,
          'levels': <Map<String, Object?>>[
            <String, Object?>{
              'n': 1,
              'id': good['id'],
              'asset': 'tr/journey-tr-01.json',
              'difficultyLabel': good['difficultyLabel'],
            },
          ],
        };

    Future<List<String>> check() => runContentCheck(
          root: '${tmp.path}/content',
          repoRoot: _repoRoot,
        );

    test(
        'a Puzzle with a stray "levels" key is still fully validated '
        '(a wrong optimalMoves is caught)', () async {
      write(journeyDir, 'journey-tr-02.json', <String, Object?>{
        ...good,
        'optimalMoves': 9,
        'levels': <Object?>[],
      });

      final failures = await check();
      expect(
        failures.where(
          (f) =>
              f.contains('journey-tr-02.json') && f.contains('!= fresh solve'),
        ),
        hasLength(1),
        reason: failures.join('\n'),
      );
    });

    test(
        'a manifest-shaped file outside journey/<lang>/journey_manifest_<lang>'
        '.json is not skipped', () async {
      write(journeyDir, 'manifest_copy.json', manifest());

      final failures = await check();
      expect(
        failures.where((f) => f.contains('manifest_copy.json')),
        isNotEmpty,
        reason: failures.join('\n'),
      );
    });

    test('a manifest with an unknown mode at the manifest path fails',
        () async {
      write(journeyDir, 'journey_manifest_tr.json', manifest(mode: 'loose'));

      final failures = await check();
      expect(
        failures,
        contains(
          allOf(
            contains('journey_manifest_tr.json'),
            contains('malformed Journey manifest'),
            contains('"mode"'),
          ),
        ),
      );
    });

    test('a manifest whose lang disagrees with its directory fails', () async {
      write(journeyDir, 'journey_manifest_tr.json', manifest(lang: 'en'));

      final failures = await check();
      expect(
        failures,
        contains(
          allOf(
            contains('journey_manifest_tr.json'),
            contains('"lang" must be "tr"'),
          ),
        ),
      );
    });

    test('a manifest without levels at the manifest path fails', () async {
      write(
        journeyDir,
        'journey_manifest_tr.json',
        manifest()..remove('levels'),
      );

      final failures = await check();
      expect(
        failures,
        contains(
          allOf(
            contains('journey_manifest_tr.json'),
            contains('"levels" must be a non-empty array'),
          ),
        ),
      );
    });
  });
}
