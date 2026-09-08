import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

import '../engine/engine_providers.dart';
import '../journey/journey_content.dart';
import '../persistence/persistence_providers.dart';
import 'debug_puzzle_library.dart';
import 'play_session_args.dart';

/// Everything the play screen needs before it can build a controller: the
/// resolved [Puzzle] and the production [WordValidator].
@immutable
class PlaySessionSetup {
  const PlaySessionSetup({required this.puzzle, required this.validator});
  final Puzzle puzzle;
  final WordValidator validator;
}

final debugPuzzleLibraryProvider = Provider<DebugPuzzleLibrary>(
  (ref) => const DebugPuzzleLibrary(),
);

/// Resolves the puzzle + validator for a given [PlaySessionArgs].
///
/// F03 only wires the **debug** path (`args.debugPuzzleId`). F05 adds Journey
/// resolution (bundled content by `journeyLevel`) and F07 the Daily cache — both
/// against this same provider shape.
final playSessionSetupProvider =
    FutureProvider.family<PlaySessionSetup, PlaySessionArgs>((ref, args) async {
      final validator = await ref.watch(wordValidatorProvider.future);

      final debugId = args.debugPuzzleId;
      if (debugId != null) {
        final puzzle = ref.watch(debugPuzzleLibraryProvider).load(debugId);
        return PlaySessionSetup(puzzle: puzzle, validator: validator);
      }

      // F05 — Journey: resolve the bundled level by number (`architecture.md
      // §5.3`). A missing/corrupt manifest entry or asset throws
      // `JourneyContentException`, which the `/play` screen renders as F03's
      // load-error state (the rest of the Journey stays playable).
      final level = args.journeyLevel;
      if (args.source == PuzzleSource.journey && level != null) {
        String lang = 'tr';
        try {
          final guestId = await ref.watch(currentGuestIdProvider.future);
          lang = (await ref.watch(settingsRepoProvider).read(guestId)).language;
        } catch (_) {
          // No settings row (tests / first launch) — fall back to the launch
          // language.
        }
        final puzzle = await ref
            .watch(journeyContentRepoProvider)
            .loadLevel(level, lang);
        return PlaySessionSetup(puzzle: puzzle, validator: validator);
      }

      // F07 territory — Daily content resolution does not exist yet.
      throw UnsupportedError(
        'play session for source "${args.source.name}" is not wired yet '
        '(F07 Daily). Use a Journey level or the debug entry.',
      );
    });
