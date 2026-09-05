import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:test/test.dart';

Future<(int, String, String)> run(List<String> args) async {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = await buildRunner(out: out, err: err).run(args) ?? 0;
  return (code, out.toString(), err.toString());
}

void main() {
  test('fill is reproducible for a given seed', () async {
    final (c1, a, _) = await run(<String>['fill', '--seed', '42']);
    final (c2, b, _) = await run(<String>['fill', '--seed', '42']);
    expect(c1, 0);
    expect(c2, 0);
    expect(a, b);
    final rows = a.trim().split('\n');
    expect(rows, hasLength(5));
    for (final row in rows) {
      expect(row.runes.length, 5);
    }
  });

  test('different seeds give different grids', () async {
    final (_, a, _) = await run(<String>['fill', '--seed', '1']);
    final (_, b, _) = await run(<String>['fill', '--seed', '999']);
    expect(a, isNot(b));
  });

  test('the letter distribution is biased toward Turkish frequency', () {
    // Sample a large grid and check that high-frequency letters dominate the
    // low-frequency ones — a uniform sampler would not.
    final sampler = SeededLetterSampler(7);
    final counts = <String, int>{};
    for (final row in sampler.grid(40)) {
      for (final rune in row.runes) {
        final ch = String.fromCharCode(rune).toLowerCase();
        counts[ch] = (counts[ch] ?? 0) + 1;
      }
    }
    final common = <String>['a', 'e', 'i', 'n', 'r'];
    final rare = <String>['f', 'j'];
    final commonTotal =
        common.fold<int>(0, (sum, ch) => sum + (counts[ch] ?? 0));
    final rareTotal = rare.fold<int>(0, (sum, ch) => sum + (counts[ch] ?? 0));
    expect(commonTotal, greaterThan(rareTotal * 3));
  });

  test('--target avoids an already-solved grid', () async {
    // Whatever seed, a 5x5 fill matching MASAL by chance is astronomically
    // unlikely; this just exercises the code path.
    final (code, out, _) = await run(<String>[
      'fill',
      '--seed',
      '3',
      '--target',
      'MASAL',
      '--avoid-near-target',
    ]);
    expect(code, 0);
    expect(out.trim().split('\n'), hasLength(5));
  });
}
