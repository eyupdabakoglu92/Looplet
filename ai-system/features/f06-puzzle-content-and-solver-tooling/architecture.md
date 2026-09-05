# F06 — puzzle-content-and-solver-tooling: Architecture

> Status: INITIAL CONTRACT BRIEF (Tech Lead). Sections marked **[LOCKED]** are contract now; sections marked **[PENDING ANALYSIS]** are decided after the Technical Analyst pass and this file's Tech Lead revision. Delivery must not start until the pending sections are resolved.

---

## Purpose

* **Feature objective:** the build-time toolchain that makes LOOPLET content trustworthy — `looplet_solver` (provable-minimum-move search), `tools/looplet_authoring` (CLI level editor), and the `looplet_content` `Puzzle` model — plus the MVP content set (30 Journey levels + Daily pool).
* **Contract scope:** the `Puzzle` schema + JSON serialization; the `looplet_solver` public API + its correctness guarantee (provable minimum); the difficulty-score definition; the CLI command surface + its export gate; the build-time content check; the content artifact layout under `content/`.
* **Non-goals:** on-device solving (`platform.md` §13 — the app never imports `looplet_solver`); F04 star bands / F05 unlock UI / F07 Daily reset+scoring / F08 persistence (F06 only produces `optimalMoves` and artifacts they consume); Daily distribution (F07/F08); a GUI editor; runtime procedural generation; Phase-2 mechanics; difficulty auto-tuning.

---

## Authorities & Inputs

* Upstream PRD: `features/f06-.../prd.md`; product PRD §5.5, §6.1 (F06), §12–13, §46–49.
* Inherited contracts **[LOCKED]**:
  * **F02** (`features/f02-grid-engine/architecture.md`) — the solver operates on `GridState` / `GridState.initial(config, validator)` / `GridState.applyMove(move, config, validator)` / `GridState.canonicalKey()` / `EngineConfig` / `EngineConfig.legalMoves(GridState)`. A solution of length `m` is an ordered `List<Move>` such that folding it over `GridState.initial` yields a state with `isSolved == true`, and every step is `applied`. `canonicalKey()` is the search node identity.
  * **F01** — word validation via `WordValidator` (the port F02 defined). The solver and CLI take a `WordValidator`; the tooling supplies an adapter over `looplet_dictionary` (`tools`/`looplet_solver` MAY depend on `looplet_dictionary` — they are not on-device).
* Project authority: `platform.md` §3 (monorepo layout + dependency edges), §11 (Turkish-locale via F01; no runtime RNG **on device** — authoring-time RNG allowed but must be seeded/reproducible), §13 (solver approach direction). Release: `none` (build-time tooling, never distributed to devices).

---

## Dependency Edges [LOCKED]

* `packages/looplet_content` → `looplet_core` only. Defines `Puzzle` + JSON + serialized enums (`DifficultyLabel`, `PuzzleType`). Re-exports F02's engine primitive types (already scaffolded) and composes `EngineConfig` — **[PENDING ANALYSIS]** whether `looplet_content` may depend on `looplet_engine` for the `EngineConfig` type, or whether `Puzzle` stores the raw fields and hands them to `EngineConfig(...)` at load time (Tech Lead leans to the latter — keeps `looplet_content` engine-free, mirrors how F02 kept `looplet_engine` dictionary-free).
* `packages/looplet_solver` → `looplet_engine` (+ `looplet_dictionary` for a `WordValidator` adapter, OR takes the port and the adapter lives in `tools` — **[PENDING ANALYSIS]**).
* `tools/looplet_authoring` → `looplet_engine` + `looplet_solver` + `looplet_content` + `looplet_dictionary`. A Dart executable package; **not** shipped in the app.
* The `app` never depends on `looplet_solver` or `tools/looplet_authoring`. The `app` depends on `looplet_content` (to load `Puzzle` artifacts).

---

## `Puzzle` Model [PENDING ANALYSIS — shape], [LOCKED — required fields]

**[LOCKED]** every `Puzzle` artifact MUST carry:

* `schemaVersion` (int; parser rejects anything it does not understand)
* `id` (stable identifier)
* `puzzleType` (`journey` | `daily`)
* `language` (matches `LanguageCode`)
* the authored puzzle definition: initial grid, `targetWord`, locked cells, frozen cells, `columnMovesEnabled`
* `optimalMoves` (int ≥ 0) — **solver-verified; an artifact without it is invalid and cannot ship**
* `difficultyScore` (num) + `difficultyLabel` (`easy` | `medium` | `hard` | `expert`)
* `contentVersion` (the pack revision this artifact came from)
* `journeyLevelNumber` (1–30) for `journey`; `dailyDate` (`YYYY-MM-DD`) for `daily`

**[PENDING ANALYSIS]** the exact JSON shape (grid as row strings vs nested arrays; locks/freezes as `"r,c"` strings vs objects; how/whether the nested `EngineConfig` is represented), and whether `Puzzle.toEngineConfig()` builds an `EngineConfig` on demand.

---

## `looplet_solver` API & Guarantee [PENDING ANALYSIS — algorithm], [LOCKED — contract]

**[LOCKED]** the solver's public result is one of:

* `SolveResult.optimal(int moves, List<Move> sequence)` — `moves` is the **provable minimum**; `sequence` is one valid optimal solution (deterministic tie-break); folding `sequence` over `GridState.initial` reaches `isSolved` with every step `applied`.
* `SolveResult.unsolvable()` — no `isSolved` state is reachable.
* `SolveResult.budgetExceeded(int bound)` — the minimum was not proven within the configured bound; the puzzle is **not publishable**.

