import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looplet_content/looplet_content.dart';

/// The number of handcrafted Journey levels (`prd.md` / `architecture.md §4`).
const int journeyLevelCount = 30;

/// The durable id for Journey level [n] in [lang] — `journey-<lang>-<NN>`
/// (zero-padded). **This scheme is a hard contract** (`architecture.md §4`):
/// `Puzzle.id` is the key for F04's `personal_best` and F03/F08 snapshot
/// resume, so it must not drift across content re-exports.
String journeyLevelId(int n, String lang) =>
    'journey-$lang-${n.toString().padLeft(2, '0')}';

final RegExp _journeyIdPattern = RegExp(r'^journey-([a-z]{2})-(\d{2})$');

/// The level number encoded in a `journey-<lang>-<NN>` id, or `null` for any
/// other id (a debug/daily id, a malformed string).
int? parseJourneyLevel(String puzzleId) {
  final m = _journeyIdPattern.firstMatch(puzzleId);
  if (m == null) return null;
  final n = int.parse(m.group(2)!);
  return (n >= 1 && n <= journeyLevelCount) ? n : null;
}

/// Raised by [JourneyContentRepo] for a missing / malformed manifest or a
/// manifest entry that does not resolve. The `/play` screen renders F03's
/// load-error state and the rest of the Journey stays playable
/// (`architecture.md §5.3`, `prd.md §4`).
class JourneyContentException implements Exception {
  JourneyContentException(this.message);
  final String message;
  @override
  String toString() => 'JourneyContentException: $message';
}

/// One `levels[]` entry of a Journey manifest (`architecture.md §5.2`).
class JourneyManifestLevel {
  const JourneyManifestLevel({
    required this.n,
    required this.id,
    required this.asset,
    required this.difficultyLabel,
    this.checksum,
  });

  final int n;
  final String id;
  final String asset;
  final String difficultyLabel;
  final String? checksum;

  static JourneyManifestLevel fromJson(Map<String, Object?> json) {
    int reqInt(String k) {
      final v = json[k];
      if (v is! int) throw JourneyContentException('level.$k must be an int');
      return v;
    }

    String reqStr(String k) {
      final v = json[k];
      if (v is! String || v.isEmpty) {
        throw JourneyContentException('level.$k must be a non-empty string');
      }
      return v;
    }

    final checksum = json['checksum'];
    return JourneyManifestLevel(
      n: reqInt('n'),
      id: reqStr('id'),
      asset: reqStr('asset'),
      difficultyLabel: reqStr('difficultyLabel'),
      checksum: checksum is String && checksum.isNotEmpty ? checksum : null,
    );
  }
}

/// A per-language Journey manifest (`architecture.md §5.2`). `mode` is
/// `"smoke"` while `F06-CONTENT` is incomplete (the build gate only logs the
/// shortfall) and `"strict"` once the full 30 land (the gate fails CI).
class JourneyManifest {
  JourneyManifest({
    required this.schemaVersion,
    required this.contentVersion,
    required this.lang,
    required this.mode,
    required List<JourneyManifestLevel> levels,
  }) : levels = List<JourneyManifestLevel>.unmodifiable(levels);

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String contentVersion;
  final String lang;
  final String mode;
  final List<JourneyManifestLevel> levels;

  bool get isStrict => mode == 'strict';

  JourneyManifestLevel? levelFor(int n) {
    for (final l in levels) {
      if (l.n == n) return l;
    }
    return null;
  }

  bool hasLevel(int n) => levelFor(n) != null;

  static JourneyManifest fromJson(Map<String, Object?> json) {
    final sv = json['schemaVersion'];
    if (sv != currentSchemaVersion) {
      throw JourneyContentException('unsupported schemaVersion $sv');
    }
    final mode = json['mode'];
    if (mode != 'smoke' && mode != 'strict') {
      throw JourneyContentException('mode must be "smoke" or "strict"');
    }
    final rawLevels = json['levels'];
    if (rawLevels is! List || rawLevels.isEmpty) {
      throw JourneyContentException('levels must be a non-empty array');
    }
    final levels = <JourneyManifestLevel>[
      for (final e in rawLevels)
        if (e is Map<String, Object?>)
          JourneyManifestLevel.fromJson(e)
        else
          throw JourneyContentException('each level must be an object'),
    ];
    for (var i = 0; i < levels.length; i++) {
      if (levels[i].n != i + 1) {
        throw JourneyContentException(
          'levels must be contiguous from 1 — got n=${levels[i].n} at index $i',
        );
      }
    }
    return JourneyManifest(
      schemaVersion: sv! as int,
      contentVersion: (json['contentVersion'] as String?) ?? 'unknown',
      lang: (json['lang'] as String?) ?? 'tr',
      mode: mode! as String,
      levels: levels,
    );
  }
}

