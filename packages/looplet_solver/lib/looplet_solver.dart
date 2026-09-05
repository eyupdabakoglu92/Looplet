/// Build-time minimum-move solver for LOOPLET puzzles (F06).
///
/// Forward BFS over the F02 engine's `GridState.canonicalKey` state space:
/// `Solver.solve` returns the provable minimum (`Optimal`), `Unsolvable`, or
/// `BudgetExceeded`. Never runs on device. Also hosts the deterministic
/// difficulty scorer.
///
/// Contract: `ai-system/features/f06-puzzle-content-and-solver-tooling/architecture.md`.
library looplet_solver;

export 'src/difficulty.dart';
export 'src/solve_result.dart';
export 'src/solver.dart';
