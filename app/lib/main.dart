import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LOOPLET is portrait-only (product-prd §1, §33).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const LoopletApp());
}

/// Scaffold shell. Real routing (go_router), theming, Riverpod scope, and the
/// game/menu screens land with F03/F05/F09/F10.
class LoopletApp extends StatelessWidget {
  const LoopletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOOPLET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B1B1F)),
        useMaterial3: true,
      ),
      home: const _BootPlaceholder(),
    );
  }
}

class _BootPlaceholder extends StatelessWidget {
  const _BootPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('LOOPLET')));
  }
}
