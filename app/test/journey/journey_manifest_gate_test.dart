// F05-FE.GATE — the Journey content-manifest build gate (`architecture.md
// §5.4`). Loads the REAL bundled `assets/journey/tr/` pack via `rootBundle` and
// runs `runJourneyManifestGate` — the same gate implementation
// `journey_manifest_strict_test.dart` exercises against synthetic
// smoke / strict manifests (the `mode:"strict"` failure path). Runs inside
// `melos run test` / `melos run content:journey`.

import 'dart:convert';

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

  test('band rules (strict-only hard check; smoke-mode advisory)', () {
    // Deferred: the strict-mode structural band assertions land with
    // F06-CONTENT — they need the real 30 authored levels (`architecture.md
    // §5.4`). In smoke mode the interim pack knowingly re-ids the F06 smoke set.
    if (!manifest.isStrict) return;
  });
}
