import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

import 'support/helpers.dart';

final _validator = SetWordValidator(<String>['MASAL', 'KALEM', 'ADAM']);

EngineConfig scenario() => cfg(
      <String>['BCDFG', 'MHJKL', 'XASAL', 'PRTUV', 'YZBCD'],
      target: 'KALEM',
      frozen: <GridCoord>{const GridCoord(2, 2)},
      locked: <GridCoord>{const GridCoord(3, 1)},
    );

const _moves = <Move>[
  Move.rowRight(0),
  Move.columnDown(0), // thaws (2,2)
  Move.rowLeft(2),
  Move.columnUp(4),
  Move.rowRight(3),
];

GridState foldPure(EngineConfig config, List<Move> moves) {
  var state = GridState.initial(config, _validator);
  for (final move in moves) {
    final step = state.applyMove(move, config, _validator);
    expect(step.applied, isTrue, reason: '$move should apply');
    state = step.state;
  }
  return state;
}

void main() {
  test('two independent folds of the same (config, moves) are equal', () {
    final a = foldPure(scenario(), _moves);
    final b = foldPure(scenario(), _moves);
    expect(a, b);
    expect(a.canonicalKey(), b.canonicalKey());
    expect(a.hashCode, b.hashCode);
  });

  test('the façade and the pure fold agree', () {
    final engine = GridEngine(scenario(), validator: _validator);
    for (final move in _moves) {
      expect(engine.applyMove(move).applied, isTrue);
    }
    final pure = foldPure(scenario(), _moves);
    expect(engine.state, pure);
    expect(engine.state.canonicalKey(), pure.canonicalKey());
  });

  group('canonicalKey', () {
    test('equal for identical letters + thawed set; differs on any change', () {
      final base = foldPure(scenario(), _moves);
      final same = foldPure(scenario(), _moves);
      expect(base.canonicalKey(), same.canonicalKey());

      final oneLess =
          foldPure(scenario(), _moves.sublist(0, _moves.length - 1));
      expect(base.canonicalKey(), isNot(oneLess.canonicalKey()));
    });

    test('reflects a difference in the thawed set', () {
      // Same letters, different thawed set: reach the same grid with and
      // without the thaw-causing column move is hard to guarantee, so compare
      // the key structure directly.
      final thawed = foldPure(scenario(), const <Move>[Move.columnDown(0)]);
      expect(thawed.thawedCells, contains(const GridCoord(2, 2)));
      expect(thawed.canonicalKey(), contains('§2,2'));

      final notThawed = GridState.initial(scenario(), _validator);
      expect(notThawed.canonicalKey(), endsWith('§'));
    });

    test('uses Turkish-lower normalization (İ vs I distinct)', () {
      final withI = cfg(
        <String>['İIXXX', 'ABCDE', 'FGHIJ', 'KLMNO', 'PRTUV'],
        target: 'WWWWW',
      );
      final key = GridState.initial(withI, const NeverValidWordValidator())
          .canonicalKey();
      expect(key.startsWith('iı'), isTrue); // İ -> i, I -> ı
    });

    test('is stable across repeated calls on the same state', () {
      final state = foldPure(scenario(), _moves);
      expect(state.canonicalKey(), state.canonicalKey());
    });
  });

  test('no runtime randomness: same inputs, 50 folds, one result', () {
    final keys = <String>{
      for (var i = 0; i < 50; i++) foldPure(scenario(), _moves).canonicalKey(),
    };
    expect(keys, hasLength(1));
  });
}
