import 'dart:async';
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

import '../content/puzzle_engine_config.dart';
import '../engine/move_shorthand.dart';
import '../persistence/active_session_snapshot.dart';
import '../persistence/elapsed_timer.dart';
import '../persistence/repositories/active_session_repo.dart';
import '../persistence/repositories/personal_best_repo.dart';
import '../persistence/session_restore.dart';
import '../rating/completion_result.dart';
import '../rating/star_rating.dart';
import 'gesture_resolver.dart';

/// Screen phase (`architecture.md` §6). There is **no input queue** — a pointer
/// interaction is accepted only in [idle].
enum PlaySessionPhase { idle, tracking, animatingShift, animatingBounce, won }

/// How [PlaySessionController.endDrag] resolved.
enum DragResolution {
  /// Below threshold, or not currently tracking — nothing happened.
  none,

  /// A legal move: the board plays the wrap shift, then calls [commitShift].
  shift,

  /// The engine rejected the move: the board plays the bounce-back, then calls
  /// [commitBounce]. `MOVES` is unchanged; nothing is persisted.
  bounce,
}

/// The row/column a drag or shift animation is acting on.
@immutable
class ActiveLine {
  const ActiveLine({
    required this.axis,
    required this.index,
    required this.direction,
  });

  final MoveAxis axis;
  final int index;
  final MoveDirection direction;

  ActiveLine copyWith({MoveDirection? direction}) => ActiveLine(
    axis: axis,
    index: index,
    direction: direction ?? this.direction,
  );
}

/// Owns the play-session state machine: the F02 [GridEngine], the F03 counters
/// (3-undo quota, restart count), the monotonic [ElapsedTimer], write-through
/// persistence into the **F08-frozen** [ActiveSessionSnapshot], and hydrate on
/// open via the F08 restore path.
///
/// This class holds **no** `AnimationController` — the board widget drives
/// animation and calls [commitShift] / [commitBounce] when it settles. That
/// keeps the state machine synchronous and unit-testable without a ticker.
class PlaySessionController extends ChangeNotifier {
  PlaySessionController({
    required this.puzzle,
    required this.source,
    required WordValidator validator,
    required ActiveSessionRepo activeSessionRepo,
    GestureResolver resolver = const GestureResolver(),
    DateTime Function()? clock,
    ActiveSessionSnapshot? restoreFrom,
    PersonalBestRepo? personalBestRepo,
    String? guestId,
  }) : _validator = validator,
       _repo = activeSessionRepo,
       _resolver = resolver,
       _personalBestRepo = personalBestRepo,
       _guestId = guestId,
       _clock = clock ?? (() => DateTime.now().toUtc()) {
    final restored = _tryRestore(restoreFrom);
    if (restored != null) {
      _engine = restored.engine;
      _undosRemaining = restored.undosRemaining;
      _restartCount = restored.restartCount;
      _timer = restored.timer;
      _startedAtUtcMs = restored.startedAtUtcMs;
      _hydratedFromSnapshot = true;
    } else {
      _engine = GridEngine(toEngineConfig(puzzle), validator: validator);
      _timer = ElapsedTimer();
      _startedAtUtcMs = _nowMs();
    }
    _refreshDisplay();
    if (_engine.isSolved) {
      // A restored-completed or authored-solved puzzle: land directly in `won`.
      _phase = PlaySessionPhase.won;
      _wonRow = _findWinningRow();
      _beginCompletion();
    }
    if (!_hydratedFromSnapshot) {
      unawaited(_persist());
    }
  }

  final Puzzle puzzle;
  final PuzzleSource source;
  final WordValidator _validator;
  final ActiveSessionRepo _repo;
  final GestureResolver _resolver;
  final PersonalBestRepo? _personalBestRepo;
  final String? _guestId;
  final DateTime Function() _clock;

  late final GridEngine _engine;
  late final ElapsedTimer _timer;
  late final int _startedAtUtcMs;
  bool _hydratedFromSnapshot = false;

  PlaySessionPhase _phase = PlaySessionPhase.idle;
  int _undosRemaining = ActiveSessionSnapshot.maxUndos;
  int _restartCount = 0;
  int? _wonRow;
  ActiveLine? _activeLine;
  int _gridVersion = 0; // bumped on undo / restart so the board can crossfade
  GridStep? _pendingShift;

