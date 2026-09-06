# F02 — grid-engine: Architecture

> Status: CONTRACT AUTHORITY. Delivery artifacts and QA notes do not override the semantics defined here.

---

## Purpose

* **Feature objective:** `looplet_engine` — the deterministic, headless rules engine for the LOOPLET 5×5 grid.
* **Contract scope:** the pure functional core (`GridState`, `EngineConfig`, `applyMove`, `canonicalKey`), the stateful `GridEngine` façade (move history, `undo`, `restart`, `moveCount`), the `WordValidator` port, the shift / locked / frozen / win semantics, and the primitive value types this feature adds to `looplet_core`.
* **Non-goals:** rendering, animation, gestures, input-lock, HUD, undo-quota, completion panel (F03); star rating (F04); level unlock / difficulty curve (F05); `Puzzle` model + JSON + difficulty scoring (`looplet_content` / F06); minimum-move search (F06 `looplet_solver`); persistence (F08); column-scan frozen detection (product rule is row-only).

---

## Authorities & Inputs

* Upstream PRD: `features/f02-grid-engine/prd.md`; product PRD §4, §6.1 (F02), §7–8 (shift mechanics), §15–16 (domain model / events), §20–22 (locked / frozen curve).
* Inherited contracts: **F01 dictionary-service** — `DictionaryService.isValidWord(String, {int minLength})`. F02 does **not** import `looplet_dictionary`; it defines a `WordValidator` port with the same shape and the app / solver / tests supply an adapter. Rationale: keep `looplet_engine` → `looplet_core` only (`platform.md` §3).
* Project authority: `platform.md` §3 (monorepo layout, dependency edges, no Flutter/Firebase), §10 (testing), §11 (Turkish-locale HARD RULE, determinism — no runtime RNG).
* Release: `none` (internal library; `release.md` §2).

### Platform authority clarification (Tech Lead decision, 2026-09-05)

`platform.md` §11 says "puzzle schema enums are defined once in `looplet_content`". That stands for **serialized** puzzle-schema enums (`difficultyLabel`, `puzzleType`). The **engine primitive** value types below are lower-level and are defined in **`looplet_core`** so `looplet_engine` (which must not depend on `looplet_content`) can use them, and `looplet_content` composes them into `Puzzle`:

* `enum MoveAxis { row, column }`
* `enum MoveDirection { left, right, up, down }`
* `enum TileStatus { normal, locked, frozen, thawed }`
* `class GridCoord { final int row; final int col; }` — value equality + `hashCode`; `compareTo` (row-major) for stable ordering.

`looplet_content` will re-export these from `looplet_core` so downstream code has one import site. (`platform.md` to be amended by the Tech Lead to record this carve-out.)

---

## Actors & Permissions

| Actor | Allowed Actions | Forbidden Actions | Notes |
| --- | --- | --- | --- |
| F03 play session | construct `GridEngine`; `applyMove`, `undo`, `restart`; read `moveCount`, `isSolved`, `state` | mutating `GridState`; bypassing `applyMove` to move letters; calling during an animation | drives the façade |
| F06 solver / `tools` | use the pure core: `GridState.applyMove`, `GridState.canonicalKey`, `EngineConfig.legalMoves` | relying on the façade's history for search | wants zero-alloc-ish pure steps |
| F04 rating | read `isSolved`, `moveCount` | writing engine state | |
| F08 persistence | read `EngineConfig`, `appliedMoves`, `state.thawedCells` | — | persists move list; thaw is re-derived on load |
| app | adapt `DictionaryService` → `WordValidator` | making `looplet_engine` import `looplet_dictionary` | dependency boundary |

---

## Entry / Exit Paths

### Allowed Entry Paths

* `EngineConfig(...)` constructor — validates and throws on malformed input (see Validation Responsibility).
* `GridEngine(EngineConfig config, {required WordValidator validator})` — builds the initial `GridState`, evaluating thaw + win once at t = 0.
* Pure core: `GridState.initial(EngineConfig, WordValidator)` → the t = 0 state; `state.applyMove(Move, config, validator)` → `GridStep`.

