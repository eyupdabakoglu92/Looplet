// Shared support for the F05 content-manifest build gate (`architecture.md
// §5.4`). One implementation, exercised by BOTH `journey_manifest_gate_test.dart`
// (against the REAL bundled `assets/journey/` pack) and
// `journey_manifest_strict_test.dart` (against synthetic smoke / strict
// manifests). Not a test suite itself — no `_test` suffix.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_content/looplet_content.dart';

/// Result of one gate run. `passed` ⇔ no violations. `shortfall` is
/// `journeyLevelCount - levels.length` clamped `>= 0` (informational in `smoke`
/// mode, a violation in `strict` mode).
class JourneyGateReport {
  JourneyGateReport(this.violations, this.shortfall);

  final List<String> violations;
  final int shortfall;

  bool get passed => violations.isEmpty;

  @override
  String toString() =>
      'JourneyGateReport(passed: $passed, shortfall: $shortfall, '
      'violations: $violations)';
}

/// Runs the gate over a parsed [manifest] + an [readAsset] callback that returns
/// the raw JSON bytes for a `levels[].asset` key.
///
/// Always checked: contiguous `n` from 1; every `asset` resolves + parses as a
/// `Puzzle`; `puzzle.id == entry.id == journeyLevelId(n, lang)`;
/// `journeyLevelNumber == n`; `optimalMoves >= 1`; declared `checksum` matches
/// the asset's sha256. `mode == "strict"` additionally requires exactly
/// [journeyLevelCount] levels. The **structural band rules** (`architecture.md
/// §5.4`) are `[PENDING — F06-CONTENT]` — they need the real 30 authored levels
/// and are not enforced here.
Future<JourneyGateReport> runJourneyManifestGate(
  JourneyManifest manifest, {
  required Future<String> Function(String assetKey) readAsset,
  String lang = 'tr',
}) async {
  final violations = <String>[];
  final shortfall = manifest.levels.length < journeyLevelCount
      ? journeyLevelCount - manifest.levels.length
      : 0;

  if (manifest.isStrict && manifest.levels.length != journeyLevelCount) {
    violations.add(
      'strict manifest must ship $journeyLevelCount levels — has '
      '${manifest.levels.length}',
    );
  }

  for (var i = 0; i < manifest.levels.length; i++) {
    final entry = manifest.levels[i];
    final where = 'level ${entry.n}';

    if (entry.n != i + 1) {
      violations.add('$where: levels not contiguous from 1 (index $i)');
    }

    final String raw;
    try {
      raw = await readAsset(entry.asset);
    } catch (e) {
      violations.add('$where: asset "${entry.asset}" does not resolve — $e');
      continue;
    }

    if (entry.checksum != null) {
      final digest = sha256.convert(utf8.encode(raw)).toString();
      if (digest != entry.checksum) {
        violations.add('$where: checksum drift for "${entry.asset}"');
      }
    }

    final Puzzle puzzle;
    try {
      puzzle = Puzzle.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (e) {
      violations.add('$where: asset failed to parse as a Puzzle — $e');
      continue;
    }

    if (puzzle.id != entry.id) {
      violations.add(
        '$where: id mismatch — manifest "${entry.id}" vs asset "${puzzle.id}"',
      );
    }
    if (puzzle.id != journeyLevelId(entry.n, lang)) {
      violations.add(
        '$where: id "${puzzle.id}" breaks the journey-$lang-NN scheme',
      );
    }
    if (puzzle.journeyLevelNumber != entry.n) {
      violations.add(
        '$where: journeyLevelNumber ${puzzle.journeyLevelNumber} != ${entry.n}',
      );
    }
    if (puzzle.optimalMoves < 1) {
      violations.add('$where: optimalMoves < 1 (not solver-verified)');
    }
  }

  return JourneyGateReport(violations, shortfall);
}
