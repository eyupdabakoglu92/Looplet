// Renders the native launch image from the Flutter ground itself (F05
// `ui-design.md` §5 / §11 "Flexible": the launch image may be regenerated from
// `LoopBackdrop` at build time, if the result is the same picture). The native
// launch, the Flutter splash and Home are then one picture, with no jump at the
// hand-off (architecture §18.3 (8)).
//
// Not part of `flutter test` (it lives outside `test/`). Regenerate with:
//   cd app && flutter test tool/render_launch_backdrop_test.dart
//
// Writes the iOS `LaunchImage` set (430 × 932 pt at 1× / 2× / 3×) and the
// Android `drawable-nodpi/launch_backdrop.png` (the 3× image).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';

const Size _logical = Size(430, 932); // 1290 × 2796 px at 3×, the Pro Max frame

Future<List<int>> _render(WidgetTester tester, double dpr) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox.fromSize(
            size: _logical,
            child: const LoopBackdrop(child: SizedBox.expand()),
          ),
        ),
      ),
    ),
  );
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

void main() {
  testWidgets('render the launch backdrop', (tester) async {
    tester.view.physicalSize = const Size(1400, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const ios = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
    final outputs = <String, double>{
      '$ios/LaunchImage.png': 1,
      '$ios/LaunchImage@2x.png': 2,
      '$ios/LaunchImage@3x.png': 3,
      'android/app/src/main/res/drawable-nodpi/launch_backdrop.png': 3,
    };
    for (final entry in outputs.entries) {
      final file = File(entry.key)..parent.createSync(recursive: true);
      file.writeAsBytesSync(await _render(tester, entry.value));
    }
  });
}
