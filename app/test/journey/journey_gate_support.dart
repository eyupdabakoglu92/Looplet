// Shared support for the F05 content-manifest build gate (`architecture.md
// §5.4`). One implementation, exercised by BOTH `journey_manifest_gate_test.dart`
// (against the REAL bundled `assets/journey/` pack) and
// `journey_manifest_strict_test.dart` (against synthetic smoke / strict
// manifests). Not a test suite itself — no `_test` suffix.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_content/looplet_content.dart';

/// Result of one gate run. `passed` ⇔ no violations. `shortfall` is
/// `journeyLevelCount - levels.length` clamped `>= 0` (informational in `smoke`
/// mode, a violation in `strict` mode).
class JourneyGateReport {
  JourneyGateReport(
    this.violations,
    this.shortfall, {
    this.advisories = const <String>[],
    this.bandChecks = 0,
  });

  final List<String> violations;
  final int shortfall;

  /// Band-rule findings in `mode:"smoke"` — logged, never failing (§5.4).
  final List<String> advisories;

  /// How many (level, band-rule) checks actually ran. A non-vacuity witness:
  /// a gate that silently skips its band rules reports 0 here.
  final int bandChecks;

  bool get passed => violations.isEmpty;

  @override
  String toString() =>
      'JourneyGateReport(passed: $passed, shortfall: $shortfall, '
      'bandChecks: $bandChecks, violations: $violations, '
      'advisories: $advisories)';
}

/// The `difficultyLabel`s allowed for Journey level [n] (`architecture.md §5.4`
/// R6 — the same bands as `content_check.dart`'s `_expectedBands`). Empty for a
/// level number outside 1..[journeyLevelCount] — no band is defined there.
Set<DifficultyLabel> journeyLabelBand(int n) {
  if (n < 1 || n > journeyLevelCount) return const <DifficultyLabel>{};
  if (n <= 6) return const {DifficultyLabel.easy, DifficultyLabel.medium};
  if (n <= 15) {
    return const {
      DifficultyLabel.easy,
      DifficultyLabel.medium,
      DifficultyLabel.hard,
    };
  }
  if (n <= 25) {
    return const {
      DifficultyLabel.medium,
      DifficultyLabel.hard,
      DifficultyLabel.expert,
    };
  }
  return const {DifficultyLabel.hard, DifficultyLabel.expert};
}

/// Evaluates the §5.4 band rules for manifest [entry] against its parsed
/// [puzzle], appending one named finding per broken rule to [findings]. Returns
/// how many rules applied to this level.
///
/// * R1 — levels 1–3: `columnMovesEnabled == false`.
/// * R2 — levels 4–10: `columnMovesEnabled == true`.
/// * R3 — levels 16–20: `lockedCells` non-empty.
/// * R4 — levels 21–25: `frozenCells` non-empty.
/// * R5 — levels 26–30: both `lockedCells` and `frozenCells` non-empty.
/// * R6 — every level: `difficultyLabel` inside [journeyLabelBand].
/// * LABEL — every level: the manifest entry's `difficultyLabel` equals the
///   asset's.
int _evaluateBandRules(
  JourneyManifestLevel entry,
  Puzzle puzzle,
  List<String> findings,
) {
  final n = entry.n;
  var checks = 0;
  void rule(String id, {required bool holds, required String message}) {
    checks++;
    if (!holds) findings.add('level $n: $id $message');
  }

  if (n >= 1 && n <= 3) {
    rule(
      'R1',
      holds: !puzzle.columnMovesEnabled,
      message: 'columnMovesEnabled must be false for levels 1–3',
    );
  }
  if (n >= 4 && n <= 10) {
    rule(
      'R2',
      holds: puzzle.columnMovesEnabled,
      message: 'columnMovesEnabled must be true for levels 4–10',
    );
  }
  if (n >= 16 && n <= 20) {
    rule(
      'R3',
      holds: puzzle.lockedCells.isNotEmpty,
      message: 'lockedCells must be non-empty for levels 16–20',
    );
  }
  if (n >= 21 && n <= 25) {
    rule(
      'R4',
      holds: puzzle.frozenCells.isNotEmpty,
      message: 'frozenCells must be non-empty for levels 21–25',
    );
  }
  if (n >= 26 && n <= 30) {
    rule(
      'R5',
      holds: puzzle.lockedCells.isNotEmpty && puzzle.frozenCells.isNotEmpty,
      message:
          'levels 26–30 need both lockedCells and frozenCells (locked '
          '${puzzle.lockedCells.length}, frozen ${puzzle.frozenCells.length})',
    );
  }
  final band = journeyLabelBand(n);
  rule(
    'R6',
    holds: band.contains(puzzle.difficultyLabel),
    message:
        'difficultyLabel "${puzzle.difficultyLabel.name}" not in '
        '{${band.map((l) => l.name).join(', ')}}',
  );
  rule(
    'LABEL',
    holds: entry.difficultyLabel == puzzle.difficultyLabel.name,
    message:
        'manifest difficultyLabel "${entry.difficultyLabel}" != asset '
        '"${puzzle.difficultyLabel.name}"',
  );
  return checks;
}

