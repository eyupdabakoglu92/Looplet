import 'package:flutter/foundation.dart';

/// F04 star rating — a **pure function** over the player's net move count and the
/// puzzle's solver-verified optimal (`architecture.md` §4). No I/O.
///
/// * `player` — `engine.moveCount`, i.e. moves net of undos (F03).
/// * `optimal` — `Puzzle.optimalMoves` (F06; always ≥ 1 for a shipped puzzle).
///
/// Mapping:
/// * `3` ⇔ `player == optimal` ("Perfect")
/// * `2` ⇔ `optimal < player <= optimal + 3` (upper boundary inclusive — AC9)
/// * `1` ⇔ `player >= optimal + 4` (AC10) — and the floor: **never 0** (AC4)
///
/// `player < optimal` is impossible (optimal is a proven minimum). If it ever
/// occurs it is treated defensively as `3` and logged — never a crash, never 0.
int starsForResult({required int player, required int optimal}) {
  if (player < optimal) {
    debugPrint(
      'star_rating: player $player < optimal $optimal — defensive 3 stars',
    );
    return 3;
  }
  if (player == optimal) {
    return 3;
  }
  if (player <= optimal + 3) {
    return 2;
  }
  return 1;
}

/// `true` ⇔ [starsForResult] is 3 ⇔ (for every valid input) `player == optimal`.
///
/// Kept as `stars == 3` so the panel's "Perfect ⇔ 3 stars" invariant
/// (`architecture.md` §5) holds even for the defensive `player < optimal` path.
bool isPerfectResult({required int player, required int optimal}) =>
    starsForResult(player: player, optimal: optimal) == 3;
