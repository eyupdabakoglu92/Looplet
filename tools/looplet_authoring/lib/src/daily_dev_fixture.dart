import 'dart:convert';
import 'dart:io';

import 'package:looplet_content/looplet_content.dart';

/// The anchor ("today") of the committed dev fixture.
final CalendarDate dailyDevFixtureAnchor = CalendarDate(2026, 10, 15);

/// Days before and after the anchor the dev fixture covers (D3: eviction
/// keeps today − 14; prefetch fills today … today + 7).
const int dailyDevFixtureDaysBefore = 14;
const int dailyDevFixtureDaysAfter = 7;

/// Writes a Daily **dev** source — a test fixture, not product content — to
/// `<outDir>/daily/tr/`: `daily_manifest_tr.json` and one `pool/` puzzle per
/// day for [anchor] − 14 … [anchor] + 7 (22 days).
///
/// Each day is a `type: daily` copy of an existing smoke / Journey
/// definition from `<repoRoot>/content/` (smoke first, then Journey by
/// level), in a fixed order, so the output depends only on [anchor] and
/// [epoch]. [epoch] defaults to the first day (#1). Existing `pool/*.json`
/// files under the fixture directory are replaced.
///
/// Returns the manifest path.
String writeDailyDevFixture({
  required String outDir,
  required String repoRoot,
  CalendarDate? anchor,
  CalendarDate? epoch,
}) {
  final today = anchor ?? dailyDevFixtureAnchor;
  final first = today.addDays(-dailyDevFixtureDaysBefore);
  final numberingEpoch = epoch ?? first;
  const dayCount = dailyDevFixtureDaysBefore + dailyDevFixtureDaysAfter + 1;

  final sources = <Puzzle>[
    ..._puzzlesIn('$repoRoot/content/smoke/tr'),
    ..._puzzlesIn('$repoRoot/content/journey/tr')
      ..sort((a, b) => a.journeyLevelNumber!.compareTo(b.journeyLevelNumber!)),
  ];
  if (sources.length < dayCount) {
    throw StateError('the dev fixture needs $dayCount source puzzles, found '
        '${sources.length} under $repoRoot/content/');
  }

  final langDir = Directory('$outDir/daily/tr');
  final poolDir = Directory('${langDir.path}/pool')
    ..createSync(recursive: true);
  for (final old in poolDir.listSync().whereType<File>()) {
    if (old.path.endsWith('.json')) old.deleteSync();
  }

  const encoder = JsonEncoder.withIndent('  ');
  final assignments = <String, String>{};
  for (var i = 0; i < dayCount; i++) {
    final date = '${first.addDays(i)}';
    final source = sources[i];
    final daily = Puzzle(
      schemaVersion: source.schemaVersion,
      contentVersion: 'dev-fixture',
      id: DailyPack.dailyIdFor('tr', date),
      puzzleType: PuzzleType.daily,
      dailyDate: date,
      language: source.language,
      grid: source.grid,
      targetWord: source.targetWord,
      lockedCells: source.lockedCells,
      frozenCells: source.frozenCells,
      columnMovesEnabled: source.columnMovesEnabled,
      optimalMoves: source.optimalMoves,
      difficultyScore: source.difficultyScore,
      difficultyLabel: source.difficultyLabel,
      difficultyBreakdown: source.difficultyBreakdown,
    );
    File('${poolDir.path}/${daily.id}.json')
        .writeAsStringSync('${encoder.convert(daily.toJson())}\n');
    assignments[date] = daily.id;
  }

  final manifestPath = '${langDir.path}/daily_manifest_tr.json';
  File(manifestPath).writeAsStringSync('${encoder.convert(<String, Object?>{
        'schemaVersion': 1,
        'lang': 'tr',
        'contentVersion': 'dev-fixture-$today',
        'numberingEpoch': '$numberingEpoch',
        'assignments': assignments,
      })}\n');
  return manifestPath;
}

List<Puzzle> _puzzlesIn(String dir) {
  final files = Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.contains('manifest'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return <Puzzle>[
    for (final file in files)
      Puzzle.fromJson(
          (jsonDecode(file.readAsStringSync()) as Map).cast<String, Object?>()),
  ];
}
