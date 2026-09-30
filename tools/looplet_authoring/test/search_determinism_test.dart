import 'dart:io';

import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/daily_quality.dart';
import 'package:looplet_authoring/src/quality_cli.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:looplet_authoring/src/quality_search.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// F07 A7 (F07-TOOL-DAILY-R1): verdicts are decided by the inputs, pruning never
// changes a witness or an absence claim, and reports are portable.

void main() {
  final corpus = CorpusWords(importCorpus('data/tr'));
  const fixture = 'test/fixtures/quality';
  final small = CorpusWords({
    'words': ['ab', 'abcd', 'baba', 'ıslak'],
    'targets': ['ab']
  });

  EngineConfig def(String name) =>
      PuzzleDef.fromFile('$fixture/$name').toEngineConfig();
  EngineConfig grid(List<String> rows, String target,
          {Set<GridCoord> frozen = const {}}) =>
      EngineConfig(
          initialGrid: rows.map((r) => r.split('')).toList(),
          targetWord: target,
          frozenCells: frozen);

  // Every search mode audit-daily uses, on real 5×5 fixtures and small
  // thaw fixtures: (label, words, config, depth, mode).
  final cases = <(String, CorpusWords, EngineConfig, int, String)>[
    for (final name in ['locked-def.json', 'regression-def.json']) ...[
      (name, corpus, def(name), 4, 'plain'),
      (name, corpus, def(name), 4, 'nondecreasing'),
      (name, corpus, def(name), 3, 'plain'), // absence below the optimum
    ],
    ('locked-def.json ablated', corpus, def('locked-def.json'), 4, 'common'),
    (
      'thaw',
      small,
      grid(['baab', 'bbba', 'cccc', 'dddd'], 'abab',
          frozen: {const GridCoord(1, 0)}),
      4,
      'thaw'
    ),
    (
      'useful',
      small,
      grid(['baab', 'bbba', 'cccc', 'dddd'], 'abab',
          frozen: {const GridCoord(1, 0)}),
      4,
      'useful'
    ),
    (
      'win-move thaw',
      small,
      grid(['bacd', 'eeee', 'ffff', 'gggg'], 'abcd',
          frozen: {const GridCoord(0, 2), const GridCoord(0, 3)}),
      3,
      'useful'
    ),
  ];

  WitnessSearch run((String, CorpusWords, EngineConfig, int, String) c,
      MoveLowerBound Function(EngineConfig)? bound) {
    final (_, words, config, depth, mode) = c;
    final ablated = EngineConfig(
        initialGrid: config.initialGrid,
        targetWord: config.targetWord,
        frozenCells: config.frozenCells,
        columnMovesEnabled: config.columnMovesEnabled);
    return searchWitness(config, words,
        maxDepth: depth,
        nondecreasingOnly: mode == 'nondecreasing',
        thawRowBeforeWin: mode == 'thaw' ? 1 : null,
        requireUsefulThaw: mode == 'useful',
        commonWith: mode == 'common' ? ablated : null,
        lowerBound: bound);
  }

  List<String> mismatches(MoveLowerBound Function(EngineConfig) bound) => [
        for (final c in cases)
          if (run(c, bound).status != run(c, (_) => noLowerBound).status ||
              formatMovesOf(run(c, bound)) !=
                  formatMovesOf(run(c, (_) => noLowerBound)))
            '${c.$1}/${c.$5}/${c.$4}'
      ];

  test('pruned witness search equals the exhaustive one in every audit mode',
      () {
    final statuses = {for (final c in cases) run(c, null).status};
    expect(statuses, containsAll(['FOUND', 'ABSENT_WITHIN_DEPTH']));
    expect(mismatches((c) => WinLowerBound(c).call), isEmpty);
  });

  test('negative: an inadmissible bound changes a witness and is caught', () {
    MoveLowerBound inflated(EngineConfig c) {
      final base = WinLowerBound(c);
      return (s) => s.isSolved ? 0 : base(s) + 1;
    }

    expect(mismatches(inflated), isNotEmpty);
  });

  test('UNKNOWN records its stop cause, nodes and elapsed time', () {
    final found = searchWitness(def('locked-def.json'), corpus,
        maxDepth: 4, budget: const SearchBudget(maxNodes: 1));
    expect(found.status, 'UNKNOWN');
    expect(found.stop!.toJson(),
        allOf(containsPair('cause', 'nodes'), contains('elapsedMs')));
    final day = auditDay(PuzzleDef.fromFile('$fixture/locked-def.json'), corpus,
        banned: {},
        journeyTargets: {},
        proof: readObject('$fixture/locked-proof.json'),
        budget: const SearchBudget(maxNodes: 1));
    expect(jsonValue(day, 'rules.Q2.status'), 'UNKNOWN');
    expect(jsonValue(day, 'rules.Q2.evidence.stop.cause'), 'nodes');
  });

  test('per-analysis stats are reported without changing verdicts', () {
    final stats = SearchStats();
    final day = auditDay(PuzzleDef.fromFile('$fixture/locked-def.json'), corpus,
        banned: {},
        journeyTargets: {},
        proof: readObject('$fixture/locked-proof.json'),
        stats: stats);
    final plain = auditDay(
        PuzzleDef.fromFile('$fixture/locked-def.json'), corpus,
        banned: {},
        journeyTargets: {},
        proof: readObject('$fixture/locked-proof.json'));
    expect(
        stats.toJson().map((e) => e['phase']),
        containsAll([
          'solve',
          'difficulty state tree',
          'Q5 locked ablated',
        ]));
    Map<String, Object?> statuses(Map<String, dynamic> report) => {
          for (final key in jsonMap(report['rules']).keys)
            key: jsonValue(report, 'rules.$key.status')
        };
    expect(statuses(day), statuses(plain));
  });

  group('time ceiling', () {
    test('seconds must be 1..300', () {
      expect(analysisSeconds('300'), 300);
      expect(() => analysisSeconds('0'), throwsArgumentError);
      expect(() => analysisSeconds('301'), throwsArgumentError);
    });

    test('the CLI refuses a ceiling above 300 s', () async {
      final err = StringBuffer();
      final code = await buildRunner(out: StringBuffer(), err: err).run([
        'audit-daily',
        'test/fixtures/quality',
        '--repo-root',
        '../..',
        '--seconds',
        '301',
        '--out',
        '${Directory.systemTemp.path}/looplet-r1-never.json',
      ]);
      expect(code, 1);
      expect(err.toString(), contains('1..300'));
    });
  });

  group('portable report source', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('looplet_r1'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('reports store a repo-relative, /-separated source', () {
      expect(
          repoRelative('../..', '../../content/daily/tr'), 'content/daily/tr');
      expect(resolveReportSource('../..', 'content/daily/tr'),
          p.normalize(p.join('../..', 'content/daily/tr')));
    });

    test('absolute, empty or unresolvable sources fail closed', () {
      for (final bad in [
        p.absolute('../../content/daily/tr'),
        '',
        null,
        'content/daily/does-not-exist'
      ]) {
        expect(() => resolveReportSource('../..', bad), throwsStateError,
            reason: '$bad');
      }
    });

    test('the batch gate rejects a pilot report with an absolute source',
        () async {
      final corpusPath = '${tmp.path}/corpus.json';
      writeObject(corpusPath, importCorpus('data/tr'));
      final report = '${tmp.path}/pilot.json';
      writeObject(report, {
        'scope': 'pilot',
        'result': 'PASS',
        'sourceDir': p.absolute('../../content/daily/tr'),
      });
      final acceptance = '${tmp.path}/acceptance.json';
      writeObject(acceptance, {'decision': 'accepted'});
      final err = StringBuffer();
      final code = await buildRunner(out: StringBuffer(), err: err).run([
        'generate-daily',
        '--repo-root',
        '../..',
        '--corpus',
        corpusPath,
        '--out',
        '${tmp.path}/batch',
        '--no-pilot',
        '--pilot-report',
        report,
        '--pilot-acceptance',
        acceptance,
      ]);
      expect(code, 1);
      expect(err.toString(), contains('repo-relative'));
      expect(Directory('${tmp.path}/batch').existsSync(), false);
    });
  });
}

String formatMovesOf(WitnessSearch s) => s.moves.map((m) => '$m').join(' ');
