import 'package:looplet_core/looplet_core.dart';

import '../engine/move_shorthand.dart';

/// Raised by [ActiveSessionSnapshot.fromJson] for any malformed snapshot. The
/// caller discards the active snapshot (durable tables are untouched) and
/// recovers to a clean state — F08 AC8.
class SnapshotFormatException implements Exception {
  SnapshotFormatException(this.message);

  final String message;

  @override
  String toString() => 'SnapshotFormatException: $message';
}

/// Which content set the saved puzzle came from.
enum PuzzleSource {
  journey,
  daily;

  static PuzzleSource parse(String raw) => switch (raw) {
    'journey' => PuzzleSource.journey,
    'daily' => PuzzleSource.daily,
    _ => throw SnapshotFormatException('unknown puzzleSource "$raw"'),
  };
}

/// Lifecycle of the persisted session.
enum ActiveSessionStatus {
  inProgress,
  completed;

  static ActiveSessionStatus parse(String raw) => switch (raw) {
    'inProgress' => ActiveSessionStatus.inProgress,
    'completed' => ActiveSessionStatus.completed,
    _ => throw SnapshotFormatException('unknown status "$raw"'),
  };
}

/// The in-progress puzzle, serialized to `kv['active_session']`.
///
/// **The JSON key names are a frozen contract** — F03 (play session) serializes
/// its state into exactly this shape. See
/// `ai-system/features/f08-offline-persistence-and-sync/architecture.md`
/// → "Active-Session Snapshot Contract".
///
/// `appliedMoves` (F06 `R/L/D/U<i>` shorthand) **is** the undo history — F02's
/// `undo` re-folds from t=0, so there is no separate undo stack.
/// `thawedFrozenCells` is a **cache**; on restore the authority is re-derived by
/// replaying `appliedMoves` through the engine.
class ActiveSessionSnapshot {
  ActiveSessionSnapshot({
    this.snapshotVersion = currentSnapshotVersion,
    required this.puzzleId,
    required this.puzzleSource,
    required this.lang,
    required List<String> appliedMoves,
    required this.undosRemaining,
    required this.restartCount,
    required this.elapsedMsAccumulated,
    required List<String> thawedFrozenCells,
    required this.status,
    required this.startedAtUtcMs,
    required this.lastPersistedAtUtcMs,
  }) : appliedMoves = List<String>.unmodifiable(appliedMoves),
       thawedFrozenCells = List<String>.unmodifiable(thawedFrozenCells) {
    if (snapshotVersion != currentSnapshotVersion) {
      throw SnapshotFormatException(
        'unsupported snapshotVersion $snapshotVersion',
      );
    }
    if (puzzleId.isEmpty) {
      throw SnapshotFormatException('puzzleId must be non-empty');
    }
    if (!ActiveSessionSnapshot.supportedLanguages.contains(lang)) {
      throw SnapshotFormatException('unsupported lang "$lang"');
    }
    if (undosRemaining < 0 || undosRemaining > maxUndos) {
      throw SnapshotFormatException(
        'undosRemaining $undosRemaining out of 0..$maxUndos',
      );
    }
    if (restartCount < 0) {
      throw SnapshotFormatException('restartCount must be >= 0');
    }
    if (elapsedMsAccumulated < 0) {
      throw SnapshotFormatException('elapsedMsAccumulated must be >= 0');
    }
    if (startedAtUtcMs <= 0 || lastPersistedAtUtcMs <= 0) {
      throw SnapshotFormatException('timestamps must be > 0');
    }
    // appliedMoves must all be valid shorthand tokens.
    for (final token in this.appliedMoves) {
      try {
        parseMove(token);
      } on MoveShorthandException catch (e) {
        throw SnapshotFormatException('bad appliedMoves token: ${e.message}');
      }
    }
    if (moveCount != this.appliedMoves.length) {
      throw SnapshotFormatException(
        'moveCount $moveCount != appliedMoves.length '
        '${this.appliedMoves.length}',
      );
    }
    for (final coord in this.thawedFrozenCells) {
      if (!_coordPattern.hasMatch(coord)) {
        throw SnapshotFormatException('bad thawedFrozenCells entry "$coord"');
      }
    }
  }

  static const int currentSnapshotVersion = 1;
  static const int maxUndos = 3;
  static const String kvKey = 'active_session';
  static const Set<String> supportedLanguages = <String>{'tr', 'en'};
  static final RegExp _coordPattern = RegExp(r'^\d+,\d+$');

