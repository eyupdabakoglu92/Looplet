# F02 — grid-engine: PRD

> Status: FEATURE PRODUCT AUTHORITY (derived from `/ai-system/product/product-prd.md` §6.1 F02, §4, §6–8, §15–16, §20–22)
> Tech Lead output — submitted for user review.

---

## Summary

* **Problem:** LOOPLET needs one deterministic, headless rules engine for the 5×5 grid: circular row/column shifting, move counting, left-to-right win detection, locked-tile and frozen-tile behavior, and undo/restart primitives. Every player-facing feature (F03 play session, F04 rating, F05 journey, F07 daily) and the F06 solver depend on this being exact and reproducible.
* **Goal:** A pure-Dart `looplet_engine` package with (a) a pure functional core — `GridState` + `applyMove` with no side effects, suitable for the F06 solver's state-space search — and (b) a thin stateful `GridEngine` façade with move history, undo, and restart for the play session.
* **User value (indirect):** the player experiences a grid where every move behaves identically every time, the target is detected the instant it forms, locked/frozen tiles behave predictably, and undo/restart are trustworthy — the foundation of the "every move matters" promise.

---

## Dependencies

* Upstream features: **F01 dictionary-service (Done)** — frozen-tile thaw needs word validation. Consumed via an injected `WordValidator` port, **not** a direct dependency on `looplet_dictionary` (keeps `looplet_engine` → `looplet_core` only, per `platform.md` §3).
* Downstream: F03 (play session drives the façade), F04 (reads `isSolved` / `moveCount`), F06 (solver uses the pure core + `canonicalKey`), F08 (persists `EngineConfig` + move list).
* Required platform assumptions (`platform.md`): pure-Dart package, no Flutter/Firebase import; no runtime randomness anywhere; `TurkishCase` from `looplet_core` for all letter comparison; shared primitive enums (`MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord`) live in `looplet_core` (see `architecture.md` — clarifies `platform.md` §11).

---

## In Scope

* 5×5 grid model; each cell holds exactly one non-empty letter.
* Circular row shift (left / right) and column shift (up / down); one cell of travel = one move.
* Move counter: +1 per applied move; frozen the instant the puzzle is solved.
* Win detection: target word appears in **any row**, left-to-right, contiguous, exact order. Reverse, vertical, and diagonal arrangements do not win. Repeated letters handled positionally.
* Locked tile: a coordinate whose letter never moves; other cells of its row/column rotate circularly around it. Multiple locked tiles per line supported.
* Frozen tile: immovable (behaves like locked) until a valid ≥4-letter contiguous left-to-right word forms **in its row**, then permanently normal for the session. Two frozen tiles in one row thaw together on a single valid word.
* Undo primitive: revert exactly the last applied move and the counter; re-derive thaw/solved state.
* Restart: return to the authored initial grid, move count 0, thaw/solved re-derived for the initial state.
* Per-puzzle "column moves disabled" flag (levels 1–3): the engine rejects column moves when the flag is off.
* Determinism: identical `(EngineConfig, ordered move list)` → identical `GridState`, always. A `canonicalKey()` state identity for the F06 solver.
* `EngineConfig` construction validation (grid dimensions, non-empty letters, target length, locked ∩ frozen = ∅, coordinates in range).
* Headless unit tests: determinism/replay matrix, shift table (all four directions incl. wrap), locked-tile rotation, frozen-tile thaw (timing, row-window scan, multi-frozen, thaw+win), win/no-win matrix (incl. reverse/vertical/repeated letters), undo/restart, no-op moves, terminal-state rejection.

## Out of Scope

