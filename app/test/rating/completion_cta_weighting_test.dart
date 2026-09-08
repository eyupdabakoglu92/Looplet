// F05 (`f05 architecture.md §16`, `ui-design.md §7.4`) — the per-outcome CTA
// weighting on F04's existing `CompletionPanel`: exactly one amber pill, and
// which action wears it depends on the star result.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/play/play_strings.dart';
import 'package:looplet_app/play/play_theme.dart';
import 'package:looplet_app/rating/completion_panel.dart';
import 'package:looplet_app/rating/completion_result.dart';
import 'package:looplet_app/rating/rating_strings.dart';

CompletionResult _result({required int stars, required bool isPerfect}) =>
    CompletionResult(
      levelId: 'journey-tr-04',
      source: PuzzleSource.journey,
      targetWord: 'MASAL',
      playerMoves: isPerfect ? 2 : 4,
      optimalMoves: 2,
      stars: stars,
      isPerfect: isPerfect,
      personalBestMoves: isPerfect ? 2 : 4,
      bestIsPerfect: isPerfect,
      bestOutcome: BestOutcome.firstClear,
      ratingPersisted: true,
    );

Future<void> _pump(
  WidgetTester tester, {
  required CompletionResult result,
  VoidCallback? onNextLevel,
}) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CompletionPanel(
          strings: PlayStrings.of('tr'),
          rating: RatingStrings.of('tr'),
          result: result,
          ratingUnavailable: false,
          bareWord: 'MASAL',
          bareMoves: result.playerMoves,
          onRetry: () {},
          onClose: () {},
          onNextLevel: onNextLevel,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The primary (amber) pill's label text uses `PlayTheme.inkAmber`.
String _primaryCtaLabel(WidgetTester tester) {
  for (final label in <String>['SONRAKİ', 'Yeniden']) {
    final t = tester.widget<Text>(find.text(label));
    if (t.style?.color == PlayTheme.inkAmber) return label;
  }
  return '(none)';
}

void main() {
  testWidgets('3★ / Perfect + Next wired → the amber pill is SONRAKİ', (
    tester,
  ) async {
    await _pump(
      tester,
      result: _result(stars: 3, isPerfect: true),
      onNextLevel: () {},
    );
    expect(_primaryCtaLabel(tester), 'SONRAKİ');
    // still exactly one amber pill
    expect(
      tester.widget<Text>(find.text('Yeniden')).style?.color,
      isNot(PlayTheme.inkAmber),
    );
  });

  testWidgets('2★ (not perfect) → the amber pill stays Yeniden', (
    tester,
  ) async {
    await _pump(
      tester,
      result: _result(stars: 2, isPerfect: false),
      onNextLevel: () {},
    );
    expect(_primaryCtaLabel(tester), 'Yeniden');
    // Next Level is present, enabled (no "· yakında")
    expect(find.text('SONRAKİ'), findsOneWidget);
    expect(find.text('yakında'), findsNothing);
  });

  testWidgets('3★ but Next NOT wired (debug entry) → amber pill stays Yeniden, '
      'Next disabled with the "· yakında" affordance', (tester) async {
    await _pump(tester, result: _result(stars: 3, isPerfect: true));
    expect(_primaryCtaLabel(tester), 'Yeniden');
    expect(find.text('yakında'), findsOneWidget);
  });
}
