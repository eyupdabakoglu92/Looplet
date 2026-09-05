import 'dart:convert';
import 'dart:io';

import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:test/test.dart';

// Tests run with CWD = tools/looplet_authoring; the repo root (for the shipped
// dictionary asset) is two levels up.
const _repoRoot = '../..';
const _fixtures = 'test/fixtures';

Future<(int, String, String)> run(List<String> args) async {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = await buildRunner(out: out, err: err).run(args) ?? 0;
  return (code, out.toString(), err.toString());
}

void main() {
  test('solve prints optimal moves + difficulty for a solvable puzzle',
      () async {
    final (code, out, _) = await run(
      <String>['solve', '$_fixtures/solvable.json', '--repo-root', _repoRoot],
    );
    expect(code, 0);
    expect(out, contains('solvable: yes'));
    expect(out, contains('optimalMoves: 1'));
    expect(out,
        contains(RegExp(r'difficultyScore: .+ \((easy|medium|hard|expert)\)')));
    expect(out, contains('sequence: R0'));
  });

  test('solve reports unsolvable cleanly with exit 0', () async {
    final (code, out, _) = await run(
      <String>['solve', '$_fixtures/unsolvable.json', '--repo-root', _repoRoot],
    );
    expect(code, 0);
    expect(out, contains('unsolvable'));
  });

  test('playtest reports each step and the final solved state', () async {
    final (code, out, _) = await run(<String>[
      'playtest',
      '$_fixtures/solvable.json',
      '--repo-root',
      _repoRoot,
      '--moves',
      'R0',
    ]);
    expect(code, 0);
    expect(out, contains('step 1 R0: applied'));
    expect(out, contains('solved: true'));
  });

  group('export gate', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('looplet_export'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('writes a valid artifact for a good puzzle', () async {
      final outPath = '${tmp.path}/level01.json';
      final (code, out, _) = await run(<String>[
        'export',
        '$_fixtures/solvable.json',
        '--repo-root',
        _repoRoot,
        '--out',
        outPath,
        '--content-version',
        '2026.09-test',
      ]);
      expect(code, 0);
      expect(out, contains('wrote'));
      final puzzle = Puzzle.fromJson(
        jsonDecode(File(outPath).readAsStringSync()) as Map<String, Object?>,
      );
      expect(puzzle.optimalMoves, 1);
      expect(puzzle.id, 'j-tr-1');
      expect(puzzle.contentVersion, '2026.09-test');
      expect(puzzle.difficultyBreakdown, isNotEmpty);
    });

    test('refuses an unsolvable puzzle: non-zero exit, no file', () async {
      final outPath = '${tmp.path}/bad.json';
      final (code, _, err) = await run(<String>[
        'export',
        '$_fixtures/unsolvable.json',
        '--repo-root',
        _repoRoot,
        '--out',
        outPath,
      ]);
      expect(code, isNot(0));
      expect(err, contains('unsolvable'));
      expect(File(outPath).existsSync(), isFalse);
    });

    test('refuses a trivial (optimalMoves 0) puzzle', () async {
      final outPath = '${tmp.path}/triv.json';
      final (code, _, err) = await run(<String>[
        'export',
        '$_fixtures/trivial.json',
        '--repo-root',
        _repoRoot,
        '--out',
        outPath,
      ]);
      expect(code, isNot(0));
      expect(err, contains('trivial'));
      expect(File(outPath).existsSync(), isFalse);
    });
  });

  test('malformed def file → non-zero exit', () async {
    final tmp = Directory.systemTemp.createTempSync('looplet_baddef');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final bad = File('${tmp.path}/bad.json')..writeAsStringSync('{ not json');
    final (code, _, _) = await run(
      <String>['solve', bad.path, '--repo-root', _repoRoot],
    );
    expect(code, isNot(0));
  });
}