### Exit / Completion Paths

* `GridEngine.state.isSolved == true` — terminal. The move that caused the win is counted; `moveCount` is frozen; `applyMove` and `undo` are rejected (`reason: puzzleComplete`). `restart` still works.
* No disposal needed — pure Dart, no resources.

### Invalid / Rejected / Terminal Paths

Every rejected operation returns a result with `applied == false` and a `MoveRejectReason`; **state and `moveCount` are unchanged**:

* `columnMovesDisabled` — a column move on a puzzle with `columnMovesEnabled == false`.
* `lineFullyImmovable` — the target line has ≤ 1 movable cell (a rotation would be identity).
* `outOfRange` — `move.index` not in `0..gridSize-1`.
* `puzzleComplete` — `applyMove` or `undo` after `isSolved`.
* `nothingToUndo` — `undo` with an empty move history.

Construction failure (`EngineConfig`) throws synchronously — it is a programming/authoring error, not a runtime path.

---

## Data / Domain Model

### `EngineConfig` (immutable, static puzzle data)

| Field | Type | Rule |
| --- | --- | --- |
| `initialGrid` | `List<List<String>>` | exactly `gridSize` rows × `gridSize` cols; each entry a single non-empty grapheme (a Turkish letter as authored, any casing) |
| `targetWord` | `String` | MVP: length == `gridSize` (5); letters only |
| `lockedCells` | `Set<GridCoord>` | in range; may be empty; may contain several per line |
| `frozenCells` | `Set<GridCoord>` | in range; disjoint from `lockedCells` |
| `columnMovesEnabled` | `bool` | `false` for Journey levels 1–3 |
| `gridSize` | `int` | 5 for MVP; the engine is written for a square `gridSize`, not hard-coded to 5 |

`EngineConfig` also provides:
* `List<Move> legalMoves(GridState state)` — every move that would return `applied: true` from `state` (used by F06; excludes column moves when disabled, excludes fully-immovable lines, excludes everything once solved).

### `GridState` (immutable, dynamic data)

| Field | Type | Meaning |
| --- | --- | --- |
| `letters` | `List<List<String>>` | current 5×5 letters (row-major, `[row][col]`) |
| `thawedCells` | `Set<GridCoord>` | frozen cells that have thawed so far (monotonic within a forward move sequence) |
| `isSolved` | `bool` | target occupies a full L→R row in exact order |

Derived:
* `TileStatus statusAt(GridCoord c)` → `locked` if `c ∈ config.lockedCells`; else `thawed` if `c ∈ thawedCells`; else `frozen` if `c ∈ config.frozenCells`; else `normal`.
* `bool isMovable(GridCoord c)` → not `locked` and not `frozen` (i.e. `normal` or `thawed`).
* `String canonicalKey()` — see below.

### `Move` (immutable)

`{ MoveAxis axis, int index, MoveDirection direction }`. `index` is the row index for `axis == row`, the column index for `axis == column`. `direction` must match the axis (`left`/`right` for rows, `up`/`down` for columns) — a mismatched pair is `outOfRange`.

### `GridEngine` (stateful façade)

Holds `config`, `validator`, `_initialState` (t = 0), and `_moves : List<Move>` (only **applied** moves). `state` = fold of `_initialState` over `_moves`. `moveCount == _moves.length`.

### Coordinate & orientation conventions

* `letters[0][0]` is the **top-left** cell. Row index increases **downward**; column index increases **rightward**.
* Row read order for win / frozen-word detection is **left → right** (increasing column).
* Column top → bottom is increasing row index.

### `canonicalKey()` (CONTRACT — F06 state identity)

```
canonicalKey = join(letters row-major, using TurkishCase.toLowerTr on each cell) + "§" +
               sortedThawed.map((c) => "${c.row},${c.col}").join(";")
```
* Uses the **normalized** (Turkish-lower) letter of each cell, row-major, no separators between cells (fixed width, one grapheme each) — so `["MA","SA","L"]` style multi-grapheme cells are disallowed by `EngineConfig` validation.
* `sortedThawed` = `thawedCells` sorted by `(row, col)`.
* **Excludes** `lockedCells`, `targetWord`, `columnMovesEnabled` — these are constant across an F06 search, carried by `EngineConfig`.
* Deterministic across process runs: no `hashCode`, no `Set`/`Map` iteration order, no locale-dependent casing (Turkish map is explicit).
* Two states are "the same search node" iff their `canonicalKey` is equal.

