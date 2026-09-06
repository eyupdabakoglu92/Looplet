import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// Builds an [EngineConfig] from a content [Puzzle].
///
/// `looplet_content` deliberately does not depend on `looplet_engine`
/// (`platform.md` §3), so this conversion lives in a consumer that does. F05
/// (Journey) and F07 (Daily) share this helper; F08 uses it to rebuild a saved
/// session. See
/// `ai-system/features/f06-puzzle-content-and-solver-tooling/architecture.md`
/// → "`Puzzle` → `EngineConfig`".
///
/// Throws [EngineConfigError] if the puzzle is structurally invalid (wrong
/// dimensions, empty cell, target length mismatch, locked∩frozen, …).
EngineConfig toEngineConfig(Puzzle puzzle) => EngineConfig(
  initialGrid: <List<String>>[for (final row in puzzle.grid) row.split('')],
  targetWord: puzzle.targetWord,
  lockedCells: puzzle.lockedCells,
  frozenCells: puzzle.frozenCells,
  columnMovesEnabled: puzzle.columnMovesEnabled,
);
