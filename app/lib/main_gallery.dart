import 'dart:io' show Directory, File, FileSystemException;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/design.dart';
import 'design/gallery/design_gallery_screen.dart';

/// Debug entry point for the design-system gallery (F00 `architecture.md`
/// §7.6): `flutter run -t lib/main_gallery.dart` /
/// `flutter build ios --simulator --debug -t lib/main_gallery.dart`.
/// It is never referenced by the shipped app (`lib/main.dart`).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const DesignGalleryApp());
}

class DesignGalleryApp extends StatelessWidget {
  const DesignGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOOPLET design gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: LoopColors.groundBottom,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: LoopColors.groundBottom,
        body: DesignGalleryScreen(initialScrollOffset: _startOffset()),
      ),
    );
  }
}

/// Deterministic runtime captures: write the scroll offset (points) into
/// `<app container>/tmp/gallery_offset` before launching and the gallery starts
/// there. (`Platform.environment` is empty on iOS, so an env var cannot carry it.)
double _startOffset() {
  try {
    final file = File('${Directory.systemTemp.path}/gallery_offset');
    if (file.existsSync()) {
      return double.tryParse(file.readAsStringSync().trim()) ?? 0;
    }
  } on FileSystemException {
    // No capture file: start at the top.
  }
  return 0;
}
