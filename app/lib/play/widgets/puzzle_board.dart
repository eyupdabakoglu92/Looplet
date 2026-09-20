import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looplet_core/looplet_core.dart'
    show MoveAxis, MoveDirection, TileStatus;

import '../play_session_controller.dart';
import '../play_theme.dart';
import 'board_tile.dart';
import '../../reduce_motion.dart';

/// The hero: the 5×5 backlit board on a recessed plate, with the loop-rail
/// affordance, the wrap-shift animation, the rejected-move bounce, and the win
/// choreography (`ui-design.md` §5–§8, `architecture.md` §6/§7/§11).
///
/// The [controller] is the state-machine authority; this widget owns only the
/// `AnimationController`s and calls [PlaySessionController.commitShift] /
/// [PlaySessionController.commitBounce] when a transition animation settles.
class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    required this.controller,
    required this.boardSize,
    this.rowVacated = false,
    super.key,
  });

  final PlaySessionController controller;
  final double boardSize;

  /// F03 `ui-design.md` §16: while `won`, once the winning row has lifted off to
  /// its dock, its home cells show a faint amber outline ("ghost") and the
  /// board's own seam bar / bloom stop drawing (the docked overlay carries them).
  final bool rowVacated;

  /// Tile edge for a [boardSize] board of [gridSize]² cells — the single source
  /// of the tile math, shared with the docked-row overlay.
  static double tileSizeFor(double boardSize, int gridSize) =>
      (boardSize -
          2 * PlayTheme.platePadding -
          (gridSize - 1) * PlayTheme.tileGap) /
      gridSize;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with TickerProviderStateMixin {
  late final AnimationController _shift = AnimationController(
    vsync: this,
    duration: PlayTheme.shiftDuration,
  );
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: PlayTheme.bounceDuration,
  );
  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: PlayTheme.winDuration,
  );

  Offset _dragOffset = Offset.zero;
  Offset _shiftFrom = Offset.zero; // drag offset captured at release
  ({int row, int col})? _pressedCell;

  PlaySessionPhase _lastPhase = PlaySessionPhase.idle;

  PlaySessionController get _c => widget.controller;

  int get _size => _c.gridSize;
  double get _plate => PlayTheme.platePadding;
  double get _gap => PlayTheme.tileGap;
  double get _tile =>
      (widget.boardSize - 2 * _plate - (_size - 1) * _gap) / _size;
  double get _stride => _tile + _gap;

  @override
  void initState() {
    super.initState();
    _lastPhase = _c.phase;
    _c.addListener(_onController);
    if (_c.phase == PlaySessionPhase.won) _win.value = 1;
  }

  @override
  void dispose() {
    _c.removeListener(_onController);
    _shift.dispose();
    _bounce.dispose();
    _win.dispose();
    super.dispose();
  }

  void _onController() {
    final phase = _c.phase;
    if (phase == _lastPhase) {
      if (mounted) setState(() {});
      return;
    }
    if (phase == PlaySessionPhase.won && _lastPhase != PlaySessionPhase.won) {
      // OS reduce-motion: the amber row + seam render static (no stagger/bloom).
      final reduceMotion = reduceMotionRequested();
      if (reduceMotion) {
        _win.value = 1;
      } else {
        _win.forward(from: 0);
      }
    } else if (phase != PlaySessionPhase.won && _win.value != 0) {
      _win.value = 0;
    }
    _lastPhase = phase;
    if (mounted) setState(() {});
  }

  // --- gesture ---------------------------------------------------------------

  ({int row, int col}) _cellAt(Offset local) {
    final c = ((local.dx - _plate) / _stride).floor().clamp(0, _size - 1);
    final r = ((local.dy - _plate) / _stride).floor().clamp(0, _size - 1);
    return (row: r, col: c);
  }

  void _onPanDown(DragDownDetails d) {
    if (_c.inputLocked) return;
    final cell = _cellAt(d.localPosition);
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
    final resolution = _c.endDrag(delta);
    switch (resolution) {
      case DragResolution.none:
        _dragOffset = Offset.zero;
        setState(() {});
      case DragResolution.shift:
        _shiftFrom = delta;
        _shift.forward(from: 0).whenComplete(() {
          final won = _c.commitShift();
          _dragOffset = Offset.zero;
          _shiftFrom = Offset.zero;
          if (mounted) setState(() {});
          // The win choreography starts from the controller listener.
          if (!won && mounted) setState(() {});
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

  // --- geometry helpers ----------------------------------------------------

  double _axisDelta(Offset o, MoveAxis axis) =>
      axis == MoveAxis.row ? o.dx : o.dy;

  /// Current translation of the active line, in px along its axis.
  double _lineTranslation(ActiveLine line) {
    final cap = _stride * 0.55;
    switch (_c.phase) {
      case PlaySessionPhase.tracking:
        return _axisDelta(_dragOffset, line.axis).clamp(-cap, cap);
      case PlaySessionPhase.animatingShift:
        final target =
            (line.direction == MoveDirection.right ||
                line.direction == MoveDirection.down)
            ? _stride
            : -_stride;
        final from = _axisDelta(_shiftFrom, line.axis).clamp(-cap, cap);
        final t = PlayTheme.shiftCurve.transform(_shift.value);
        return from + (target - from) * t;
      case PlaySessionPhase.animatingBounce:
        final from = _axisDelta(_shiftFrom, line.axis).clamp(-cap, cap);
        final t = PlayTheme.bounceCurve.transform(_bounce.value);
        return from * (1 - t);
      case PlaySessionPhase.idle:
      case PlaySessionPhase.won:
        return 0;
    }
  }

  bool _inActiveLine(ActiveLine? line, int r, int c) {
    if (line == null) return false;
    return line.axis == MoveAxis.row ? r == line.index : c == line.index;
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_shift, _bounce, _win]),
      builder: (context, _) => _buildBoard(context),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final radius = _tile * PlayTheme.tileRadiusFraction + _gap;
    final line = _c.activeLine;
    final letters = _c.displayLetters;
    final statuses = _c.tileStatuses;
    final wonRow = _c.phase == PlaySessionPhase.won ? _c.wonRow : null;
    final vacated = wonRow != null && widget.rowVacated;
    final lineActive =
        line != null &&
        (_c.phase == PlaySessionPhase.tracking ||
            _c.phase == PlaySessionPhase.animatingShift ||
            _c.phase == PlaySessionPhase.animatingBounce);
    final dimInactive = lineActive ? PlayTheme.inactiveTileDim : 0.0;

    return Listener(
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onPanCancel: _onPanCancel,
        child: SizedBox(
          width: widget.boardSize,
          height: widget.boardSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: PlayTheme.plate,
              borderRadius: BorderRadius.circular(radius),
              border: const Border(top: BorderSide(color: Color(0x0FFFFFFF))),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x73000000),
                  offset: Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: <Widget>[
                  // Loop rails on the active axis' two edges.
                  ..._buildRails(line, lineActive),
                  // Static tiles (skip the active line — the moving layer draws it).
                  for (var r = 0; r < _size; r++)
                    for (var c = 0; c < _size; c++)
                      if (!(lineActive && _inActiveLine(line, r, c)))
                        Positioned(
                          left: _plate + c * _stride,
                          top: _plate + r * _stride,
                          width: _tile,
                          height: _tile,
                          child: vacated && r == wonRow
                              ? _GhostCell(size: _tile)
                              : BoardTile(
                                  letter: letters[r][c],
                                  size: _tile,
                                  status: statuses[r][c],
                                  winning: wonRow != null && r == wonRow,
                                  pressed:
                                      _pressedCell?.row == r &&
                                      _pressedCell?.col == c,
                                  dim: (wonRow != null && r != wonRow)
                                      ? 0.12
                                      : (_inActiveLine(line, r, c)
                                            ? 0
                                            : dimInactive),
                                ),
                        ),
                  // Moving active line (with wrap ghosts).
                  if (lineActive) _buildMovingLine(line, letters, statuses),
                  // Winning seam bar (the docked overlay draws it once vacated).
                  if (wonRow != null && !vacated) _buildSeam(wonRow),
                  // Win bloom (finished by T0+600, i.e. before the dock).
                  if (wonRow != null && !vacated && _win.value > 0)
                    _buildBloom(wonRow),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRails(ActiveLine? line, bool active) {
    if (line == null || !active) return const <Widget>[];
    final forward =
        line.direction == MoveDirection.right ||
        line.direction == MoveDirection.down;
    Widget bar({required bool horizontal, required bool atForwardEnd}) {
      final bright = 0.30 * (atForwardEnd == forward ? 1.0 : 0.5);
      final gradient = LinearGradient(
        begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
        end: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
        colors: <Color>[
          PlayTheme.cyan.withValues(alpha: 0),
          PlayTheme.cyan.withValues(alpha: bright),
          PlayTheme.cyan.withValues(alpha: 0),
        ],
      );
      return DecoratedBox(decoration: BoxDecoration(gradient: gradient));
    }

    if (line.axis == MoveAxis.row) {
      final top = _plate + line.index * _stride;
      return <Widget>[
        Positioned(
          left: 0,
          width: 2,
          top: top,
          height: _tile,
          child: bar(horizontal: false, atForwardEnd: false),
        ),
        Positioned(
          right: 0,
          width: 2,
          top: top,
          height: _tile,
          child: bar(horizontal: false, atForwardEnd: true),
        ),
      ];
    }
    final left = _plate + line.index * _stride;
    return <Widget>[
      Positioned(
        top: 0,
        height: 2,
        left: left,
        width: _tile,
        child: bar(horizontal: true, atForwardEnd: false),
      ),
      Positioned(
        bottom: 0,
        height: 2,
        left: left,
        width: _tile,
        child: bar(horizontal: true, atForwardEnd: true),
      ),
    ];
  }

  Widget _buildMovingLine(
    ActiveLine line,
    List<List<String>> letters,
    List<List<TileStatus>> statuses,
  ) {
    final translation = _lineTranslation(line);
    final isRow = line.axis == MoveAxis.row;
    final emerging = _c.phase == PlaySessionPhase.animatingShift
        ? PlayTheme.shiftCurve.transform(_shift.value)
        : (_c.phase == PlaySessionPhase.tracking
              ? (translation.abs() / _stride).clamp(0.0, 1.0)
              : 0.0);

    // Cells c = -1 .. size (two wrap ghosts).
    final children = <Widget>[];
    for (var i = -1; i <= _size; i++) {
      final idx = (i + _size) % _size;
      final r = isRow ? line.index : idx;
      final cc = isRow ? idx : line.index;
      final isGhost = i < 0 || i >= _size;
      final left = _plate + (isRow ? i * _stride : line.index * _stride);
      final top = _plate + (isRow ? line.index * _stride : i * _stride);
      children.add(
        Positioned(
          left: left,
          top: top,
          width: _tile,
          height: _tile,
          child: Opacity(
            opacity: isGhost ? (0.35 + 0.65 * emerging) : 1.0,
            child: BoardTile(
              letter: letters[r][cc],
              size: _tile,
              status: statuses[r][cc],
            ),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Transform.translate(
        offset: isRow ? Offset(translation, 0) : Offset(0, translation),
        child: Stack(children: children),
      ),
    );
  }

  Widget _buildSeam(int row) {
    final progress = _win.value == 0 && _c.phase == PlaySessionPhase.won
        ? 1.0
        : PlayTheme.shiftCurve.transform(_win.value);
    final rowWidth = _size * _tile + (_size - 1) * _gap;
    return Positioned(
      left: _plate,
      top: _plate + row * _stride + _tile + 3,
      height: 3,
      width: rowWidth * progress,
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
    final v = _win.value;
    final o = math.sin(math.pi * v) * 0.20;
    final rowWidth = _size * _tile + (_size - 1) * _gap;
    return Positioned(
      left: _plate,
      top: _plate + row * _stride - _tile * 0.5,
      width: rowWidth,
      height: _tile * 2,
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
