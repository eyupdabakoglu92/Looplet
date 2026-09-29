// F05-FE-D3 — the native launch resources (F05 architecture §18.3 (8),
// `ui-design.md` §11 Must, §11.1 (14)): no white or theme-dependent frame on
// iOS or Android (light and dark, API < 21 and 31+). Reads the platform files
// from `app/` (like the content mirror test, `flutter test` runs there).

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const String res = 'android/app/src/main/res';

String read(String path) => File(path).readAsStringSync();

/// `<item name="…">value</item>` inside `<style name="style">…</style>`.
String? styleItem(String xml, String style, String item) {
  final block = RegExp(
    '<style name="$style"[^>]*>(.*?)</style>',
    dotAll: true,
  ).firstMatch(xml);
  if (block == null) return null;
  return RegExp(
    '<item name="$item">([^<]*)</item>',
  ).firstMatch(block.group(1)!)?.group(1)?.trim();
}

/// A PNG's pixel size from its IHDR chunk.
(int, int) pngSize(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  group('Android', () {
    test('LaunchTheme and NormalTheme use the launch drawable in light and '
        'dark mode — never ?android:colorBackground', () {
      for (final dir in <String>['values', 'values-night']) {
        final xml = read('$res/$dir/styles.xml');
        for (final style in <String>['LaunchTheme', 'NormalTheme']) {
          expect(
            styleItem(xml, style, 'android:windowBackground'),
            '@drawable/launch_background',
            reason: '$dir $style',
          );
        }
      }
    });

    test('API 31+: the system splash background is the ground', () {
      for (final dir in <String>['values-v31', 'values-night-v31']) {
        final xml = read('$res/$dir/styles.xml');
        expect(
          styleItem(xml, 'LaunchTheme', 'android:windowSplashScreenBackground'),
          '@color/loop_ground',
          reason: dir,
        );
        expect(
          styleItem(xml, 'NormalTheme', 'android:windowBackground'),
          '@drawable/launch_background',
          reason: dir,
        );
      }
    });

    test('no resource falls back to a white or theme colour', () {
      final files = Directory(res)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.xml'));
      for (final file in files) {
        final xml = file.readAsStringSync();
        expect(
          xml,
          isNot(contains('?android:colorBackground')),
          reason: file.path,
        );
        expect(xml, isNot(contains('@android:color/white')), reason: file.path);
      }
    });

    test('launch_background (API < 21 and 21+): the ground under the '
        'backdrop image', () {
      for (final dir in <String>['drawable', 'drawable-v21']) {
        final xml = read('$res/$dir/launch_background.xml');
        expect(xml, contains('android:drawable="@color/loop_ground"'));
        expect(xml, contains('android:src="@drawable/launch_backdrop"'));
      }
      expect(read('$res/values/colors.xml'), contains('#FF070C25'));
      expect(pngSize('$res/drawable-nodpi/launch_backdrop.png'), (1290, 2796));
    });
  });

  group('iOS', () {
    const storyboard = 'ios/Runner/Base.lproj/LaunchScreen.storyboard';
    const images = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';

    test('the launch view is the ground (#070C25) with the backdrop image '
        'aspect-filled edge to edge', () {
      final xml = read(storyboard);
      expect(
        xml,
        contains(
          '<color key="backgroundColor" red="0.027450980392156862" '
          'green="0.047058823529411764" blue="0.14509803921568629" alpha="1"',
        ),
      );
      expect(xml, isNot(contains('red="1" green="1" blue="1"')));
      expect(
        xml,
        contains('contentMode="scaleAspectFill" image="LaunchImage"'),
      );
      for (final edge in <String>['leading', 'trailing', 'top', 'bottom']) {
        expect(
          xml,
          contains('firstAttribute="$edge" secondItem="Ze5-6b-2t3"'),
          reason: edge,
        );
      }
    });

    test(
      'the LaunchImage set is the 430 × 932 pt backdrop at 1× / 2× / 3×',
      () {
        expect(pngSize('$images/LaunchImage.png'), (430, 932));
        expect(pngSize('$images/LaunchImage@2x.png'), (860, 1864));
        expect(pngSize('$images/LaunchImage@3x.png'), (1290, 2796));
      },
    );

    test('the launch status bar is light content (no dark icons on navy)', () {
      final plist = read('ios/Runner/Info.plist');
      expect(
        plist,
        matches(
          RegExp(
            r'<key>UIStatusBarStyle</key>\s*<string>UIStatusBarStyleLightContent</string>',
          ),
        ),
      );
    });
  });
}
