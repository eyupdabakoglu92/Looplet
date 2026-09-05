// Shared content value types. They cross package boundaries — `looplet_solver`
// produces a DifficultyLabel, `looplet_content` serializes it, the app reads it
// — so they live in looplet_core (same rationale as the engine primitives) and
// looplet_content re-exports them.

/// What a puzzle is used for.
enum PuzzleType { journey, daily }

/// The difficulty band assigned to a puzzle.
enum DifficultyLabel { easy, medium, hard, expert }
