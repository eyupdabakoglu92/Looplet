import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

import '../engine/engine_providers.dart';
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

      // F05 / F07 territory — no real content resolution exists yet.
      throw UnsupportedError(
        'play session for source "${args.source.name}" is not wired yet '
        '(F05 Journey / F07 Daily). Use the debug entry.',
      );
    });
