/// Build-time level-authoring toolchain for LOOPLET (F06).
///
/// CLI: `solve` / `playtest` / `export` / `check` / `fill`. Never shipped in the
/// app. Contract:
/// `ai-system/features/f06-puzzle-content-and-solver-tooling/architecture.md`.
library looplet_authoring;

export 'src/cli.dart' show buildRunner;
export 'src/content_check.dart' show runContentCheck;
export 'src/move_shorthand.dart';
export 'src/puzzle_def.dart';
export 'src/turkish_frequency.dart';
