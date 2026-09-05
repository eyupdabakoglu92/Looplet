/// Deterministic, headless rules engine for the LOOPLET 5×5 grid (F02).
///
/// Two layers:
/// * pure core — [GridState] + [GridState.applyMove], with no side effects,
///   for the F06 solver's state-space search ([GridState.canonicalKey]);
/// * stateful façade — [GridEngine] with move history, [GridEngine.undo] and
///   [GridEngine.restart], for the F03 play session.
///
/// Contract: `ai-system/features/f02-grid-engine/architecture.md`.
library looplet_engine;

export 'src/engine_config.dart';
export 'src/grid_engine.dart';
export 'src/grid_state.dart';
export 'src/move.dart';
export 'src/word_validator.dart';
