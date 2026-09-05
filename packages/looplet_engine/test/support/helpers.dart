import 'package:looplet_core/looplet_core.dart';
import 'package:looplet_engine/looplet_engine.dart';

/// A [WordValidator] backed by an explicit word set, with Turkish-locale
/// normalization matching F01's `DictionaryService`.
class SetWordValidator implements WordValidator {
  SetWordValidator(Iterable<String> words)
      : _words = words.map(TurkishCase.toLowerTr).toSet();

  final Set<String> _words;

  @override
  bool isValidWord(String candidate, {int minLength = 1}) {
    if (candidate.runes.length < minLength) return false;
    return _words.contains(TurkishCase.toLowerTr(candidate));
  }
}

/// Builds an [EngineConfig] from row strings like `'KAMEL'`.
EngineConfig cfg(
  List<String> rows, {
  required String target,
  Set<GridCoord> locked = const <GridCoord>{},
  Set<GridCoord> frozen = const <GridCoord>{},
  bool columns = true,
}) =>
    EngineConfig(
      initialGrid: <List<String>>[for (final r in rows) r.split('')],
      targetWord: target,
      lockedCells: locked,
      frozenCells: frozen,
      columnMovesEnabled: columns,
    );

/// Row `r` of a state as a plain string.
String rowOf(GridState state, int r) => state.letters[r].join();

/// The whole grid as a `/`-joined string of rows.
String gridOf(GridState state) =>
    List<int>.generate(state.letters.length, (r) => r)
        .map((r) => rowOf(state, r))
        .join('/');
