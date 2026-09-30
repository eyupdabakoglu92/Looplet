import 'dart:io';

import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:looplet_authoring/src/daily_pool_quality.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:test/test.dart';

Map<String, dynamic> day(DateTime date,
    {bool useful = true, bool regression = true, bool hard = true}) {
  const kinds = [
    'open',
    'locked',
    'frozen',
    'open',
    'locked',
    'both',
    'frozen'
  ];
  final stamp = date.toIso8601String().substring(0, 10);
  return {
    'id': 'daily-tr-$stamp',
    'date': stamp,
    'target': stamp,
    'accepted': true,
    'mechanic': kinds[date.weekday - 1],
    'difficulty': {'label': hard ? 'hard' : 'medium'},
    'regression': {'status': regression ? 'PASS' : 'FAIL'},
    'rules': {
      'Q7': {'status': useful ? 'PASS' : 'FAIL'}
    }
  };
}

void main() {
  test('60-day calendar handles initial/final partial ISO weeks', () {
    final days = List.generate(
        60, (i) => day(DateTime.utc(2026, 11, 1).add(Duration(days: i))));
    days.first['regression'] = {
      'status': 'FAIL'
    }; // single-day week, no two-day quota
    expect(poolRules(days, pilot: false)['status'], 'PASS');
    expect(poolRules(days.take(59).toList(), pilot: false)['status'], 'FAIL');
    days[2]['target'] = days[1]['target'];
    expect(poolRules(days, pilot: false)['status'], 'FAIL');
  });
  test('Q3 complete week requires two proofs and a hard heavy regression day',
      () {
    final days = List.generate(
        60, (i) => day(DateTime.utc(2026, 11, 1).add(Duration(days: i))));
    for (var i = 1; i <= 7; i++) {
      days[i]['regression'] = {'status': 'UNKNOWN'};
    }
    expect(poolRules(days, pilot: false)['status'], 'FAIL');
    for (var i = 1; i <= 7; i++) {
      days[i]['regression'] = {'status': 'PASS'};
    }
    for (var i = 5; i <= 7; i++) {
      days[i]['difficulty'] = {'label': 'medium'};
    }
    expect(poolRules(days, pilot: false)['status'], 'FAIL');
  });
  test('Q7 threshold accepts half, rejects fewer without misusing N/A', () {
    final dates = [2, 3, 4, 7, 9, 10, 11, 14];
    final days = dates.map((d) => day(DateTime.utc(2026, 11, d))).toList();
    days[2]['rules'] = {
      'Q7': {'status': 'FAIL'}
    };
    days[3]['rules'] = {
      'Q7': {'status': 'UNKNOWN'}
    };
    expect(poolRules(days, pilot: true)['status'], 'PASS');
    days[6]['rules'] = {
      'Q7': {'status': 'FAIL'}
    };
    expect(poolRules(days, pilot: true)['status'], 'FAIL');
  });
  test('pilot requires exactly eight and two of every mechanic', () {
    final days = [2, 3, 4, 7, 9, 10, 11, 14]
        .map((d) => day(DateTime.utc(2026, 11, d)))
        .toList();
    expect(poolRules(days, pilot: true)['status'], 'PASS');
    days[7]['mechanic'] = 'open';
    expect(poolRules(days, pilot: true)['status'], 'FAIL');
  });
  test('pilot rejects duplicate dates even with distinct targets', () {
    final days = [2, 3, 4, 7, 9, 10, 11, 14]
        .map((d) => day(DateTime.utc(2026, 11, d)))
        .toList();
    days[4]['date'] = days[0]['date'];
    expect(poolRules(days, pilot: true)['status'], 'FAIL');
  });
  test(
      'production packing fails without evidence and preserves existing output',
      () async {
    final tmp = Directory.systemTemp.createTempSync('looplet_pack_gate');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final output = File('${tmp.path}/pack.json')
      ..writeAsStringSync('previous valid build');
    final err = StringBuffer();
    final code = await buildRunner(out: StringBuffer(), err: err).run([
      'pack-daily',
      '../../content/daily/tr',
      '--repo-root',
      '../..',
      '--out',
      output.path
    ]);
    expect(code, 1);
    expect(err.toString(), contains('quality-report'));
    expect(output.readAsStringSync(), 'previous valid build');
  });
  test('development switch cannot pack production-marked content', () async {
    final tmp = Directory.systemTemp.createTempSync('looplet_pack_bypass');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final err = StringBuffer();
    final code = await buildRunner(out: StringBuffer(), err: err).run([
      'pack-daily',
      '../../content/daily/tr',
      '--repo-root',
      '../..',
      '--development-fixture',
      '--out',
      '${tmp.path}/pack.json'
    ]);
    expect(code, 1);
    expect(err.toString(), contains('restricted to marked dev fixtures'));
    expect(File('${tmp.path}/pack.json').existsSync(), false);
  });
  test('missing and pilot evidence never authorize production pack', () {
    final tmp = Directory.systemTemp.createTempSync('looplet_report');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final path = '${tmp.path}/report.json';
    expect(() => verifyQualityReport('../..', '../../content/daily/tr', path),
        throwsA(isA<FileSystemException>()));
    writeObject(path, {'schemaVersion': 1, 'scope': 'pilot', 'result': 'PASS'});
    expect(() => verifyQualityReport('../..', '../../content/daily/tr', path),
        throwsStateError);
  });
  test('fingerprint binds engine/corpus/source/proof, stale report fails', () {
    final tmp = Directory.systemTemp.createTempSync('looplet_fingerprint');
    addTearDown(() => tmp.deleteSync(recursive: true));
    for (final dir in ['pool', 'defs', 'proofs']) {
      Directory('${tmp.path}/$dir').createSync();
    }
    writeObject('${tmp.path}/daily_manifest_tr.json', {'test': true});
    writeObject('${tmp.path}/proofs/test.json', {'reference': 'L0'});
    for (var i = 0; i < 60; i++) {
      writeObject('${tmp.path}/pool/test-$i.json', {'synthetic': true});
    }
    final before = qualityFingerprint('../..', tmp.path);
    expect(before.keys.any((k) => k.startsWith('packages/looplet_engine/lib/')),
        true);
    expect(before.keys.any((k) => k.contains('dictionary.json')), true);
    final path = '${tmp.path}/report.json';
    final days = List.generate(60, (i) {
      final d = day(DateTime.utc(2026, 11, 1).add(Duration(days: i)));
      d['id'] = 'test-$i';
      d['rules'] = {
        for (final q in ['Q1', 'Q2', 'Q3', 'Q4', 'Q8', 'Q10', 'Q11', 'Q12'])
          q: {'status': 'PASS'},
        'Q5': {'status': d['mechanic'] == 'open' ? 'N/A' : 'PASS'},
        'Q6': {
          'status': ['open', 'locked'].contains(d['mechanic']) ? 'N/A' : 'PASS'
        },
        'Q7': {'status': 'PASS'},
      };
      return d;
    });
    writeObject(path, {
      'schemaVersion': 1,
      'scope': 'full',
      'result': 'PASS',
      'pool': {'status': 'PASS'},
      'Q12': {'status': 'PASS'},
      'errors': <String>[],
      'days': days,
      'files': before,
      'inputHash': fingerprintHash(before)
    });
    verifyQualityReport('../..', tmp.path,
        path); // synthetic gate fixture, NOT a real content audit
    writeObject('${tmp.path}/proofs/test.json', {'reference': 'R0'});
    expect(
        () => verifyQualityReport('../..', tmp.path, path), throwsStateError);
  });
}
