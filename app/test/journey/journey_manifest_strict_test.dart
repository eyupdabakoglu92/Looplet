// F05-QA-2 / F05-QA-STRICT-1 — the content-manifest build gate's failure paths
// (`architecture.md §5.4` / §15). Feeds `runJourneyManifestGate` synthetic
// manifests to prove the strict branch rejects a short / broken pack AND every
// single band rule (R1–R6 + the manifest-label check), each with its own
// negative case, while smoke mode only reports. Also proves the bundle-mirror
// comparison rejects drift.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart';

import 'journey_gate_support.dart';

/// The label every synthetic level uses — inside its §5.4 R6 band.
String _bandLabel(int n) => n <= 6
    ? 'easy'
    : n <= 15
    ? 'medium'
    : n <= 25
    ? 'hard'
    : 'expert';

/// A synthetic level that satisfies every §5.4 band rule for [n]: columns from
/// level 4, a locked cell on 16–20 and 26–30, a frozen cell on 21–30.
Map<String, Object?> _level(int n) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'strict-test',
  'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
  'puzzleType': 'journey',
  'journeyLevelNumber': n,
  'language': 'tr',
  'grid': const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  'targetWord': 'MASAL',
  'lockedCells': (n >= 16 && n <= 20) || n >= 26
      ? const <String>['0,0']
      : const <String>[],
  'frozenCells': n >= 21 ? const <String>['4,4'] : const <String>[],
  'columnMovesEnabled': n >= 4,
  'optimalMoves': 1,
  'difficultyScore': 1,
  'difficultyLabel': _bandLabel(n),
  'difficultyBreakdown': const <String, Object?>{},
};

/// A manifest map with `count` contiguous levels in the given [mode].
/// [labels] overrides individual manifest-entry labels.
Map<String, Object?> _manifestJson(
  int count, {
  required String mode,
  Map<int, String> labels = const {},
}) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'strict-test',
  'lang': 'tr',
  'mode': mode,
  'levels': <Map<String, Object?>>[
    for (var n = 1; n <= count; n++)
      <String, Object?>{
        'n': n,
        'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
        'asset': 'tr/journey-tr-${n.toString().padLeft(2, '0')}.json',
        'difficultyLabel': labels[n] ?? _bandLabel(n),
      },
  ],
};

/// A reader backed by `count` synthetic level assets. Any level number in
/// [missing] is treated as an unresolved asset; [mutate] edits one level's JSON.
Future<String> Function(String) _reader(
  int count, {
  Set<int> missing = const {},
  Map<int, void Function(Map<String, Object?> level)> mutate = const {},
}) {
  final files = <String, String>{};
  for (var n = 1; n <= count; n++) {
    if (missing.contains(n)) continue;
    final level = _level(n);
    mutate[n]?.call(level);
    files['tr/journey-tr-${n.toString().padLeft(2, '0')}.json'] = jsonEncode(
      level,
    );
  }
  return (assetKey) async {
    final v = files[assetKey];
    if (v == null) throw StateError('no asset "$assetKey"');
    return v;
  };
}

/// Runs the strict gate over 30 band-conformant levels with exactly one edit.
Future<JourneyGateReport> _strictWith({
  Map<int, void Function(Map<String, Object?> level)> mutate = const {},
  Map<int, String> labels = const {},
}) => runJourneyManifestGate(
  JourneyManifest.fromJson(
    _manifestJson(journeyLevelCount, mode: 'strict', labels: labels),
  ),
  readAsset: _reader(journeyLevelCount, mutate: mutate),
);

/// Asserts the gate failed with exactly one violation: [rule] on [level].
void _expectOnly(JourneyGateReport report, String rule, int level) {
  expect(report.passed, isFalse, reason: report.toString());
  expect(report.violations, hasLength(1), reason: report.toString());
  expect(report.violations.single, startsWith('level $level: $rule '));
}