---

## API / Event Contract

### `looplet_core` additions

```dart
enum MoveAxis { row, column }
enum MoveDirection { left, right, up, down }
enum TileStatus { normal, locked, frozen, thawed }

final class GridCoord implements Comparable<GridCoord> {
  const GridCoord(this.row, this.col);
  final int row;
  final int col;
  @override bool operator ==(Object other);
  @override int get hashCode;
  @override int compareTo(GridCoord other); // row-major
}
```

### `package:looplet_engine`

```dart
abstract interface class WordValidator {
  /// Same contract as F01 DictionaryService.isValidWord: true iff [candidate]
  /// normalizes to a letters-only word of >= [minLength] letters in the active
  /// language's list. Must be pure/deterministic.
  bool isValidWord(String candidate, {int minLength = 1});
}

/// Never-valid validator, for frozen-free contexts.
final class NeverValidWordValidator implements WordValidator { const NeverValidWordValidator(); }

enum MoveRejectReason {
  columnMovesDisabled, lineFullyImmovable, outOfRange, puzzleComplete, nothingToUndo,
}

final class Move {
  const Move.rowLeft(int index);
  const Move.rowRight(int index);
  const Move.columnUp(int index);
  const Move.columnDown(int index);
  final MoveAxis axis;
  final int index;
  final MoveDirection direction;
}

final class EngineConfig {
  EngineConfig({
    required List<List<String>> initialGrid,
    required String targetWord,
    Set<GridCoord> lockedCells = const {},
    Set<GridCoord> frozenCells = const {},
    bool columnMovesEnabled = true,
  }); // validates; throws EngineConfigError on any violation

  int get gridSize;
  String get targetWord;
  Set<GridCoord> get lockedCells;
  Set<GridCoord> get frozenCells;
  bool get columnMovesEnabled;

  List<Move> legalMoves(GridState state);
}

final class EngineConfigError extends ArgumentError {
  EngineConfigError(String message);
}

final class GridState {
  static GridState initial(EngineConfig config, WordValidator validator);

  List<List<String>> get letters;   // unmodifiable view
  Set<GridCoord> get thawedCells;   // unmodifiable view
  bool get isSolved;

  TileStatus statusAt(GridCoord c);
  bool isMovable(GridCoord c);
  String canonicalKey();

  /// Pure step. Never throws for a rejected move — returns applied == false.
  GridStep applyMove(Move move, EngineConfig config, WordValidator validator);

  @override bool operator ==(Object other); // value equality: letters + thawedCells + isSolved
  @override int get hashCode;
}

final class GridStep {
  final bool applied;
  final MoveRejectReason? rejectedReason; // non-null iff !applied
  final GridState state;                  // next state if applied; unchanged state if not
  final bool thawedThisStep;              // a frozen tile thawed on this step
  final bool solvedThisStep;              // the puzzle became solved on this step
}

final class GridEngine {
  GridEngine(EngineConfig config, {required WordValidator validator});

  EngineConfig get config;
  GridState get state;
  int get moveCount;
  bool get isSolved;
  List<Move> get appliedMoves;   // unmodifiable

  GridStep applyMove(Move move); // delegates to state.applyMove; appends to history iff applied
  GridStep undo();               // removes last applied move, re-folds from initial
  void restart();                // clears history; state = initial
}
```

### Events / Async Inputs

None. Fully synchronous, single-isolate, no streams. (Product PRD §16 domain events — `MOVE_APPLIED`, `MOVE_UNDONE`, `PUZZLE_RESTARTED`, `FROZEN_TILE_THAWED`, `TARGET_WORD_FORMED`, `PUZZLE_COMPLETED` — are **derived by callers** from `GridStep` flags + `moveCount` changes and emitted by F12; the engine does not emit them.)

