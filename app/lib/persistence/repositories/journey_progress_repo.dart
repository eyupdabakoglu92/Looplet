import 'package:drift/drift.dart';

import '../app_database.dart';

/// Journey unlock state (product PRD §15 `JourneyProgress`). Written by F05 on
/// level completion. Linear unlock: completing level N makes N+1 available;
/// stars do not gate (product PRD §6.1 F05).
class JourneyProgressRepo {
  JourneyProgressRepo(this._db);

  final AppDatabase _db;

  Future<JourneyProgressRow> read(String guestId) => (_db.select(
    _db.journeyProgressRows,
  )..where((t) => t.guestId.equals(guestId))).getSingle();

  Stream<JourneyProgressRow> watch(String guestId) => (_db.select(
    _db.journeyProgressRows,
  )..where((t) => t.guestId.equals(guestId))).watchSingle();

  Future<Set<int>> completedLevels(String guestId) async =>
      _parseCsv((await read(guestId)).completedLevelsCsv);

  /// Marks [levelNumber] complete and unlocks the next level. Write-through,
  /// transactional, idempotent (re-completing a level is a no-op for progress).
  Future<void> markCompleted(String guestId, int levelNumber) async {
    await _db.transaction(() async {
      final row = await read(guestId);
      final completed = _parseCsv(row.completedLevelsCsv)..add(levelNumber);
      final highest = row.highestUnlockedLevel > levelNumber + 1
          ? row.highestUnlockedLevel
          : levelNumber + 1;
      await (_db.update(
        _db.journeyProgressRows,
      )..where((t) => t.guestId.equals(guestId))).write(
        JourneyProgressRowsCompanion(
          completedLevelsCsv: Value(_toCsv(completed)),
          highestUnlockedLevel: Value(highest),
        ),
      );
    });
  }

  static Set<int> _parseCsv(String csv) => csv
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map(int.parse)
      .toSet();

  static String _toCsv(Set<int> levels) => (levels.toList()..sort()).join(',');
}
