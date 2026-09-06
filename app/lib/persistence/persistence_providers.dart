import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'repositories/active_session_repo.dart';
import 'repositories/daily_puzzle_cache.dart';
import 'repositories/daily_repo.dart';
import 'repositories/daily_streak_repo.dart';
import 'repositories/journey_progress_repo.dart';
import 'repositories/personal_best_repo.dart';
import 'repositories/player_repo.dart';
import 'repositories/settings_repo.dart';
import 'repositories/sync_queue_repo.dart';

/// The single on-device [AppDatabase]. Opened lazily; closed when the provider
/// container is disposed (app shutdown). Override in tests with an in-memory DB.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The seeded guest id (there is exactly one `player` row after first launch).
final currentGuestIdProvider = FutureProvider<String>((ref) async {
  return ref.watch(playerRepoProvider).currentGuestId();
});

final playerRepoProvider = Provider<PlayerRepo>(
  (ref) => PlayerRepo(ref.watch(appDatabaseProvider)),
);

final settingsRepoProvider = Provider<SettingsRepo>(
  (ref) => SettingsRepo(ref.watch(appDatabaseProvider)),
);

final journeyProgressRepoProvider = Provider<JourneyProgressRepo>(
  (ref) => JourneyProgressRepo(ref.watch(appDatabaseProvider)),
);

final personalBestRepoProvider = Provider<PersonalBestRepo>(
  (ref) => PersonalBestRepo(ref.watch(appDatabaseProvider)),
);

final dailyRepoProvider = Provider<DailyRepo>(
  (ref) => DailyRepo(ref.watch(appDatabaseProvider)),
);

final dailyStreakRepoProvider = Provider<DailyStreakRepo>(
  (ref) => DailyStreakRepo(ref.watch(appDatabaseProvider)),
);

final dailyPuzzleCacheProvider = Provider<DailyPuzzleCache>(
  (ref) => DailyPuzzleCache(ref.watch(appDatabaseProvider)),
);

final syncQueueRepoProvider = Provider<SyncQueueRepo>(
  (ref) => SyncQueueRepo(ref.watch(appDatabaseProvider)),
);

final activeSessionRepoProvider = Provider<ActiveSessionRepo>(
  (ref) => ActiveSessionRepo(ref.watch(appDatabaseProvider)),
);