**[LOCKED]** the solver is deterministic: same `(EngineConfig, WordValidator)` → same `moves` (and `unsolvable`/`budgetExceeded`); the returned `sequence` is stable under a documented tie-break. No unseeded RNG.

**[PENDING ANALYSIS]** the search algorithm (forward BFS + `canonicalKey` visited set + bound; IDA* + admissible heuristic; bidirectional with an enumerated goal frontier — see `prd.md` Open Questions), the search bound (depth / nodes / wall-clock), the frozen-thaw branching handling, and the proof-of-minimality argument. `platform.md` §13's direction (bidirectional BFS, IDA* fallback) is the starting point but the Analyst evaluates it against the goal-is-a-set and thaw-is-irreversible facts.

---

## Difficulty Score [PENDING ANALYSIS]

Computable definitions for each §48 parameter (optimal move count; correct-looking intermediate states; required temporary displacement; locked count; frozen count; number of plausible routes), the score formula, and the score → `easy`/`medium`/`hard`/`expert` thresholds. **[LOCKED]** the score and label MUST be deterministic and the thresholds documented in this file after the Analyst pass.

---

## CLI Surface [PENDING ANALYSIS — exact commands], [LOCKED — behaviors]

**[LOCKED]**:

* a `solve` capability — prints solvability, `optimalMoves` (or `unsolvable` / `budgetExceeded`), difficulty score + label, one optimal move sequence.
* a `playtest` capability — applies a given move sequence via the real engine, reports each step's applied/rejected + final solved state.
* an `export` capability — writes a validated `Puzzle` artifact; **exits non-zero and writes nothing** for an unsolvable puzzle or one without `optimalMoves`.
* a puzzle-definition input format (file and/or flags).

**[PENDING ANALYSIS]** exact command names, the definition-file format, and whether a minimal Flutter-desktop preview is in the MVP (Tech Lead: no — CLI only).

---

## Content Artifacts & Build Check [LOCKED]

* Journey levels: `content/journey/<lang>/levelNN.json` (NN = 01..30). Daily pool: `content/daily/<lang>/pool/*.json` (Daily distribution shape is F07's).
* A build-time content check (runnable in CI) MUST fail if any shipped artifact: lacks `optimalMoves`; fails `Puzzle` schema validation; (Journey) has a `columnMovesEnabled` / difficulty-band inconsistent with its level number per source §20; (Daily) duplicates a Journey puzzle.
* Content generation RNG (`tools/looplet_authoring` grid-fill helper) MUST be seeded and reproducible from the seed.

---

## Validation Responsibility [LOCKED]

* **`looplet_content`:** `Puzzle` JSON shape + `schemaVersion` + required-field presence (esp. `optimalMoves`).
* **`looplet_solver`:** solution validity (every step `applied`, reaches `isSolved`) + minimality; unsolvable / budget-exceeded detection.
* **`tools/looplet_authoring`:** the export gate (no unsolvable / optimal-less artifact); the build-time content check.
* **`EngineConfig` (F02):** structural puzzle validity — F06 does not re-validate grid dimensions etc.

---

## QA Focus [LOCKED]

* Solver minimality vs an exhaustive-BFS reference on a bounded test set (no-tiles, locked, single-frozen, multi-frozen); locked/frozen honoring (returned sequence only uses `applied` moves); `unsolvable` and `budgetExceeded` detection; determinism (same minimum twice; stable tie-break).
* `Puzzle` JSON lossless round-trip; rejection of missing `optimalMoves` / bad `schemaVersion` / shape violations.
* Difficulty score + label determinism; documented thresholds honored.
* CLI: `solve` / `playtest` / `export` behaviors, incl. the export gate exiting non-zero on a broken puzzle.
* Build-time content check catches a planted bad artifact (no `optimalMoves`; wrong `columnMovesEnabled` for level 2; Journey/Daily duplicate).
* Turkish-frequency grid-fill statistical check; seeded reproducibility.
* **Evidence class:** `automated functional` (pure-Dart `dart test` + CLI invocation from tests). No device runtime.
* **QA scope:** client-only (package + CLI level), source + automated tests.

---

## Release / Deployment Impact [LOCKED]

* Release scope: **none** — build-time tooling + checked-in content artifacts; nothing is distributed to devices by F06. (Daily *distribution* is F07/F08 and has its own release considerations.)
* CI impact: the build-time content check SHOULD be added to `.github/workflows/ci.yml` as a gate once the first artifacts exist.

---

## Open Technical Decisions — routed to Technical Analyst

1. Solver algorithm + search bound + frozen-thaw branching + minimality proof (`prd.md` Open Q 1–2).
2. Difficulty-score computable definitions + formula + label thresholds (`prd.md` Open Q 3).
3. `Puzzle` JSON schema + whether `looplet_content` depends on `looplet_engine` (`prd.md` Open Q 4).
4. CLI command set + puzzle-definition input format; desktop-preview yes/no (`prd.md` Open Q 5).
5. Content-rule heuristics: Turkish-frequency biasing table + "misleading nonsense strings" rule (`prd.md` Open Q 6).
6. Daily pool size + no-duplication + no-repeat-window rules (`prd.md` Open Q 7).
7. `WordValidator` adapter placement: `looplet_solver` depends on `looplet_dictionary`, or takes the port with the adapter in `tools`.

The Analyst produces `analysis.md` (options + trade-offs + recommendation per item); the Tech Lead then revises this file to move each item from **[PENDING ANALYSIS]** to **[LOCKED]** before any implementation handoff.
