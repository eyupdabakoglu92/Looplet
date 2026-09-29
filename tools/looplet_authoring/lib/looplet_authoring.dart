/// Build-time level-authoring toolchain for LOOPLET (F06).
///
/// CLI: `solve` / `playtest` / `export` / `check` / `fill` / `pack-daily`.
/// Never shipped in the app. Contract:
/// `ai-system/features/f06-puzzle-content-and-solver-tooling/architecture.md`;
/// `pack-daily` and the Daily rules of `check`: F07 `architecture.md` D2.
library looplet_authoring;

export 'src/cli.dart' show buildRunner;
export 'src/content_check.dart' show runContentCheck;
export 'src/daily_dev_fixture.dart';
export 'src/daily_source.dart';
export 'src/move_shorthand.dart';
export 'src/puzzle_def.dart';
export 'src/turkish_frequency.dart';
