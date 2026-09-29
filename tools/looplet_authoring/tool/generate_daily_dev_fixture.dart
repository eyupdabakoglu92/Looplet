// Writes the Daily dev source (a test fixture, not product content) for
// F07-FE delivery and tests: `<out>/daily/tr/daily_manifest_tr.json` + one
// `pool/` puzzle per day for anchor − 14 … anchor + 7.
//
// Committed fixture (anchor 2026-10-15), from tools/looplet_authoring:
//   dart run tool/generate_daily_dev_fixture.dart
// A variant shifted to another "today" (build output, not committed):
//   dart run tool/generate_daily_dev_fixture.dart \
//     --anchor "$(date +%F)" --out ../../build/daily/dev-source
//   dart run bin/looplet_authoring.dart pack-daily \
//     ../../build/daily/dev-source/daily/tr --repo-root ../..
import 'dart:io';

import 'package:args/args.dart';
import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:looplet_content/looplet_content.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('anchor', help: '"today" (YYYY-MM-DD); default 2026-10-15')
    ..addOption('epoch', help: 'numberingEpoch; default anchor − 14 (#1)')
    ..addOption('out', defaultsTo: 'test/fixtures/daily_dev')
    ..addOption('repo-root', defaultsTo: '../..');
  final options = parser.parse(args);

  CalendarDate? date(String name) {
    final raw = options[name] as String?;
    if (raw == null) return null;
    final parsed = CalendarDate.tryParse(raw);
    if (parsed == null) {
      stderr.writeln('--$name must be a YYYY-MM-DD date, got "$raw"');
      exit(64);
    }
    return parsed;
  }

  final manifest = writeDailyDevFixture(
    outDir: options['out'] as String,
    repoRoot: options['repo-root'] as String,
    anchor: date('anchor'),
    epoch: date('epoch'),
  );
  stdout.writeln('wrote $manifest');
}
