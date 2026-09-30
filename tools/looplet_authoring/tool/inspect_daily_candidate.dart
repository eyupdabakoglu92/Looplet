// Read-only diagnostic for a deterministic generator candidate. This never
// exports content or grants acceptance; use audit-daily for quality evidence.
import 'dart:convert';
import 'dart:io';

import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/daily_generator.dart';
import 'package:looplet_authoring/src/move_shorthand.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:looplet_authoring/src/quality_search.dart';
import 'package:looplet_core/looplet_core.dart';

void main(List<String> args) {
  if (args.length < 4) {
    stderr.writeln(
        'usage: inspect_daily_candidate.dart <corpus.json> <target> <YYYY-MM-DD> <seed> [prefix]');
    exit(64);
  }
  final words = CorpusWords(readObject(args[0]));
  final candidate = buildCandidate(
      words, args[1], DateTime.parse(args[2]), int.parse(args[3]),
      thawPrefix: args.length > 4 && args[4] == 'prefix');
  final config = candidate.$1.toEngineConfig();
  final states = replay(config, words, candidate.$2);
  final target = TurkishCase.toLowerTr(config.targetWord);
  stdout.writeln(const JsonEncoder.withIndent('  ').convert({
    'definition': defJson(candidate.$1),
    'reference': formatMoves(candidate.$2),
    'forwardReplay': states != null,
    'constructionFiller': candidate.$3,
    'states': states
        ?.map((s) => {
              'grid': s.letters.map((r) => r.join()).toList(),
              'maxCorrect': maxCorrect(config, s),
              'rowCorrect': s.letters
                  .map((r) => [
                        for (var c = 0; c < target.length; c++)
                          TurkishCase.toLowerTr(r[c]) == target[c] ? 1 : 0
                      ].reduce((a, b) => a + b))
                  .toList(),
              'thawed': s.thawedCells.map((c) => '${c.row},${c.col}').toList(),
              'solved': s.isSolved
            })
        .toList(),
  }));
}
