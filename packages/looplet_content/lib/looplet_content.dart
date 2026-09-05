/// Puzzle definition model + JSON serialization for LOOPLET.
///
/// `Puzzle` is the one content schema consumed by F05 (Journey), F07 (Daily),
/// and F08 (persistence). Contract:
/// `ai-system/features/f06-puzzle-content-and-solver-tooling/architecture.md`.
///
/// `PuzzleType` / `DifficultyLabel` and the engine primitive value types are
/// defined in `looplet_core` and re-exported here so downstream code has one
/// import site.
library looplet_content;

export 'package:looplet_core/looplet_core.dart'
    show
        DifficultyLabel,
        GridCoord,
        MoveAxis,
        MoveDirection,
        PuzzleType,
        TileStatus;

export 'src/puzzle.dart';
