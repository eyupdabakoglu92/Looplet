import 'dart:convert';
import 'dart:io';

import 'package:looplet_content/looplet_content.dart';

/// What [buildDailyPack] read from a Daily source: the pack when every rule
/// holds, and every failure otherwise.
final class DailySourceResult {
  const DailySourceResult({this.pack, required this.failures});

  /// The served pack; `null` when [failures] is not empty.
  final DailyPack? pack;

  /// `[rule] …` lines. The rule is a [DailyPackRule] name, or `manifest` for a
  /// problem that exists only in the source (the manifest's shape and place,
  /// a pool reference that resolves to nothing).
  final List<String> failures;
}

final RegExp _isoDateKey = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final RegExp _manifestName = RegExp(r'^daily_manifest_([a-z]{2})\.json$');

/// Builds the served Daily pack (F07 `architecture.md` D2) from the source at
/// [manifestPath] — `daily/<lang>/daily_manifest_<lang>.json` — and the pool
/// beside it (`daily/<lang>/pool/`), then checks it against every D2 (2) rule
/// with [DailyPack.validate].
///
/// The manifest:
///
/// ```json
/// {
///   "schemaVersion": 1,
///   "lang": "tr",
///   "contentVersion": "2026-10-01.1",
///   "numberingEpoch": "2026-10-01",
///   "assignments": { "2026-10-01": "daily-tr-2026-10-01" }
/// }
/// ```
///
/// Each assignment names a pool puzzle by its `id`, or by its file under
/// `pool/` (a value ending in `.json`). The pool puzzle is served as it is:
/// it must already be the day's puzzle (`type` daily, `dailyDate` the day,
/// `id` `daily-{lang}-{date}`). Days are emitted sorted by date and numbered
/// from `numberingEpoch`, so the same source always gives the same pack.
DailySourceResult buildDailyPack(
  String manifestPath, {
  int noRepeatWindowDays = DailyPack.defaultNoRepeatWindowDays,
}) {
  final failures = <String>[];
  DailySourceResult failed() => DailySourceResult(failures: failures);
  void manifestFail(String message) => failures.add('[manifest] $message');

  final manifestFile = File(manifestPath);
  if (!manifestFile.existsSync()) {
    manifestFail('no such file: $manifestPath');
    return failed();
  }

  // JSON objects keep the last of two equal keys, so a date assigned twice
  // is counted while decoding. Date-shaped keys occur only in `assignments`.
  final dateKeysSeen = <String, int>{};
  final Object? decoded;
  try {
    decoded = JsonDecoder((key, value) {
      if (key is String && _isoDateKey.hasMatch(key)) {
        dateKeysSeen[key] = (dateKeysSeen[key] ?? 0) + 1;
      }
      return value;
    }).convert(manifestFile.readAsStringSync());
  } on FormatException catch (e) {
    manifestFail('not valid JSON (${e.message})');
    return failed();
  }
  if (decoded is! Map) {
    manifestFail('the root is not a JSON object');
    return failed();
  }
  final manifest = decoded.cast<String, Object?>();

  // Shape.
  if (manifest['schemaVersion'] != 1) {
    manifestFail('"schemaVersion" must be 1');
  }
  final rawLang = manifest['lang'];
  final lang = rawLang is String && Puzzle.supportedLanguages.contains(rawLang)
      ? rawLang
      : null;
  if (lang == null) {
    manifestFail(
        '"lang" must be one of ${Puzzle.supportedLanguages}, got $rawLang');
  }
  final contentVersion = manifest['contentVersion'];
  if (contentVersion is! String || contentVersion.isEmpty) {
    manifestFail('"contentVersion" must be a non-empty string');
  }
  final rawEpoch = manifest['numberingEpoch'];
  final epoch = CalendarDate.tryParse(rawEpoch is String ? rawEpoch : null);
  if (epoch == null) {
    manifestFail('"numberingEpoch" must be a YYYY-MM-DD date, got $rawEpoch');
  }

  // Place: daily/<lang>/daily_manifest_<lang>.json, the pool beside it.
  final fileName = manifestFile.uri.pathSegments.last;
  final nameLang = _manifestName.firstMatch(fileName)?.group(1);
  final dirName = manifestFile.parent.uri.pathSegments
      .lastWhere((s) => s.isNotEmpty, orElse: () => '');
  if (lang != null && (nameLang != lang || dirName != lang)) {
    manifestFail('must be <lang>/daily_manifest_<lang>.json with <lang> = '
        '"$lang", got $dirName/$fileName');
  }

  final rawAssignments = manifest['assignments'];
  final assignments = <CalendarDate, String>{};
  if (rawAssignments is! Map || rawAssignments.isEmpty) {
    manifestFail('"assignments" must be a non-empty object');
  } else {
    for (final entry in rawAssignments.entries) {
      final date = CalendarDate.tryParse('${entry.key}');
      final ref = entry.value;
      if (date == null) {
        manifestFail('assignment key "${entry.key}" is not a YYYY-MM-DD date');
      } else if (ref is! String || ref.isEmpty) {
        manifestFail('${entry.key}: the assignment must name a pool puzzle');
      } else {
        assignments[date] = ref;
      }
    }
  }
  dateKeysSeen.forEach((key, count) {
    if (count > 1) {
      failures.add('[${DailyPackRule.datesUnique.name}] $key: assigned '
          '$count times');
    }
  });
  if (failures.isNotEmpty || lang == null || epoch == null) return failed();

  // Pool.
  final poolDir = Directory('${manifestFile.parent.path}/pool');
  final poolByFile = <String, Puzzle>{}; // path under pool/ -> puzzle
  final brokenFiles = <String, String>{}; // path under pool/ -> why
  if (poolDir.existsSync()) {
    final files = poolDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final rel = file.path
          .substring(poolDir.path.length + 1)
          .replaceAll(Platform.pathSeparator, '/');
      try {
        final json = jsonDecode(file.readAsStringSync());
        if (json is! Map) throw PuzzleFormatException('not a JSON object');
        poolByFile[rel] = Puzzle.fromJson(json.cast<String, Object?>());
      } on FormatException catch (e) {
        brokenFiles[rel] = 'not valid JSON (${e.message})';
      } on PuzzleFormatException catch (e) {
        brokenFiles[rel] = e.message;
      }
    }
  }
  final poolById = <String, Puzzle>{};
  final fileById = <String, String>{};
  poolByFile.forEach((rel, puzzle) {
    final other = fileById[puzzle.id];
    if (other != null) {
      manifestFail('pool id "${puzzle.id}" is in both pool/$other and '
          'pool/$rel');
    }
    poolById[puzzle.id] = puzzle;
    fileById[puzzle.id] = rel;
  });

  // Resolve every assignment, in date order.
  final dates = assignments.keys.toList()..sort();
  final resolved = <CalendarDate, Puzzle>{};
  final referencedBroken = <String>{};
  for (final date in dates) {
    final ref = assignments[date]!;
    final isFile = ref.endsWith('.json');
    // A broken file has no id; `<id>.json` is the pool's naming convention.
    final brokenRef = isFile ? ref : '$ref.json';
    if (brokenFiles.containsKey(brokenRef) && !poolById.containsKey(ref)) {
      failures.add('[${DailyPackRule.puzzleParses.name}] $date: '
          'pool/$brokenRef: ${brokenFiles[brokenRef]}');
      referencedBroken.add(brokenRef);
      continue;
    }
    final puzzle = isFile ? poolByFile[ref] : poolById[ref];
    if (puzzle == null) {
      manifestFail('$date: "$ref" matches no pool puzzle '
          '(${isFile ? 'no such file under pool/' : 'no pool puzzle has this '
              'id'})');
      continue;
    }
    resolved[date] = puzzle;
  }
  brokenFiles.forEach((rel, why) {
    if (!referencedBroken.contains(rel)) {
      failures.add('[${DailyPackRule.puzzleParses.name}] pool/$rel: $why');
    }
  });
  if (failures.isNotEmpty) return failed();

  // Assemble, then hold the pack to every D2 (2) rule.
  final packJson = <String, Object?>{
    'schemaVersion': DailyPack.currentSchemaVersion,
    'contentVersion': contentVersion,
    'lang': lang,
    'numberingEpoch': '$epoch',
    'days': <Map<String, Object?>>[
      for (final date in dates)
        DailyPackDay(
          dailyDate: '$date',
          dailyNumber: DailyPack.dailyNumberFor(epoch, date),
          puzzle: resolved[date]!,
        ).toJson(),
    ],
  };
  final violations =
      DailyPack.validate(packJson, noRepeatWindowDays: noRepeatWindowDays);
  if (violations.isNotEmpty) {
    failures.addAll(violations.map((v) => '$v'));
    return failed();
  }
  return DailySourceResult(
    pack: DailyPack.fromJson(packJson, noRepeatWindowDays: noRepeatWindowDays),
    failures: const <String>[],
  );
}

/// The served bytes of [pack]: two-space JSON and a final newline. The same
/// pack always gives the same bytes.
String encodeDailyPack(DailyPack pack) =>
    '${const JsonEncoder.withIndent('  ').convert(pack.toJson())}\n';
