import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/repositories/personal_best_repo.dart';
import 'package:looplet_app/rating/completion_result.dart';

/// The personal-best logic F04 layers over F08's `PersonalBestRepo`: the repo's
/// monotone write + the pure `bestOutcomeFor` derivation, exercised as the
/// win-path uses them (read prior → record → read back) — `architecture.md` §11.
void main() {
  late AppDatabase db;
  late PersonalBestRepo repo;
  const guest = 'guest-1';
  const level = 'smoke-tr-01';
  const optimal = 6;
  const nowMs = 1757160000000;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PersonalBestRepo(db);
  });

  tearDown(() => db.close());

  Future<BestOutcome> record(int moves, int stars) async {
    final prior = await repo.read(guest, level);
    await repo.recordCompletion(
      guestId: guest,
      levelId: level,
      moveCount: moves,
      stars: stars,
      optimalMoves: optimal,
      completedAtUtcMs: nowMs,
    );
    return bestOutcomeFor(player: moves, priorBest: prior?.bestMoveCount);
  }

  test('first clear → firstClear + best = result, not perfect (AC8)', () async {
    final outcome = await record(9, 2);
    expect(outcome, BestOutcome.firstClear);
    final best = await repo.read(guest, level);
    expect(best!.bestMoveCount, 9);
    expect(best.isPerfect, isFalse);
  });

  test('a worse result → noImprovement, best unchanged (AC5)', () async {
    await record(9, 2);
    final outcome = await record(11, 1);
    expect(outcome, BestOutcome.noImprovement);
    expect((await repo.read(guest, level))!.bestMoveCount, 9);
  });

  test('a better result → newBest, best updates, isPerfect iff == optimal '
      '(AC6)', () async {
    await record(9, 2);
    final outcome = await record(6, 3);
    expect(outcome, BestOutcome.newBest);
    final best = await repo.read(guest, level);
    expect(best!.bestMoveCount, 6);
    expect(best.isPerfect, isTrue); // 6 == optimal
  });

  test('an equal result → matchedBest, no rewrite', () async {
    await record(6, 3);
    final outcome = await record(6, 3);
    expect(outcome, BestOutcome.matchedBest);
    expect((await repo.read(guest, level))!.bestMoveCount, 6);
  });

  test(
    'Perfect then a Perfect replay → stays optimal + Perfect, not newBest',
    () async {
      await record(6, 3);
      final outcome = await record(6, 3);
      expect(outcome, BestOutcome.matchedBest);
      final best = await repo.read(guest, level);
      expect(best!.bestMoveCount, 6);
      expect(best.isPerfect, isTrue);
    },
  );

  test('bestOutcomeFor is pure over prior-best', () {
    expect(bestOutcomeFor(player: 5, priorBest: null), BestOutcome.firstClear);
    expect(bestOutcomeFor(player: 4, priorBest: 6), BestOutcome.newBest);
    expect(bestOutcomeFor(player: 6, priorBest: 6), BestOutcome.matchedBest);
    expect(bestOutcomeFor(player: 8, priorBest: 6), BestOutcome.noImprovement);
  });
}