void main() {
  test('strict + < 30 levels → gate FAILS', () async {
    final manifest = JourneyManifest.fromJson(_manifestJson(5, mode: 'strict'));
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(5),
    );

    expect(report.passed, isFalse);
    expect(report.shortfall, journeyLevelCount - 5);
    expect(
      report.violations.any((v) => v.contains('must ship $journeyLevelCount')),
      isTrue,
      reason: report.toString(),
    );
  });

  test('strict + a missing/unresolvable asset → gate FAILS', () async {
    final manifest = JourneyManifest.fromJson(
      _manifestJson(journeyLevelCount, mode: 'strict'),
    );
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(journeyLevelCount, missing: <int>{17}),
    );

    expect(report.passed, isFalse);
    expect(
      report.violations.any(
        (v) => v.contains('level 17') && v.contains('resolve'),
      ),
      isTrue,
      reason: report.toString(),
    );
  });

  test('strict + exactly 30 band-conformant levels → gate PASSES and every '
      'band rule ran', () async {
    final report = await _strictWith();

    expect(report.passed, isTrue, reason: report.toString());
    expect(report.shortfall, 0);
    expect(report.advisories, isEmpty);
    // R1 ×3 + R2 ×7 + R3 ×5 + R4 ×5 + R5 ×5 + R6 ×30 + LABEL ×30.
    expect(report.bandChecks, 85);
  });

  group('strict band rules — one rejecting case per rule (§5.4)', () {
    test('R1: level 2 with column moves enabled → FAILS', () async {
      final report = await _strictWith(
        mutate: {2: (l) => l['columnMovesEnabled'] = true},
      );
      _expectOnly(report, 'R1', 2);
    });

    test('R2: level 7 without column moves → FAILS', () async {
      final report = await _strictWith(
        mutate: {7: (l) => l['columnMovesEnabled'] = false},
      );
      _expectOnly(report, 'R2', 7);
    });

    test('R3: level 17 without a locked cell → FAILS', () async {
      final report = await _strictWith(
        mutate: {17: (l) => l['lockedCells'] = const <String>[]},
      );
      _expectOnly(report, 'R3', 17);
    });

    test('R4: level 22 without a frozen cell → FAILS', () async {
      final report = await _strictWith(
        mutate: {22: (l) => l['frozenCells'] = const <String>[]},
      );
      _expectOnly(report, 'R4', 22);
    });

    test('R5: level 28 without a frozen cell (locked kept) → FAILS', () async {
      final report = await _strictWith(
        mutate: {28: (l) => l['frozenCells'] = const <String>[]},
      );
      _expectOnly(report, 'R5', 28);
    });

    test('R5: level 27 without a locked cell (frozen kept) → FAILS', () async {
      final report = await _strictWith(
        mutate: {27: (l) => l['lockedCells'] = const <String>[]},
      );
      _expectOnly(report, 'R5', 27);
    });

    test(
      'R6: level 28 labelled "easy" (asset and manifest agree) → FAILS',
      () async {
        final report = await _strictWith(
          mutate: {28: (l) => l['difficultyLabel'] = 'easy'},
          labels: {28: 'easy'},
        );
        _expectOnly(report, 'R6', 28);
      },
    );

    test('LABEL: manifest says "medium", asset says "hard" (both in band) → '
        'FAILS', () async {
      final report = await _strictWith(labels: {20: 'medium'});
      _expectOnly(report, 'LABEL', 20);
    });
  });

  test('smoke + < 30 levels → gate PASSES, shortfall only reported', () async {
    final manifest = JourneyManifest.fromJson(_manifestJson(5, mode: 'smoke'));
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(5),
    );

    expect(report.passed, isTrue, reason: report.toString());
    expect(report.shortfall, journeyLevelCount - 5);
    expect(report.advisories, isEmpty);
  });

  test('smoke + a band-rule break → PASSES, reported as an advisory', () async {
    final manifest = JourneyManifest.fromJson(_manifestJson(5, mode: 'smoke'));
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(
        5,
        mutate: {4: (l) => l['columnMovesEnabled'] = false},
      ),
    );

    expect(report.passed, isTrue, reason: report.toString());
    expect(report.advisories, hasLength(1), reason: report.toString());
    expect(report.advisories.single, startsWith('level 4: R2 '));
  });

  test('smoke + a broken asset → still FAILS (consistency is enforced in both '
      'modes)', () async {
    final manifest = JourneyManifest.fromJson(_manifestJson(5, mode: 'smoke'));
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(5, missing: <int>{3}),
    );

    expect(report.passed, isFalse);
    expect(
      report.violations.any((v) => v.contains('level 3')),
      isTrue,
      reason: report.toString(),
    );
  });

  group('bundle mirror (§5.4 "shipped bundle == verified source")', () {
    late Directory tmp;
    late Directory source;
    late Directory bundle;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('journey_mirror');
      source = Directory('${tmp.path}/content/journey/tr')
        ..createSync(recursive: true);
      bundle = Directory('${tmp.path}/assets/journey/tr')
        ..createSync(recursive: true);
      for (final dir in <Directory>[source, bundle]) {
        File('${dir.path}/journey-tr-01.json').writeAsStringSync('{"a":1}');
        File('${dir.path}/journey_manifest_tr.json').writeAsStringSync('{}');
      }
    });
    tearDown(() => tmp.deleteSync(recursive: true));

    List<String> compare() => compareJourneyMirror(
      source: Directory('${tmp.path}/content/journey'),
      bundle: Directory('${tmp.path}/assets/journey'),
    );

    test('identical trees → no differences', () {
      expect(compare(), isEmpty);
    });

    test('a byte drift in the bundle → reported', () {
      File('${bundle.path}/journey-tr-01.json').writeAsStringSync('{"a":2}');
      expect(compare(), <String>['tr/journey-tr-01.json: bytes differ']);
    });

    test('a file missing from the bundle → reported', () {
      File('${bundle.path}/journey-tr-01.json').deleteSync();
      expect(compare(), <String>[
        'tr/journey-tr-01.json: missing from the bundle',
      ]);
    });

    test('a bundle-only file → reported', () {
      File('${bundle.path}/journey-tr-02.json').writeAsStringSync('{}');
      expect(compare(), <String>[
        'tr/journey-tr-02.json: in the bundle but not in the authored source',
      ]);
    });

    test('dotfiles are ignored', () {
      File('${bundle.path}/.DS_Store').writeAsStringSync('x');
      expect(compare(), isEmpty);
    });
  });
}
