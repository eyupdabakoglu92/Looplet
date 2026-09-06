/// Monotonic elapsed-time accumulator for a play session.
///
/// LOOPLET measures elapsed time with a monotonic [Stopwatch] and **never** the
/// wall clock (`platform.md` §5/§11, F08 architecture → Ownership & Lifecycle):
/// a device clock change mid-session must not affect the recorded duration
/// (F08 AC10). The running total is persisted as `elapsedMsAccumulated` in the
/// active-session snapshot; on resume, a fresh [Stopwatch] delta is added to the
/// restored accumulated value.
class ElapsedTimer {
  ElapsedTimer({int accumulatedMs = 0})
    : assert(accumulatedMs >= 0, 'accumulatedMs must be >= 0'),
      _accumulatedMs = accumulatedMs;

  /// Restores a timer from a persisted accumulated value (paused — call [start]
  /// when the session becomes active again).
  factory ElapsedTimer.resumed(int accumulatedMs) =>
      ElapsedTimer(accumulatedMs: accumulatedMs);

  final Stopwatch _stopwatch = Stopwatch();
  int _accumulatedMs;

  /// Starts (or resumes) counting. Idempotent.
  void start() {
    if (!_stopwatch.isRunning) _stopwatch.start();
  }

  /// Pauses counting and folds the current run into the accumulated total.
  void pause() {
    if (_stopwatch.isRunning) {
      _accumulatedMs += _stopwatch.elapsedMilliseconds;
      _stopwatch
        ..stop()
        ..reset();
    }
  }

  /// Total elapsed so far — accumulated plus the current run if active.
  int get elapsedMs =>
      _accumulatedMs +
      (_stopwatch.isRunning ? _stopwatch.elapsedMilliseconds : 0);

  Duration get elapsed => Duration(milliseconds: elapsedMs);

  bool get isRunning => _stopwatch.isRunning;

  /// The value to persist in the snapshot (safe to call while running).
  int get accumulatedForSnapshot => elapsedMs;
}
