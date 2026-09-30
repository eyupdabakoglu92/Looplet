import 'package:looplet_authoring/src/corpus_quality.dart';
import 'package:looplet_authoring/src/daily_quality.dart';
import 'package:looplet_authoring/src/puzzle_def.dart';
import 'package:looplet_authoring/src/quality_io.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_solver/looplet_solver.dart';
import 'package:test/test.dart';

void main() {
  final words = CorpusWords(importCorpus('data/tr'));
  const fixture = 'test/fixtures/quality';
  final baseline = readObject('$fixture/locked-def.json');
  final proof = readObject('$fixture/locked-proof.json');
  final export = readObject('$fixture/locked-export.json');
  Map<String, dynamic> audit(
          {Map<String, dynamic>? input,
          Map<String, dynamic>? witness,
          Set<String> banned = const {},
          Puzzle? exported,
          Map<String, dynamic>? definitionJson,
          Map<String, dynamic>? exportJson,
          SearchBudget budget = const SearchBudget()}) =>
      auditDay(PuzzleDef.fromJson(input ?? baseline), words,
          banned: banned,
          journeyTargets: {},
          proof: witness ?? proof,
          budget: budget,
          exported: exported,
          definitionJson: definitionJson,
          exportJson: exportJson,
          stopAtCheapFailure: true);
  test('real locked fixture passes applicable day rules and separate ablation',
      () {
    final result = audit(exported: Puzzle.fromJson(export));
    expect(result['accepted'], true);
    expect(jsonValue(result, 'rules.Q5.status'), 'PASS');
    expect(jsonValue(result, 'rules.Q6.status'), 'N/A');
    expect(jsonValue(result, 'rules.Q10.status'), 'PASS');
    expect(
        jsonValue(result, 'regression.status'), 'FAIL'); // no false aha claim
  });
  test('Q1 rejects invalid date/id, Journey target and target eligibility', () {
    expect(
        jsonValue(audit(input: {...baseline, 'id': 'daily-tr-wrong'}),
            'rules.Q1.status'),
        'FAIL');
    expect(
        jsonValue(audit(input: {...baseline, 'dailyDate': '2026-02-30'}),
            'rules.Q1.status'),
        'FAIL');
    final r = auditDay(PuzzleDef.fromJson(baseline), words,
        banned: {},
        journeyTargets: {'leğen'},
        proof: proof,
        stopAtCheapFailure: true);
    expect(jsonValue(r, 'rules.Q1.status'), 'FAIL');
  });
  test(
      'Q1 rejects noncanonical definition fields before they are lost in parsing',
      () {
    expect(
        jsonValue(audit(definitionJson: {...baseline, 'unknown': true}),
            'rules.Q1.status'),
        'FAIL');
  });
  test(
      'Q2 refuses malformed, rejected, nonoptimal and post-win reference paths',
      () {
    for (final sequence in [
      'INVALID',
      'R9',
      'R0',
      '${proof['reference']} R0'
    ]) {
      final result = audit(witness: {'reference': sequence});
      expect(jsonValue(result, 'rules.Q2.status'), 'FAIL', reason: sequence);
      expect(result['accepted'], false);
    }
  });
  test('Q2 missing reference and unknown unscanned sidecar paths fail closed',
      () {
    expect(jsonValue(audit(witness: {}), 'rules.Q2.status'), 'FAIL');
    expect(
        jsonValue(
            audit(witness: {...proof, 'extraPath': 'R0'}), 'rules.Q2.status'),
        'FAIL');
  });
  test('Q2 budget exhaustion is UNKNOWN and non-accepting', () {
    final result = audit(budget: const SearchBudget(maxNodes: 1));
    expect(jsonValue(result, 'rules.Q2.status'), 'UNKNOWN');
    expect(result['accepted'], false);
  });
  test('Q3 rejects a weekday-length solution moved to the heavy-day calendar',
      () {
    final result = audit(input: {
      ...baseline,
      'dailyDate': '2026-11-06',
      'id': 'daily-tr-2026-11-06'
    });
    expect(jsonValue(result, 'rules.Q3.status'), 'FAIL');
  });
  test('Q4 rejects stale metadata and definition/export mismatch', () {
    final result =
        audit(exported: Puzzle.fromJson({...export, 'difficultyScore': 999}));
    expect(jsonValue(result, 'rules.Q4.status'), 'FAIL');
    expect(result['accepted'], false);
    final unknown = {...export, 'unknown': true};
    expect(
        jsonValue(
            audit(exported: Puzzle.fromJson(unknown), exportJson: unknown),
            'rules.Q4.status'),
        'FAIL');
  });
  test('Q8 rejects initially solved / near-target start before search', () {
    final grid = List<String>.from(baseline['grid'] as List)..[0] = 'leğen';
    expect(
        jsonValue(audit(input: {...baseline, 'grid': grid}), 'rules.Q8.status'),
        'FAIL');
  });
  test('Q10 missing valid optimal final state cannot pass filler', () {
    expect(jsonValue(audit(witness: {'reference': 'R9'}), 'rules.Q10.status'),
        'FAIL');
  });
  test('Q11 rejects explicit list match in initial state', () {
    final row = (baseline['grid'] as List).first as String;
    expect(jsonValue(audit(banned: {row}), 'rules.Q11.status'), 'FAIL');
  });
}