### Request / Response Rules

* `applyMove` / `undo` are pure w.r.t. `(GridState, Move, EngineConfig, WordValidator)`. Equal inputs → equal `GridStep`.
* A rejected op returns `applied: false`, a non-null `rejectedReason`, and the **unchanged** state; `GridEngine` does not append to history and does not change `moveCount`.
* `GridState.letters` and `thawedCells` getters return unmodifiable views; callers cannot mutate engine state.
* No method returns `null` for a `GridState` or `GridStep`.

### Error Semantics

* `EngineConfigError` (a subtype of `ArgumentError`) — thrown synchronously by `EngineConfig(...)` for: wrong dimensions; a non-single-grapheme or empty cell; `targetWord.length != gridSize` or non-letter target; a coordinate out of range; `lockedCells ∩ frozenCells != ∅`.
* No other exceptions. Rejected moves are values, not throws.

---

## Validation Responsibility

* **Engine (`EngineConfig` constructor):** structural validity of the puzzle definition (dimensions, cell content, target length, coordinate ranges, locked/frozen disjointness).
* **Engine (`applyMove`):** move legality (axis/direction match, index range, column-enabled, line movability, terminal state).
* **Caller (F06 authoring):** that the puzzle is actually solvable and that authored frozen rows are not accidentally pre-thawed / pre-solved — the engine surfaces `isSolved` / `thawedCells` at t = 0 but does not reject a trivial puzzle.
* **Caller (F03):** the 3-undo quota, not querying during animations, not sending out-of-range moves.
* **`WordValidator` (F01 adapter):** word validity + normalization. The engine passes raw row-window substrings (built from the authored-cased letters, joined) to `isValidWord`; F01 normalizes.

---

## State / Flow Semantics

### Shift algorithm (CONTRACT)

For a move on line `L` (a row or a column), in direction `d`:

1. If solved → reject `puzzleComplete`. If `axis == column && !columnMovesEnabled` → reject `columnMovesDisabled`. If `index` out of range or direction/axis mismatch → reject `outOfRange`.
2. Collect the line's cells in **position order** (columns 0→4 for a row; rows 0→4 for a column). Partition into **fixed** positions (`statusAt` is `locked`, or `frozen` and not yet thawed) and **movable** positions (`normal` or `thawed`).
3. If movable positions ≤ 1 → reject `lineFullyImmovable` (rotation is identity).
4. Let `movablePositions = [p0, p1, …, pk-1]` in ascending order, holding letters `[l0, l1, …, lk-1]`. A **forward** shift (`right` for a row, `down` for a column) moves each letter to the **next** movable position, wrapping: new letter at `p_i` is `l_{(i-1) mod k}`. A **backward** shift (`left` / `up`) is the inverse: new letter at `p_i` is `l_{(i+1) mod k}`.
5. Fixed positions keep their letters. Build the next `letters` grid.
6. Evaluate **thaw** on the next grid (see below), producing `nextThawed ⊇ state.thawedCells`.
7. Evaluate **win** on the next grid. `solved = anyRowEqualsTarget(nextLetters)`.
8. Return `GridStep(applied: true, state: GridState(nextLetters, nextThawed, solved), thawedThisStep: nextThawed.length > state.thawedCells.length, solvedThisStep: solved && !state.isSolved)`.

Worked example (AC): row `A B [C] D E`, `[C]` locked at col 2, shift **right**. Movable positions `[0,1,3,4]` hold `[A,B,D,E]`. Forward: new `p_i = l_{(i-1) mod 4}` → `p0=E, p1=A, p3=B, p4=D`. Result: `E A [C] B D`.

Wrap example: row `A B C D E` (no fixed cells), shift right → movable `[0,1,2,3,4]` holding `[A,B,C,D,E]` → `p_i = l_{(i-1) mod 5}` → `E A B C D`. Shift left → `p_i = l_{(i+1) mod 5}` → `B C D E A`.

### Thaw evaluation (CONTRACT)

