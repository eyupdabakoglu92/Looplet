import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/persistence_providers.dart';
import 'play_session_args.dart';
import 'play_session_controller.dart';
import 'play_session_providers.dart';
import 'play_strings.dart';
import 'play_theme.dart';
import 'widgets/completion_sheet.dart';
import 'widgets/moves_hud.dart';
import 'widgets/play_stage.dart';
import 'widgets/puzzle_board.dart';
import 'widgets/restart_button.dart';
import 'widgets/target_rail.dart';
import 'widgets/undo_button.dart';

/// Route `'/play'` (`architecture.md` §13). Resolves the puzzle + validator,
/// then hands off to [_LoadedPlaySession] which owns the [PlaySessionController]
/// and the lifecycle observer.
class PlaySessionScreen extends ConsumerWidget {
  const PlaySessionScreen({required this.args, super.key});

  final PlaySessionArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(playSessionSetupProvider(args));
    return setup.when(
      loading: () => const _PlayScaffold(child: _LoadingBoard()),
      error: (error, _) => _PlayScaffold(
        child: _LoadErrorBody(
          strings: PlayStrings.of('tr'),
          onBack: () => _popToCaller(context),
        ),
      ),
      data: (data) => _LoadedPlaySession(args: args, setup: data),
    );
  }
}

void _popToCaller(BuildContext context) {
  final nav = Navigator.of(context);
  if (nav.canPop()) {
    nav.pop();
  } else {
    // Direct entry (deep link / debug) with an empty stack — fall back home.
    nav.maybePop();
  }
}

class _PlayScaffold extends StatelessWidget {
  const _PlayScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlayTheme.stage1,
      body: PlayStage(child: SafeArea(child: child)),
    );
  }
}

class _LoadedPlaySession extends ConsumerStatefulWidget {
  const _LoadedPlaySession({required this.args, required this.setup});

  final PlaySessionArgs args;
  final PlaySessionSetup setup;

  @override
  ConsumerState<_LoadedPlaySession> createState() => _LoadedPlaySessionState();
}

class _LoadedPlaySessionState extends ConsumerState<_LoadedPlaySession>
    with WidgetsBindingObserver {
  PlaySessionController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(activeSessionRepoProvider);
    final snapshot = await repo.read();
    if (!mounted) return;
    final controller = PlaySessionController(
      puzzle: widget.setup.puzzle,
      source: widget.args.source,
      validator: widget.setup.validator,
      activeSessionRepo: repo,
      restoreFrom: snapshot,
    )..attach();
    setState(() => _controller = controller);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;
    if (state == AppLifecycleState.paused) {
      c.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      c.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) return const _PlayScaffold(child: _LoadingBoard());

    final strings = PlayStrings.of(c.lang);
    return _PlayScaffold(
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) => _PlayBody(controller: c, strings: strings),
      ),
    );
  }
}

class _PlayBody extends StatelessWidget {
  const _PlayBody({required this.controller, required this.strings});

  final PlaySessionController controller;
  final PlayStrings strings;

