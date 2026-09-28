import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:looplet_core/looplet_core.dart' show TileStatus;

import '../app_router.dart';
import '../design/design.dart';
import '../journey/column_tutorial_overlay.dart';
import '../journey/journey_content.dart';
import '../journey/journey_nav.dart';
import '../journey/journey_strings.dart';
import '../journey/journey_tutorial.dart';
import '../persistence/persistence_providers.dart';
import '../rating/completion_panel.dart';
import '../rating/completion_result.dart';
import '../rating/rating_strings.dart';
import '../reduce_motion.dart';
import 'play_layout.dart';
import 'play_session_args.dart';
import 'play_session_controller.dart';
import 'play_session_providers.dart';
import 'play_strings.dart';
import 'play_theme.dart';
import 'won_composition.dart';
import 'widgets/docked_row.dart';
import 'widgets/puzzle_board.dart';
import 'widgets/target_rail.dart';

/// Route `'/play'` (`architecture.md` §13). Resolves the puzzle + validator,
/// then hands off to [_LoadedPlaySession] which owns the [PlaySessionController]
/// and the lifecycle observer.
///
/// Every non-`won` state is the Loop Glass Play (F03 `ui-design.md` §1–§14,
/// architecture §19, Phase D1); the `won` moment keeps its shipped look until
/// Phase D2 (§16).
class PlaySessionScreen extends ConsumerWidget {
  const PlaySessionScreen({required this.args, super.key});

