import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/play/play_layout.dart';
import 'package:looplet_app/play/play_session_args.dart';
import 'package:looplet_app/play/play_strings.dart';

import '../design/text_ink_support.dart';
import 'play_test_support.dart';

/// F03-FE-D1R, architecture §19.10 (2) (F03-QA-D1-02): at every OS text size
/// from default to AX5, on 390 / 393 / 440-pt widths, the load-error headline
/// breaks only between words — no line made only of punctuation, no word
/// split across lines. The §19.9 (3) 1.3× cap stays; the headline may use the
/// card's inner width; the default-size (D1-07) layout is unchanged.
///
/// Real fonts; the break positions are read from the laid-out paragraph.

/// The Play screen in its load-error state for Journey level 07 (a level
/// asset that fails to parse, as in QA's corrupted `journey-tr-07.json`).
Future<void> _bootLoadError(WidgetTester tester) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    playApp(
      db: db,
      puzzle: null,
      args: const PlaySessionArgs(
        source: PuzzleSource.journey,
        journeyLevel: 7,
      ),
      setup: () async => throw const FormatException('journey-tr-07.json'),
    ),
  );
  await tester.pump();
  await tester.tap(find.text('HOME'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadAppFonts();
  });

  final headline = PlayStrings.of('tr').loadFailed;

  for (final device in kPlayDevices) {
    for (final textScale in kOsTextScales) {
      testWidgets(
        '${device.width.toInt()} pt, OS text ${textScale}x: "$headline" '
        'breaks only between words, capped at 1.3×',
        (tester) async {
          setDevice(tester, device, textScale: textScale);
          await _bootLoadError(tester);
          expect(tester.takeException(), isNull);

          final paragraph = paragraphOf(tester, find.text(headline));
          expect(
            paragraph.textScaler.scale(10) / 10,
            closeTo(textScale < 1.3 ? textScale : 1.3, 1e-9),
            reason: 'the §19.9 (3) cap stays',
          );
          final lines = lineTexts(paragraph);
          expect(lines.join(), headline);
          expect(
            lineBreakFaults(headline, lines),
            isEmpty,
            reason:
                '${device.width.toInt()} pt, OS text ${textScale}x: '
                'lines ${lines.map((l) => '"$l"').join(' / ')}',
          );

          // The headline ink stays inside the card's inner column: the card is
          // 309·s wide from x 24.5·s, with 26·s side padding.
          final layout = PlayLayout(device);
          final s = layout.s;
          final innerLeft = layout.left + (24.5 + 26) * s;
          final innerRight = layout.left + (24.5 + 309 - 26) * s;
          final ink = inkBounds(await inkPixels(tester, paragraph));
          expect(ink.left, greaterThanOrEqualTo(innerLeft - 1));
          expect(ink.right, lessThanOrEqualTo(innerRight + 1));
        },
      );
    }
  }

  testWidgets(
    'the rule check itself: a punctuation-only line and a split word are '
    'faults; breaks at spaces are not',
    (tester) async {
      expect(
        lineBreakFaults('Bu bulmaca yüklenemedi.', <String>[
          'Bu bulmaca ',
          'yüklenemedi',
          '.',
        ]),
        hasLength(2),
      );
      expect(
        lineBreakFaults('Bu bulmaca yüklenemedi.', <String>[
          'Bu bulmaca yük',
          'lenemedi.',
        ]),
        hasLength(1),
      );
      expect(
        lineBreakFaults('Bu bulmaca yüklenemedi.', <String>[
          'Bu bulmaca ',
          'yüklenemedi.',
        ]),
        isEmpty,
      );
      expect(
        lineBreakFaults('Bu bulmaca yüklenemedi.', <String>[
          'Bu ',
          'bulmaca ',
          'yüklenemedi.',
        ]),
        isEmpty,
      );
    },
  );
}