Given a grid and the current `thawedCells`:
* For each row `r` that contains at least one frozen-and-not-thawed cell:
  * Build every contiguous left-to-right window of the row of length **4** (`cols 0–3`, `cols 1–4`) and length **5** (`cols 0–4`). Window string = the window's cell letters joined in column order, authored casing.
  * If `validator.isValidWord(windowString, minLength: 4)` is `true` for **any** window, mark **every** frozen-and-not-thawed cell in row `r` as thawed (add to the result set).
* The word need **not** pass through a frozen cell — any valid ≥4-letter run in the row thaws all frozen cells in that row.
* Only the **row** is scanned. The column is never scanned (product PRD §22).
* Thaw is **monotonic within a forward sequence**: a cell that is thawed stays thawed for every subsequent `applyMove`. It can only return to `frozen` via `undo` / `restart` (which re-fold from t = 0).
* Also evaluated once at `GridState.initial` (t = 0): an authored grid that already contains a valid word in a frozen row starts with that tile thawed.

### Win evaluation (CONTRACT)

`anyRowEqualsTarget(letters)` = there exists a row `r` such that `join(letters[r], TurkishCase.toLowerTr) == TurkishCase.toLowerTr(targetWord)`.
* MVP: `targetWord.length == gridSize`, so this is a full-row match. (Written generally as "a contiguous L→R run of `targetWord.length` cells in some row equals the target" for future non-full-row targets; for MVP the run is the whole row.)
* Left-to-right only. Reverse (`LASAM`), any column arrangement, and diagonals never win.
* Repeated target letters are handled by plain string equality.
* Evaluated once at t = 0 (a pre-solved authored grid is reported `isSolved` immediately) and after every applied move.

### Move counting & terminal state

* `GridEngine.moveCount == appliedMoves.length`. Rejected moves and `undo` never change it.
* The move that produces `solvedThisStep == true` **is** appended and **is** counted; then the engine is terminal.
* Terminal: `applyMove` → `puzzleComplete`; `undo` → `puzzleComplete`; `restart` → allowed, returns to t = 0 (unsolved unless the authored grid is pre-solved).

### Undo & restart

* `undo()`: if `appliedMoves` empty → `nothingToUndo`. Else remove the last move, recompute `state = fold(initialState, appliedMoves)` where `fold` replays `GridState.applyMove` for each remaining move in order. `thawedCells` and `isSolved` are whatever that replay produces — a tile that thawed only on the removed move is `frozen` again; a win that only existed after the removed move is gone.
* `restart()`: `appliedMoves = []`; `state = initialState` (the cached t = 0 state).
* `fold` is the single definition of "current state"; there is no separately-mutated live grid. This guarantees `undo` and forward play can never diverge.

### Determinism

* No `Random`, no `DateTime`, no `Stopwatch`, no I/O, no `Isolate`, no `hashCode` leakage into observable output.
* `GridState.applyMove` given identical `(state, move, config, validator)` returns an identical `GridStep` every call.
* A guard test asserts the package source contains no `dart:math` `Random`, `DateTime.now`, or `dart:io` import.

### Concurrency

Single-isolate synchronous. `GridEngine` is not safe for concurrent mutation from multiple isolates and is not required to be (F03 uses it from the UI isolate only).

---

## Integration Rules

* `looplet_engine` `pubspec.yaml` depends on **`looplet_core` only** (+ dev `test`). No `flutter`, no `looplet_dictionary`, no `looplet_content`, no Firebase. Enforced by `melos run analyze` + review.
* The app supplies a `WordValidator` adapter over F01's `DictionaryService` (e.g. `class DictionaryWordValidator implements WordValidator` in `app/lib/`), and injects it where a `GridEngine` is built. F06 supplies its own adapter over `looplet_dictionary` in `tools` / `looplet_solver`.
* F08 persists `EngineConfig` (or the `Puzzle` it derives from) + `appliedMoves`. On resume it reconstructs `GridEngine` and replays `appliedMoves` via repeated `applyMove` (or a batch `restoreMoves`). `thawedCells` is **not** persisted as authority — it is re-derived. (F08 may cache it.)
* F06 uses `GridState.initial` + `GridState.applyMove` + `canonicalKey` for its search and `EngineConfig.legalMoves` for successor generation; it does not use `GridEngine`.
* Navigation / route / async / realtime: n/a (headless).

