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
}
