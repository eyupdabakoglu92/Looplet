import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wall-clock seam for F04's `completedAtUtcMs` (`architecture.md` §6). Only
/// feeds `personal_best.firstCompletedAtUtcMs`, which `PersonalBestRepo`
/// preserves once set — not used for ordering or anti-cheat. Overridden in
/// tests for determinism.
///
/// The personal-best store itself is F08's `personalBestRepoProvider` and the
/// guest id is F08's `currentGuestIdProvider` — F04 reuses both unchanged
/// (see `persistence/persistence_providers.dart`).
final ratingClockProvider = Provider<DateTime Function()>(
  (ref) =>
      () => DateTime.now().toUtc(),
);
