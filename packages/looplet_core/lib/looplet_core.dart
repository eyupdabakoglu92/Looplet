/// Shared primitives for LOOPLET.
///
/// Turkish-locale case conversion + dictionary normalization; the engine
/// primitive value types (`MoveAxis`, `MoveDirection`, `TileStatus`,
/// `GridCoord`); the content primitives (`PuzzleType`, `DifficultyLabel`).
library looplet_core;

export 'src/content_primitives.dart';
export 'src/grid_primitives.dart';
export 'src/normalize.dart';
export 'src/turkish_case.dart';