---

## QA Focus

* **Acceptance criteria coverage:** every AC in `prd.md` → an automated test.
* **Shift table:** all four directions, with and without wrap, on rows and columns; identity check on a no-fixed-cell 5-cycle after 5 shifts.
* **Locked-tile rotation:** the worked example; 2 locked tiles in one line; locked tile at each of the 5 positions; a line that becomes fully immovable → `lineFullyImmovable`, not counted.
* **Frozen-tile thaw:** thaw on a length-4 window and a length-5 window; word not through the frozen cell; two frozen tiles in one row thaw together; frozen tiles in different rows evaluated independently; thaw at t = 0 for a pre-worded authored grid; no column scan (a valid word down the frozen tile's column does **not** thaw); thaw is permanent across subsequent moves; thaw reverts on `undo` of the causing move.
* **Win / no-win matrix:** full-row match any casing; reverse row `LASAM` no win; column `M/A/S/A/L` no win; repeated-letter target `MASAL`; win + thaw on the same move → `solvedThisStep` and `thawedThisStep` both true and engine terminal; pre-solved authored grid → `isSolved` at t = 0.
* **Move counting:** +1 per applied move; rejected moves and `undo` don't change it; counter frozen after solved.
* **Undo / restart:** undo 5→4 exact state + count; `nothingToUndo` on empty; `puzzleComplete` on undo-after-solved; restart from mid-game and from solved.
* **Rejections:** `columnMovesDisabled`, `outOfRange` (index & axis/direction mismatch), `lineFullyImmovable`, `puzzleComplete`, `nothingToUndo` — each leaves state + count unchanged.
* **Determinism:** compute `fold(config, moves)` twice independently → `==` and equal `canonicalKey`; `canonicalKey` differs on any letter or thawed-cell change and is equal on identical letters+status; guard test for no `Random` / `DateTime.now` / `dart:io`.
* **`EngineConfig` validation:** each malformed input throws `EngineConfigError`.
* **`legalMoves`:** returns exactly the moves that would be `applied: true` from a given state (spot-checked against `applyMove`), empty once solved.
* **Evidence class:** `automated functional` (pure-Dart `dart test`). No device runtime.
* **QA scope:** client-only (package-level), source + automated tests.

---

## Release / Deployment Impact

* Release scope: **none** — internal library, no distributable surface. Standard CI gates only (`format:check`, `analyze`, `test`).
* No environment/config/migration/observability impact.
* Runtime evidence expectation: none — automated test evidence is sufficient (`platform.md` §10).

---

## Open Technical Decisions

* **`GridState` internal letter storage** (`List<List<String>>` vs a flat `List<String>` of length 25 vs a packed `String`/`Uint16List`): decided by the Frontend/Mobile Developer against F06's state-expansion needs; the public getters and `canonicalKey` contract are fixed regardless. Record the choice + a micro-benchmark note (states/sec for `applyMove`) in `frontend.md`.
* **`restoreMoves(List<Move>)` batch API** on `GridEngine` for F08 resume — **REQUIRED by F08 (Tech Lead, 2026-09-06, F08 contract).** Additive, non-breaking: replays a batch of already-`applied` moves from the initial state and must produce the identical `GridState` (letters + `thawedCells` + `isSolved`) and `moveCount` as replaying `applyMove` one-by-one; a move in the batch that would be rejected is a programming error (assert / throw — the batch is a persisted applied-move list, not user input). Implemented as a small F02 follow-on task alongside F08-FE (or folded into F08-FE4 with an F02-owned review). See `features/f08-offline-persistence-and-sync/architecture.md` → Active-Session Snapshot Contract.
* **`gridSize` generality** — implement for a square `gridSize` from `EngineConfig` (not a hard-coded 5) so Phase-2 grid sizes need no rewrite, but only 5×5 is tested in the MVP.