* Any rendering, animation, gesture handling, input lock, or `MOVES` HUD → **F03**.
* The 3-free-undo quota, `Restart` button placement, completion panel → **F03**.
* Star rating / personal best → **F04**.
* Level unlock / difficulty curve → **F05**.
* The `Puzzle` model + JSON (de)serialization + difficulty scoring → **`looplet_content`** / **F06**. The engine consumes a plain `EngineConfig`, not a `Puzzle`.
* The solver itself (minimum-move search) → **F06** (`looplet_solver`). This feature only exposes the pure core + `canonicalKey` it will build on.
* Persistence / autosave → **F08**. The engine exposes what F08 needs (`EngineConfig`, `appliedMoves`, derived `thawedCells`).
* Frozen-word detection in a tile's **column** — the product rule is **row only** (product PRD §22, Assumptions).

---

## User Stories

F02 is Infrastructure; expressed as system requirements.

* The system must apply a single-cell circular shift to a chosen row (left/right) or column (up/down) as exactly one move, deterministically, so gameplay is reproducible and countable.
* The system must detect a win the instant the target word occupies a full left-to-right row in exact order, and then stop the move counter and refuse further moves.
* The system must hold a locked tile fixed while the other cells of its line rotate circularly around it.
* The system must keep a frozen tile immovable until a valid ≥4-letter contiguous left-to-right word exists in its row, then convert it to a normal tile permanently for the session.
* The system must provide undo (revert the last applied move and the counter) and restart (return to the authored initial state), each re-deriving thaw and solved state.
* The system must never use randomness; identical inputs must always produce an identical grid state, and must expose a canonical state key for search/deduplication.

---

## Acceptance Criteria

* **Given** row `A B C D E`, **When** shifted right once, **Then** it becomes `E A B C D` and the move count increases by 1.
* **Given** row `A B C D E`, **When** shifted left once, **Then** it becomes `B C D E A`.
* **Given** column `A / B / C / D / E`, **When** shifted down once, **Then** it becomes `E / A / B / C / D`; **When** shifted up once, **Then** `B / C / D / E / A`.
* **Given** target `MASAL` and a row that settles as `M A S A L` (any letter casing), **When** the move settles, **Then** the engine reports solved, the counter freezes at its current value, and a subsequent `applyMove` / `undo` is rejected.
* **Given** a row that settles as `L A S A M`, or a column reading `M A S A L` top-to-bottom, **When** evaluated, **Then** the engine does **not** report solved.
* **Given** a locked tile at column 2 of row `A B [C] D E`, **When** the row is shifted right, **Then** `C` stays at column 2 and the other cells rotate: the row becomes `E A [C] B D`.
* **Given** a row/column whose movable cells number ≤ 1 (fully locked / fully unthawed-frozen), **When** a shift is applied to it, **Then** the state is unchanged, the move is **not counted**, and the result reports `applied: false, reason: lineFullyImmovable`.
* **Given** a puzzle with column moves disabled, **When** a column shift is applied, **Then** it is rejected (`applied: false, reason: columnMovesDisabled`) and nothing changes.
* **Given** a frozen tile in row `r`, **When** an applied move leaves row `r` containing a contiguous left-to-right run of ≥ 4 cells that `WordValidator.isValidWord(run, minLength: 4)` accepts, **Then** every frozen tile in row `r` becomes `thawed` and stays thawed for the rest of the session.
* **Given** two frozen tiles in the same row, **When** one valid ≥4-letter word forms in that row, **Then** both thaw on the same move.
* **Given** a frozen tile's row forms a word that also equals the target word, **When** the move settles, **Then** the tile thaws **and** the engine reports solved (win resolves; move is counted; engine locks).
* **Given** 5 applied moves then one `undo`, **When** the state is read, **Then** it equals the state after 4 moves, the move count is 4, and any tile that had thawed only because of move 5 is `frozen` again.
* **Given** `undo` with no applied moves, **When** called, **Then** it is rejected (`applied: false, reason: nothingToUndo`) and nothing changes.
* **Given** any mid-game state, **When** `restart` is called, **Then** the grid equals the authored initial grid, the move count is 0, and thaw/solved are re-derived from the initial state.
* **Given** any `EngineConfig` and any ordered list of moves, **When** the resulting state is computed twice (independently), **Then** the two `GridState`s are equal and produce the same `canonicalKey()`.
* **Given** two `GridState`s with identical letters and identical tile statuses, **When** `canonicalKey()` is computed for each, **Then** the keys are equal; **Given** any difference in a letter or a thawed-tile, **Then** the keys differ.
* **Given** an `EngineConfig` with mismatched dimensions, an empty-string cell, a target whose length ≠ grid width, a coordinate out of range, or a cell that is both locked and frozen, **When** constructed, **Then** construction throws `ArgumentError` (or a typed `EngineConfigError`).

