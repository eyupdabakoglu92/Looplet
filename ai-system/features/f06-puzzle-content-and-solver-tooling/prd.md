# F06 — puzzle-content-and-solver-tooling: PRD

> Status: FEATURE PRODUCT AUTHORITY (derived from `/ai-system/product/product-prd.md` §6.1 F06, §5.5, §12–13, §46–49)
> Tech Lead output — submitted for user review; Technical Analyst pass pending.

---

## Summary

* **Problem:** LOOPLET's star rating is only fair if every shipped puzzle carries a **proven minimum move count**, and the game only has content if there is a repeatable way to author, verify, rate, and export puzzles. Neither exists yet. F02 also deferred the `Puzzle` model / JSON serialization (`looplet_content`) to this feature.
* **Goal:** A build-time toolchain — `looplet_solver` (provable-minimum-move search over F02's `GridState`) + `tools/looplet_authoring` (an internal level editor / CLI) + the `looplet_content` `Puzzle` model — that produces the 30 handcrafted Journey levels and the Daily puzzle pool as versioned, validated content artifacts.
* **User value (indirect):** the player gets a fair 1–3 star rating (F04), a gently-ramping 30-level campaign (F05), and a solvable daily (F07) — all because every shipped puzzle was solver-verified with a stored `optimalMoves`.

---

## Dependencies

* Upstream: **F01 dictionary-service (Done)** — the solver's frozen-thaw checks and target-word eligibility go through a `WordValidator` over `DictionaryService`. **F02 grid-engine (Done)** — the solver operates on `GridState` / `GridState.applyMove` / `GridState.canonicalKey` / `EngineConfig.legalMoves`; a valid solution is a move sequence that drives `GridState.initial` to a state where `isSolved`.
* Downstream: F05 (Journey loads the 30 exported level artifacts), F07 (Daily loads pool artifacts), F04 (reads `optimalMoves` for the star bands), F08 (persists the `Puzzle` / `EngineConfig` a session was built from).
* Platform (`platform.md`): §3 monorepo layout (`packages/looplet_solver` → `looplet_engine`; `packages/looplet_content` → `looplet_core`; `tools/looplet_authoring` → engine + solver + content); §11 no runtime RNG *on device* — the authoring tools MAY use RNG at authoring time; §13 "solver approach: bidirectional BFS over a packed canonical grid-state hash; fall back to IDA* only if memory-bound" (direction set, exact form open).

---

## In Scope

* **`looplet_content` `Puzzle` model** — the authored puzzle definition + JSON (de)serialization, `schemaVersion` / `contentVersion`, and the serialized enums (`difficultyLabel`, `puzzleType`). It composes F02's `EngineConfig`. This is the single content schema for F05, F07, F08.
* **`looplet_solver`** — given an `EngineConfig` + `WordValidator`, compute the **provable minimum** number of moves from `GridState.initial` to any `isSolved` state, honoring locked/frozen tiles (frozen-thaw is already part of `applyMove`). Return the count and one optimal move sequence, or "unsolvable", or "exceeds the search budget".
* **Solvability verification** — a puzzle is publishable only if the solver proves it solvable with a finite minimum.
* **Difficulty score + label** — a numeric score from the §48 parameters (optimal move count, correct-looking intermediate states, required temporary displacement, locked count, frozen count, number of plausible routes) and an `Easy` / `Medium` / `Hard` / `Expert` label.
* **`tools/looplet_authoring` CLI** — commands to: define a puzzle (target, initial grid, locked cells, frozen cells, columnMovesEnabled), run the solver, print solvability + `optimalMoves` + difficulty, playtest (apply a move sequence against the real engine and report state), and **export** a validated `Puzzle` artifact. **Refuses to export** an unsolvable puzzle or one without an `optimalMoves` value.
* **Content generation helpers** — bias the grid's random letter fill toward Turkish letter frequency; reduce "misleading nonsense strings" per a defined heuristic (not every row must be a real word).
* **The MVP content set** — the 30 Journey level artifacts (honoring the §20 difficulty curve) and an initial Daily pool, checked into `content/` and (for Daily) shaped for F07/F08 distribution.
* **Tests** — solver minimality (vs a brute-force reference on a bounded test set), locked/frozen honoring, unsolvable detection, budget-exceeded handling, determinism; `Puzzle` JSON round-trip + schema validation; difficulty-score stability; CLI export-gate behavior; a build-time check that every shipped artifact is solver-verified with a stored `optimalMoves`.

## Out of Scope

* Running the solver **on device** — build-time / authoring-time only (`platform.md` §13). The app never imports `looplet_solver`.
* The Journey unlock / progress UI (F05), the Daily reset / streak / scoring (F07), the star bands themselves (F04) — F06 only produces the `optimalMoves` those features consume.
* Daily puzzle **distribution** (CDN / Remote Config / offline cache) — F07/F08. F06 produces the pool artifacts.
* A polished GUI level editor — a **CLI is the MVP-critical path** (`platform.md` §13); a Flutter-desktop editor is a Future Consideration.
* Procedural / infinite level generation at runtime (source §43 — out of MVP).
* Phase-2 mechanics (Portal, One-Way, Move-Limited, Multi-target — source §44).
* Difficulty **auto-tuning** (search for puzzles hitting a target difficulty) — the MVP authors handcraft and the tool *rates*; auto-search is a Future Consideration.

---

## User Stories

F06 is Infrastructure + internal tooling; expressed as system requirements plus a Level Designer actor.

* The system must compute the provable minimum move count from an authored puzzle's initial grid to a winning state, honoring locked and frozen tiles, so that every shipped puzzle has a trustworthy `optimalMoves`.
* The system must report a puzzle as unsolvable (no winning state reachable) or budget-exceeded (minimum not proven within the configured search bound), so unverified puzzles are never shipped.
* The system must compute a difficulty score and an `Easy`/`Medium`/`Hard`/`Expert` label from the §48 parameters, so a Level Designer can place a puzzle on the §20 curve.
* As a Level Designer, I want to define a puzzle (target, grid, locks, freezes, column toggle), run the solver, see solvability + `optimalMoves` + difficulty, and playtest it, so that I can iterate quickly.
* As a Level Designer, I want export to refuse an unsolvable or optimal-less puzzle, so a broken puzzle cannot reach production.
* The system must serialize/deserialize a `Puzzle` (authored definition + `optimalMoves` + difficulty + `schemaVersion`/`contentVersion`) as the one content schema consumed by F05, F07, and F08.
* The system must produce the 30 Journey level artifacts and an initial Daily pool as versioned files, with a build-time check that each carries a solver-verified `optimalMoves`.

---

## Acceptance Criteria

* **Given** a solvable `EngineConfig` with no locked/frozen tiles, **When** the solver runs, **Then** it returns a move count `m` and a length-`m` move sequence that drives `GridState.initial` to an `isSolved` state, and no shorter sequence exists (verified against an exhaustive BFS reference on the bounded test set).
* **Given** a solvable `EngineConfig` with locked and/or frozen tiles, **When** the solver runs, **Then** the returned optimal sequence only uses moves that `GridState.applyMove` accepts (`applied == true`) and reaches `isSolved`, and its length is minimal.
* **Given** an `EngineConfig` from which no winning state is reachable, **When** the solver runs, **Then** it returns `unsolvable` (not a wrong number, not a hang).
* **Given** an `EngineConfig` whose minimum exceeds the configured search bound, **When** the solver runs, **Then** it returns `budgetExceeded` with the bound, and the puzzle is not publishable.
* **Given** the same `(EngineConfig, WordValidator)`, **When** the solver runs twice, **Then** it returns the same minimum count (the returned sequence may differ but must also be minimal and valid).
* **Given** a `Puzzle` object, **When** serialized to JSON and parsed back, **Then** the result equals the original (`EngineConfig`, target, locks, freezes, `columnMovesEnabled`, `optimalMoves`, `difficultyScore`, `difficultyLabel`, `schemaVersion`, `puzzleType`, `journeyLevelNumber?` / `dailyDate?`).
* **Given** a JSON artifact with a missing `optimalMoves`, an unsupported `schemaVersion`, or a shape violation, **When** parsed, **Then** it is rejected (a typed error), and any build-time content check fails.
* **Given** the §48 parameters for a puzzle, **When** the difficulty score is computed twice, **Then** the score and label are identical (deterministic), and the label thresholds are documented.
* **Given** the CLI `export` command on an unsolvable puzzle or one with no `optimalMoves`, **When** invoked, **Then** it exits non-zero and writes no artifact.
* **Given** the CLI `solve` command on a puzzle, **When** invoked, **Then** it prints solvability, `optimalMoves` (or `unsolvable` / `budgetExceeded`), the difficulty score + label, and one optimal move sequence.
* **Given** the CLI `playtest` command with a move sequence, **When** invoked, **Then** it applies the sequence via the real engine and reports each step's applied/rejected state and whether the puzzle is solved.
* **Given** the 30 shipped Journey artifacts, **When** the build-time content check runs, **Then** every artifact has a solver-verified `optimalMoves`, a difficulty label consistent with the §20 curve band for its level number, and the correct `columnMovesEnabled` (false for levels 1–3).
* **Given** the grid letter-fill helper, **When** it fills N cells, **Then** the letter distribution is measurably closer to Turkish frequency than uniform (a documented statistical check).

---

## Edge Cases

* Puzzle already solved at t = 0 (`optimalMoves == 0`) → rejected by content rules as trivial (not by the solver, which would correctly return 0).
* Multiple frozen tiles whose thaw order branches the search — the solver must still terminate with a proven minimum (frozen-thaw is monotone forward, but the *order* in which rows form words is a branching choice).
* A frozen tile whose only thaw path needs a column move on a `columnMovesEnabled == false` puzzle → the solver reports `unsolvable` (correct); the CLI surfaces it clearly so the designer fixes the puzzle.
* A target reachable in multiple rows / by multiple distinct routes → the solver still returns *the* minimum; the "number of plausible routes" difficulty metric reflects the multiplicity.
* Highly symmetric grids producing many equal-cost optimal solutions → deterministic minimum count; the returned sequence is one of them (tie-break must be deterministic).
* Search-space blow-up on a hard 26–30 (locked + frozen) puzzle → the search bound + a time budget prevent a hang; `budgetExceeded` is a valid, non-shipping outcome.
* A `Puzzle` JSON with extra unknown keys → ignored (forward-compatible), as with F01's dictionary asset.
* Daily pool artifacts must not duplicate a Journey puzzle and must not repeat within a rolling window (a documented rule).
* Difficulty label for a puzzle whose `optimalMoves` is outside the §20 band for its intended level → the check flags it (a Level Designer decision, not an auto-fix).
* Circumflex / `İ`/`I` handling in the grid fill and the frozen-word checks — must go through F01's normalization (via the `WordValidator`), consistent with F02.

---

## Success Metrics

* 100% of shipped puzzles (30 Journey + Daily pool) are solver-verified with a stored `optimalMoves`; a build-time check enforces it.
* Solver minimality is correct on 100% of the bounded reference test set (solver result == exhaustive-BFS minimum).
* Solver terminates (proven minimum, `unsolvable`, or `budgetExceeded`) within the configured time budget on every 5×5 puzzle in the test set, including the hardest locked+frozen configurations.
* `Puzzle` JSON round-trips losslessly; 0 shipped artifacts fail schema validation.
* Difficulty score + label are deterministic (identical on repeated computation) and the label thresholds are documented.
* The CLI `export` gate rejects 100% of unsolvable / optimal-less puzzles in the test set.
* 0 uses of RNG in `looplet_solver` and `looplet_content` (deterministic); RNG in `tools/looplet_authoring` is confined to the seeded grid-fill helper and is reproducible from a seed.

---

## Open Questions

*(To be resolved by the Technical Analyst pass, then locked by the Tech Lead in `architecture.md`.)*

* **Solver algorithm.** `platform.md` §13 sets the direction ("bidirectional BFS over a packed canonical grid-state hash; fall back to IDA* if memory-bound"). Open: does bidirectional BFS work cleanly given (a) the goal is a *set* of states (any grid with a full target row), and (b) frozen-thaw is irreversible (backward moves cannot un-thaw)? Compare: forward BFS with a `canonicalKey` visited set + depth/time bound; IDA* with an admissible heuristic (e.g. minimum shifts to bring the target letters into some row, ignoring collisions); bidirectional with an enumerated goal frontier. Recommend one, with the memory/time trade-offs on a 5×5 with locked + up-to-N frozen tiles.
* **Search bound.** What maximum depth / node count / wall-clock budget makes a puzzle "publishable" vs `budgetExceeded`? (The §20 curve tops out at optimal 8–12, so a bound around ~16–20 is plausible.)
* **Difficulty-score formula.** Concrete, computable definitions for each §48 parameter: "correct-looking intermediate states" (states where ≥ k target letters are already in a row?), "required temporary displacement" (does every optimal solution move a target letter *away* from a target row at some point?), "number of plausible routes" (count of distinct optimal solutions? distinct optimal *first moves*? a bounded near-optimal count?). Plus the score → label thresholds.
* **`Puzzle` schema.** Exact field set and JSON shape; how `EngineConfig` (nested) is serialized (grid as row strings? coord lists for locks/freezes?); `contentVersion` semantics; where `looplet_content` re-exports F02 types.
* **Editor form.** CLI only for the MVP (confirmed direction) — exact command set, input format (a puzzle-definition file? interactive prompts? both?), and whether a minimal Flutter-desktop preview is worth it now.
* **Content-rule heuristics.** The Turkish-frequency biasing method (weighted sampling table) and the "misleading nonsense strings" reduction rule (reject a random fill if a row contains a ≥4-letter substring that is *almost* a word? that reads as an offensive/again-excluded string?).
* **Daily pool rules.** Pool size for the MVP, the no-duplication-with-Journey rule, and the no-repeat-within-window rule.
