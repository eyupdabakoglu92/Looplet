import 'dart:io';

import 'package:test/test.dart';

/// The engine's determinism guarantee requires zero runtime nondeterminism.
/// This guard fails if `lib/` ever imports `dart:io`, uses `dart:math`'s
/// `Random`, or reads the wall clock.
void main() {
  test('looplet_engine/lib contains no Random / DateTime.now / dart:io', () {
    final libDir = Directory('lib');
    final offenders = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      // strip line comments so doc references don't trip the guard
      final code = source.split('\n').map((line) {
        final idx = line.indexOf('//');
        return idx >= 0 ? line.substring(0, idx) : line;
      }).join('\n');

      for (final pattern in <RegExp>[
        RegExp(r'''\bimport\s+['"]dart:io['"]'''),
        RegExp(r'\bRandom\s*\('),
        RegExp(r'\bDateTime\s*\.\s*now\b'),
        RegExp(r'\bStopwatch\s*\('),
        RegExp(r'\bIsolate\s*\.\s*spawn\b'),
      ]) {
        if (pattern.hasMatch(code)) {
          offenders.add('${entity.path}: matched ${pattern.pattern}');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