/// Runs the gate over a parsed [manifest] + an [readAsset] callback that returns
/// the raw JSON bytes for a `levels[].asset` key.
///
/// Always checked: contiguous `n` from 1; every `asset` resolves + parses as a
/// `Puzzle`; `puzzle.id == entry.id == journeyLevelId(n, lang)`;
/// `journeyLevelNumber == n`; `optimalMoves >= 1`; declared `checksum` matches
/// the asset's sha256. `mode == "strict"` additionally requires exactly
/// [journeyLevelCount] levels, and every §5.4 band rule (R1–R6 + LABEL, see
/// [_evaluateBandRules]) is a hard violation; in `mode == "smoke"` band findings
/// are only reported as [JourneyGateReport.advisories].
Future<JourneyGateReport> runJourneyManifestGate(
  JourneyManifest manifest, {
  required Future<String> Function(String assetKey) readAsset,
  String lang = 'tr',
}) async {
  final violations = <String>[];
  final advisories = <String>[];
  var bandChecks = 0;
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

    final findings = <String>[];
    bandChecks += _evaluateBandRules(entry, puzzle, findings);
    (manifest.isStrict ? violations : advisories).addAll(findings);
  }

  return JourneyGateReport(
    violations,
    shortfall,
    advisories: advisories,
    bandChecks: bandChecks,
  );
}

/// Byte-for-byte comparison of the authored Journey tree [source]
/// (`content/journey/`) with the shipped bundle [bundle] (`app/assets/journey/`)
/// — `architecture.md §5.4` "shipped bundle == verified source", so
/// `content:check`'s solver re-verification (which runs on `content/`) covers
/// what actually ships. Returns the differences, one line per relative path
/// (empty = identical). Dotfiles (`.DS_Store` & co.) are ignored.
List<String> compareJourneyMirror({
  required Directory source,
  required Directory bundle,
}) {
  if (!source.existsSync()) return <String>['${source.path} does not exist'];
  if (!bundle.existsSync()) return <String>['${bundle.path} does not exist'];

  Map<String, File> index(Directory root) {
    final prefix = root.path.endsWith(Platform.pathSeparator)
        ? root.path
        : '${root.path}${Platform.pathSeparator}';
    return <String, File>{
      for (final e in root.listSync(recursive: true))
        if (e is File && !e.uri.pathSegments.last.startsWith('.'))
          e.path.substring(prefix.length).replaceAll(r'\', '/'): e,
    };
  }

  bool sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  final src = index(source);
  final dst = index(bundle);
  final diffs = <String>[];
  for (final path in (<String>{...src.keys, ...dst.keys}.toList()..sort())) {
    final a = src[path];
    final b = dst[path];
    if (b == null) {
      diffs.add('$path: missing from the bundle');
    } else if (a == null) {
      diffs.add('$path: in the bundle but not in the authored source');
    } else if (!sameBytes(a.readAsBytesSync(), b.readAsBytesSync())) {
      diffs.add('$path: bytes differ');
    }
  }
  return diffs;
}
