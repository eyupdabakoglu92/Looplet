// F05-FE.GATE — the Journey content-manifest build gate (`architecture.md
// §5.4`). Loads the REAL bundled `assets/journey/tr/` pack via `rootBundle` and
// runs `runJourneyManifestGate` — the same gate implementation
// `journey_manifest_strict_test.dart` exercises against synthetic
// smoke / strict manifests (the `mode:"strict"` failure path). Runs inside
// `melos run test` / `melos run content:journey`.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart';

import 'journey_gate_support.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lang = 'tr';
  final raw = await rootBundle.loadString(
    'assets/journey/$lang/journey_manifest_$lang.json',
  );
  final manifest = JourneyManifest.fromJson(
    jsonDecode(raw) as Map<String, Object?>,
  );

  Future<String> readAsset(String assetKey) =>
      rootBundle.loadString('assets/journey/$assetKey');

  test('manifest schema + contiguity', () {
    expect(manifest.schemaVersion, JourneyManifest.currentSchemaVersion);
    expect(manifest.lang, lang);
    expect(manifest.mode, anyOf('smoke', 'strict'));
    for (var i = 0; i < manifest.levels.length; i++) {
      expect(manifest.levels[i].n, i + 1);
    }
  });

  test('the gate passes for the bundled pack; strict ⇒ 30 (smoke ⇒ logs the '
      'shortfall)', () async {
    final report = await runJourneyManifestGate(
      manifest,
      readAsset: readAsset,
      lang: lang,
    );

    expect(
      report.passed,
      isTrue,
      reason: 'bundled Journey pack failed the gate: ${report.violations}',
    );

    if (manifest.isStrict) {
      expect(manifest.levels.length, journeyLevelCount);
      expect(report.shortfall, 0);
    } else if (report.shortfall > 0) {
      // ignore: avoid_print
      print(
        'journey content gate (smoke): ${manifest.levels.length}/'
        '$journeyLevelCount levels — F06-CONTENT delivers the rest.',
      );
    }
  });

  test('every manifest level follows the journey-<lang>-NN id scheme', () async {
    // Puzzle parse / id / journeyLevelNumber / optimalMoves / checksum are all
    // asserted inside `runJourneyManifestGate` above; re-state the id scheme
    // here for readability.
    for (final entry in manifest.levels) {
      expect(entry.id, journeyLevelId(entry.n, lang));
      expect(entry.asset, startsWith('$lang/'));
    }
  });

  test('band rules R1–R6 + manifest label hold for every shipped level '
      '(§5.4, F05-QA-STRICT-1)', () async {
    // F06-CONTENT has landed: the shipped pack must be the strict one (§5.5).
    expect(manifest.isStrict, isTrue, reason: 'shipped manifest is not strict');

    final report = await runJourneyManifestGate(
      manifest,
      readAsset: readAsset,
      lang: lang,
    );

    expect(report.violations, isEmpty, reason: report.toString());
    expect(report.advisories, isEmpty, reason: report.toString());
    // Non-vacuity: every band rule actually ran against every level —
    // R1 ×3 + R2 ×7 + R3 ×5 + R4 ×5 + R5 ×5 + R6 ×30 + LABEL ×30 = 85.
    expect(report.bandChecks, 85, reason: report.toString());
  });

  test('the shipped bundle mirrors content/journey byte-for-byte (§5.4)', () {
    // `flutter test` runs with the package root (`app/`) as the cwd.
    final diffs = compareJourneyMirror(
      source: Directory('../content/journey'),
      bundle: Directory('assets/journey'),
    );

    expect(
      diffs,
      isEmpty,
      reason:
          'app/assets/journey drifted from content/journey — run '
          '`melos run content:sync`:\n${diffs.join('\n')}',
    );
  });
}
