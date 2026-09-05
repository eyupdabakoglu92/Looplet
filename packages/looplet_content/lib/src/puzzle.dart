import 'package:looplet_core/looplet_core.dart';

/// Thrown by [Puzzle.fromJson] for any malformed artifact.
final class PuzzleFormatException implements Exception {
  PuzzleFormatException(this.message);

  final String message;

  @override
  String toString() => 'PuzzleFormatException: $message';
}

/// The authored puzzle definition + solver-verified metadata. The one content
/// schema consumed by F05 (Journey), F07 (Daily), and F08 (persistence).
///
/// `looplet_content` does not depend on `looplet_engine`; a consumer builds the
/// `EngineConfig` from [grid] / [targetWord] / [lockedCells] / [frozenCells] /
/// [columnMovesEnabled].
final class Puzzle {
  Puzzle({
    required this.schemaVersion,
    required this.contentVersion,
    required this.id,
    required this.puzzleType,
    this.journeyLevelNumber,
    this.dailyDate,
    required this.language,
    required List<String> grid,
    required this.targetWord,
    required Set<GridCoord> lockedCells,
    required Set<GridCoord> frozenCells,
    required this.columnMovesEnabled,
    required this.optimalMoves,
    required this.difficultyScore,
    required this.difficultyLabel,
    required Map<String, num> difficultyBreakdown,
  })  : grid = List<String>.unmodifiable(grid),
        lockedCells = Set<GridCoord>.unmodifiable(lockedCells),
        frozenCells = Set<GridCoord>.unmodifiable(frozenCells),
        difficultyBreakdown =
            Map<String, num>.unmodifiable(difficultyBreakdown) {
    if (puzzleType == PuzzleType.journey && journeyLevelNumber == null) {
      throw PuzzleFormatException(
          'journey puzzle "$id" needs journeyLevelNumber');
    }
    if (puzzleType == PuzzleType.daily && dailyDate == null) {
      throw PuzzleFormatException('daily puzzle "$id" needs dailyDate');
    }
  }

  static const int currentSchemaVersion = 1;
  static const Set<String> supportedLanguages = <String>{'tr', 'en'};

  final int schemaVersion;
  final String contentVersion;
  final String id;
  final PuzzleType puzzleType;

  /// 1–30, set for [PuzzleType.journey].
  final int? journeyLevelNumber;

  /// `YYYY-MM-DD`, set for [PuzzleType.daily].
  final String? dailyDate;

  /// `'tr'` | `'en'`.
  final String language;

  /// Row strings, one per grid row, each a run of single letters.
  final List<String> grid;
  final String targetWord;
  final Set<GridCoord> lockedCells;
  final Set<GridCoord> frozenCells;
  final bool columnMovesEnabled;

  /// Solver-verified provable minimum move count. Always present in a valid
  /// artifact.
  final int optimalMoves;

  final num difficultyScore;
  final DifficultyLabel difficultyLabel;
  final Map<String, num> difficultyBreakdown;

  /// Parses [json]. Unknown keys are ignored (forward-compatible). Throws
  /// [PuzzleFormatException] for any missing/typed/shape violation.
  static Puzzle fromJson(Map<String, Object?> json) {
    int reqInt(String key) {
      final value = json[key];
      if (value is! int) {
        throw PuzzleFormatException(
            '"$key" must be an int, got ${value.runtimeType}');
      }
      return value;
    }

    num reqNum(String key) {
      final value = json[key];
      if (value is! num) {
        throw PuzzleFormatException('"$key" must be a number');
      }
      return value;
    }

    String reqStr(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw PuzzleFormatException('"$key" must be a non-empty string');
      }
      return value;
    }

    bool reqBool(String key) {
      final value = json[key];
      if (value is! bool) {
        throw PuzzleFormatException('"$key" must be a bool');
      }
      return value;
    }

    List<String> reqStrList(String key) {
      final value = json[key];
      if (value is! List) {
        throw PuzzleFormatException('"$key" must be an array');
      }
      return <String>[
        for (final entry in value)
          if (entry is String && entry.isNotEmpty)
            entry
          else
            throw PuzzleFormatException(
                '"$key" must contain non-empty strings'),
      ];
    }

