import 'package:flutter/foundation.dart';

import '../persistence/active_session_snapshot.dart' show PuzzleSource;

export '../persistence/active_session_snapshot.dart' show PuzzleSource;

/// Route arguments for `'/play'` (`architecture.md` §13).
///
/// F03 ships a single real navigation shape (`source` + an optional Journey
/// level) plus a `debugPuzzleId` used only by the temporary debug entry on the
/// placeholder home. F05 (Journey) / F07 (Daily) resolve the real puzzle for a
/// given `source`; `debugPuzzleId` goes away with F05.
@immutable
class PlaySessionArgs {
  const PlaySessionArgs({
    required this.source,
    this.journeyLevel,
    this.debugPuzzleId,
  });

  final PuzzleSource source;

  /// 1..30 — set for a Journey entry (F05). Not used yet for puzzle resolution.
  final int? journeyLevel;

  /// A `content/smoke/tr` puzzle id for the debug entry only.
  final String? debugPuzzleId;

  /// Stable key for a `FutureProvider.family` and for equality in tests.
  String get key =>
      'src:${source.name}|lvl:${journeyLevel ?? '-'}|dbg:${debugPuzzleId ?? '-'}';

  @override
  bool operator ==(Object other) =>
      other is PlaySessionArgs &&
      other.source == source &&
      other.journeyLevel == journeyLevel &&
      other.debugPuzzleId == debugPuzzleId;

  @override
  int get hashCode => Object.hash(source, journeyLevel, debugPuzzleId);

  @override
  String toString() => 'PlaySessionArgs($key)';
}
