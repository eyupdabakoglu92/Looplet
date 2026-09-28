// Glyph-ink and line-break probes for the text-scale rules (F03-FE-D1R,
// architecture §19.10). Not a test suite itself — no `_test` suffix.
//
// A layout box (`getRect`) is not the ink: glyphs sit inside their line box
// with ascent / descent padding and may overhang it. These helpers repaint a
// laid-out `Text` with a `TextPainter` built from the same `RenderParagraph`
// and read back the pixels, so a rule such as "the ink lies inside the card's
// rounded rect" is checked against what the screen would actually draw.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The render paragraph of the single `Text` matched by [finder].
RenderParagraph paragraphOf(WidgetTester tester, Finder finder) =>
    tester.renderObject<RenderParagraph>(finder);

/// The global rects of the ink pixels of [paragraph], sampled at
/// [pixelsPerPoint] (each rect is one sample pixel, 1 / [pixelsPerPoint] pt
/// square). Any pixel with non-zero alpha counts as ink — anti-aliased fringes
/// included.
Future<List<Rect>> inkPixels(
  WidgetTester tester,
  RenderParagraph paragraph, {
  double pixelsPerPoint = 4,
}) async {
  final painter = TextPainter(
    text: paragraph.text,
    textAlign: paragraph.textAlign,
    textDirection: paragraph.textDirection,
    textScaler: paragraph.textScaler,
    maxLines: paragraph.maxLines,
    locale: paragraph.locale,
    strutStyle: paragraph.strutStyle,
    textWidthBasis: paragraph.textWidthBasis,
    textHeightBehavior: paragraph.textHeightBehavior,
  )..layout(maxWidth: paragraph.constraints.maxWidth);
  addTearDown(painter.dispose);
  // The repaint must reproduce the on-screen layout, or the ink is not the
  // ink of the widget under test.
  expect(
    painter.size.height,
    closeTo(paragraph.size.height, 0.01),
    reason: 'repainted paragraph has a different line layout',
  );

  // Glyphs may overhang their layout box; leave a margin around it.
  const margin = 24.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..scale(pixelsPerPoint)
    ..translate(margin, margin);
  painter.paint(canvas, Offset.zero);
  final picture = recorder.endRecording();
  final width = ((painter.width + 2 * margin) * pixelsPerPoint).ceil();
  final height = ((painter.height + 2 * margin) * pixelsPerPoint).ceil();

  final bytes = await tester.runAsync(() async {
    final image = await picture.toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data;
  });
  picture.dispose();

  final origin = paragraph.localToGlobal(Offset.zero);
  final step = 1 / pixelsPerPoint;
  final pixels = <Rect>[];
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (bytes!.getUint8((y * width + x) * 4 + 3) == 0) continue;
      pixels.add(
        Rect.fromLTWH(
          origin.dx + x * step - margin,
          origin.dy + y * step - margin,
          step,
          step,
        ),
      );
    }
  }
  return pixels;
}

/// The bounding box of [pixels].
Rect inkBounds(List<Rect> pixels) =>
    pixels.reduce((a, b) => a.expandToInclude(b));

/// The ink pixels of [pixels] that are not wholly inside [shape] (all four
/// corners of a sample pixel must be inside; the shape is convex).
List<Rect> inkOutside(List<Rect> pixels, RRect shape) => pixels
    .where(
      (p) =>
          !(shape.contains(p.topLeft) &&
              shape.contains(p.topRight) &&
              shape.contains(p.bottomLeft) &&
              shape.contains(p.bottomRight)),
    )
    .toList();

/// The largest inset (to 0.01 pt) by which [shape] can shrink with every ink
/// pixel of [pixels] still wholly inside it; negative when ink already crosses
/// the shape's edge.
double inkInset(List<Rect> pixels, RRect shape) {
  var lo = -20.0;
  var hi = 20.0;
  while (hi - lo > 0.01) {
    final mid = (lo + hi) / 2;
    final fits = inkOutside(
      pixels,
      mid >= 0 ? shape.deflate(mid) : shape.inflate(-mid),
    ).isEmpty;
    if (fits) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// The text of each laid-out line of [paragraph], in order — every character
/// is assigned to the line its selection box sits on.
List<String> lineTexts(RenderParagraph paragraph) {
  final text = paragraph.text.toPlainText();
  final lines = <double, StringBuffer>{};
  for (var i = 0; i < text.length; i++) {
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: i, extentOffset: i + 1),
    );
    if (boxes.isEmpty) continue; // e.g. a collapsed trailing space
    final top = (boxes.first.top * 100).roundToDouble() / 100;
    lines.putIfAbsent(top, StringBuffer.new).write(text[i]);
  }
  final tops = lines.keys.toList()..sort();
  return <String>[for (final t in tops) lines[t].toString()];
}

/// Line-break faults of [lines] made from [text]: a line with no letter or
/// digit (a lone "." or "…"), and a break that is not at a space (a word split
/// across two lines). Empty when every break falls between words.
List<String> lineBreakFaults(String text, List<String> lines) {
  final faults = <String>[];
  final wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);
  var index = 0;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (!wordChar.hasMatch(line)) {
      faults.add('line ${i + 1} "$line" has no word');
    }
    index += line.length;
    if (i < lines.length - 1) {
      final before = line.trimRight();
      final brokeAtSpace =
          line.length > before.length ||
          (index < text.length && text[index] == ' ');
      if (!brokeAtSpace) {
        faults.add('break inside a word after "$before"');
      }
    }
  }
  return faults;
}
