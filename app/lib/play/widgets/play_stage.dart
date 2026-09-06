import 'package:flutter/widgets.dart';

import '../play_theme.dart';

/// The atmospheric background for the play screen (`ui-design.md` §5): a warm
/// dark vertical gradient, one soft radial spotlight above board centre, and a
/// gentle corner vignette. Static — the optional "breathing" ambient is
/// deferred (kept out so `pumpAndSettle` stays deterministic).
class PlayStage extends StatelessWidget {
  const PlayStage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[PlayTheme.stage0, PlayTheme.stage1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Spotlight — centred slightly above the middle, wide + feathered.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.28),
                radius: 1.1,
                colors: <Color>[
                  Color(0x242A2350), // ~14% stageGlow
                  Color(0x00141322),
                ],
                stops: <double>[0.0, 1.0],
              ),
            ),
          ),
          // Corner vignette.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: <Color>[Color(0x00000000), Color(0x2E000000)],
                stops: <double>[0.62, 1.0],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
