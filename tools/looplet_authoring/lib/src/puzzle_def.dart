import 'dart:convert';
import 'dart:io';

import 'package:looplet_content/looplet_content.dart';
import 'package:looplet_engine/looplet_engine.dart';
import 'package:looplet_solver/looplet_solver.dart';

/// Thrown for a malformed puzzle-definition file.
class PuzzleDefException implements Exception {
  PuzzleDefException(this.message);
  final String message;
  @override
  String toString() => 'PuzzleDefException: $message';
}

/// A raw authored puzzle definition (the CLI input). Turns into an
/// [EngineConfig] for the solver and into a [Puzzle] artifact on export.
class PuzzleDef {
  PuzzleDef({
    required this.id,
    required this.puzzleType,
    this.journeyLevelNumber,
    this.dailyDate,
    required this.language,
    required this.grid,
    required this.target,
    required this.locked,
    required this.frozen,
    required this.columns,
  });

  final String id;
  final PuzzleType puzzleType;
  final int? journeyLevelNumber;
  final String? dailyDate;
  final String language;
  final List<String> grid;
  final String target;
  final Set<GridCoord> locked;
  final Set<GridCoord> frozen;
  final bool columns;

  static PuzzleDef fromFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw PuzzleDefException('no such def file: $path');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (e) {
      throw PuzzleDefException('def file is not valid JSON: ${e.message}');
    }
    if (decoded is! Map) {
      throw PuzzleDefException('def file root must be a JSON object');
    }
    return fromJson(decoded.cast<String, Object?>());
  }

  static PuzzleDef fromJson(Map<String, Object?> json) {
    String str(String key) {
      final v = json[key];
      if (v is! String || v.isEmpty) {
        throw PuzzleDefException('"$key" must be a non-empty string');
      }
      return v;
    }

    final typeRaw = str('puzzleType');
    final type = switch (typeRaw) {
      'journey' => PuzzleType.journey,
      'daily' => PuzzleType.daily,
      _ => throw PuzzleDefException('unknown puzzleType "$typeRaw"'),
    };

    final gridRaw = json['grid'];
    if (gridRaw is! List) throw PuzzleDefException('"grid" must be an array');
    final grid = <String>[
      for (final row in gridRaw)
        if (row is String && row.isNotEmpty)
          row
        else
          throw PuzzleDefException('"grid" rows must be non-empty strings'),
    ];

    Set<GridCoord> coords(String key) {
      final v = json[key];
      if (v == null) return <GridCoord>{};
      if (v is! List) throw PuzzleDefException('"$key" must be an array');
      return <GridCoord>{
        for (final entry in v) _coord(entry, key),
      };
    }

    return PuzzleDef(
      id: str('id'),
      puzzleType: type,
      journeyLevelNumber: json['journeyLevelNumber'] is int
          ? json['journeyLevelNumber']! as int
          : null,
      dailyDate:
          json['dailyDate'] is String ? json['dailyDate']! as String : null,
      language: str('language'),
      grid: grid,
      target: str('target'),
      locked: coords('locked'),
      frozen: coords('frozen'),
      columns: json['columns'] is bool ? json['columns']! as bool : true,
    );
  }

  static GridCoord _coord(Object? raw, String key) {
    if (raw is! String) {
      throw PuzzleDefException('"$key" entries must be "row,col" strings');
    }
    final parts = raw.split(',');
    final row = parts.length == 2 ? int.tryParse(parts[0].trim()) : null;
    final col = parts.length == 2 ? int.tryParse(parts[1].trim()) : null;
    if (row == null || col == null || row < 0 || col < 0) {
      throw PuzzleDefException('bad coordinate "$raw" in "$key"');
    }
    return GridCoord(row, col);
  }

  /// Builds the engine config. Throws [EngineConfigError] (from F02) for a
  /// structurally invalid grid.
  EngineConfig toEngineConfig() => EngineConfig(
        initialGrid: <List<String>>[for (final row in grid) row.split('')],
        targetWord: target,
        lockedCells: locked,
        frozenCells: frozen,
        columnMovesEnabled: columns,
      );

  Puzzle toPuzzle({
    required int optimalMoves,
    required Difficulty difficulty,
    required String contentVersion,
  }) =>
      Puzzle(
        schemaVersion: Puzzle.currentSchemaVersion,
        contentVersion: contentVersion,
        id: id,
        puzzleType: puzzleType,
        journeyLevelNumber: journeyLevelNumber,
        dailyDate: dailyDate,
        language: language,
        grid: grid,
        targetWord: target,
        lockedCells: locked,
        frozenCells: frozen,
        columnMovesEnabled: columns,
        optimalMoves: optimalMoves,
        difficultyScore: double.parse(difficulty.score.toStringAsFixed(3)),
        difficultyLabel: difficulty.label,
        difficultyBreakdown: difficulty.breakdown,
      );
}
