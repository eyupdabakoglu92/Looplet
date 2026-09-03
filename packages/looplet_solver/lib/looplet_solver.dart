/// Minimum-move solver for LOOPLET puzzles (F06).
///
/// Scaffold barrel. The search (bidirectional BFS over a packed canonical
/// grid-state hash, per `platform.md` §13) is implemented in F06.
library looplet_solver;

export 'src/placeholder.dart';
