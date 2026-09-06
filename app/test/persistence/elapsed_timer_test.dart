import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/elapsed_timer.dart';

void main() {
  test('accumulates across start/pause cycles', () async {
    final timer = ElapsedTimer();
    expect(timer.elapsedMs, 0);

    timer.start();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    timer.pause();
    final afterFirst = timer.elapsedMs;
    expect(afterFirst, greaterThan(0));

    // Paused → no growth.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(timer.elapsedMs, afterFirst);

    timer.start();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(timer.elapsedMs, greaterThan(afterFirst));
  });

  test('resumed() restores the persisted accumulated value', () async {
    final resumed = ElapsedTimer.resumed(41200);
    expect(resumed.elapsedMs, 41200);
    expect(resumed.isRunning, isFalse);

    resumed.start();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(resumed.elapsedMs, greaterThan(41200));
  });

  test('elapsed is monotonic and snapshot-safe while running', () async {
    final timer = ElapsedTimer()..start();
    final a = timer.accumulatedForSnapshot;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final b = timer.accumulatedForSnapshot;
    expect(b, greaterThanOrEqualTo(a));
  });

  test('rejects a negative accumulated value', () {
    expect(
      () => ElapsedTimer(accumulatedMs: -1),
      throwsA(isA<AssertionError>()),
    );
  });
}
