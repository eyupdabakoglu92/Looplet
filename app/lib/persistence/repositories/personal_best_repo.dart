import 'package:drift/drift.dart';

import '../app_database.dart';

/// Per-level best move count (product PRD §15 `PersonalBest`). Written by F04 on
/// completion. **Monotone** — `bestMoveCount` only decreases; a worse result
/// never overwrites a better one. `isPerfect` = best equals the puzzle's
/// `optimalMoves`.
class PersonalBestRepo {
  PersonalBestRepo(this._db);

  final AppDatabase _db;

  Future<PersonalBest?> read(String guestId, String levelId) =>
      (_db.select(_db.personalBests)..where(
            (t) => t.guestId.equals(guestId) & t.levelId.equals(levelId),
          ))
          .getSingleOrNull();

  /// Records a completion. Returns `true` if this became the new best (or the
  /// first record), `false` if an equal-or-better best already existed.
  /// Write-through, transactional.
  Future<bool> recordCompletion({
    required String guestId,
    required String levelId,
    required int moveCount,
    required int stars,
    required int optimalMoves,
    required int completedAtUtcMs,
  }) async {
    return _db.transaction(() async {
      final existing = await read(guestId, levelId);
      if (existing != null && existing.bestMoveCount <= moveCount) {
        return false;
      }
      final companion = PersonalBestsCompanion(
        guestId: Value(guestId),
        levelId: Value(levelId),
        bestMoveCount: Value(moveCount),
        stars: Value(stars),
        isPerfect: Value(moveCount == optimalMoves),
        // First-completion timestamp is preserved once set.
        firstCompletedAtUtcMs: Value(
          existing?.firstCompletedAtUtcMs ?? completedAtUtcMs,
        ),
      );
      await _db.into(_db.personalBests).insertOnConflictUpdate(companion);
      return true;
    });
  }
}
