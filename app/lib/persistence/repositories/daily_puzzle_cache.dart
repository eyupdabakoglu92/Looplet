import 'package:drift/drift.dart';

import '../app_database.dart';

/// Local cache of previously-fetched Daily puzzles, so a pre-fetched Daily is
/// playable offline (F08 AC3).
///
/// F08 owns this store + interface (**mechanism only**). F07 owns *when* to
/// populate it, the fetch cadence, and the retention window
/// (F08 architecture → `[OPEN — F07]`).
class DailyPuzzleCache {
  DailyPuzzleCache(this._db);

  final AppDatabase _db;

  /// Stores (or replaces) the `Puzzle` JSON for `(lang, dailyDate)`.
  Future<void> put({
    required String lang,
    required String dailyDate,
    required String puzzleJson,
    required int fetchedAtUtcMs,
  }) => _db
      .into(_db.dailyPuzzleCacheRows)
      .insertOnConflictUpdate(
        DailyPuzzleCacheRowsCompanion.insert(
          lang: lang,
          dailyDate: dailyDate,
          puzzleJson: puzzleJson,
          fetchedAtUtcMs: fetchedAtUtcMs,
        ),
      );

  /// The cached `Puzzle` JSON, or null if nothing was fetched for that date.
  Future<String?> get(String lang, String dailyDate) async {
    final row =
        await (_db.select(_db.dailyPuzzleCacheRows)..where(
              (t) => t.lang.equals(lang) & t.dailyDate.equals(dailyDate),
            ))
            .getSingleOrNull();
    return row?.puzzleJson;
  }

  /// Drops cache rows with `dailyDate` strictly before [cutoffDailyDate]
  /// (`YYYY-MM-DD` strings sort chronologically). Returns the number removed.
  Future<int> evictOlderThan(String cutoffDailyDate) => (_db.delete(
    _db.dailyPuzzleCacheRows,
  )..where((t) => t.dailyDate.isSmallerThanValue(cutoffDailyDate))).go();
}
