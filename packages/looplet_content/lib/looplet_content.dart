/// Puzzle definition models and shared schema enums for LOOPLET.
///
/// Scaffold barrel. `Puzzle`, the serialized schema enums (`difficultyLabel`,
/// `puzzleType`), and JSON serialization are implemented alongside F05/F06/F07.
///
/// The engine primitive value types (`MoveAxis`, `MoveDirection`, `TileStatus`,
/// `GridCoord`) are defined in `looplet_core` and re-exported here so downstream
/// code has one import site (`platform.md` §11).
library looplet_content;

export 'package:looplet_core/looplet_core.dart'
    show MoveAxis, MoveDirection, TileStatus, GridCoord;

export 'src/placeholder.dart';