    Set<GridCoord> coordSet(String key) {
      final value = json[key];
      if (value == null) return const <GridCoord>{};
      if (value is! List) {
        throw PuzzleFormatException(
            '"$key" must be an array of "row,col" strings');
      }
      return <GridCoord>{
        for (final entry in value) _parseCoord(entry, key),
      };
    }

    final schemaVersion = reqInt('schemaVersion');
    if (schemaVersion != currentSchemaVersion) {
      throw PuzzleFormatException('unsupported schemaVersion $schemaVersion');
    }

    final typeRaw = reqStr('puzzleType');
    final puzzleType = switch (typeRaw) {
      'journey' => PuzzleType.journey,
      'daily' => PuzzleType.daily,
      _ => throw PuzzleFormatException('unknown puzzleType "$typeRaw"'),
    };

    final labelRaw = reqStr('difficultyLabel');
    final difficultyLabel = switch (labelRaw) {
      'easy' => DifficultyLabel.easy,
      'medium' => DifficultyLabel.medium,
      'hard' => DifficultyLabel.hard,
      'expert' => DifficultyLabel.expert,
      _ => throw PuzzleFormatException('unknown difficultyLabel "$labelRaw"'),
    };

    final language = reqStr('language');
    if (!supportedLanguages.contains(language)) {
      throw PuzzleFormatException('unsupported language "$language"');
    }

    final breakdownRaw = json['difficultyBreakdown'];
    if (breakdownRaw is! Map) {
      throw PuzzleFormatException('"difficultyBreakdown" must be an object');
    }
    final difficultyBreakdown = <String, num>{};
    for (final entry in breakdownRaw.entries) {
      final value = entry.value;
      if (value is! num) {
        throw PuzzleFormatException(
            'difficultyBreakdown values must be numbers');
      }
      difficultyBreakdown['${entry.key}'] = value;
    }

    return Puzzle(
      schemaVersion: schemaVersion,
      contentVersion: reqStr('contentVersion'),
      id: reqStr('id'),
      puzzleType: puzzleType,
      journeyLevelNumber: json['journeyLevelNumber'] is int
          ? json['journeyLevelNumber']! as int
          : null,
      dailyDate:
          json['dailyDate'] is String ? json['dailyDate']! as String : null,
      language: language,
      grid: reqStrList('grid'),
      targetWord: reqStr('targetWord'),
      lockedCells: coordSet('lockedCells'),
      frozenCells: coordSet('frozenCells'),
      columnMovesEnabled: reqBool('columnMovesEnabled'),
      optimalMoves: reqInt('optimalMoves'),
      difficultyScore: reqNum('difficultyScore'),
      difficultyLabel: difficultyLabel,
      difficultyBreakdown: difficultyBreakdown,
    );
  }

  Map<String, Object?> toJson() {
    String coord(GridCoord c) => '${c.row},${c.col}';
    List<String> sortedCoords(Set<GridCoord> cells) =>
        (cells.toList()..sort()).map(coord).toList(growable: false);

    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'contentVersion': contentVersion,
      'id': id,
      'puzzleType': puzzleType.name,
      if (journeyLevelNumber != null) 'journeyLevelNumber': journeyLevelNumber,
      if (dailyDate != null) 'dailyDate': dailyDate,
      'language': language,
      'grid': grid,
      'targetWord': targetWord,
      'lockedCells': sortedCoords(lockedCells),
      'frozenCells': sortedCoords(frozenCells),
      'columnMovesEnabled': columnMovesEnabled,
      'optimalMoves': optimalMoves,
      'difficultyScore': difficultyScore,
      'difficultyLabel': difficultyLabel.name,
      'difficultyBreakdown': difficultyBreakdown,
    };
  }

  static GridCoord _parseCoord(Object? raw, String key) {
    if (raw is! String) {
      throw PuzzleFormatException('"$key" entries must be "row,col" strings');
    }
    final parts = raw.split(',');
    if (parts.length != 2) {
      throw PuzzleFormatException('bad coordinate "$raw" in "$key"');
    }
    final row = int.tryParse(parts[0].trim());
    final col = int.tryParse(parts[1].trim());
    if (row == null || col == null || row < 0 || col < 0) {
      throw PuzzleFormatException('bad coordinate "$raw" in "$key"');
    }
    return GridCoord(row, col);
  }
}
