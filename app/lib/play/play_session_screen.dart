import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'
    show SchedulerBinding, SchedulerPhase, Ticker;
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
import '../rating/rating_strings.dart';
import '../rating/result_model.dart';
import '../reduce_motion.dart';
import 'play_layout.dart';
import 'play_session_args.dart';
import 'play_session_controller.dart';
import 'play_session_providers.dart';
import 'play_strings.dart';
import 'widgets/lime_glow.dart';
import 'widgets/puzzle_board.dart';
import 'widgets/result_view.dart';
import 'widgets/target_rail.dart';
import 'widgets/travelling_tile.dart';
import 'win_timeline.dart';

/// Route `'/play'` (`architecture.md` §13). Resolves the puzzle + validator,
/// then hands off to [_LoadedPlaySession] which owns the [PlaySessionController]
/// and the lifecycle observer.
///
/// Every non-`won` state is the Loop Glass Play (F03 `ui-design.md` §1–§14,
/// architecture §19, Phase D1); `won` is the win sequence, the board → result
/// transition and the full-screen result (§16, architecture §20, Phase D2).
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

  /// F05 — the result's `Next Level` handler (`architecture.md §8`). `pushReplacement` to N+1, or `/` (→ terminal) when
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
        builder: (context, _) => _PlayBody(
          controller: c,
          strings: strings,
          layout: layout,
          level: widget.args.journeyLevel,
          onNextLevel: onNext,
          tutorial: _showColumnTutorial
              ? ColumnTutorialOverlay(
                  controller: c,
                  strings: JourneyStrings.of(c.lang),
                  layout: layout,
                  onSatisfied: _onColumnTutorialSatisfied,
                )
              : null,
        ),
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
    this.tutorial,
  });

  final PlaySessionController controller;
  final PlayStrings strings;
  final PlayLayout layout;

  /// The Journey level number for the header label; `null` for the debug set
  /// (and Daily later) — the chevron alone (§19.8 (5)).
  final int? level;
  final VoidCallback? onNextLevel;

  /// F05's column tutorial overlay (a `Positioned.fill`), or `null`. It
  /// belongs to the Play chrome: it dims and fades with it in `won`
  /// (`ui-design.md` §16.5 "Tutorial active at T0").
  final Widget? tutorial;

  @override
  State<_PlayBody> createState() => _PlayBodyState();
}

/// The winning row captured at `T0` — its index, letters and board faces — so
/// the travelling row and the result never read the controller after Retry
/// has restarted it.
class _WonSnapshot {
  const _WonSnapshot({
    required this.row,
    required this.letters,
    required this.faces,
  });

  final int row;
  final List<String> letters;
  final List<TileState> faces;
}

TileState _faceOf(TileStatus status) => switch (status) {
  TileStatus.locked => TileState.locked,
  TileStatus.frozen => TileState.frozen,
  TileStatus.normal || TileStatus.thawed => TileState.normal,
};