  @override
  Widget build(BuildContext context) {
    final won = controller.phase == PlaySessionPhase.won;

    return Stack(
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            // Board-first sizing (`ui-design.md` §6): the board shrinks first;
            // the fixed zone gaps hold until the board hits its floor.
            const chromeAndZones = 2 * PlayTheme.zoneGap + 44 + 150 + 96;
            const boardFloor =
                5 * PlayTheme.minTileSize +
                2 * PlayTheme.platePadding +
                4 * PlayTheme.tileGap;
            final maxByWidth = w * PlayTheme.boardWidthFraction;
            final maxByHeight = h - chromeAndZones;
            final board = math
                .min(maxByWidth, math.max(maxByHeight, boardFloor))
                .clamp(boardFloor, w * 0.94)
                .toDouble();

            return Column(
              children: <Widget>[
                _TopBar(
                  strings: strings,
                  showBack: !won,
                  onBack: () => _popToCaller(context),
                ),
                const SizedBox(height: 8),
                TargetRail(
                  label: strings.targetLabel,
                  word: controller.targetWord,
                  tileSize: board / controller.gridSize,
                ),
                const _DividerGlow(),
                const SizedBox(height: PlayTheme.zoneGap),
                Expanded(
                  child: Center(
                    child: Semantics(
                      label:
                          '${strings.boardSemantics}. '
                          '${strings.targetLabel}: ${controller.targetWord}. '
                          '${strings.movesLabel}: ${controller.moveCount}.',
                      child: PuzzleBoard(
                        controller: controller,
                        boardSize: board,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: PlayTheme.zoneGap),
                _HudBar(controller: controller, strings: strings),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
        // Completion sheet + scrim.
        IgnorePointer(
          ignoring: !won,
          child: AnimatedOpacity(
            opacity: won ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: const ColoredBox(color: Color(0x66000000)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: won ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 320),
            curve: PlayTheme.shiftCurve,
            child: won
                ? CompletionSheet(
                    strings: strings,
                    word: controller.targetWord,
                    moves: controller.moveCount,
                    onRetry: controller.retryFromCompletion,
                    onClose: () => _popToCaller(context),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.strings,
    required this.showBack,
    required this.onBack,
  });

  final PlayStrings strings;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Align(
        alignment: Alignment.centerLeft,
        child: showBack
            ? Semantics(
                button: true,
                label: strings.back,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: PlayTheme.muted,
                      size: 28,
                    ),
                  ),
                ),
              )
            : const SizedBox(width: 44, height: 44),
      ),
    );
  }
}

class _DividerGlow extends StatelessWidget {
  const _DividerGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            PlayTheme.cyan.withValues(alpha: 0),
            PlayTheme.muted.withValues(alpha: 0.28),
            PlayTheme.cyan.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _HudBar extends StatelessWidget {
  const _HudBar({required this.controller, required this.strings});

  final PlaySessionController controller;
  final PlayStrings strings;

  @override
  Widget build(BuildContext context) {
    final locked = controller.inputLocked;
    final opacity = controller.phase == PlaySessionPhase.won
        ? PlayTheme.wonControlsOpacity
        : (locked ? PlayTheme.lockedControlsOpacity : 1.0);

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 160),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: MovesHud(
                moves: controller.moveCount,
                label: strings.movesLabel,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                UndoButton(
                  remaining: controller.undosRemaining,
                  enabled: controller.canUndo,
                  onPressed: controller.undo,
                  semanticLabel: strings.undoTooltip,
                ),
                const Spacer(),
                Container(
                  width: 1,
                  height: 32,
                  color: PlayTheme.paper.withValues(alpha: 0.06),
                ),
                const SizedBox(width: 20),
                RestartButton(
                  enabled: controller.canRestart,
                  onPressed: controller.restart,
                  semanticLabel: strings.restartTooltip,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBoard extends StatelessWidget {
  const _LoadingBoard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final board = math.min(
            constraints.maxWidth * PlayTheme.boardWidthFraction,
            constraints.maxHeight * 0.6,
          );
          final tile =
              (board - 2 * PlayTheme.platePadding - 4 * PlayTheme.tileGap) / 5;
          return SizedBox(
            width: board,
            height: board,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: PlayTheme.plate,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Wrap(
                spacing: PlayTheme.tileGap,
                runSpacing: PlayTheme.tileGap,
                children: <Widget>[
                  for (var i = 0; i < 25; i++)
                    Container(
                      width: tile,
                      height: tile,
                      decoration: BoxDecoration(
                        color: PlayTheme.paper.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(
                          tile * PlayTheme.tileRadiusFraction,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadErrorBody extends StatelessWidget {
  const _LoadErrorBody({required this.strings, required this.onBack});

  final PlayStrings strings;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: PlayTheme.danger,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(strings.loadFailed, style: PlayTheme.helper),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                strings.back,
                style: PlayTheme.helper.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PlayTheme.paper,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
