// F05-QA-2 — the content-manifest build gate's `mode:"strict"` failure path
// (`architecture.md §5.4` / §15). The bundled pack ships `mode:"smoke"`, so this
// feeds `runJourneyManifestGate` synthetic manifests to prove the strict branch
// actually rejects a short / broken pack while smoke mode only reports it.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart';

import 'journey_gate_support.dart';

Map<String, Object?> _level(int n) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'strict-test',
  'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
  'puzzleType': 'journey',
  'journeyLevelNumber': n,
  'language': 'tr',
  'grid': const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  'targetWord': 'MASAL',
  'lockedCells': const <String>[],
  'frozenCells': const <String>[],
  'columnMovesEnabled': false,
  'optimalMoves': 1,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': const <String, Object?>{},
};

/// A manifest map with `count` contiguous levels in the given [mode].
Map<String, Object?> _manifestJson(int count, {required String mode}) =>
    <String, Object?>{
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
            'difficultyLabel': 'easy',
          },
      ],
    };

/// A reader backed by `count` synthetic level assets. Any level number in
/// [missing] is treated as an unresolved asset.
Future<String> Function(String) _reader(
  int count, {
  Set<int> missing = const {},
}) {
  final files = <String, String>{
    for (var n = 1; n <= count; n++)
      if (!missing.contains(n))
        'tr/journey-tr-${n.toString().padLeft(2, '0')}.json': jsonEncode(
          _level(n),
        ),
  };
  return (assetKey) async {
    final v = files[assetKey];
    if (v == null) throw StateError('no asset "$assetKey"');
    return v;
  };
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

  test('strict + exactly 30 valid levels → gate PASSES', () async {
    final manifest = JourneyManifest.fromJson(
      _manifestJson(journeyLevelCount, mode: 'strict'),
    );
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(journeyLevelCount),
    );

    expect(report.passed, isTrue, reason: report.toString());
    expect(report.shortfall, 0);
  });

  test('smoke + < 30 levels → gate PASSES, shortfall only reported', () async {
    final manifest = JourneyManifest.fromJson(_manifestJson(5, mode: 'smoke'));
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: _reader(5),
    );

    expect(report.passed, isTrue, reason: report.toString());
    expect(report.shortfall, journeyLevelCount - 5);
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
}
