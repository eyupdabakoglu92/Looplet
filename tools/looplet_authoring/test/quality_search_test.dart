import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/daily_quality.dart';
import 'package:looplet_authoring/src/daily_pool_quality.dart';
import 'package:looplet_authoring/src/quality_search.dart';
import 'package:looplet_authoring/src/puzzle_def.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:looplet_authoring/src/move_shorthand.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

void main() {
  final words = CorpusWords({
    'words': ['ab', 'abcd', 'baba', 'ıslak'],
    'targets': ['ab']
  });
  final easy = EngineConfig(initialGrid: [
    ['b', 'a'],
    ['c', 'd']
  ], targetWord: 'ab');
  test('finite absence and UNKNOWN are different results', () {
    expect(
        searchWitness(easy, words, maxDepth: 0).status, 'ABSENT_WITHIN_DEPTH');
    expect(
        searchWitness(easy, words,
                maxDepth: 1, budget: const SearchBudget(maxNodes: 1))
            .status,
        'UNKNOWN');
  });
  test('forward witness is a real applied winning path', () {
    final found = searchWitness(easy, words, maxDepth: 1);
    expect(found.status, 'FOUND');
    expect(found.moves, hasLength(1));
    expect(replay(easy, words, found.moves)!.last.isSolved, true);
  });
  test('replay rejects post-win moves and out-of-range moves', () {
    expect(replay(easy, words, [const Move.rowLeft(0), const Move.rowLeft(1)]),
        isNull);
    expect(replay(easy, words, [const Move.rowLeft(7)]), isNull);
  });
  test('Q5 shared optimum disproves cosmetic-mechanic relevance', () {
    final cosmetic = EngineConfig(
        initialGrid: easy.initialGrid,
        targetWord: easy.targetWord,
        lockedCells: {const GridCoord(1, 0)});
    final common =
        searchWitness(cosmetic, words, maxDepth: 1, commonWith: easy);
    expect(common.status, 'FOUND');
    expect(replay(cosmetic, words, common.moves)!.last.isSolved, true);
    expect(replay(easy, words, common.moves)!.last.isSolved, true);
  });
  test('a real four-move fixture requires regression across ALL optimal paths',
      () {
    final corpus = CorpusWords(importCorpus('data/tr'));
    final config =
        PuzzleDef.fromFile('test/fixtures/quality/regression-def.json')
            .toEngineConfig();
    final proof = readObject('test/fixtures/quality/regression-proof.json');
    final optimal = Solver.solve(config, corpus) as Optimal;
    expect(optimal.moves, 4);
    expect(replay(config, corpus, parseMoves(proof['reference'] as String)),
        isNotNull);
    expect(
        searchWitness(config, corpus, maxDepth: 4, nondecreasingOnly: true)
            .status,
        'ABSENT_WITHIN_DEPTH');
    expect(
        searchWitness(config, corpus,
                maxDepth: 4,
                nondecreasingOnly: true,
                budget: const SearchBudget(maxNodes: 1))
            .status,
        'UNKNOWN');
  });
  test('nondecreasing witness refutes temporary regression', () {
    expect(
        searchWitness(easy, words, maxDepth: 1, nondecreasingOnly: true).status,
        'FOUND');
  });
  test('Q6 winning-move-only thaw does not count as prior thaw', () {
    final c = EngineConfig(
        initialGrid:
            ['bacd', 'eeee', 'ffff', 'gggg'].map((r) => r.split('')).toList(),
        targetWord: 'abcd',
        frozenCells: {const GridCoord(0, 2), const GridCoord(0, 3)});
    final played = replay(c, words, [const Move.rowLeft(0)])!;
    expect(played.last.thawedCells, hasLength(2));
    expect(searchWitness(c, words, maxDepth: 1, thawRowBeforeWin: 0).status,
        'ABSENT_WITHIN_DEPTH');
    expect(searchWitness(c, words, maxDepth: 1, requireUsefulThaw: true).status,
        'ABSENT_WITHIN_DEPTH');
  });
  test('Q6/Q7 useful thaw requires a later move of the thawed cell', () {
    // Row 1 forms baba after column 1 down; row 1 can then rotate all cells.
    final c = EngineConfig(
        initialGrid:
            ['baab', 'bbba', 'cccc', 'dddd'].map((r) => r.split('')).toList(),
        targetWord: 'abab',
        frozenCells: {const GridCoord(1, 0)});
    final played =
        replay(c, words, [const Move.columnDown(1), const Move.rowLeft(1)]);
    expect(played, isNotNull);
    expect(played![1].isSolved, false);
    expect(played[1].thawedCells, contains(const GridCoord(1, 0)));
    expect(
        movedThawedLetter(played[1], played[2], const Move.rowLeft(1)), true);
    expect(searchWitness(c, words, maxDepth: 2, thawRowBeforeWin: 1).status,
        'FOUND');
  });
  test('Q11 scans Turkish I correctly, both axes and directions', () {
    final c = EngineConfig(
        initialGrid: ['ISLAK', 'ABCDE', 'ABCDE', 'ABCDE', 'ABCDE']
            .map((r) => r.split(''))
            .toList(),
        targetWord: 'XXXXX');
    expect(bannedWindows(GridState.initial(c, words), {'ıslak'}), ['ıslak']);
    expect(bannedWindows(GridState.initial(c, words), {'islak'}), isEmpty);
    final reverse = EngineConfig(
        initialGrid: ['KALSI', 'ABCDE', 'ABCDE', 'ABCDE', 'ABCDE']
            .map((r) => r.split(''))
            .toList(),
        targetWord: 'XXXXX');
    expect(
        bannedWindows(GridState.initial(reverse, words), {'ıslak'}), ['ıslak']);
  });
  test('Q12 ignores target/name but respects masks and actual reachability',
      () {
    final b = EngineConfig(initialGrid: [
      ['b', 'd'],
      ['c', 'a']
    ], targetWord: 'ac');
    expect(nearDuplicate(easy, b, words), true);
    final mask = EngineConfig(
        initialGrid: b.initialGrid,
        targetWord: b.targetWord,
        lockedCells: {const GridCoord(0, 0)});
    expect(nearDuplicate(easy, mask, words), false);
  });
  test('Q10 four-letter windows count within five-cell filler', () {
    expect(rowWords('xabcd'.split(''), words), ['abcd']);
    expect(rowWords('çlşüi'.split(''), words), isEmpty);
  });
}
