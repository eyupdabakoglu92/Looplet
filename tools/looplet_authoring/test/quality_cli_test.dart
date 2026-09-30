import 'dart:io';

import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:looplet_authoring/src/quality_cli.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  late String corpus;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('looplet_quality_cli');
    corpus = '${tmp.path}/corpus.json';
    writeObject(corpus, importCorpus('data/tr'));
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('regression planner satisfies pilot and every complete production week',
      () {
    final pilotDates = [2, 3, 4, 7, 9, 10, 11, 14]
        .map((day) => DateTime.utc(2026, 11, day))
        .toList();
    expect(plannedRegressionDates(pilotDates, pilot: true), {'2026-11-14'});
    final fullDates = List.generate(
        60, (i) => DateTime.utc(2026, 11, 1).add(Duration(days: i)));
    final planned = plannedRegressionDates(fullDates, pilot: false);
    expect(planned, hasLength(16));
    expect(planned, containsAll(['2026-11-02', '2026-11-07']));
    expect(planned, isNot(contains('2026-11-01')));
    expect(plannedRegressionDates(pilotDates, pilot: true, forceAll: true),
        pilotDates.map((d) => d.toIso8601String().substring(0, 10)).toSet());
  });

  test('batch cannot start without an accepted current pilot', () async {
    final err = StringBuffer();
    final code = await buildRunner(out: StringBuffer(), err: err).run([
      'generate-daily',
      '--repo-root',
      '../..',
      '--corpus',
      corpus,
      '--out',
      '${tmp.path}/batch',
      '--no-pilot',
    ]);
    expect(code, 1);
    expect(err.toString(), contains('batch needs --pilot-report'));
    expect(Directory('${tmp.path}/batch').existsSync(), false);
  });

  test('source-uncurated corpus cannot enter generation', () async {
    final asset = readObject(corpus);
    (asset['words'] as List).add('uydur');
    writeObject(corpus, asset);
    final err = StringBuffer();
    final code = await buildRunner(out: StringBuffer(), err: err).run([
      'generate-daily',
      '--repo-root',
      '../..',
      '--corpus',
      corpus,
      '--out',
      '${tmp.path}/pilot',
    ]);
    expect(code, 1);
    expect(err.toString(), contains('source-checked curated corpus'));
    expect(Directory('${tmp.path}/pilot').existsSync(), false);
  });

  test('attempt budget cannot silently exceed the bounded profile', () async {
    final err = StringBuffer();
    final code = await buildRunner(out: StringBuffer(), err: err).run([
      'generate-daily',
      '--repo-root',
      '../..',
      '--corpus',
      corpus,
      '--out',
      '${tmp.path}/pilot',
      '--attempts',
      '201',
    ]);
    expect(code, 1);
    expect(err.toString(), contains('attempts must be 1..200'));
  });

  test('empty pilot and invalid manifest produce persisted FAIL, never PASS',
      () async {
    final source = '${tmp.path}/pilot';
    for (final dir in ['defs', 'proofs', 'pool']) {
      Directory('$source/$dir').createSync(recursive: true);
    }
    writeObject('$source/daily_manifest_tr.json', {'schemaVersion': 1});
    final report = '${tmp.path}/audit.json';
    final code =
        await buildRunner(out: StringBuffer(), err: StringBuffer()).run([
      'audit-daily',
      source,
      '--repo-root',
      '../..',
      '--corpus',
      corpus,
      '--out',
      report,
      '--pilot',
    ]);
    expect(code, 1);
    final result = readObject(report);
    expect(result['result'], 'FAIL');
    expect(jsonValue(result, 'pool.status'), 'FAIL');
    expect(result['errors'], isNotEmpty);
    expect(result['independentQa'], false);
  });
}
