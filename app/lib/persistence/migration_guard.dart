import 'package:drift/drift.dart';

/// Thrown when a Drift `onUpgrade` step would reduce the row count of a
/// protected player-data table. It aborts the migration transaction without a
/// partial apply — the app keeps the old DB and surfaces a recoverable error
/// rather than silently wiping data (F08 architecture → Persistence Schema;
/// F08 AC9; `release.md` §6 "never ship a migration that drops personal_best /
/// daily_streak / first-run daily_entry rows").
class MigrationDataLossError extends StateError {
  MigrationDataLossError(super.message);
}

/// Guards forward migrations against player-data loss.
abstract final class MigrationGuard {
  /// Tables whose row count must never shrink across a migration.
  static const List<String> protectedTables = <String>[
    'personal_best',
    'daily_entry',
    'daily_streak',
  ];

  /// Runs [migration], then verifies no protected table lost rows. Throws
  /// [MigrationDataLossError] (which propagates out of `onUpgrade` and rolls the
  /// migration back) if any did.
  static Future<void> guardPlayerData(
    GeneratedDatabase db,
    Future<void> Function() migration,
  ) async {
    final before = await _counts(db);
    await migration();
    final after = await _counts(db);
    for (final table in protectedTables) {
      final b = before[table] ?? 0;
      final a = after[table] ?? 0;
      if (a < b) {
        throw MigrationDataLossError(
          'migration dropped rows from "$table": $b -> $a',
        );
      }
    }
  }

  static Future<Map<String, int>> _counts(GeneratedDatabase db) async {
    final result = <String, int>{};
    for (final table in protectedTables) {
      final row = await db
          .customSelect('SELECT COUNT(*) AS c FROM $table')
          .getSingle();
      result[table] = row.read<int>('c');
    }
    return result;
  }
}