---

## Edge Cases

* Shift on a fully-locked or fully-(unthawed-)frozen line → no-op, not counted (AC above).
* Locked tile and frozen tile in the same row and/or column (both are fixed points for shifts until the frozen one thaws).
* A line with exactly 2 movable cells → a shift swaps them; this is a real counted move.
* Frozen tile in a row where the **authored initial grid already** contains a valid ≥4-letter word → the tile thaws at construction (t = 0). F06 authoring must account for this.
* Target word with repeated letters (`MASAL` has two `A`) → matched by positional string equality, not a set/multiset check.
* A valid word forming only transiently during an animation is irrelevant — the engine evaluates thaw/win only on settled states (the engine has no notion of animation; F03 must not query mid-animation).
* Wrap-around correctness at both ends of every row and column, in every direction.
* `undo` after the puzzle is solved → rejected (`reason: puzzleComplete`).
* `restart` after solved → allowed; returns to a fresh unsolved initial state.
* Multiple frozen tiles across different rows → each row evaluated independently on every move.
* A move that both thaws a tile and breaks a different (previously word-forming) row → the earlier thaw stays (permanent); no re-freeze.
* `canonicalKey` stability across process runs (no map-ordering or hashcode leakage into the key).
* Move `index` outside 0–4 → rejected (`reason: outOfRange`), defensive.
* Column-moves-disabled puzzle that also has a frozen tile whose only thaw path needs a column move → unsolvable-by-thaw; F06's problem to avoid, not F02's to fix. Engine just enforces the rule.

---

## Success Metrics

* 100% determinism across the QA replay matrix (every `(config, moves)` pair reproduces bit-for-bit, and `canonicalKey` matches).
* Win / no-win, locked-rotation, and frozen-thaw behavior match this PRD's matrix 100% in the automated suite.
* Solver-readiness: `GridState.applyMove` is allocation-disciplined enough that F06 can expand a 5×5 state space within its authoring time budget (validated qualitatively here; quantitatively in F06).
* 0 uses of `Random`, `DateTime.now`, or I/O in `looplet_engine` (enforced by review + a guard test).

---

## Open Questions

* **[Resolved — Tech Lead, `architecture.md`]** Locked-tile rotation = rotate the cyclic subsequence of non-locked positions by one step in the shift direction (worked example in the ACs).
* **[Resolved — Tech Lead, `architecture.md`]** Frozen-tile thaw scans **all** length-4 and length-5 contiguous left-to-right windows of the tile's **row**; the word need not pass through the frozen cell. Row only, never the column.
* **[Resolved — Tech Lead, `architecture.md`]** On a move that both thaws and wins → win takes the terminal outcome; the move is counted; thaw is also recorded.
* **[Resolved — Tech Lead, `architecture.md`]** Undo re-folds from the initial state, so thaw state is history-accurate (a tile can revert to frozen on undo). The engine's authoritative thaw state is derived from the move history, not stored independently.
* **[Resolved — Tech Lead, `architecture.md`]** Thaw and win are also evaluated once at construction (t = 0), so an authored grid cannot ship a hidden pre-thawed tile or a pre-solved puzzle silently — construction surfaces both.
* **[Deferred to F06]** Whether the solver treats "column moves disabled" purely as a pruning rule or the engine should expose the legal-move set — the engine will expose `legalMoves(GridState)` for F06's convenience.