  int _dragStartRow = 0;
  int _dragStartCol = 0;

  Future<void> _pendingWrite = Future<void>.value();

  /// Completes when the most recent write-through persistence call settles.
  /// For tests / `paused`-flush ordering; not needed for normal play.
  @visibleForTesting
  Future<void> get whenPersisted => _pendingWrite;

  // --- F04 star rating / personal best ------------------------------------
  CompletionResult? _completion;
  bool _ratingUnavailable = false;
  bool _ratingResolved = false;
  Future<void> _ratingWork = Future<void>.value();

  /// The F04 completion result once the puzzle is solved. `null` while playing,
  /// and `null` for the defensive no-optimal case (see [ratingUnavailable]) —
  /// the panel then falls back to a bare completion from [targetWord] /
  /// [moveCount] (`architecture.md` §6).
  CompletionResult? get completion => _completion;

  /// `true` when the puzzle is solved but `optimalMoves < 1`, so no rating can
  /// be computed (defensive — F06 guarantees this never happens for a shipped
  /// puzzle). The panel shows the completion without stars / best.
  bool get ratingUnavailable => _ratingUnavailable;

  /// `true` once the personal-best read-back has settled (or was skipped). Until
  /// then [completion] may carry the sentinel `personalBestMoves == 0`.
  bool get ratingResolved => _ratingResolved;

  /// Completes when the personal-best write + read-back settles. Tests only.
  @visibleForTesting
  Future<void> get whenRatingResolved => _ratingWork;

  List<List<String>> _displayLetters = const <List<String>>[];
  List<List<TileStatus>> _tileStatuses = const <List<TileStatus>>[];

  // --- read model ----------------------------------------------------------

  PlaySessionPhase get phase => _phase;
  int get moveCount => _engine.moveCount;
  int get optimalMoves => puzzle.optimalMoves;
  int get undosRemaining => _undosRemaining;
  int get restartCount => _restartCount;
  int get gridSize => _engine.config.gridSize;
  int get gridVersion => _gridVersion;
  String get targetWord => puzzle.targetWord;
  String get lang => puzzle.language;
  bool get columnMovesEnabled => _engine.config.columnMovesEnabled;
  bool get isSolved => _engine.isSolved;
  int? get wonRow => _wonRow;
  ActiveLine? get activeLine => _activeLine;
  int get dragStartRow => _dragStartRow;
  int get dragStartCol => _dragStartCol;
  bool get hydratedFromSnapshot => _hydratedFromSnapshot;

  /// Settled grid to render. During a shift animation the board renders the
  /// pre-move letters itself; this is always the committed state.
  List<List<String>> get displayLetters => _displayLetters;
  List<List<TileStatus>> get tileStatuses => _tileStatuses;

  /// Undo is a 3-**action** quota (not history depth). Allowed only from [idle],
  /// with quota left, at least one move applied, and not already solved.
  bool get canUndo =>
      _phase == PlaySessionPhase.idle &&
      _undosRemaining > 0 &&
      _engine.moveCount > 0 &&
      !_engine.isSolved;

  /// Restart resets to the authored grid. Allowed from [idle] (inert during
  /// animation and `won` — `won` exits via the completion sheet's Retry).
  bool get canRestart => _phase == PlaySessionPhase.idle;

  bool get inputLocked =>
      _phase == PlaySessionPhase.animatingShift ||
      _phase == PlaySessionPhase.animatingBounce ||
      _phase == PlaySessionPhase.won;

  // --- lifecycle ---------------------------------------------------------------

  /// Called by the screen once it is on-stage: starts the elapsed timer.
  void attach() {
    if (_phase != PlaySessionPhase.won) _timer.start();
  }

