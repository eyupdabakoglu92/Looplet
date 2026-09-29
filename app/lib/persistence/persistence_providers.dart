import 'dart:io';

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
import 'store_recovery.dart';

/// Where the on-device store lives (`<app-documents>/looplet.sqlite`). The
/// bootstrap reads it to quarantine an unreadable store; tests point it at a
/// temporary directory to exercise the real file connection.
final appStoreFileProvider = Provider<Future<File> Function()>(
  (ref) => defaultStoreFile,
);

/// The single on-device [AppDatabase]. Opened lazily; closed when the provider
/// container is disposed (app shutdown). The bootstrap replaces it with a fresh
/// connection after a recreate or before a Retry (`bootstrap.dart`, F08
/// Activation A1 / A2). Override in tests with an in-memory DB.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.at(ref.watch(appStoreFileProvider));
  ref.onDispose(db.close);
  return db;
});

/// Launch-scoped store state (the recreate loop guard, the stale-connection
/// flag). Never invalidated, so it outlives every bootstrap run in a launch.
final storeLaunchStateProvider = Provider<StoreLaunchState>(
  (ref) => StoreLaunchState(),
);

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