  final PlaySessionArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(playSessionSetupProvider(args));
    final strings = PlayStrings.of('tr');
    return setup.when(
      loading: () => _PlayScaffold(
        builder: (context, layout) => _LoadingView(
          layout: layout,
          strings: strings,
          level: args.journeyLevel,
          onBack: () => _popToCaller(context),
        ),
      ),
      error: (error, _) => _PlayScaffold(
        builder: (context, layout) => _LoadErrorView(
          layout: layout,
          strings: strings,
          level: args.journeyLevel,
          onBack: () => _popToCaller(context),
          onHome: () => context.go(Routes.home),
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

/// The Play ground: `LoopBackdrop` edge to edge, light status-bar content, no
/// system header. Every Play state lays out in screen coordinates from one
/// [PlayLayout], with [LoopScale] set to its `s` so the design components use
/// the same scale.
class _PlayScaffold extends StatelessWidget {
  const _PlayScaffold({required this.builder});

  final Widget Function(BuildContext context, PlayLayout layout) builder;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: LoopColors.groundBottom,
        body: LoopBackdrop(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = PlayLayout(constraints.biggest);
              return LoopScale(
                value: layout.s,
                child: Builder(builder: (context) => builder(context, layout)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The header's back control: the chevron plus `SEVİYE NN` (the chevron alone
/// without a level number — §19.8 (5)), one ≥ 44 pt control.
Widget _backControl({
  required PlayLayout layout,
  required PlayStrings strings,
  required int? level,
  required bool showLabel,
  required VoidCallback onPressed,
}) {
  return Positioned(
    left: layout.backHitLeft,
    top: layout.backHitTop,
    child: LoopBackButton(
      label: showLabel && level != null ? strings.levelLabel(level) : null,
      semanticLabel: strings.backSemantics(level),
      padding: EdgeInsets.only(left: layout.backHitInset, right: 8),
      onPressed: onPressed,
    ),
  );
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
  bool _tutorialSatisfied = false;
  Timer? _tutorialExit;

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

  /// The gated column move was committed: persist the ack now; the overlay
  /// fades out and is removed after its exit (at once under reduced motion).
  void _onColumnTutorialSatisfied() {
    if (_tutorialSatisfied) return;
    _tutorialSatisfied = true;
    if (reduceMotionRequested()) {
      setState(() => _showColumnTutorial = false);
    } else {
      _tutorialExit = Timer(ColumnTutorialOverlay.exitDuration, () {
        if (mounted) setState(() => _showColumnTutorial = false);
      });
    }
    unawaited(_persistColumnTutorialAck());
  }

  Future<void> _persistColumnTutorialAck() async {
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
    _tutorialExit?.cancel();
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
    if (c == null) {
      return _PlayScaffold(
        builder: (context, layout) => _LoadingView(
          layout: layout,
          strings: PlayStrings.of(_lang),
          level: widget.args.journeyLevel,
          onBack: () => _popToCaller(context),
        ),
      );
    }

    final strings = PlayStrings.of(c.lang);
    final onNext = _nextLevelHandler();
    return _PlayScaffold(
      builder: (context, layout) => AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          final won = c.phase == PlaySessionPhase.won;
          return Stack(
            children: <Widget>[
              _PlayBody(
                controller: c,
                strings: strings,
                layout: layout,
                level: widget.args.journeyLevel,
                onNextLevel: onNext,
              ),
              if (_showColumnTutorial && !won)
                ColumnTutorialOverlay(
                  controller: c,
                  strings: JourneyStrings.of(c.lang),
                  layout: layout,
                  onSatisfied: _onColumnTutorialSatisfied,
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
    required this.layout,
    required this.level,
    this.onNextLevel,
  });

  final PlaySessionController controller;
  final PlayStrings strings;
  final PlayLayout layout;

  /// The Journey level number for the header label; `null` for the debug set
  /// (and Daily later) — the chevron alone (§19.8 (5)).
  final int? level;
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

/// Measured layout the won moment needs (won-stack-local px), see
/// [WonGeometry].
class _WonMetrics {
  const _WonMetrics({
    required this.rowLeft,
    required this.homeTop,
    required this.tile,
    required this.gap,
    required this.geometry,
  });

  final double rowLeft;
  final double homeTop;
  final double tile;
  final double gap;
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

  /// Loading → loaded (§5): the skeleton cross-fades to the tiles and the
  /// rail, `HAMLE` card and HUD fade in over 160 ms; instant when reduced.
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );

  final GlobalKey _stackKey = GlobalKey(debugLabel: 'play.wonStack');
  final GlobalKey _boardKey = GlobalKey(debugLabel: 'play.board');
  final GlobalKey _railKey = GlobalKey(debugLabel: 'play.rail');

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
    if (reduceMotionRequested()) {
      _appear.value = 1;
    } else {
      _appear.forward();
    }
    if (_c.phase == PlaySessionPhase.won) {
      _enterWon(animate: false);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onController);
    _timeline.dispose();
    _retire.dispose();
    _appear.dispose();
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
    final reduceMotion = reduceMotionRequested();
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
  /// until the board / rail / won stack have a size.
  _WonMetrics? _measure(BuildContext context) {
    final stack = _stackKey.currentContext?.findRenderObject();
    final board = _boardKey.currentContext?.findRenderObject();
    final rail = _railKey.currentContext?.findRenderObject();
    if (stack is! RenderBox || board is! RenderBox || rail is! RenderBox) {
      return null;
    }
    if (!stack.hasSize || !board.hasSize || !rail.hasSize) return null;
    if (!stack.attached || !board.attached || !rail.attached) return null;
    final snap = _snap;
    if (snap == null) return null;

    final stackTop = stack.localToGlobal(Offset.zero).dy;
    final boardTopLeft = stack.globalToLocal(board.localToGlobal(Offset.zero));
    final g = BoardGeometry.forWidth(board.size.width, gridSize: _c.gridSize);
    // The rail tiles: the bottom 42·s of the rail widget.
    final railBottom = stack
        .globalToLocal(rail.localToGlobal(Offset(0, rail.size.height)))
        .dy;
    final railTop = railBottom - TargetRail.tilesHeightRef * g.s;
    final home = boardTopLeft + g.cellOrigin(snap.row, 0);
    return _WonMetrics(
      rowLeft: home.dx,
      homeTop: home.dy,
      tile: g.tile,
      gap: g.gap,
      geometry: WonGeometry.compute(
        screenHeight: MediaQuery.sizeOf(context).height,
        stackTopGlobal: stackTop,
        stackBottomGlobal: stackTop + stack.size.height,
        railTopLocal: railTop,
        railBottomLocal: railBottom,
        tile: g.tile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final strings = widget.strings;
    final layout = widget.layout;
    final won = c.phase == PlaySessionPhase.won;
    final retiring = !won && _snap != null && _retire.isAnimating;

    // `HAMLE` changes at the settle, not at release (§5): the engine applies
    // the move when the shift starts.
    final moves = c.phase == PlaySessionPhase.animatingShift
        ? c.moveCount - 1
        : c.moveCount;
    // The HUD keeps its look through a drag and a settle (the controller
    // still drops a press while input is locked); it dims to 40 % in `won`
    // (§16.2, unchanged).
    final undoEnabled = !won && c.undosRemaining > 0 && moves > 0;
    final hudOpacity = won ? PlayTheme.wonControlsOpacity : 1.0;

    return Stack(
      children: <Widget>[
        // Header — back + level (hidden from T0, §16), `HAMLE` card.
        if (!won)
          _backControl(
            layout: layout,
            strings: strings,
            level: widget.level,
            showLabel: true,
            onPressed: () => _popToCaller(context),
          ),
        Positioned(
          left: layout.movesCard.dx,
          top: layout.movesCard.dy,
          child: FadeTransition(
            opacity: _appear,
            child: MovesCard(moves: moves, label: strings.movesLabel),
          ),
        ),
        // Goal — `HEDEF DÖNGÜ` + the rail tiles. In `won` the answer row
        // docks onto the tiles, which fade out beneath it (and back on Retry).
        Positioned(
          left: 0,
          right: 0,
          top: layout.captionTop,
          child: FadeTransition(
            opacity: _appear,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[_timeline, _retire]),
              builder: (context, _) => TargetRail(
                key: _railKey,
                label: strings.targetLabel,
                word: c.targetWord,
                semanticsLabel: '${strings.targetSemantics}: ${c.targetWord}',
                tileOpacity: (won || retiring) && _snap != null
                    ? 1 -
                          _tl.dock(_timeline.value) *
                              (won ? 1 : 1 - _retire.value)
                    : 1,
              ),
            ),
          ),
        ),
        // The board card.
        Positioned.fromRect(
          rect: layout.boardRect,
          child: Semantics(
            label:
                '${strings.boardSemantics}. '
                '${strings.targetSemantics}: ${c.targetWord}. '
                '${strings.movesLabel}: $moves.',
            // §16: the board hands its winning row to the dock overlay from
            // the moment the dock begins (ghost outlines).
            child: AnimatedBuilder(
              animation: _timeline,
              builder: (context, _) => PuzzleBoard(
                key: _boardKey,
                controller: c,
                geometry: layout.board,
                rowVacated: won && _tl.dockStarted(_timeline.value),
                appear: _appear,
              ),
            ),
          ),
        ),
        // HUD — undo pill (quota dots) left, restart right; nothing between.
        Positioned.fromRect(
          rect: layout.undoRect,
          child: FadeTransition(
            opacity: _appear,
            child: AnimatedOpacity(
              opacity: hudOpacity,
              duration: const Duration(milliseconds: 160),
              child: UndoPill(
                quota: c.undosRemaining,
                onPressed: undoEnabled ? c.undo : null,
                semanticLabel: strings.undoTooltip,
              ),
            ),
          ),
        ),
        Positioned(
          left: layout.restartRect.left,
          top: layout.restartRect.top,
          child: FadeTransition(
            opacity: _appear,
            child: AnimatedOpacity(
              opacity: hudOpacity,
              duration: const Duration(milliseconds: 160),
              child: GlassIconButton(
                icon: LoopIcon.restart,
                onPressed: won ? null : c.restart,
                semanticLabel: strings.restartTooltip,
              ),
            ),
          ),
        ),
        // The won moment (§16) — scrim, docked row, F04 panel — in the safe
        // area, exactly as shipped.
        Positioned.fill(
          child: SafeArea(
            child: Stack(
              key: _stackKey,
              children: <Widget>[
                if (won || retiring) _buildWonLayers(context, won: won),
              ],
            ),
          ),
        ),
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
                      gap: metrics.gap,
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
/// height exceeds [maxHeight] (`0.64 H`, or less under the D1 floor — see
/// [WonGeometry]), step the density (compact → tight) on the next frame.
/// Layout is measured after the fact, while the panel is still sliding in from
/// below the stack, so the step is not visible.
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

/// Loading (§8, `D1-11`): the header with its level and the board card with 25
/// glass cells at the final geometry — no rail, `HAMLE` card, HUD or spinner,
/// so nothing jumps when the puzzle arrives. "Yükleniyor" is announced if it
/// lasts more than 300 ms.
class _LoadingView extends StatefulWidget {
  const _LoadingView({
    required this.layout,
    required this.strings,
    required this.level,
    required this.onBack,
  });

  final PlayLayout layout;
  final PlayStrings strings;
  final int? level;
  final VoidCallback onBack;

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> {
  Timer? _announceTimer;
  bool _announce = false;

  @override
  void initState() {
    super.initState();
    _announceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _announce = true);
    });
  }

  @override
  void dispose() {
    _announceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;
    final g = layout.board;
    return Stack(
      children: <Widget>[
        _backControl(
          layout: layout,
          strings: widget.strings,
          level: widget.level,
          showLabel: true,
          onPressed: widget.onBack,
        ),
        Positioned.fromRect(
          rect: layout.boardRect,
          child: Semantics(
            label: _announce ? widget.strings.loading : null,
            liveRegion: _announce,
            child: SizedBox(
              width: g.width,
              height: g.height,
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(
                    child: BoardCard(child: SizedBox.expand()),
                  ),
                  for (var r = 0; r < g.gridSize; r++)
                    for (var c = 0; c < g.gridSize; c++)
                      Positioned.fromRect(
                        rect: g.cellRect(r, c),
                        child: SkeletonCell(size: g.tile),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Load error (§8, `D1-07`): the chevron, and one calm glass card — the level,
/// the drawn `loopBreak` glyph, "Bu bulmaca yüklenemedi." — over one lime way
/// home. No red, no raw exception. The column scrolls if the OS text size ever
/// makes it taller than the band; the pill label follows the OS scale to AX5,
/// the headline role is capped at 1.3× (architecture §19.3 (1)).
class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({
    required this.layout,
    required this.strings,
    required this.level,
    required this.onBack,
    required this.onHome,
  });

  final PlayLayout layout;
  final PlayStrings strings;
  final int? level;
  final VoidCallback onBack;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final s = layout.s;
    final bandTop = 140 * s;
    final bandBottom = layout.screen.height - 40 * s;
    final capped = loopCappedTextScaler(context);
    return Stack(
      children: <Widget>[
        // The chevron alone — the level is on the card.
        _backControl(
          layout: layout,
          strings: strings,
          level: null,
          showLabel: false,
          onPressed: onBack,
        ),
        Positioned(
          left: layout.left + 24.5 * s,
          width: 309 * s,
          top: bandTop,
          height: bandBottom - bandTop,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GlassCard(
                      radius: 30,
                      padding: EdgeInsets.fromLTRB(
                        26 * s,
                        28 * s,
                        26 * s,
                        32 * s,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: level == null
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: EdgeInsets.only(top: 4 * s),
                                        child: ExcludeSemantics(
                                          child: Text(
                                            strings.levelLabel(level!),
                                            style: LoopText.caption(s),
                                            textScaler: capped,
                                          ),
                                        ),
                                      ),
                              ),
                              Opacity(
                                opacity: 0.9,
                                child: LoopIconView(
                                  LoopIcon.loopBreak,
                                  color: LoopColors.periwinkle,
                                  size: 44 * s,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18 * s),
                          // The card's full inner width (257·s): at the 1.3×
                          // cap the last word needs more than the render's
                          // 230·s column, which broke off its full stop
                          // (F03 architecture §19.10 (2), F03-QA-D1-02).
                          Text(
                            strings.loadFailed,
                            style: LoopText.headline(s),
                            textScaler: capped,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    LimePill(
                      label: strings.backHome,
                      onPressed: onHome,
                      icon: null,
                      height: 63 * s,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
