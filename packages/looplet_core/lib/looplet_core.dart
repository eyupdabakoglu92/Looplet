/// Shared primitives for LOOPLET.
///
/// Turkish-locale case conversion + dictionary normalization, and the engine
/// primitive value types (`MoveAxis`, `MoveDirection`, `TileStatus`,
/// `GridCoord`). Shared value types and `Result` helpers land here as later
/// features need them.
library looplet_core;

export 'src/grid_primitives.dart';
export 'src/normalize.dart';
export 'src/turkish_case.dart';
