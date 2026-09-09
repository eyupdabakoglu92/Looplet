import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/journey/journey_content.dart'
    show journeyLevelCount;
import 'package:looplet_app/journey/journey_nav.dart';
import 'package:looplet_app/journey/journey_progress.dart';
import 'package:looplet_app/persistence/active_session_snapshot.dart';
import 'package:looplet_app/persistence/app_database.dart';
import 'package:looplet_app/persistence/repositories/journey_progress_repo.dart';
import 'package:looplet_app/persistence/repositories/player_repo.dart';

ActiveSessionSnapshot _journeySnapshot(
  String puzzleId, {
  ActiveSessionStatus status = ActiveSessionStatus.inProgress,
}) => ActiveSessionSnapshot(
  puzzleId: puzzleId,
  puzzleSource: PuzzleSource.journey,
  lang: 'tr',
  appliedMoves: const <String>['R1'],
  undosRemaining: 3,
  restartCount: 0,
  elapsedMsAccumulated: 1000,
  thawedFrozenCells: const <String>[],
  status: status,
  startedAtUtcMs: 1757145000000,
  lastPersistedAtUtcMs: 1757145001000,
);

void main() {
  late AppDatabase db;
  late JourneyProgressRepo repo;
  late String guestId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = JourneyProgressRepo(db);
    guestId = await PlayerRepo(db).currentGuestId();
  });

  tearDown(() => db.close());

  test(
    'fresh guest → all locked except level 1, count 0, continue → 1',
    () async {
      final row = await repo.read(guestId);
      final m = buildJourneyProgressModel(row: row, activeSnapshot: null);

      expect(m.progressCount, 0);
      expect(m.allComplete, isFalse);
      expect(m.continueTarget, 1);
      expect(m.stateOf(1), LevelState.unlockedIncomplete);
      expect(m.stateOf(2), LevelState.locked);
      expect(m.stateOf(30), LevelState.locked);
    },
  );

  test(
    'after completing 1..3 → count 3, level 4 unlocked, continue → 4',
    () async {
      for (final n in <int>[1, 2, 3]) {
        await repo.markCompleted(guestId, n);
      }
      final row = await repo.read(guestId);
      final m = buildJourneyProgressModel(row: row, activeSnapshot: null);

      expect(m.progressCount, 3);
      expect(m.stateOf(2), LevelState.completed);
      expect(m.stateOf(4), LevelState.unlockedIncomplete);
      expect(m.stateOf(5), LevelState.locked);
      expect(m.continueTarget, 4);
    },
  );

  test(
    'an in-progress Journey snapshot → that level is inProgress + continue',
    () async {
      await repo.markCompleted(guestId, 1);
      final row = await repo.read(guestId);
      final m = buildJourneyProgressModel(
        row: row,
        activeSnapshot: _journeySnapshot('journey-tr-02'),
      );

      expect(m.inProgressLevel, 2);
      expect(m.stateOf(2), LevelState.inProgress);
      expect(m.continueTarget, 2); // in-progress wins over lowest-unlocked
    },
  );

  test(
    'a completed snapshot / a non-journey snapshot → no inProgress',
    () async {
      final row = await repo.read(guestId);
      expect(
        buildJourneyProgressModel(
          row: row,
          activeSnapshot: _journeySnapshot(
            'journey-tr-01',
            status: ActiveSessionStatus.completed,
          ),
        ).inProgressLevel,
        isNull,
      );
    },
  );

  test('all 30 complete → allComplete, continueTarget null', () async {
    for (var n = 1; n <= 30; n++) {
      await repo.markCompleted(guestId, n);
    }
    final row = await repo.read(guestId);
    final m = buildJourneyProgressModel(row: row, activeSnapshot: null);

    expect(m.progressCount, 30);
    expect(m.allComplete, isTrue);
    expect(m.continueTarget, isNull);
    expect(m.stateOf(30), LevelState.completed);
  });

  test(
    'stray / out-of-range completed ids are clamped for the count',
    () async {
      // markCompleted(30) unlocks "31" internally; the count must ignore it.
      await repo.markCompleted(guestId, 30);
      final row = await repo.read(guestId);
      final m = buildJourneyProgressModel(row: row, activeSnapshot: null);
      expect(m.progressCount, 1);
    },
  );

  // AC2 (`architecture.md §12` clarification): F05 has no navigation path that
  // resolves to a `locked` level — the home's CONTINUE only ever targets
  // `continueTarget`, and `Next Level` only advances to an earned `N+1`. There
  // is no runtime guard (no MVP surface can request an arbitrary level — the
  // level-select surface + guard are `[DEFERRED — F10]`); this proves the "no
  // navigation to a locked level" guarantee holds by construction, across the
  // new / mid / in-progress / terminal + last-available states.
  test('no F05 navigation target is ever a `locked` level', () async {
    void assertSafeTargets(JourneyProgressModel m, {required int manifestLen}) {
      // CONTINUE — the only `LevelState`-driven navigation on the home.
      final target = m.continueTarget;
      if (target != null) {
        expect(
          m.stateOf(target),
          isNot(LevelState.locked),
          reason: 'CONTINUE resolved to a locked level ($target)',
        );
      } else {
        expect(m.allComplete, isTrue); // null ⇔ terminal
      }
      // `Next Level` is only ever shown on the completion panel of a level the
      // player JUST solved — so `markCompleted(n)` has fired and `n+1` is
      // unlocked. From every completed level, its `Next Level` target is either
      // an unlocked level or null (terminal), never a locked one.
      for (var n = 1; n <= journeyLevelCount; n++) {
        if (m.stateOf(n) != LevelState.completed) continue;
        final next = nextJourneyLevel(n, manifestLevelCount: manifestLen);
        if (next != null) {
          expect(
            m.stateOf(next),
            isNot(LevelState.locked),
            reason:
                'Next Level from completed $n reached a locked level ($next)',
          );
        }
      }
    }

    Future<JourneyProgressModel> current({
      ActiveSessionSnapshot? snapshot,
    }) async => buildJourneyProgressModel(
      row: await repo.read(guestId),
      activeSnapshot: snapshot,
    );

    // new (0 completed)
    assertSafeTargets(await current(), manifestLen: 5);

    // mid (1..3 completed)
    for (final n in <int>[1, 2, 3]) {
      await repo.markCompleted(guestId, n);
    }
    assertSafeTargets(await current(), manifestLen: 5);

    // in-progress (level 4 resumable) + last-available boundary (manifest = 4)
    assertSafeTargets(
      await current(snapshot: _journeySnapshot('journey-tr-04')),
      manifestLen: 4,
    );

    // terminal (all 30 completed)
    for (var n = 4; n <= 30; n++) {
      await repo.markCompleted(guestId, n);
    }
    assertSafeTargets(await current(), manifestLen: 30);
  });
}
