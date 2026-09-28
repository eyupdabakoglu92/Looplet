import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_theme.dart';

import '../play/play_test_support.dart';
import 'text_ink_support.dart';

/// F03-FE-D1R, architecture §19.10 (1) (F03-QA-D1-01): at every OS text size
/// from default to AX5, on 390 / 393 / 440-pt widths, the ink of the `HAMLE`
/// card's numeral and label lies inside the card's rounded rect — corner arcs
/// included — inset by ≥ 2 pt. The card keeps its 60·s width and its top-left
/// anchor, grows downward only, stays ≥ 8 pt above `HEDEF DÖNGÜ`, and is
/// 60 × 63·s at the default size (D1-00).
///
/// Real fonts, real glyph ink (pixels), not the text's layout box — and the
/// app's Material text context: the counter has no line height of its own and
/// inherits the theme's (1.43), which puts the label ≈ 4 pt lower than in a
/// bare widget tree (and matches the device capture; QA-16-16 / QM-measurements).

/// The ink of the numeral and the label is ≥ 2 pt inside the card's rounded
/// rect; returns the smaller inset.
Future<double> expectMovesInkInside(
  WidgetTester tester, {
  required double s,
  required List<String> texts,
  required String context,
}) async {
  final card = tester.getRect(find.byType(MovesCard));
  final shape = RRect.fromRectAndRadius(card, Radius.circular(22 * s));
  var smallest = double.infinity;
  for (final text in texts) {
    final pixels = await inkPixels(
      tester,
      paragraphOf(
        tester,
        find.descendant(of: find.byType(MovesCard), matching: find.text(text)),
      ),
    );
    expect(pixels, isNotEmpty);
    final inset = inkInset(pixels, shape);
    expect(
      inset,
      greaterThanOrEqualTo(2),
      reason:
          '$context, "$text": ink ${inkBounds(pixels)} is '
          '${inset.toStringAsFixed(2)} pt inside the card $card '
          '(r ${(22 * s).toStringAsFixed(2)})',
    );
    if (inset < smallest) smallest = inset;
  }
  return smallest;
}

/// `MovesCard` at its Play anchor, under the app's theme (`main.dart`).
Widget _cardInApp(
  PlayLayout layout, {
  required int moves,
  required String label,
}) => MaterialApp(
  theme: ThemeData(
    colorScheme: PlayTheme.colorScheme,
    scaffoldBackgroundColor: PlayTheme.stage1,
    useMaterial3: true,
  ),
  home: Scaffold(
    body: LoopScale(
      value: layout.s,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: layout.movesCard.dx,
            top: layout.movesCard.dy,
            child: MovesCard(moves: moves, label: label),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  group('MovesCard glyph ink at every OS text size (§19.10 (1))', () {
    for (final device in kPlayDevices) {
      for (final textScale in kOsTextScales) {
        testWidgets(
          '${device.width.toInt()} pt, OS text ${textScale}x: numeral and '
          'label ink ≥ 2 pt inside the rounded card; width, anchor and '
          'caption gap kept',
          (tester) async {
            setDevice(tester, device, textScale: textScale);
            final layout = PlayLayout(device);
            final s = layout.s;
            for (final label in <String>['HAMLE', 'MOVES']) {
              for (final moves in <int>[0, 8, 48, 99, 188]) {
                await tester.pumpWidget(
                  _cardInApp(layout, moves: moves, label: label),
                );
                final card = tester.getRect(find.byType(MovesCard));
                expect(card.topLeft, layout.movesCard);
                expect(card.width, closeTo(60 * s, 1e-9));
                expect(card.height, greaterThanOrEqualTo(63 * s - 1e-9));
                if (textScale == 1.0) {
                  // The default-size look (D1-00) is unchanged.
                  expect(card.height, closeTo(63 * s, 1e-9));
                }
                expect(
                  layout.captionTop - card.bottom,
                  greaterThanOrEqualTo(8),
                  reason: 'the card stays ≥ 8 pt above HEDEF DÖNGÜ',
                );
                await expectMovesInkInside(
                  tester,
                  s: s,
                  texts: <String>['$moves', label],
                  context:
                      '${device.width.toInt()} pt, OS text ${textScale}x, '
                      '$moves moves',
                );
              }
            }
          },
        );
      }
    }
  });

  group('MovesCard on the Play screen (§19.10 (1))', () {
    for (final device in kPlayDevices) {
      for (final textScale in <double>[1.0, 1.235, 1.3, 3.118]) {
        testWidgets(
          '${device.width.toInt()} pt, OS text ${textScale}x: anchored at '
          '(273.5, 75)·s, 60·s wide, ≥ 8 pt above the HEDEF DÖNGÜ text, '
          'ink ≥ 2 pt inside',
          (tester) async {
            setDevice(tester, device, textScale: textScale);
            await bootPlay(
              tester,
              puzzle: testPuzzle(
                grid: const <String>[
                  'KALEM',
                  'DOLAP',
                  'SEHİR',
                  'BİLGİ',
                  'KUMAŞ',
                ],
                level: 26,
              ),
            );
            final layout = PlayLayout(device);
            final s = layout.s;
            final card = tester.getRect(find.byType(MovesCard));
            expect(card.topLeft.dx, closeTo(layout.movesCard.dx, 1e-6));
            expect(card.topLeft.dy, closeTo(layout.movesCard.dy, 1e-6));
            expect(card.width, closeTo(60 * s, 1e-9));
            if (textScale == 1.0) {
              expect(card.height, closeTo(63 * s, 1e-9));
            }
            final caption = tester.getRect(find.text('HEDEF DÖNGÜ'));
            expect(caption.top - card.bottom, greaterThanOrEqualTo(8));
            await expectMovesInkInside(
              tester,
              s: s,
              texts: const <String>['0', 'HAMLE'],
              context: 'Play ${device.width.toInt()} pt, OS text ${textScale}x',
            );
          },
        );
      }
    }
  });
}
