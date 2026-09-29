// F08-QA-FUNCTIONAL-R2 independent probe (QA-owned, not part of the suite).
// AC2 "all levels load": opens every Journey level 1–30 through the production
// level-open path — `playSessionSetupProvider` (real `rootBundle` journey assets,
// real dictionary validator, in-memory store for the language lookup) — and
// builds the engine the Play screen builds (`GridEngine(toEngineConfig(...))`).
// No network is involved on this path (see qa.md § F08-QA-FUNCTIONAL-R2).
// Copied into app/test/ only for the run and removed afterwards.
// Control: QA_BREAK_LEVEL=<n> makes that level's asset unreadable (the probe must FAIL).
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/content/puzzle_engine_config.dart';
import 'package:looplet_app/journey/journey_content.dart';
import 'package:looplet_app/persistence/persistence_providers.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_session_providers.dart';
import 'package:looplet_engine/looplet_engine.dart';

import 'support/widget_test_database.dart';

class _BreakingSource implements JourneyAssetSource {
  _BreakingSource(this.level);
  final int level;
  static const _real = RootBundleJourneyAssetSource();
  @override
  Future<String> readString(String assetKey) {
    if (assetKey.endsWith('${journeyLevelId(level, 'tr')}.json')) {
      throw StateError('QA control: asset of level $level made unreadable');
    }
    return _real.readString(assetKey);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('QA R2 — every Journey level 1–30 opens through the production path', () async {
    final db = widgetTestDatabase();
    final container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        if (Platform.environment['QA_BREAK_LEVEL'] case final b?)
          journeyAssetSourceProvider.overrideWithValue(_BreakingSource(int.parse(b))),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final manifest = await container.read(journeyManifestProvider('tr').future);
    expect(manifest.isStrict, isTrue);
    expect(manifest.levels.length, journeyLevelCount);

    final opened = <String>[];
    for (var n = 1; n <= journeyLevelCount; n++) {
      final setup = await container.read(
        playSessionSetupProvider(
          PlaySessionArgs(source: PuzzleSource.journey, journeyLevel: n),
        ).future,
      );
      expect(setup.puzzle.id, journeyLevelId(n, 'tr'), reason: 'level $n');
      final engine = GridEngine(
        toEngineConfig(setup.puzzle),
        validator: setup.validator,
      );
      expect(engine.isSolved, isFalse, reason: 'level $n starts unsolved');
      opened.add(setup.puzzle.id);
    }
    // ignore: avoid_print
    print('QA R2 opened ${opened.length} levels: ${opened.first} … ${opened.last}');
    expect(opened.toSet().length, journeyLevelCount);
  });
}