/// Reads Journey content from the asset bundle. Injectable for tests.
abstract class JourneyAssetSource {
  Future<String> readString(String assetKey);
}

/// [JourneyAssetSource] over the Flutter asset bundle. Assets are declared under
/// `flutter/assets: assets/journey/` in `app/pubspec.yaml`. (Interim: the
/// manifest + the 5 level artifacts are hand-maintained under
/// `app/assets/journey/tr/`; `F06-CONTENT` moves the source of truth to
/// `content/journey/<lang>/` + a `melos content:sync` mirror — `architecture.md
/// §5.1`.)
class RootBundleJourneyAssetSource implements JourneyAssetSource {
  const RootBundleJourneyAssetSource();
  @override
  Future<String> readString(String assetKey) =>
      rootBundle.loadString('assets/journey/$assetKey');
}

/// Resolves a Journey level number → its `Puzzle` (`architecture.md §5.3`).
/// Manifest + parsed levels are cached for the session.
class JourneyContentRepo {
  JourneyContentRepo(this._source);

  final JourneyAssetSource _source;
  final Map<String, JourneyManifest> _manifests = <String, JourneyManifest>{};
  final Map<String, Puzzle> _levels = <String, Puzzle>{};

  Future<JourneyManifest> loadManifest(String lang) async {
    final cached = _manifests[lang];
    if (cached != null) return cached;
    final String raw;
    try {
      raw = await _source.readString('$lang/journey_manifest_$lang.json');
    } catch (e) {
      throw JourneyContentException('manifest for "$lang" not found — $e');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw JourneyContentException('manifest must be a JSON object');
    }
    final manifest = JourneyManifest.fromJson(decoded);
    _manifests[lang] = manifest;
    return manifest;
  }

  Future<Puzzle> loadLevel(int n, String lang) async {
    final key = '$lang#$n';
    final cached = _levels[key];
    if (cached != null) return cached;

    final manifest = await loadManifest(lang);
    final entry = manifest.levelFor(n);
    if (entry == null) {
      throw JourneyContentException(
        'level $n not in the $lang manifest (${manifest.levels.length} levels, '
        'mode ${manifest.mode})',
      );
    }
    final String raw;
    try {
      raw = await _source.readString(entry.asset);
    } catch (e) {
      throw JourneyContentException('asset "${entry.asset}" not found — $e');
    }
    final Puzzle puzzle;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('not a JSON object');
      }
      puzzle = Puzzle.fromJson(decoded);
    } catch (e) {
      throw JourneyContentException('level $n asset failed to parse — $e');
    }
    if (puzzle.id != entry.id) {
      throw JourneyContentException(
        'level $n id mismatch: manifest "${entry.id}" vs asset "${puzzle.id}"',
      );
    }
    if (puzzle.id != journeyLevelId(n, lang)) {
      throw JourneyContentException(
        'level $n id "${puzzle.id}" does not match the journey-$lang-NN scheme',
      );
    }
    _levels[key] = puzzle;
    return puzzle;
  }
}

/// Where Journey content is read from. Overridden in tests.
final journeyAssetSourceProvider = Provider<JourneyAssetSource>(
  (ref) => const RootBundleJourneyAssetSource(),
);

final journeyContentRepoProvider = Provider<JourneyContentRepo>(
  (ref) => JourneyContentRepo(ref.watch(journeyAssetSourceProvider)),
);

/// The active-language Journey manifest, loaded once. Used by the home surface
/// (progress / `Next Level` reach) and the resolver.
final journeyManifestProvider = FutureProvider.family<JourneyManifest, String>(
  (ref, lang) => ref.watch(journeyContentRepoProvider).loadManifest(lang),
);
