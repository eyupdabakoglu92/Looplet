import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../design/design.dart';
import 'shell_layout.dart';
import 'shell_wordmark.dart';

/// The frame between the native launch and Home (F05 `ui-design.md` §4, §8
/// `D3-22`; architecture §18.3 (8)): the Foundation ground — the same picture
/// as the native launch image — and the `Looplet` wordmark at its Home
/// position, fading in. Nothing else, no spinner.
///
/// Also the first frame of Home before the Journey model loads (`D3-08`) —
/// Home renders the same frame through [ShellFrame].
class LoopSplashScreen extends StatelessWidget {
  const LoopSplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      ShellFrame(builder: (context, layout) => const SizedBox.shrink());
}

/// The shell's common frame: the ground, the light status bar and the
/// wordmark at (25, 58)·s; [builder] adds the screen's content above it.
class ShellFrame extends StatelessWidget {
  const ShellFrame({
    required this.builder,
    this.scrollingWordmark = false,
    super.key,
  });

  final Widget Function(BuildContext context, ShellLayout layout) builder;

  /// When the content column scrolls and carries its own wordmark (the
  /// store-error screen), the frame draws none.
  final bool scrollingWordmark;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: LoopColors.groundMid,
        body: LoopBackdrop(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = ShellLayout(constraints.biggest);
              return LoopScale(
                value: layout.s,
                child: Stack(
                  children: <Widget>[
                    if (!scrollingWordmark)
                      Positioned(
                        left: layout.wordmarkLeft,
                        top: layout.wordmarkTop,
                        child: ShellWordmark(fontSize: layout.wordmarkSize),
                      ),
                    Positioned.fill(
                      child: Builder(
                        builder: (context) => builder(context, layout),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
