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
import 'package:looplet_core/looplet_core.dart' show TileStatus;

import '../rating/completion_panel.dart';
import '../rating/completion_result.dart';
import '../rating/rating_strings.dart';
import 'play_session_args.dart';
import 'play_session_controller.dart';
import 'play_session_providers.dart';
import 'play_strings.dart';
import 'play_theme.dart';
import 'won_composition.dart';
import 'widgets/docked_row.dart';
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

class _PlayBody extends StatefulWidget {
  const _PlayBody({
    required this.controller,
    required this.strings,
    this.onNextLevel,
  });

  final PlaySessionController controller;
  final PlayStrings strings;
  final VoidCallback? onNextLevel;

  @override
  State<_PlayBody> createState() => _PlayBodyState();
}

/// The won-presentation snapshot taken at `T0` (the winning row's letters and
/// statuses), so the docked overlay and the Retry fade-out never depend on the
/// controller after it has restarted.
class _WonSnapshot {
  const _WonSnapshot({
    required this.row,
    required this.letters,
    required this.statuses,
  });

  final int row;
  final List<String> letters;
  final List<TileStatus> statuses;
}

/// Measured layout the won moment needs (stack-local px), see [WonGeometry].
class _WonMetrics {
  const _WonMetrics({
    required this.rowLeft,
    required this.homeTop,
    required this.tile,
    required this.geometry,
  });

  final double rowLeft;
  final double homeTop;
  final double tile;
  final WonGeometry geometry;
}

class _PlayBodyState extends State<_PlayBody> with TickerProviderStateMixin {
  // `preserve`: under OS reduce-motion the default `normal` behaviour would
  // collapse these durations to ~5 %, defeating the reduced timeline's hold.
  late final AnimationController _timeline = AnimationController(
    vsync: this,
    duration: WonTimeline.regular.total,
    animationBehavior: AnimationBehavior.preserve,
  );

