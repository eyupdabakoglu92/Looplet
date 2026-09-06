import 'package:drift/drift.dart';

import '../app_database.dart';

/// Durable storage for the daily streak (product PRD §15 `DailyStreak`).
///
/// **Store-only.** F08 does NOT own the increment/reset rule or the rollover
/// decision — those are F07 (F08 architecture → Streak-Integrity / Clock). This
/// repo writes exactly what F07 computes. `lastCompletedDate` is a plain local
/// `YYYY-MM-DD` string.
class DailyStreakRepo {
  DailyStreakRepo(this._db);

  final AppDatabase _db;

  Future<DailyStreak> read(String guestId) => (_db.select(
    _db.dailyStreaks,
  )..where((t) => t.guestId.equals(guestId))).getSingle();

  Stream<DailyStreak> watch(String guestId) => (_db.select(
    _db.dailyStreaks,
  )..where((t) => t.guestId.equals(guestId))).watchSingle();

  /// Persists the streak state F07 computed. `bestStreak` is expected to be
  /// monotone by F07; this repo does not second-guess it. Write-through.
  Future<void> write(
    String guestId, {
    required int currentStreak,
    required int bestStreak,
    required String? lastCompletedDate,
  }) => (_db.update(_db.dailyStreaks)..where((t) => t.guestId.equals(guestId)))
      .write(
        DailyStreaksCompanion(
          currentStreak: Value(currentStreak),
          bestStreak: Value(bestStreak),
          lastCompletedDate: Value(lastCompletedDate),
        ),
      );
}
