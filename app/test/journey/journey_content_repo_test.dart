import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart';

/// A hand-built `journey-tr-<NN>` Puzzle JSON (a valid F06 `Puzzle` artifact).
Map<String, Object?> _level(int n, {bool cols = false}) => <String, Object?>{
  'schemaVersion': 1,
  'contentVersion': 'test',
  'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
  'puzzleType': 'journey',
  'journeyLevelNumber': n,
  'language': 'tr',
  'grid': const <String>['ASALM', 'BCDFG', 'HJKLN', 'PRTUV', 'YZBCD'],
  'targetWord': 'MASAL',
  'lockedCells': const <String>[],
  'frozenCells': const <String>[],
  'columnMovesEnabled': cols,
  'optimalMoves': 1,
  'difficultyScore': 1,
  'difficultyLabel': 'easy',
  'difficultyBreakdown': const <String, Object?>{},
};

Map<String, Object?> _manifest(int levelCount, {String mode = 'smoke'}) =>
    <String, Object?>{
      'schemaVersion': 1,
      'contentVersion': 'test',
      'lang': 'tr',
      'mode': mode,
      'levels': <Map<String, Object?>>[
        for (var n = 1; n <= levelCount; n++)
          <String, Object?>{
            'n': n,
            'id': 'journey-tr-${n.toString().padLeft(2, '0')}',
            'asset': 'tr/journey-tr-${n.toString().padLeft(2, '0')}.json',
            'difficultyLabel': 'easy',
          },
      ],
    };

class _FakeSource implements JourneyAssetSource {
  _FakeSource(this._files);
  final Map<String, String> _files;
  @override
  Future<String> readString(String assetKey) async {
    final v = _files[assetKey];
    if (v == null) throw StateError('no asset "$assetKey"');
    return v;
  }
}

void main() {
  test('resolves a level number → the right Puzzle', () async {
    final repo = JourneyContentRepo(
      _FakeSource(<String, String>{
        'tr/journey_manifest_tr.json': jsonEncode(_manifest(3)),
        'tr/journey-tr-01.json': jsonEncode(_level(1)),
        'tr/journey-tr-02.json': jsonEncode(_level(2)),
        'tr/journey-tr-03.json': jsonEncode(_level(3, cols: true)),
      }),
    );

    final p2 = await repo.loadLevel(2, 'tr');
    expect(p2.id, 'journey-tr-02');
    expect(p2.journeyLevelNumber, 2);
    expect(p2.targetWord, 'MASAL');

    final p3 = await repo.loadLevel(3, 'tr');
    expect(p3.columnMovesEnabled, isTrue);
  });

  test('missing manifest entry → JourneyContentException', () async {
    final repo = JourneyContentRepo(
      _FakeSource(<String, String>{
        'tr/journey_manifest_tr.json': jsonEncode(_manifest(2)),
        'tr/journey-tr-01.json': jsonEncode(_level(1)),
        'tr/journey-tr-02.json': jsonEncode(_level(2)),
      }),
    );
    expect(
      () => repo.loadLevel(5, 'tr'),
      throwsA(isA<JourneyContentException>()),
    );
  });

  test('missing asset file → JourneyContentException', () async {
    final repo = JourneyContentRepo(
      _FakeSource(<String, String>{
        'tr/journey_manifest_tr.json': jsonEncode(_manifest(1)),
        // journey-tr-01.json absent
      }),
    );
    expect(
      () => repo.loadLevel(1, 'tr'),
      throwsA(isA<JourneyContentException>()),
    );
  });

  test(
    'corrupt level JSON → JourneyContentException (rest stay playable)',
    () async {
      final repo = JourneyContentRepo(
        _FakeSource(<String, String>{
          'tr/journey_manifest_tr.json': jsonEncode(_manifest(2)),
          'tr/journey-tr-01.json': '{ this is not json',
          'tr/journey-tr-02.json': jsonEncode(_level(2)),
        }),
      );
      expect(
        () => repo.loadLevel(1, 'tr'),
        throwsA(isA<JourneyContentException>()),
      );
      // level 2 still resolves
      expect((await repo.loadLevel(2, 'tr')).id, 'journey-tr-02');
    },
  );

  test(
    'id mismatch between manifest and asset → JourneyContentException',
    () async {
      final bad = _level(1)..['id'] = 'journey-tr-99';
      final repo = JourneyContentRepo(
        _FakeSource(<String, String>{
          'tr/journey_manifest_tr.json': jsonEncode(_manifest(1)),
          'tr/journey-tr-01.json': jsonEncode(bad),
        }),
      );
      expect(
        () => repo.loadLevel(1, 'tr'),
        throwsA(isA<JourneyContentException>()),
      );
    },
  );

  test('manifest with non-contiguous levels → JourneyContentException', () {
    final m = <String, Object?>{
      'schemaVersion': 1,
      'lang': 'tr',
      'mode': 'smoke',
      'contentVersion': 'x',
      'levels': <Map<String, Object?>>[
        <String, Object?>{
          'n': 1,
          'id': 'journey-tr-01',
          'asset': 'a',
          'difficultyLabel': 'easy',
        },
        <String, Object?>{
          'n': 3,
          'id': 'journey-tr-03',
          'asset': 'c',
          'difficultyLabel': 'easy',
        },
      ],
    };
    expect(
      () => JourneyManifest.fromJson(m),
      throwsA(isA<JourneyContentException>()),
    );
  });
}