  /// Retry: the won layers fade out (~180 ms) while the board re-lights.
  late final AnimationController _retire = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    animationBehavior: AnimationBehavior.preserve,
  );

  final GlobalKey _stackKey = GlobalKey(debugLabel: 'play.stack');
  final GlobalKey _boardKey = GlobalKey(debugLabel: 'play.board');
  final GlobalKey _dividerKey = GlobalKey(debugLabel: 'play.divider');

  WonTimeline _tl = WonTimeline.regular;
  _WonSnapshot? _snap;
  late PlaySessionPhase _lastPhase;

  // Last panel props while won — reused during the Retry fade-out, after the
  // controller has already restarted.
  CompletionResult? _pResult;
  bool _pUnavailable = false;
  String _pWord = '';
  int _pMoves = 0;

  PlaySessionController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _lastPhase = _c.phase;
    _c.addListener(_onController);
    _retire.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _snap = null;
          _timeline.value = 0;
        });
      }
    });
    if (_c.phase == PlaySessionPhase.won) {
      _enterWon(animate: false);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onController);
    _timeline.dispose();
    _retire.dispose();
    super.dispose();
  }

  void _onController() {
    final phase = _c.phase;
    if (phase == _lastPhase) return;
    final was = _lastPhase;
    _lastPhase = phase;
    if (phase == PlaySessionPhase.won && was != PlaySessionPhase.won) {
      _enterWon(animate: true);
    } else if (phase != PlaySessionPhase.won && was == PlaySessionPhase.won) {
      _leaveWon();
    }
  }

  void _enterWon({required bool animate}) {
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    _tl = WonTimeline.forReduceMotion(reduceMotion);
    _timeline.duration = _tl.total;
    final row = _c.wonRow ?? 0;
    _snap = _WonSnapshot(
      row: row,
      letters: List<String>.of(_c.displayLetters[row]),
      statuses: List<TileStatus>.of(_c.tileStatuses[row]),
    );
    _retire.value = 0;
    if (animate) {
      _timeline.forward(from: 0);
      if (mounted) setState(() {});
    } else {
      _timeline.value = 1; // restored straight into `won`: settled, no replay
    }
  }

  void _leaveWon() {
    // Retry: freeze the timeline, fade the won layers out, board re-lights now.
    _timeline.stop();
    _retire.forward(from: 0);
    if (mounted) setState(() {});
  }

  /// Reads the live layout (after layout, before the dock starts) — `null`
  /// until the board / divider / stack have a size.
  _WonMetrics? _measure(BuildContext context) {
    final stack = _stackKey.currentContext?.findRenderObject();
    final board = _boardKey.currentContext?.findRenderObject();
    final divider = _dividerKey.currentContext?.findRenderObject();
    if (stack is! RenderBox || board is! RenderBox || divider is! RenderBox) {
      return null;
    }
    if (!stack.hasSize || !board.hasSize || !divider.hasSize) return null;
    if (!stack.attached || !board.attached || !divider.attached) return null;
    final snap = _snap;
    if (snap == null) return null;

    final stackTop = stack.localToGlobal(Offset.zero).dy;
    final boardTopLeft = board.localToGlobal(Offset.zero, ancestor: stack);
    final dividerBottom = divider
        .localToGlobal(Offset(0, divider.size.height), ancestor: stack)
        .dy;
    final tile = PuzzleBoard.tileSizeFor(board.size.width, _c.gridSize);
    final stride = tile + PlayTheme.tileGap;
    return _WonMetrics(
      rowLeft: boardTopLeft.dx + PlayTheme.platePadding,
      homeTop: boardTopLeft.dy + PlayTheme.platePadding + snap.row * stride,
      tile: tile,
      geometry: WonGeometry.compute(
        screenHeight: MediaQuery.sizeOf(context).height,
        stackTopGlobal: stackTop,
        stackBottomGlobal: stackTop + stack.size.height,
        dividerBottomLocal: dividerBottom,
        tile: tile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final strings = widget.strings;
    final won = controller.phase == PlaySessionPhase.won;
    final retiring = !won && _snap != null && _retire.isAnimating;

    return Stack(
      key: _stackKey,
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
                _DividerGlow(key: _dividerKey),
                const SizedBox(height: PlayTheme.zoneGap),
                Expanded(
                  child: Center(
                    child: Semantics(
                      label:
                          '${strings.boardSemantics}. '
                          '${strings.targetLabel}: ${controller.targetWord}. '
                          '${strings.movesLabel}: ${controller.moveCount}.',
                      // §16: the board hands its winning row to the dock overlay
                      // from the moment the dock begins (ghost outlines).
                      child: AnimatedBuilder(
                        animation: _timeline,
                        builder: (context, _) => PuzzleBoard(
                          key: _boardKey,
                          controller: controller,
                          boardSize: board,
                          rowVacated: won && _tl.dockStarted(_timeline.value),
                        ),
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
        if (won || retiring) _buildWonLayers(context, won: won),
      ],
    );
  }

  /// Scrim → docked answer row → completion panel (`ui-design.md` §16.2).
  Widget _buildWonLayers(BuildContext context, {required bool won}) {
    final controller = widget.controller;
    if (won) {
      _pResult = controller.completion;
      _pUnavailable = controller.ratingUnavailable;
      _pWord = controller.targetWord;
      _pMoves = controller.moveCount;
    }
    final snap = _snap;
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_timeline, _retire]),
        builder: (context, _) {
          final v = _timeline.value;
          final fade = won ? 1.0 : 1.0 - _retire.value;
          final metrics = _measure(context);
          final dockP = _tl.dock(v);
          final panelP = _tl.panel(v);
          final atRest = _tl.atRest(v);

          return Stack(
            children: <Widget>[
              // 40 % scrim — never before T0 + 600 ms.
              IgnorePointer(
                child: Opacity(
                  opacity: (_tl.scrim(v) * fade).clamp(0.0, 1.0),
                  child: const SizedBox.expand(
                    child: ColoredBox(color: PlayTheme.sheetScrim),
                  ),
                ),
              ),
              // The docked answer row: home slot → dock, from T0 + 600 ms.
              if (snap != null && metrics != null && _tl.dockStarted(v))
                Positioned(
                  left: metrics.rowLeft,
                  top: _tl.reduceMotion
                      ? metrics.geometry.dockTopLocal
                      : metrics.homeTop +
                            (metrics.geometry.dockTopLocal - metrics.homeTop) *
                                dockP,
                  child: Opacity(
                    opacity: (_tl.reduceMotion ? dockP : 1.0) * fade,
                    child: DockedAnswerRow(
                      letters: snap.letters,
                      statuses: snap.statuses,
                      tile: metrics.tile,
                      dockProgress: dockP,
                      scale: metrics.geometry.dockScale,
                    ),
                  ),
                ),
              // The panel exists only from its own start (never before 600 ms).
              if (_tl.panelStarted(v) || !won)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !won || !atRest,
                    child: _slide(
                      progress: won ? panelP : 1.0,
                      fade: fade,
                      child: _WonPanelHost(
                        maxHeight:
                            metrics?.geometry.panelMaxHeight ?? double.infinity,
                        builder: (density) => CompletionPanel(
                          strings: widget.strings,
                          rating: RatingStrings.of(controller.lang),
                          result: _pResult,
                          ratingUnavailable: _pUnavailable,
                          bareWord: _pWord,
                          bareMoves: _pMoves,
                          onRetry: controller.retryFromCompletion,
                          onClose: () => _popToCaller(context),
                          onNextLevel: widget.onNextLevel,
                          density: density,
                          startReveal: atRest || !won,
                          spineGlow: false,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Regular: slide up from below the stack (clipped by it); reduced: fade.
  Widget _slide({
    required double progress,
    required double fade,
    required Widget child,
  }) {
    if (_tl.reduceMotion) {
      return Opacity(opacity: (progress * fade).clamp(0.0, 1.0), child: child);
    }
    return Opacity(
      opacity: fade.clamp(0.0, 1.0),
      child: FractionalTranslation(
        translation: Offset(0, 1 - progress),
        child: child,
      ),
    );
  }
}

/// Hosts the completion panel and applies the §16.3 concessions: if its natural
/// height exceeds [maxHeight] (`0.64 H`), step the density (compact → tight) on
/// the next frame. Layout is measured after the fact, while the panel is still
/// sliding in from below the stack, so the step is not visible.
class _WonPanelHost extends StatefulWidget {
  const _WonPanelHost({required this.maxHeight, required this.builder});

  final double maxHeight;
  final Widget Function(PanelDensity density) builder;

  @override
  State<_WonPanelHost> createState() => _WonPanelHostState();
}

class _WonPanelHostState extends State<_WonPanelHost> {
  final GlobalKey _panelKey = GlobalKey(debugLabel: 'play.panel');
  PanelDensity _density = PanelDensity.regular;

  void _fit() {
    if (!mounted || !widget.maxHeight.isFinite) return;
    final box = _panelKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    if (box.size.height > widget.maxHeight + 0.5 &&
        _density != PanelDensity.tight) {
      setState(() {
        _density = _density == PanelDensity.regular
            ? PanelDensity.compact
            : PanelDensity.tight;
      });
    } else if (box.size.height > widget.maxHeight + 0.5) {
      debugPrint(
        'play: completion panel ${box.size.height.toStringAsFixed(1)} pt '
        'exceeds the ${widget.maxHeight.toStringAsFixed(1)} pt cap even at '
        'tight density (ui-design §16.3 — Needs Tech Lead Clarification)',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    return KeyedSubtree(key: _panelKey, child: widget.builder(_density));
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
  const _DividerGlow({super.key});

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
