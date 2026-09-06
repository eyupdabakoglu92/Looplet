import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'play/debug_puzzle_library.dart';
import 'play/play_session_args.dart';

/// Placeholder home. The real menu lands with F10; for now it shows the
/// wordmark and a **debug** row that opens the F03 play screen against the F06
/// smoke set (`architecture.md` §4 — not a shipping navigation path).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'LOOPLET',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'debug',
                style: TextStyle(fontSize: 11, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final id in DebugPuzzleLibrary.ids)
                    OutlinedButton(
                      onPressed: () => context.push(
                        Routes.play,
                        extra: PlaySessionArgs(
                          source: PuzzleSource.journey,
                          debugPuzzleId: id,
                        ),
                      ),
                      child: Text(id.replaceFirst('smoke-tr-', 'L')),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
