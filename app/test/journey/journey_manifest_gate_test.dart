// F05-FE.GATE — the Journey content-manifest build gate (f05 architecture.md
// §5.4). Loads the REAL bundled `assets/journey/tr/` pack via `rootBundle` and
// validates it. `smoke` mode only logs a <30 shortfall; `strict` mode requires
// exactly 30. Runs inside `melos run test` / `melos run content:journey`.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_content/looplet_content.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lang = 'tr';
  final raw = await rootBundle.loadString(
    'assets/journey/$lang/journey_manifest_$lang.json',
  );
  final manifest = JourneyManifest.fromJson(
    jsonDecode(raw) as Map<String, Object?>,
  );

  test('manifest schema + contiguity', () {
    expect(manifest.schemaVersion, JourneyManifest.currentSchemaVersion);
    expect(manifest.lang, lang);
    expect(manifest.mode, anyOf('smoke', 'strict'));
    for (var i = 0; i < manifest.levels.length; i++) {
      expect(manifest.levels[i].n, i + 1);
    }
  });

  test(
    'strict mode ⇒ exactly 30 levels (smoke mode only logs the shortfall)',
    () {
      if (manifest.isStrict) {
        expect(
          manifest.levels.length,
          journeyLevelCount,
          reason: 'strict Journey manifest must ship all 30 levels',
        );
      } else {
        if (manifest.levels.length < journeyLevelCount) {
          // ignore: avoid_print
          print(
            'journey content gate (smoke): ${manifest.levels.length}/'
            '$journeyLevelCount levels — F06-CONTENT delivers the rest.',
          );
        }
      }
    },
  );

  test(
    'every manifest level resolves to a valid Puzzle with a stable id',
    () async {
      for (final entry in manifest.levels) {
        final assetRaw = await rootBundle.loadString(
          'assets/journey/${entry.asset}',
        );

        // checksum (when the manifest declares one)
        if (entry.checksum != null) {
          final digest = sha256.convert(utf8.encode(assetRaw)).toString();
          expect(
            digest,
            entry.checksum,
            reason: 'checksum drift for ${entry.asset}',
          );
        }

        final puzzle = Puzzle.fromJson(
          jsonDecode(assetRaw) as Map<String, Object?>,
        );
        expect(puzzle.id, entry.id, reason: 'id mismatch for level ${entry.n}');
        expect(
          puzzle.id,
          journeyLevelId(entry.n, lang),
          reason: 'level ${entry.n} does not follow journey-$lang-NN',
        );
        expect(puzzle.journeyLevelNumber, entry.n);
        expect(
          puzzle.optimalMoves,
          greaterThanOrEqualTo(1),
          reason: 'level ${entry.n} must carry a solver-verified optimal',
        );
      }
    },
  );

  test('band rules (strict-only hard check; smoke-mode advisory)', () {
    // Only meaningful once the full 30 land; skip in smoke mode where the
    // interim pack knowingly re-ids the smoke set.
    if (!manifest.isStrict) return;
    // (Deferred: the strict-mode structural band assertions land with
    // F06-CONTENT — see f05 architecture.md §5.4.)
  });
}