  final int snapshotVersion;
  final String puzzleId;
  final PuzzleSource puzzleSource;
  final String lang;

  /// Ordered applied moves in F06 shorthand — the undo history itself.
  final List<String> appliedMoves;
  final int undosRemaining;
  final int restartCount;
  final int elapsedMsAccumulated;

  /// `"r,c"` strings — a render cache, re-derived as authority on restore.
  final List<String> thawedFrozenCells;
  final ActiveSessionStatus status;
  final int startedAtUtcMs;
  final int lastPersistedAtUtcMs;

  /// Derived: always equal to `appliedMoves.length`.
  int get moveCount => appliedMoves.length;

  Set<GridCoord> get thawedCoords => <GridCoord>{
    for (final entry in thawedFrozenCells)
      GridCoord(int.parse(entry.split(',')[0]), int.parse(entry.split(',')[1])),
  };

  ActiveSessionSnapshot copyWith({
    List<String>? appliedMoves,
    int? undosRemaining,
    int? restartCount,
    int? elapsedMsAccumulated,
    List<String>? thawedFrozenCells,
    ActiveSessionStatus? status,
    int? lastPersistedAtUtcMs,
  }) => ActiveSessionSnapshot(
    snapshotVersion: snapshotVersion,
    puzzleId: puzzleId,
    puzzleSource: puzzleSource,
    lang: lang,
    appliedMoves: appliedMoves ?? this.appliedMoves,
    undosRemaining: undosRemaining ?? this.undosRemaining,
    restartCount: restartCount ?? this.restartCount,
    elapsedMsAccumulated: elapsedMsAccumulated ?? this.elapsedMsAccumulated,
    thawedFrozenCells: thawedFrozenCells ?? this.thawedFrozenCells,
    status: status ?? this.status,
    startedAtUtcMs: startedAtUtcMs,
    lastPersistedAtUtcMs: lastPersistedAtUtcMs ?? this.lastPersistedAtUtcMs,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'snapshotVersion': snapshotVersion,
    'puzzleId': puzzleId,
    'puzzleSource': puzzleSource.name,
    'lang': lang,
    'appliedMoves': appliedMoves,
    'moveCount': moveCount,
    'undosRemaining': undosRemaining,
    'restartCount': restartCount,
    'elapsedMsAccumulated': elapsedMsAccumulated,
    'thawedFrozenCells': thawedFrozenCells,
    'status': status.name,
    'startedAtUtcMs': startedAtUtcMs,
    'lastPersistedAtUtcMs': lastPersistedAtUtcMs,
  };

  static ActiveSessionSnapshot fromJson(Map<String, Object?> json) {
    int reqInt(String key) {
      final value = json[key];
      if (value is! int) {
        throw SnapshotFormatException('"$key" must be an int');
      }
      return value;
    }

    String reqStr(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw SnapshotFormatException('"$key" must be a non-empty string');
      }
      return value;
    }

    List<String> reqStrList(String key) {
      final value = json[key];
      if (value is! List) {
        throw SnapshotFormatException('"$key" must be an array');
      }
      return <String>[
        for (final entry in value)
          if (entry is String)
            entry
          else
            throw SnapshotFormatException('"$key" entries must be strings'),
      ];
    }

    final appliedMoves = reqStrList('appliedMoves');
    final declaredMoveCount = reqInt('moveCount');
    if (declaredMoveCount != appliedMoves.length) {
      throw SnapshotFormatException(
        'moveCount $declaredMoveCount != appliedMoves.length '
        '${appliedMoves.length}',
      );
    }

    return ActiveSessionSnapshot(
      snapshotVersion: reqInt('snapshotVersion'),
      puzzleId: reqStr('puzzleId'),
      puzzleSource: PuzzleSource.parse(reqStr('puzzleSource')),
      lang: reqStr('lang'),
      appliedMoves: appliedMoves,
      undosRemaining: reqInt('undosRemaining'),
      restartCount: reqInt('restartCount'),
      elapsedMsAccumulated: reqInt('elapsedMsAccumulated'),
      thawedFrozenCells: reqStrList('thawedFrozenCells'),
      status: ActiveSessionStatus.parse(reqStr('status')),
      startedAtUtcMs: reqInt('startedAtUtcMs'),
      lastPersistedAtUtcMs: reqInt('lastPersistedAtUtcMs'),
    );
  }
}
