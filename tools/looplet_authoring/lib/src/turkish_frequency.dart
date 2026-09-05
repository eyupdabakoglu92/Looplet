import 'dart:math';

import 'package:looplet_core/looplet_core.dart';

/// Approximate Turkish letter frequencies (percent), from published corpus
/// statistics (TDK / BOUN-corpus order of magnitude). Not exact — this is a
/// sampling *bias*, and the Level Designer hand-tunes the resulting grid.
/// No q / w / x (not in the Turkish alphabet).
const Map<String, double> turkishLetterFrequency = <String, double>{
  'a': 11.9,
  'e': 8.9,
  'i': 8.6,
  'n': 7.5,
  'r': 6.7,
  'l': 5.9,
  'ı': 5.1,
  'k': 4.7,
  'd': 4.7,
  'm': 3.7,
  't': 3.3,
  'u': 3.2,
  's': 3.0,
  'y': 3.4,
  'b': 2.8,
  'o': 2.5,
  'ü': 1.9,
  'ş': 1.8,
  'z': 1.5,
  'g': 1.1,
  'ç': 1.2,
  'h': 1.2,
  'ğ': 1.1,
  'v': 1.0,
  'c': 1.0,
  'p': 0.9,
  'ö': 0.8,
  'f': 0.4,
  'j': 0.03,
};

/// A seeded, reproducible weighted letter sampler. Emits Turkish-uppercase
/// letters. Deterministic for a given seed.
class SeededLetterSampler {
  SeededLetterSampler(int seed) : _random = Random(seed) {
    var running = 0.0;
    turkishLetterFrequency.forEach((letter, weight) {
      running += weight;
      _cumulative.add(running);
      _letters.add(letter);
    });
    _total = running;
  }

  final Random _random;
  final List<double> _cumulative = <double>[];
  final List<String> _letters = <String>[];
  late final double _total;

  /// One uppercase Turkish letter, sampled by frequency.
  String nextLetter() {
    final pick = _random.nextDouble() * _total;
    for (var i = 0; i < _cumulative.length; i++) {
      if (pick <= _cumulative[i]) return TurkishCase.toUpperTr(_letters[i]);
    }
    return TurkishCase.toUpperTr(_letters.last);
  }

  /// A `size`×`size` grid of row strings.
  List<String> grid(int size) => <String>[
        for (var r = 0; r < size; r++)
          <String>[for (var c = 0; c < size; c++) nextLetter()].join(),
      ];
}

/// True if any contiguous ≥4-letter run in a grid row is edit-distance ≤ 1 from
/// [target] (a "you almost see it!" board — feels unfair). Turkish-normalized.
bool hasNearTargetRun(List<String> grid, String target) {
  final t = TurkishCase.toLowerTr(target);
  for (final row in grid) {
    final normalized = TurkishCase.toLowerTr(row);
    for (var len = 4; len <= normalized.length; len++) {
      for (var start = 0; start + len <= normalized.length; start++) {
        final window = normalized.substring(start, start + len);
        if (_editDistanceAtMost1(window, t)) return true;
      }
    }
  }
  return false;
}

bool _editDistanceAtMost1(String a, String b) {
  if ((a.length - b.length).abs() > 1) return false;
  if (a == b) return true;
  // one substitution
  if (a.length == b.length) {
    var diffs = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i] && ++diffs > 1) return false;
    }
    return diffs == 1;
  }
  // one insertion / deletion
  final shorter = a.length < b.length ? a : b;
  final longer = a.length < b.length ? b : a;
  for (var skip = 0; skip < longer.length; skip++) {
    final candidate = longer.substring(0, skip) + longer.substring(skip + 1);
    if (candidate == shorter) return true;
  }
  return false;
}
