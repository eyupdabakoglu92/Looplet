import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';

Map<String, Object?> validJson() => <String, Object?>{
  'snapshotVersion': 1,
  'puzzleId': 'journey-tr-14',
  'puzzleSource': 'journey',
  'lang': 'tr',
  'appliedMoves': <String>['R0', 'D2', 'L4', 'U1'],
  'moveCount': 4,
  'undosRemaining': 2,
  'restartCount': 1,
  'elapsedMsAccumulated': 41200,
  'thawedFrozenCells': <String>['4,4'],
  'status': 'inProgress',
  'startedAtUtcMs': 1757145000000,
  'lastPersistedAtUtcMs': 1757145041200,
};

void main() {
  test('round-trips losslessly', () {
    final snapshot = ActiveSessionSnapshot.fromJson(validJson());
    expect(snapshot.toJson(), validJson());
    expect(snapshot.moveCount, 4);
    expect(snapshot.puzzleSource, PuzzleSource.journey);
    expect(snapshot.status, ActiveSessionStatus.inProgress);
  });

  test('parses thawed coords', () {
    final s = ActiveSessionSnapshot.fromJson(validJson());
    final coord = s.thawedCoords.single;
    expect(coord.row, 4);
    expect(coord.col, 4);
  });

  group('rejects malformed input', () {
    void expectReject(void Function(Map<String, Object?>) mutate) {
      final json = validJson();
      mutate(json);
      expect(
        () => ActiveSessionSnapshot.fromJson(json),
        throwsA(isA<SnapshotFormatException>()),
      );
    }

    test(
      'unsupported snapshotVersion',
      () => expectReject((j) => j['snapshotVersion'] = 2),
    );
    test('empty puzzleId', () => expectReject((j) => j['puzzleId'] = ''));
    test(
      'unknown puzzleSource',
      () => expectReject((j) => j['puzzleSource'] = 'weekly'),
    );
    test('unsupported lang', () => expectReject((j) => j['lang'] = 'de'));
    test('unknown status', () => expectReject((j) => j['status'] = 'paused'));
    test(
      'moveCount != appliedMoves.length',
      () => expectReject((j) => j['appliedMoves'] = <String>['R0']),
    );
    test(
      'bad move token',
      () => expectReject(
        (j) => j['appliedMoves'] = <String>['R0', 'X9', 'L4', 'U1'],
      ),
    );
    test(
      'undosRemaining out of range',
      () => expectReject((j) => j['undosRemaining'] = 4),
    );
    test(
      'negative restartCount',
      () => expectReject((j) => j['restartCount'] = -1),
    );
    test(
      'negative elapsed',
      () => expectReject((j) => j['elapsedMsAccumulated'] = -5),
    );
    test(
      'bad thawed coord',
      () => expectReject((j) => j['thawedFrozenCells'] = <String>['4-4']),
    );
    test(
      'non-positive timestamp',
      () => expectReject((j) => j['startedAtUtcMs'] = 0),
    );
    test('wrong type for int', () => expectReject((j) => j['moveCount'] = '4'));
    test('missing key', () => expectReject((j) => j.remove('lang')));
  });

  test('copyWith preserves frozen fields and applies patches', () {
    final s = ActiveSessionSnapshot.fromJson(validJson());
    final next = s.copyWith(
      appliedMoves: <String>['R0', 'D2', 'L4', 'U1', 'R3'],
      undosRemaining: 1,
      status: ActiveSessionStatus.completed,
      lastPersistedAtUtcMs: 1757145099999,
    );
    expect(next.moveCount, 5);
    expect(next.undosRemaining, 1);
    expect(next.status, ActiveSessionStatus.completed);
    expect(next.puzzleId, s.puzzleId);
    expect(next.startedAtUtcMs, s.startedAtUtcMs);
  });
}
