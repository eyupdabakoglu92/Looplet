import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looplet_core/looplet_core.dart'
    show MoveAxis, MoveDirection, TileStatus;

import '../../design/design.dart';
import '../../reduce_motion.dart';
import '../play_layout.dart';
import '../play_session_controller.dart';
import '../play_theme.dart';
import 'board_tile.dart';

/// The hero (F03 `ui-design.md` §5–§9, Loop Glass, Phase D1): the 5×5 board in
/// its [BoardCard] with cream [TileFace]s; the lifted active line (periwinkle
/// rim + glow, [LineRail]s at the card edges, the rest of the board at 42 %);
/// the wrap ghost; the rejected-move bounce; the thaw cross-fade; and — for the
/// `won` moment only — the legacy amber row, seam and bloom (§16, until D2).
///
/// The [controller] is the state-machine authority; this widget owns only the
/// `AnimationController`s and calls [PlaySessionController.commitShift] /
/// [PlaySessionController.commitBounce] when a transition animation settles.
/// The drag logic (gesture → move) is unchanged.
class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    required this.controller,
    required this.geometry,
    this.rowVacated = false,
    this.appear,
    super.key,
  });

  final PlaySessionController controller;
  final BoardGeometry geometry;

  /// F03 `ui-design.md` §16: while `won`, once the winning row has lifted off to
  /// its dock, its home cells show a faint amber outline ("ghost") and the
  /// board's own seam bar / bloom stop drawing (the docked overlay carries them).
  final bool rowVacated;

  /// 0 → 1 while the loaded tiles replace the loading skeleton (§5 "loading →
  /// loaded", 160 ms). `null` = fully shown.
  final Animation<double>? appear;

  /// Lift, rails and the rest-of-board dim fade in (ease-out) and out
  /// (ease-in) over 90 ms (§5).
  static const Duration liftDuration = Duration(milliseconds: 90);

  /// The thaw cross-fade (§5, architecture §19.3 (3)).
  static const Duration thawDuration = Duration(milliseconds: 180);
  static const Cubic thawCurve = Cubic(0.2, 0, 0.2, 1);

  /// The rest of the board while a line is lifted.
  static const double restOpacity = 0.42;

  /// The wrap ghost while tracking; it reaches 100 % as the move settles.
  static const double ghostOpacity = 0.30;

  /// The settle overshoots to 101.5 % of the stride at 80 % of its time (§5).
  static const double settleOvershoot = 1.015;
  static const double settleOvershootAt = 0.8;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with TickerProviderStateMixin {
  // `preserve`: the shift and the bounce are state feedback — under OS reduced
  // motion they keep their duration with a plain ease-out (§5), instead of the
  // framework's 5 % speed-up for `disableAnimations`.
  late final AnimationController _shift = AnimationController(
    vsync: this,
    duration: PlayTheme.shiftDuration,
    animationBehavior: AnimationBehavior.preserve,
  );
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: PlayTheme.bounceDuration,
    animationBehavior: AnimationBehavior.preserve,
  );
  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: PlayTheme.winDuration,
  );
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: PuzzleBoard.liftDuration,
  );
  late final CurvedAnimation _liftCurve = CurvedAnimation(
    parent: _lift,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );
  late final AnimationController _thaw = AnimationController(
    vsync: this,
    duration: PuzzleBoard.thawDuration,
  );

  Offset _dragOffset = Offset.zero;
  Offset _shiftFrom = Offset.zero; // drag offset captured at release
  ({int row, int col})? _pressedCell;

  /// Settle / bounce use the reduced path (ease-out, no overshoot) when the OS
  /// asked for reduced motion at release.
  bool _reducedSettle = false;

  /// The line the rim, rails and dim belong to — kept while they fade out
  /// after the settle.
  ActiveLine? _liftLine;

  /// Cells cross-fading from frozen to normal after the settle that thawed them.
  Set<(int, int)> _thawCells = const <(int, int)>{};

  late PlaySessionPhase _lastPhase;
  late int _lastGridVersion;

  PlaySessionController get _c => widget.controller;
  BoardGeometry get _g => widget.geometry;
  int get _size => _c.gridSize;

  @override
  void initState() {
    super.initState();
    _lastPhase = _c.phase;
    _lastGridVersion = _c.gridVersion;
    _c.addListener(_onController);
    _lift.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) _liftLine = null;
    });
    if (_c.phase == PlaySessionPhase.won) _win.value = 1;
  }

  @override
  void dispose() {
    _c.removeListener(_onController);
    _shift.dispose();
    _bounce.dispose();
    _win.dispose();
    _liftCurve.dispose();
    _lift.dispose();
    _thaw.dispose();
    super.dispose();
  }

  void _onController() {
    final phase = _c.phase;
    if (_c.gridVersion != _lastGridVersion) {
      // Undo / restart swap the grid: a running thaw snaps to its end.
      _lastGridVersion = _c.gridVersion;
      _clearThaw();
    }
    if (phase != _lastPhase) {
      if (phase == PlaySessionPhase.won && _lastPhase != PlaySessionPhase.won) {
        // The won moment (§16) takes over: no rim, rails or thaw on top of it.
        _lift.value = 0;
        _liftLine = null;
        _clearThaw();
        // OS reduce-motion: the amber row + seam render static (no bloom).
        if (reduceMotionRequested()) {
          _win.value = 1;
        } else {
          _win.forward(from: 0);
        }
      } else if (phase != PlaySessionPhase.won && _win.value != 0) {
        _win.value = 0;
      }
      _lastPhase = phase;
    }
    _syncLift(phase);
    if (mounted) setState(() {});
  }

  /// Axis recognised → the line lifts (rim, rails, the rest to 42 %) over
  /// 90 ms; released / settled / cancelled → it all fades out over 90 ms.
  /// Reduced motion: instant both ways (§5).
  void _syncLift(PlaySessionPhase phase) {
    if (phase == PlaySessionPhase.won) return;
    final line = _c.activeLine;
    if (line != null && _lineMoving(phase)) {
      _liftLine = line;
      if (_lift.value < 1 && _lift.status != AnimationStatus.forward) {
        if (reduceMotionRequested()) {
          _lift.value = 1;
        } else {
          _lift.forward();
        }
      }
    } else if (_lift.value > 0 && _lift.status != AnimationStatus.reverse) {
      if (reduceMotionRequested()) {
        _lift.value = 0;
      } else {
        _lift.reverse();
      }
    }
  }

  bool _lineMoving(PlaySessionPhase phase) =>
      phase == PlaySessionPhase.tracking ||
      phase == PlaySessionPhase.animatingShift ||
      phase == PlaySessionPhase.animatingBounce;

  // --- gesture ---------------------------------------------------------------

  void _onPanDown(DragDownDetails d) {
    if (_c.inputLocked) return;
    final cell = _g.cellAt(d.localPosition);
    _dragOffset = Offset.zero;
    _pressedCell = cell;
    _c.beginDrag(startRow: cell.row, startCol: cell.col);
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_c.phase != PlaySessionPhase.tracking) return;
    _dragOffset += d.delta;
    _c.updateDrag(_dragOffset);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails d) => _release(_dragOffset);

  /// Only reached when the pointer is cancelled before the pan is accepted
  /// (never resolves a move — the pan slop was not even crossed).
  void _onPanCancel() => _abort();

  /// An OS-level pointer cancel (`PointerCancelEvent`: app switch, system
  /// gesture, call) aborts the drag — no move (`architecture.md` §12,
  /// F03-QA-03). Flutter's pan recogniser reports a cancel of an *accepted*
  /// pan through `onPanEnd`, exactly like a lift-off, so `onPanCancel` alone
  /// cannot tell them apart; this raw listener sees the cancel first (render
  /// listeners run before the gesture arena's pointer router) and drops the
  /// drag, which makes the `onPanEnd` that follows a no-op (phase is no longer
  /// `tracking`). A genuine release — including one outside the plate — is a
  /// `PointerUpEvent` and still resolves through [_release].
  void _onPointerCancel(PointerCancelEvent _) => _abort();

  void _abort() {
    _pressedCell = null;
    _dragOffset = Offset.zero;
    _c.cancelDrag();
    if (mounted) setState(() {});
  }

  void _release(Offset delta) {
    _pressedCell = null;
    if (_c.phase != PlaySessionPhase.tracking) {
      setState(() {});
      return;
    }
    _reducedSettle = reduceMotionRequested();
    final resolution = _c.endDrag(delta);
    switch (resolution) {
      case DragResolution.none:
        _dragOffset = Offset.zero;
        setState(() {});
      case DragResolution.shift:
        _shiftFrom = delta;
        _shift.forward(from: 0).whenComplete(() {
          final before = _c.tileStatuses;
          // The win choreography starts from the controller listener.
          final won = _c.commitShift();
          _dragOffset = Offset.zero;
          _shiftFrom = Offset.zero;
          // A thaw on the winning move gives way to §16 (no cross-fade).
          if (!won) _startThaw(before, _c.tileStatuses);
          if (mounted) setState(() {});
        });
        setState(() {});
      case DragResolution.bounce:
        _shiftFrom = delta;
        _bounce.forward(from: 0).whenComplete(() {
          _c.commitBounce();
          _dragOffset = Offset.zero;
          _shiftFrom = Offset.zero;
          if (mounted) setState(() {});
        });
        setState(() {});
    }
  }

  // --- thaw ------------------------------------------------------------------

  /// Cells frozen before the settle and not after it cross-fade to the normal
  /// tile in 180 ms (instant under reduced motion).
  void _startThaw(List<List<TileStatus>> before, List<List<TileStatus>> after) {
    final cells = <(int, int)>{
      for (var r = 0; r < _size; r++)
        for (var c = 0; c < _size; c++)
          if (before[r][c] == TileStatus.frozen &&
              after[r][c] != TileStatus.frozen)
            (r, c),
    };
    if (cells.isEmpty || reduceMotionRequested() || !mounted) return;
    _thawCells = cells;
    _thaw.forward(from: 0).whenComplete(() {
      if (mounted) setState(_clearThaw);
    });
  }

  void _clearThaw() {
    _thaw.stop();
    _thaw.value = 0;
    _thawCells = const <(int, int)>{};
  }

  bool _thawing(int r, int c) => _thawCells.contains((r, c)) && _thaw.value < 1;

  // --- geometry helpers ----------------------------------------------------

  double _axisDelta(Offset o, MoveAxis axis) =>
      axis == MoveAxis.row ? o.dx : o.dy;

  /// Current translation of the active line, in px along its axis.
  double _lineTranslation(ActiveLine line) {
    final stride = _g.stride;
    final cap = stride * 0.55;
    switch (_c.phase) {
      case PlaySessionPhase.tracking:
        return _axisDelta(_dragOffset, line.axis).clamp(-cap, cap);
      case PlaySessionPhase.animatingShift:
        final target =
            (line.direction == MoveDirection.right ||
                line.direction == MoveDirection.down)
            ? stride
            : -stride;
        final from = _axisDelta(_shiftFrom, line.axis).clamp(-cap, cap);
        return _settle(from, target, _shift.value);
      case PlaySessionPhase.animatingBounce:
        final from = _axisDelta(_shiftFrom, line.axis).clamp(-cap, cap);
        final t = _reducedSettle
            ? Curves.easeOut.transform(_bounce.value)
            : PlayTheme.bounceCurve.transform(_bounce.value);
        return from * (1 - t);
      case PlaySessionPhase.idle:
      case PlaySessionPhase.won:
        return 0;
    }
  }

  /// The settle: `cubic-bezier(.22,1,.36,1)` to 101.5 % of the stride at 80 %
  /// of the time, then back to 100 % (the prototype's keyframes, §5). Reduced
  /// motion: a plain ease-out to the stride.
  double _settle(double from, double target, double v) {
    if (_reducedSettle) {
      return from + (target - from) * Curves.easeOut.transform(v);
    }
    const at = PuzzleBoard.settleOvershootAt;
    final peak = target * PuzzleBoard.settleOvershoot;
    if (v <= at) {
      return from + (peak - from) * PlayTheme.shiftCurve.transform(v / at);
    }
    return peak +
        (target - peak) * PlayTheme.shiftCurve.transform((v - at) / (1 - at));
  }

  /// Wrap-ghost opacity: 30 % while tracking, → 100 % over the settle.
  double _ghostOpacity() {
    if (_c.phase != PlaySessionPhase.animatingShift) {
      return PuzzleBoard.ghostOpacity;
    }
    final t = _reducedSettle
        ? Curves.easeOut.transform(_shift.value)
        : PlayTheme.shiftCurve.transform(_shift.value);
    return PuzzleBoard.ghostOpacity + (1 - PuzzleBoard.ghostOpacity) * t;
  }

  bool _inLine(ActiveLine? line, int r, int c) {
    if (line == null) return false;
    return line.axis == MoveAxis.row ? r == line.index : c == line.index;
  }

  static TileState _stateOf(TileStatus status) => switch (status) {
    TileStatus.locked => TileState.locked,
    TileStatus.frozen => TileState.frozen,
    TileStatus.normal || TileStatus.thawed => TileState.normal,
  };

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[
        _shift,
        _bounce,
        _win,
        _lift,
        _thaw,
        widget.appear,
      ]),
      builder: (context, _) => _buildBoard(context),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final g = _g;
    final phase = _c.phase;
    final line = _c.activeLine;
    final letters = _c.displayLetters;
    final statuses = _c.tileStatuses;
    final wonRow = phase == PlaySessionPhase.won ? _c.wonRow : null;
    final vacated = wonRow != null && widget.rowVacated;
    final lineMoving = line != null && _lineMoving(phase);
    final lift = wonRow == null ? _liftCurve.value : 0.0;
    final liftLine = lineMoving ? line : (lift > 0 ? _liftLine : null);
    final appear = widget.appear?.value ?? 1.0;
    final reduceMotion = reduceMotionRequested();

    Widget at(int r, int c, Widget child) {
      final rect = g.cellRect(r, c);
      return Positioned.fromRect(rect: rect, child: child);
    }

    // Static tiles: every cell outside the lifted line.
    final statics = <Widget>[
      for (var r = 0; r < _size; r++)
        for (var c = 0; c < _size; c++)
          if (!_inLine(liftLine, r, c))
            at(
              r,
              c,
              AnimatedScale(
                scale:
                    (!reduceMotion &&
                        _pressedCell?.row == r &&
                        _pressedCell?.col == c)
                    ? 0.98
                    : 1.0,
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                child: _staticCell(
                  r,
                  c,
                  letters[r][c],
                  statuses[r][c],
                  wonRow: wonRow,
                  vacated: vacated,
                ),
              ),
            ),
    ];

    final restOpacity =
        appear * (1 - (1 - PuzzleBoard.restOpacity) * lift.clamp(0.0, 1.0));

    return Listener(
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onPanCancel: _onPanCancel,
        child: SizedBox(
          width: g.width,
          height: g.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              const Positioned.fill(child: BoardCard(child: SizedBox.expand())),
              // Loading skeleton, cross-fading out as the tiles arrive.
              if (appear < 1)
                for (var r = 0; r < _size; r++)
                  for (var c = 0; c < _size; c++)
                    at(
                      r,
                      c,
                      Opacity(
                        opacity: 1 - appear,
                        child: SkeletonCell(size: g.tile),
                      ),
                    ),
              // The rest of the board, dimmed as one group while a line is
              // lifted (never an `Opacity` over the lifted line itself).
              Positioned.fill(
                child: Opacity(
                  opacity: restOpacity.clamp(0.0, 1.0),
                  child: Stack(clipBehavior: Clip.none, children: statics),
                ),
              ),
              // A settled / returned line whose rim is still fading out.
              if (!lineMoving && liftLine != null)
                Positioned.fill(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: _lineCellsInPlace(
                      liftLine,
                      letters,
                      statuses,
                      lift,
                    ),
                  ),
                ),
              // The moving line (with its wrap ghosts), clipped to the card.
              if (lineMoving)
                Positioned.fill(
                  child: Opacity(
                    opacity: appear,
                    child: _buildMovingLine(line, letters, statuses, lift),
                  ),
                ),
              // Rails at the card edges across the lifted line.
              if (liftLine != null && lift > 0) ..._buildRails(liftLine, lift),
              // Winning seam bar (the docked overlay draws it once vacated).
              if (wonRow != null && !vacated) _buildSeam(wonRow),
              // Win bloom (finished by T0+600, i.e. before the dock).
              if (wonRow != null && !vacated && _win.value > 0)
                _buildBloom(wonRow),
            ],
          ),
        ),
      ),
    );
  }

  /// A cell outside the lifted line, in its current state.
  Widget _staticCell(
    int r,
    int c,
    String letter,
    TileStatus status, {
    required int? wonRow,
    required bool vacated,
  }) {
    final tile = _g.tile;
    if (wonRow != null) {
      // The won moment keeps its shipped look until D2 (§16): the amber
      // winning row (or its ghost slot once docked) on a receded board.
      if (r == wonRow) {
        return vacated
            ? _GhostCell(size: tile)
            : BoardTile(
                letter: letter,
                size: tile,
                status: status,
                winning: true,
              );
      }
      return _Receded(
        radius: tile * LoopRadii.tileFraction,
        child: TileFace(letter: letter, size: tile, state: _stateOf(status)),
      );
    }
    if (_thawing(r, c)) return _thawFace(letter);
    return TileFace(letter: letter, size: tile, state: _stateOf(status));
  }

  /// The thaw at `t`: the normal tile under the frozen face, which fades out
  /// (`cubic-bezier(.2,0,.2,1)`) while its snowflake shrinks 1 → 0.6 (ease-in).
  Widget _thawFace(String letter) {
    final tile = _g.tile;
    final t = _thaw.value;
    return Stack(
      children: <Widget>[
        TileFace(letter: letter, size: tile),
        Opacity(
          opacity: (1 - PuzzleBoard.thawCurve.transform(t)).clamp(0.0, 1.0),
          child: TileFace(
            letter: letter,
            size: tile,
            state: TileState.frozen,
            iconScale: 1 - 0.4 * Curves.easeIn.transform(t),
          ),
        ),
      ],
    );
  }

  /// A tile of the lifted line: the rim, glow and deeper shadow cross-fade in
  /// with [lift]. Pivots (locked, still-frozen) keep their own face — they are
  /// the tiles that stay.
  Widget _liftedFace(String letter, TileStatus status, double lift) {
    final tile = _g.tile;
    final base = _stateOf(status);
    if (base != TileState.normal || lift <= 0) {
      return TileFace(letter: letter, size: tile, state: base);
    }
    if (lift >= 1) {
      return TileFace(letter: letter, size: tile, state: TileState.active);
    }
    return Stack(
      children: <Widget>[
        TileFace(letter: letter, size: tile),
        Opacity(
          opacity: lift,
          child: TileFace(letter: letter, size: tile, state: TileState.active),
        ),
      ],
    );
  }

  List<Widget> _lineCellsInPlace(
    ActiveLine line,
    List<List<String>> letters,
    List<List<TileStatus>> statuses,
    double lift,
  ) {
    final isRow = line.axis == MoveAxis.row;
    final cells = <Widget>[];
    for (var i = 0; i < _size; i++) {
      final r = isRow ? line.index : i;
      final c = isRow ? i : line.index;
      cells.add(
        Positioned.fromRect(
          rect: _g.cellRect(r, c),
          child: _thawing(r, c)
              ? _thawFace(letters[r][c])
              : _liftedFace(letters[r][c], statuses[r][c], lift),
        ),
      );
    }
    return cells;
  }

  Widget _buildMovingLine(
    ActiveLine line,
    List<List<String>> letters,
    List<List<TileStatus>> statuses,
    double lift,
  ) {
    final g = _g;
    final translation = _lineTranslation(line);
    final isRow = line.axis == MoveAxis.row;
    final ghostOpacity = _ghostOpacity();

    // Cells i = -1 .. size (the two wrap ghosts); the clip hides the one on
    // the leading side.
    final children = <Widget>[];
    for (var i = -1; i <= _size; i++) {
      final idx = (i + _size) % _size;
      final r = isRow ? line.index : idx;
      final c = isRow ? idx : line.index;
      final isGhost = i < 0 || i >= _size;
      final origin = isRow
          ? g.cellOrigin(line.index, 0) + Offset(i * g.stride, 0)
          : g.cellOrigin(0, line.index) + Offset(0, i * g.stride);
      final face = _liftedFace(letters[r][c], statuses[r][c], lift);
      children.add(
        Positioned(
          left: origin.dx,
          top: origin.dy,
          width: g.tile,
          height: g.tile,
          child: isGhost ? Opacity(opacity: ghostOpacity, child: face) : face,
        ),
      );
    }

    return ClipRect(
      clipper: _LineClip(axis: line.axis, geometry: g),
      child: Transform.translate(
        offset: isRow ? Offset(translation, 0) : Offset(0, translation),
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }

  /// Two rails straddling the card edge across the line (the render's
  /// `x − 1` and `x + w − 2·s`), inset 8·s from the tile ends.
  List<Widget> _buildRails(ActiveLine line, double lift) {
    final g = _g;
    final s = g.s;
    final railLength = g.tile - 16 * s;
    Widget rail(double left, double top, Axis axis) => Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: lift.clamp(0.0, 1.0),
        child: LineRail(length: railLength, axis: axis),
      ),
    );
    if (line.axis == MoveAxis.row) {
      final top = g.cellOrigin(line.index, 0).dy + 8 * s;
      return <Widget>[
        rail(-1, top, Axis.vertical),
        rail(g.width - 2 * s, top, Axis.vertical),
      ];
    }
    final left = g.cellOrigin(0, line.index).dx + 8 * s;
    return <Widget>[
      rail(left, -1, Axis.horizontal),
      rail(left, g.height - 2 * s, Axis.horizontal),
    ];
  }

  Widget _buildSeam(int row) {
    final g = _g;
    final progress = _win.value == 0 && _c.phase == PlaySessionPhase.won
        ? 1.0
        : PlayTheme.shiftCurve.transform(_win.value);
    final origin = g.cellOrigin(row, 0);
    return Positioned(
      left: origin.dx,
      top: origin.dy + g.tile + 3,
      height: 3,
      width: g.rowWidth * progress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PlayTheme.amber,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66FFC24B), blurRadius: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBloom(int row) {
    final g = _g;
    final v = _win.value;
    final o = math.sin(math.pi * v) * 0.20;
    final origin = g.cellOrigin(row, 0);
    return Positioned(
      left: origin.dx,
      top: origin.dy - g.tile * 0.5,
      width: g.rowWidth,
      height: g.tile * 2,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                PlayTheme.amber.withValues(alpha: o),
                PlayTheme.amber.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips the moving line to the card interior along its axis — the tile area
/// plus 5·s each side, inside the 11·s padding — and leaves the cross axis
/// open so the rim's glow and shadow are not cut (`ui-design.md` §11.3).
class _LineClip extends CustomClipper<Rect> {
  const _LineClip({required this.axis, required this.geometry});

  final MoveAxis axis;
  final BoardGeometry geometry;

  static const double _open = 80;

  @override
  Rect getClip(Size size) {
    final inset = geometry.pad - 5 * geometry.s;
    return axis == MoveAxis.row
        ? Rect.fromLTRB(inset, -_open, size.width - inset, size.height + _open)
        : Rect.fromLTRB(-_open, inset, size.width + _open, size.height - inset);
  }

  @override
  bool shouldReclip(_LineClip oldClipper) =>
      oldClipper.axis != axis || oldClipper.geometry.s != geometry.s;
}

/// The won moment's 12 % recede of the non-winning tiles (§16.2, dim only, no
/// blur), over the Loop Glass tile.
class _Receded extends StatelessWidget {
  const _Receded({required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x1F000000),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The vacated slot of a docked winning row (`ui-design.md` §16.3): a 1 pt
/// `amber` @ 25 % outline at the tile radius on the plate colour, no fill, so
/// the board reads "this row left", not "broken".
class _GhostCell extends StatelessWidget {
  const _GhostCell({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          size * PlayTheme.tileRadiusFraction,
        ),
        border: Border.all(color: PlayTheme.amber.withValues(alpha: 0.25)),
      ),
    );
  }
}