  /// `AppLifecycleState.paused` — cancel any in-progress gesture, force any
  /// in-flight animation to its settled end (the move is already applied to the
  /// engine), pause the timer, and persist a **settled** snapshot
  /// (`architecture.md` §12: never a half-applied move on disk).
  void onAppPaused() {
    switch (_phase) {
      case PlaySessionPhase.tracking:
        _activeLine = null;
        _phase = PlaySessionPhase.idle;
      case PlaySessionPhase.animatingShift:
        _finishShift();
      case PlaySessionPhase.animatingBounce:
        _activeLine = null;
        _phase = PlaySessionPhase.idle;
      case PlaySessionPhase.idle:
      case PlaySessionPhase.won:
        break;
    }
    _timer.pause();
    if (_phase != PlaySessionPhase.won) unawaited(_persist());
    notifyListeners();
  }

  /// `AppLifecycleState.resumed` — resume timing an unfinished session.
  void onAppResumed() {
    if (_phase == PlaySessionPhase.idle) _timer.start();
  }

  @override
  void dispose() {
    _timer.pause();
    super.dispose();
  }

  // --- gesture ---------------------------------------------------------------

  /// Pointer went down on cell `(startRow, startCol)`. Ignored unless [idle]
  /// (no queue). Does not lift a line yet — [updateDrag] does, past threshold.
  void beginDrag({required int startRow, required int startCol}) {
    if (_phase != PlaySessionPhase.idle) return;
    _dragStartRow = startRow;
    _dragStartCol = startCol;
    _activeLine = null;
    _phase = PlaySessionPhase.tracking;
    notifyListeners();
  }

  /// Cumulative pointer delta (screen coords, y-down). Past threshold this lifts
  /// the dominant row/column and sets its provisional direction (AC9).
  void updateDrag(Offset delta) {
    if (_phase != PlaySessionPhase.tracking) return;
    final axis = _resolver.trackingAxis(delta);
    if (axis == null) {
      if (_activeLine != null) {
        _activeLine = null;
        notifyListeners();
      }
      return;
    }
    final ActiveLine next;
    if (axis == MoveAxis.row) {
      next = ActiveLine(
        axis: MoveAxis.row,
        index: _dragStartRow,
        direction: delta.dx >= 0 ? MoveDirection.right : MoveDirection.left,
      );
    } else {
      next = ActiveLine(
        axis: MoveAxis.column,
        index: _dragStartCol,
        direction: delta.dy >= 0 ? MoveDirection.down : MoveDirection.up,
      );
    }
    if (_activeLine == null ||
        _activeLine!.axis != next.axis ||
        _activeLine!.index != next.index ||
        _activeLine!.direction != next.direction) {
      _activeLine = next;
      notifyListeners();
    }
  }

  /// Pointer released with cumulative [delta]. Resolves the move and moves to
  /// [animatingShift] / [animatingBounce] — the board then animates and calls
  /// [commitShift] / [commitBounce].
  DragResolution endDrag(Offset delta) {
    if (_phase != PlaySessionPhase.tracking) return DragResolution.none;

    final move = _resolver.resolve(
      startRow: _dragStartRow,
      startCol: _dragStartCol,
      delta: delta,
    );
    if (move == null) {
      _activeLine = null;
      _phase = PlaySessionPhase.idle;
      notifyListeners();
      return DragResolution.none;
    }

    _activeLine = ActiveLine(
      axis: move.axis,
      index: move.index,
      direction: move.direction,
    );

    final step = _engine.applyMove(move);
    if (step.applied) {
      _pendingShift = step;
      _phase = PlaySessionPhase.animatingShift;
      notifyListeners();
      return DragResolution.shift;
    }
    _phase = PlaySessionPhase.animatingBounce;
    notifyListeners();
    return DragResolution.bounce;
  }

  /// The board finished the wrap-shift animation. Commits the settled grid,
  /// persists, and — on a win — moves to [won] and clears the active snapshot.
  /// Returns `true` iff this move solved the puzzle (the board then runs the
  /// win choreography + reveals the completion sheet).
  bool commitShift() {
    if (_phase != PlaySessionPhase.animatingShift) return false;
    return _finishShift();
  }

  bool _finishShift() {
    final solved = _pendingShift?.solvedThisStep ?? false;
    _pendingShift = null;
    _refreshDisplay();
    if (solved) {
      _wonRow = _findWinningRow();
      _phase = PlaySessionPhase.won;
      _activeLine = null;
      _timer.pause();
      unawaited(_persistCompletedThenClear());
      _beginCompletion();
    } else {
      _phase = PlaySessionPhase.idle;
      _activeLine = null;
      unawaited(_persist());
    }
    notifyListeners();
    return solved;
  }