/// The `won` orchestrator (F03 architecture §20.3, `ui-design.md` §16.4–§16.5):
/// the Play surface, the win sequence on the board, the board → result
/// transition and the full-screen [ResultView], plus the retry transition back
/// into Play. [WinTimeline] and [RetryTimeline] drive every piece from one
/// controller each; the result is an in-screen state of `/play` (no route).
///
/// Persistence and controller timing are untouched: the controller writes the
/// completion at `won` (§20.3 (3)); this widget only presents it.
class _PlayBodyState extends State<_PlayBody>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// The win clock, 0 → 1 over [WinTimeline.total]. It is driven by
  /// [_winTicker] from `T0` itself — the settle frame's timestamp — not from
  /// the ticker's first tick one frame later, so every window of the timeline
  /// (the T0 + 600 rule, rest at 940) holds on the real frame clock.
  late final AnimationController _win = AnimationController(vsync: this);
  late final Ticker _winTicker = createTicker(_onWinTick);
  Duration? _t0;

  // `preserve`: under OS reduced motion the default `normal` behaviour would
  // collapse the duration to ~5 %, defeating the reduced path's dip.
  late final AnimationController _retry = AnimationController(
    vsync: this,
    duration: RetryTimeline.regular.total,
    animationBehavior: AnimationBehavior.preserve,
  );

  /// Loading → loaded (§5): the skeleton cross-fades to the tiles and the
  /// rail, `HAMLE` card and HUD fade in over 160 ms; instant when reduced.
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );

  final GlobalKey _stackKey = GlobalKey(debugLabel: 'play.stack');
  final GlobalKey _slotKey = GlobalKey(debugLabel: 'result.slot');

  WinTimeline _tl = WinTimeline.regular;
  RetryTimeline _rt = RetryTimeline.regular;
  _WonSnapshot? _snap;

  /// The result as it was at the Retry tap, and where its answer tiles were —
  /// the retry transition plays them out after the controller has restarted.
  ResultModel? _retryModel;
  List<Rect>? _flightFrom;
  late PlaySessionPhase _lastPhase;

  PlaySessionController get _c => widget.controller;

  double get _winMs => _win.value * _tl.endMs;
  double get _retryMs => _retry.value * _rt.restMs;

  /// The retry transition is running (the controller is already `idle`).
  bool get _retrying => _snap != null && _c.phase != PlaySessionPhase.won;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastPhase = _c.phase;
    _c.addListener(_onController);
    // Rest is the frame the retry clock reaches its end — not the
    // `completed` status, which an `AnimationController` reports one frame
    // later.
    _retry.addListener(() {
      if (_retry.value >= 1 && _retryModel != null && mounted) {
        setState(() {
          _snap = null;
          _retryModel = null;
          _flightFrom = null;
          _win.value = 0;
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
    WidgetsBinding.instance.removeObserver(this);
    _c.removeListener(_onController);
    _winTicker.dispose();
    _win.dispose();
    _retry.dispose();
    _appear.dispose();
    super.dispose();
  }

  /// Backgrounded mid-sequence → the sequence resolves to its rest state
  /// (architecture §12, §20.3 (2)); the same for a retry in flight.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    if (_winTicker.isActive) {
      _winTicker.stop();
      _win.value = 1;
    }
    if (_retry.isAnimating) _retry.value = 1;
  }

  /// Starts the win clock at `T0`: the current frame when the settle lands in
  /// one (it always does in play — the shift completes on a frame tick),
  /// otherwise the next frame.
  void _startWinClock() {
    final binding = SchedulerBinding.instance;
    _t0 = binding.schedulerPhase == SchedulerPhase.idle
        ? null
        : binding.currentFrameTimeStamp;
    _win.value = 0;
    _winTicker
      ..stop()
      ..start();
  }

  void _onWinTick(Duration elapsed) {
    final now = SchedulerBinding.instance.currentFrameTimeStamp;
    final t0 = _t0 ??= now;
    final ms = (now - t0).inMicroseconds / 1000;
    _win.value = (ms / _tl.endMs).clamp(0.0, 1.0);
    if (ms >= _tl.endMs) _winTicker.stop();
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
    _tl = WinTimeline.forReduceMotion(reduceMotionRequested());
    final row = _c.wonRow ?? 0;
    _snap = _WonSnapshot(
      row: row,
      letters: List<String>.of(_c.displayLetters[row]),
      faces: <TileState>[for (final s in _c.tileStatuses[row]) _faceOf(s)],
    );
    _retry.value = 0;
    _retryModel = null;
    _flightFrom = null;
    if (animate) {
      _startWinClock();
      if (mounted) setState(() {});
    } else {
      _win.value = 1; // restored straight into `won`: at rest, no replay
    }
  }

  /// "Tekrar oyna": freeze what the result shows, then restart in place. The
  /// controller's listener starts the retry transition.
  void _onRetry() {
    if (_c.phase != PlaySessionPhase.won) return;
    _retryModel = _model();
    _flightFrom = _slotTiles();
    _c.retryFromCompletion();
  }

  void _leaveWon() {
    _rt = RetryTimeline.forReduceMotion(reduceMotionRequested());
    _retry.duration = _rt.total;
    _winTicker.stop();
    _retry.forward(from: 0);
    if (mounted) setState(() {});
  }

  ResultNext get _next {
    if (widget.onNextLevel == null) return ResultNext.none;
    final n = widget.level;
    if (n != null &&
        nextJourneyLevel(n, manifestLevelCount: journeyLevelCount) == null) {
      return ResultNext.terminal;
    }
    return ResultNext.next;
  }

  ResultModel _model() => ResultModel.from(
    completion: _c.completion,
    ratingResolved: _c.ratingResolved,
    targetWord: _c.targetWord,
    moveCount: _c.moveCount,
    next: _next,
  );

  // --- geometry (stack-local; the stack spans the screen) ---------------------

  Rect _boardCell(int row, int col) {
    final layout = widget.layout;
    return layout.board.cellRect(row, col).shift(layout.boardRect.topLeft);
  }

  /// The result's answer tiles as laid out (scroll offset 0), or `null`
  /// before the result has a size.
  List<Rect>? _slotTiles() {
    final slot = _slotKey.currentContext?.findRenderObject();
    final stack = _stackKey.currentContext?.findRenderObject();
    final snap = _snap;
    if (slot is! RenderBox || stack is! RenderBox || snap == null) return null;
    if (!slot.hasSize || !slot.attached || !stack.attached) return null;
    final s = widget.layout.s;
    final topLeft = stack.globalToLocal(slot.localToGlobal(Offset.zero));
    final n = snap.letters.length;
    final w = TileFace.answerWidthRef * s;
    final h = TileFace.answerHeightRef * s;
    final gap = ResultView.tilesGapRef * s;
    final rowWidth = n * w + (n - 1) * gap;
    final left = topLeft.dx + (slot.size.width - rowWidth) / 2;
    return <Rect>[
      for (var i = 0; i < n; i++)
        Rect.fromLTWH(left + i * (w + gap), topLeft.dy, w, h),
    ];
  }

  /// The goal rail's tiles (`TargetRail`: 36 × 42·s, 8·s apart, centred).
  Rect _railTile(int i, int n) {
    final layout = widget.layout;
    final s = layout.s;
    final w = 36 * s;
    final gap = 8 * s;
    final left = (layout.screen.width - (n * w + (n - 1) * gap)) / 2;
    return Rect.fromLTWH(left + i * (w + gap), layout.railTop, w, 42 * s);
  }

  // --- build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final won = c.phase == PlaySessionPhase.won;
    final retrying = _retrying;
    return Stack(
      key: _stackKey,
      children: <Widget>[
        _buildPlay(context, won: won, retrying: retrying),
        if (won && !_tl.reduceMotion) _buildBloom(),
        if (won || retrying) _buildResult(context, won: won),
        if (won || retrying) _buildTravellingRow(won: won),
      ],
    );
  }

  /// Play — header, `HAMLE`, goal, board, HUD and the tutorial — as one group:
  /// it dims with the win sequence and fades out by 720 (chrome), then
  /// leaves the tree's paint and semantics; on Retry it fades back in on the
  /// restarted grid (160–360).
  Widget _buildPlay(
    BuildContext context, {
    required bool won,
    required bool retrying,
  }) {
    final c = widget.controller;
    final strings = widget.strings;
    final layout = widget.layout;
    final snap = _snap;

    // `HAMLE` changes at the settle, not at release (§5): the engine applies
    // the move when the shift starts.
    final moves = c.phase == PlaySessionPhase.animatingShift
        ? c.moveCount - 1
        : c.moveCount;
    // The HUD keeps its look through a drag, a settle and the win sequence
    // (the controller drops a press while input is locked).
    final undoEnabled = c.undosRemaining > 0 && moves > 0;
    // During the retry flight the answer row *is* the rail until rest.
    final railTiles = retrying && !_rt.reduceMotion ? 0.0 : 1.0;

    final board = Positioned.fromRect(
      rect: layout.boardRect,
      child: AnimatedBuilder(
        animation: _retry,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, retrying ? _rt.boardRise(_retryMs) * layout.s : 0),
          child: child,
        ),
        child: RepaintBoundary(
          child: Semantics(
            label:
                '${strings.boardSemantics}. '
                '${strings.targetSemantics}: ${c.targetWord}. '
                '${strings.movesLabel}: $moves.',
            child: PuzzleBoard(
              controller: c,
              geometry: layout.board,
              hiddenRow: won ? snap?.row : null,
              appear: _appear,
            ),
          ),
        ),
      ),
    );

    final play = Stack(
      children: <Widget>[
        // Header — back + level, `HAMLE` card.
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
        // Goal — `HEDEF DÖNGÜ` + the rail tiles.
        Positioned(
          left: 0,
          right: 0,
          top: layout.captionTop,
          child: FadeTransition(
            opacity: _appear,
            child: TargetRail(
              label: strings.targetLabel,
              word: c.targetWord,
              semanticsLabel: '${strings.targetSemantics}: ${c.targetWord}',
              tileOpacity: railTiles,
            ),
          ),
        ),
        board,
        // HUD — undo pill (quota dots) left, restart right; nothing between.
        Positioned.fromRect(
          rect: layout.undoRect,
          child: FadeTransition(
            opacity: _appear,
            child: UndoPill(
              quota: c.undosRemaining,
              onPressed: undoEnabled ? c.undo : null,
              semanticLabel: strings.undoTooltip,
            ),
          ),
        ),
        Positioned(
          left: layout.restartRect.left,
          top: layout.restartRect.top,
          child: FadeTransition(
            opacity: _appear,
            child: GlassIconButton(
              icon: LoopIcon.restart,
              onPressed: c.restart,
              semanticLabel: strings.restartTooltip,
            ),
          ),
        ),
        if (widget.tutorial != null) widget.tutorial!,
      ],
    );

    final locked = won || retrying;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: locked,
        child: ExcludeSemantics(
          excluding: locked,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_win, _retry]),
            builder: (context, child) {
              final double opacity;
              if (won) {
                opacity = _tl.chrome(_winMs);
              } else if (retrying) {
                opacity = _rt.playIn(_retryMs);
              } else {
                opacity = 1;
              }
              // Gone at rest: nothing of Play paints or ticks (the tutorial
              // ghost loops) behind the result.
              final gone = won && opacity == 0 && _winMs > 0;
              return Offstage(
                offstage: gone,
                child: TickerMode(
                  enabled: !gone,
                  child: Opacity(opacity: opacity, child: child),
                ),
              );
            },
            child: play,
          ),
        ),
      ),
    );
  }

  /// The single bloom at the row's board position (100–450, out by 720).
  Widget _buildBloom() {
    final snap = _snap;
    if (snap == null) return const SizedBox.shrink();
    final layout = widget.layout;
    final s = layout.s;
    final g = layout.board;
    final rowTop = _boardCell(snap.row, 0).top;
    return Positioned(
      left: layout.boardRect.left,
      width: layout.boardRect.width,
      top: rowTop - 22 * s,
      height: g.tile + 44 * s,
      child: AnimatedBuilder(
        animation: _win,
        builder: (context, _) {
          final o = _tl.bloom(_winMs);
          if (o <= 0) return const SizedBox.shrink();
          return Opacity(opacity: o, child: const LimeGlow.bloom());
        },
      ),
    );
  }

  Widget _buildResult(BuildContext context, {required bool won}) {
    final c = widget.controller;
    final snap = _snap;
    if (snap == null) return const SizedBox.shrink();
    final model = won ? _model() : _retryModel;
    if (model == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_win, _retry]),
        builder: (context, _) {
          final ms = _winMs;
          if (won && ms < _tl.resultMountMs) return const SizedBox.shrink();
          return ResultView(
            model: model,
            letters: snap.letters,
            strings: widget.strings,
            rating: RatingStrings.of(c.lang),
            layout: widget.layout,
            motion: won
                ? ResultMotion.win(_tl, ms)
                : ResultMotion.retry(_rt, _retryMs),
            slotKey: _slotKey,
            interactive: won && _tl.atRest(ms),
            onBack: () => _popToCaller(context),
            onRetry: _onRetry,
            onNext: widget.onNextLevel,
          );
        },
      ),
    );
  }

  /// The answer row while it travels: filling lime on its board cells
  /// (0–210), gliding to the result slot as one unit (600–840) — or, on
  /// Retry, flying into the goal rail (0–300, held on the rail to rest).
  Widget _buildTravellingRow({required bool won}) {
    final snap = _snap;
    if (snap == null) return const SizedBox.shrink();
    final layout = widget.layout;
    final s = layout.s;
    final g = layout.board;
    final n = snap.letters.length;
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_win, _retry]),
            builder: (context, _) {
              if (won) {
                final ms = _winMs;
                if (!_tl.overlayRow(ms)) return const SizedBox.shrink();
                final glide = _tl.glide(ms);
                final to = glide > 0 ? _slotTiles() : null;
                final t = to == null ? 0.0 : glide;
                final tiles = <Widget>[
                  for (var i = 0; i < n; i++)
                    Positioned.fromRect(
                      rect: Rect.lerp(
                        _boardCell(snap.row, i),
                        to?[i] ?? _boardCell(snap.row, i),
                        t,
                      )!,
                      child: TravellingTile.win(
                        letter: snap.letters[i],
                        base: snap.faces[i],
                        fill: _tl.fill(ms, i),
                        width: _lerp(g.tile, TileFace.answerWidthRef * s, t),
                        height: _lerp(g.tile, TileFace.answerHeightRef * s, t),
                        radius: _lerp(
                          g.tile * LoopRadii.tileFraction,
                          TileFace.answerRadiusRef * s,
                          t,
                        ),
                        glyph: _lerp(
                          g.tile * 0.38,
                          TileFace.answerGlyphRef * s,
                          t,
                        ),
                      ),
                    ),
                ];
                return Opacity(
                  opacity: _tl.overlayRowOpacity(ms).clamp(0.0, 1.0),
                  child: Stack(children: tiles),
                );
              }
              final ms = _retryMs;
              final from = _flightFrom;
              if (!_rt.flying(ms) || from == null) {
                return const SizedBox.shrink();
              }
              final t = _rt.flight(ms);
              return Stack(
                children: <Widget>[
                  for (var i = 0; i < n; i++)
                    Positioned.fromRect(
                      rect: Rect.lerp(from[i], _railTile(i, n), t)!,
                      child: TravellingTile.flight(
                        letter: snap.letters[i],
                        lime: _rt.flightLime(ms),
                        width: _lerp(TileFace.answerWidthRef * s, 36 * s, t),
                        height: _lerp(TileFace.answerHeightRef * s, 42 * s, t),
                        radius: _lerp(TileFace.answerRadiusRef * s, 14 * s, t),
                        glyph: _lerp(TileFace.answerGlyphRef * s, 16.5 * s, t),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
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
