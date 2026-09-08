import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_router.dart';
import '../journey/column_tutorial_overlay.dart';
import '../journey/journey_content.dart';
import '../journey/journey_nav.dart';
import '../journey/journey_strings.dart';
import '../journey/journey_tutorial.dart';
import '../persistence/persistence_providers.dart';
import '../rating/completion_panel.dart';
import '../rating/rating_strings.dart';
import 'play_session_args.dart';
import 'play_session_controller.dart';
import 'play_session_providers.dart';
import 'play_strings.dart';
import 'play_theme.dart';
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
  // Every `/play` exit resolves to `/` (`f05 architecture.md §8`): pop if there
  // is a caller, else (direct entry / a `pushReplacement` chain) go home.
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    context.go(Routes.home);
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

  /// F05 — the 4–6 column micro-tutorial (`architecture.md §9`). Resolved once
  /// in [_init]: shown iff a Journey level in 4..6 AND the `kv` ack is unset.
  bool _showColumnTutorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(activeSessionRepoProvider);
    final snapshot = await repo.read();
    // F04: the personal-best store + guest id (F08). A guest row always exists
    // after bootstrap; guard defensively so a lookup failure only costs the
    // "best" line, never the panel.
    final personalBestRepo = ref.read(personalBestRepoProvider);
    final journeyProgressRepo = ref.read(journeyProgressRepoProvider);
    String? guestId;
    try {
      guestId = await ref.read(currentGuestIdProvider.future);
    } catch (error) {
      debugPrint('play: guest id unavailable, best line disabled — $error');
    }

    // F05 — the 4–6 column micro-tutorial gate.
    final level = widget.args.journeyLevel;
    var showTutorial = false;
    if (widget.args.source == PuzzleSource.journey &&
        level != null &&
        level >= 4 &&
        level <= 6) {
      try {
        showTutorial = !await ref
            .read(journeyTutorialRepoProvider)
            .isColumnTutorialAcknowledged();
      } catch (_) {
        showTutorial = true; // read failed → show it (mild over-prompt, safe)
      }
    }

    if (!mounted) return;
    final controller = PlaySessionController(
      puzzle: widget.setup.puzzle,
      source: widget.args.source,
      validator: widget.setup.validator,
      activeSessionRepo: repo,
      restoreFrom: snapshot,
      personalBestRepo: personalBestRepo,
      guestId: guestId,
      journeyProgressRepo: journeyProgressRepo,
      journeyLevel: widget.args.journeyLevel,
    )..attach();
    setState(() {
      _controller = controller;
      _showColumnTutorial = showTutorial;
    });
  }

  Future<void> _dismissColumnTutorial() async {
    if (!_showColumnTutorial) return;
    setState(() => _showColumnTutorial = false);
    try {
      await ref.read(journeyTutorialRepoProvider).acknowledgeColumnTutorial();
    } catch (error) {
      debugPrint('journey: tutorial ack write failed (non-fatal) — $error');
    }
  }

  /// F05 — `Next Level` handler for F04's `CompletionPanel.onNextLevel`
  /// (`architecture.md §8`). `pushReplacement` to N+1, or `/` (→ terminal) when
  /// there is no next level. `null` for a non-Journey session.
  VoidCallback? _nextLevelHandler() {
    final n = widget.args.journeyLevel;
    if (widget.args.source != PuzzleSource.journey || n == null) return null;
    return () async {
      var manifestLen = journeyLevelCount;
      try {
        final manifest = await ref.read(journeyManifestProvider(_lang).future);
        manifestLen = manifest.levels.length;
      } catch (_) {
        // manifest unavailable → treat as "no next level" → terminal
        manifestLen = n;
      }
      if (!mounted) return;
      final next = nextJourneyLevel(n, manifestLevelCount: manifestLen);
      if (next == null) {
        context.go(Routes.home);
      } else {
        context.pushReplacement(
          Routes.play,
          extra: PlaySessionArgs(
            source: PuzzleSource.journey,
            journeyLevel: next,
          ),
        );
      }
    };
  }

  // Launch language for the MVP (F10 owns switching).
  static const String _lang = 'tr';

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
    final onNext = _nextLevelHandler();
    return _PlayScaffold(
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          final won = c.phase == PlaySessionPhase.won;
          return Stack(
            children: <Widget>[
              _PlayBody(controller: c, strings: strings, onNextLevel: onNext),
              if (_showColumnTutorial && !won)
                ColumnTutorialOverlay(
                  controller: c,
                  strings: JourneyStrings.of(c.lang),
                  onSatisfied: _dismissColumnTutorial,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayBody extends StatelessWidget {
  const _PlayBody({
    required this.controller,
    required this.strings,
    this.onNextLevel,
  });

  final PlaySessionController controller;
  final PlayStrings strings;
  final VoidCallback? onNextLevel;

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
        // F04 completion panel + scrim (over F03's dimmed + receded board).
        IgnorePointer(
          ignoring: !won,
          child: AnimatedOpacity(
            opacity: won ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: const ColoredBox(color: PlayTheme.sheetScrim),
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
                ? CompletionPanel(
                    strings: strings,
                    rating: RatingStrings.of(controller.lang),
                    result: controller.completion,
                    ratingUnavailable: controller.ratingUnavailable,
                    bareWord: controller.targetWord,
                    bareMoves: controller.moveCount,
                    onRetry: controller.retryFromCompletion,
                    onClose: () => _popToCaller(context),
                    onNextLevel: onNextLevel,
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