  /// The board finished the bounce-back. Nothing changed; not persisted.
  void commitBounce() {
    if (_phase != PlaySessionPhase.animatingBounce) return;
    _activeLine = null;
    _phase = PlaySessionPhase.idle;
    notifyListeners();
  }

  // --- controls ------------------------------------------------------------

  /// One undo action (AC6: at quota 0 this is never reached — [canUndo] is
  /// false — and the button is inert, with no prompt/ad).
  bool undo() {
    if (!canUndo) return false;
    final step = _engine.undo();
    if (!step.applied) return false;
    _undosRemaining -= 1;
    _gridVersion += 1;
    _refreshDisplay();
    unawaited(_persist());
    notifyListeners();
    return true;
  }

  /// Restart to the authored grid: `MOVES = 0`, undos back to 3,
  /// `restartCount++`, no confirmation (AC7).
  bool restart() {
    if (!canRestart) return false;
    _applyRestart();
    unawaited(_persist());
    notifyListeners();
    return true;
  }

  /// Retry from the completion sheet — a restart that is also allowed from
  /// [won]. Re-arms the timer and writes a fresh `inProgress` snapshot (the
  /// completed one was cleared).
  void retryFromCompletion() {
    _applyRestart();
    _timer.start();
    unawaited(_persist());
    notifyListeners();
  }

  void _applyRestart() {
    _engine.restart();
    _undosRemaining = ActiveSessionSnapshot.maxUndos;
    _restartCount += 1;
    _wonRow = null;
    _activeLine = null;
    _gridVersion += 1;
    _phase = PlaySessionPhase.idle;
    // A fresh attempt: drop the previous completion so the next win recomputes.
    _completion = null;
    _ratingUnavailable = false;
    _ratingResolved = false;
    _refreshDisplay();
  }

  // --- F04 win-path wiring (additive; no F03 contract change) --------------

  /// On a win: compute the star rating (synchronous — depends only on
  /// `moveCount` + `optimalMoves`), publish a preliminary [CompletionResult],
  /// then resolve the personal-best line from F08's `PersonalBestRepo`
  /// (`architecture.md` §6).
  void _beginCompletion() {
    final optimal = puzzle.optimalMoves;
    final player = _engine.moveCount;

    if (optimal < 1) {
      // Defensive only — F06's export/check gate guarantees `optimalMoves`.
      _ratingUnavailable = true;
      _ratingResolved = true;
      _completion = null;
      debugPrint('play: rating_blocked_no_optimal (puzzle ${puzzle.id})');
      return;
    }

    final stars = starsForResult(player: player, optimal: optimal);
    _completion = CompletionResult(
      levelId: puzzle.id,
      source: source,
      targetWord: puzzle.targetWord,
      playerMoves: player,
      optimalMoves: optimal,
      stars: stars,
      isPerfect: isPerfectResult(player: player, optimal: optimal),
      // Sentinel until the read-back resolves (§6). `0` renders as "—".
      personalBestMoves: 0,
      bestIsPerfect: false,
      bestOutcome: BestOutcome.firstClear,
      ratingPersisted: false,
    );
    _ratingResolved = false;
    _ratingWork = _resolvePersonalBest(
      player: player,
      optimal: optimal,
      stars: stars,
    );
  }

  /// Fire-and-forget with a **caught** failure (same posture as [_persist]).
  /// Stars are already published; a storage failure degrades only the best line
  /// to "—" and never blocks the panel.
  Future<void> _resolvePersonalBest({
    required int player,
    required int optimal,
    required int stars,
  }) async {
    final repo = _personalBestRepo;
    final guestId = _guestId;

    // Daily persistence is F07's; a missing repo/guest means an unwired caller
    // (unit tests). Either way: stars stand, no best line.
    if (repo == null || guestId == null || source != PuzzleSource.journey) {
      _ratingResolved = true;
      notifyListeners();
      return;
    }

    try {
      final prior = await repo.read(guestId, puzzle.id);
      await repo.recordCompletion(
        guestId: guestId,
        levelId: puzzle.id,
        moveCount: player,
        stars: stars,
        optimalMoves: optimal,
        completedAtUtcMs: _nowMs(),
      );
      final post = await repo.read(guestId, puzzle.id);
      _completion = _completion?.copyWith(
        personalBestMoves: post?.bestMoveCount ?? player,
        bestIsPerfect: post?.isPerfect ?? (player == optimal),
        bestOutcome: bestOutcomeFor(
          player: player,
          priorBest: prior?.bestMoveCount,
        ),
        ratingPersisted: true,
      );
    } catch (error) {
      debugPrint('play: best_persist_failed (non-fatal) — $error');
      _completion = _completion?.copyWith(
        personalBestMoves: 0,
        bestOutcome: BestOutcome.firstClear,
        ratingPersisted: false,
      );
    }
    _ratingResolved = true;
    notifyListeners();
  }

  // --- internals ---------------------------------------------------------------

  int _nowMs() => _clock().millisecondsSinceEpoch;

  RestoredSession? _tryRestore(ActiveSessionSnapshot? snapshot) {
    if (snapshot == null || snapshot.puzzleId != puzzle.id) return null;
    try {
      return restoreSession(snapshot, puzzle, _validator);
    } on SessionRestoreException catch (error) {
      debugPrint('play: snapshot replay rejected, fresh start — $error');
      return null;
    }
  }

  void _refreshDisplay() {
    final size = _engine.config.gridSize;
    final letters = _engine.state.letters;
    _displayLetters = List<List<String>>.unmodifiable(<List<String>>[
      for (final row in letters) List<String>.unmodifiable(row),
    ]);
    _tileStatuses = List<List<TileStatus>>.unmodifiable(<List<TileStatus>>[
      for (var r = 0; r < size; r++)
        List<TileStatus>.unmodifiable(<TileStatus>[
          for (var c = 0; c < size; c++)
            _engine.state.statusAt(GridCoord(r, c)),
        ]),
    ]);
  }

  int? _findWinningRow() {
    final size = _engine.config.gridSize;
    final target = TurkishCase.toLowerTr(puzzle.targetWord);
    final targetLen = puzzle.targetWord.runes.length;
    final letters = _engine.state.letters;
    for (var r = 0; r < size; r++) {
      for (var start = 0; start + targetLen <= size; start++) {
        final buffer = StringBuffer();
        for (var c = start; c < start + targetLen; c++) {
          buffer.write(TurkishCase.toLowerTr(letters[r][c]));
        }
        if (buffer.toString() == target) return r;
      }
    }
    return null;
  }

  ActiveSessionSnapshot _snapshot(ActiveSessionStatus status) {
    final thawed = (_engine.state.thawedCells.toList()..sort())
        .map((c) => '${c.row},${c.col}')
        .toList(growable: false);
    return ActiveSessionSnapshot(
      puzzleId: puzzle.id,
      puzzleSource: source,
      lang: puzzle.language,
      appliedMoves: formatMoveList(_engine.appliedMoves),
      undosRemaining: _undosRemaining,
      restartCount: _restartCount,
      elapsedMsAccumulated: _timer.accumulatedForSnapshot,
      thawedFrozenCells: thawed,
      status: status,
      startedAtUtcMs: _startedAtUtcMs,
      lastPersistedAtUtcMs: _nowMs(),
    );
  }

  Future<void> _persist() {
    final future = () async {
      try {
        await _repo.save(_snapshot(ActiveSessionStatus.inProgress));
      } catch (error) {
        // Storage full / write error → non-fatal; keep playing from memory
        // (`architecture.md` §Resilience). Retried on the next boundary.
        debugPrint('play: persist_failed (non-fatal) — $error');
      }
    }();
    _pendingWrite = future;
    return future;
  }

  Future<void> _persistCompletedThenClear() {
    final future = () async {
      try {
        await _repo.save(_snapshot(ActiveSessionStatus.completed));
        await _repo.clear();
      } catch (error) {
        debugPrint(
          'play: completion persist/clear failed (non-fatal) — $error',
        );
      }
    }();
    _pendingWrite = future;
    return future;
  }
}
