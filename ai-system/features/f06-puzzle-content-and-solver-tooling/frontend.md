# F06 — puzzle-content-and-solver-tooling: Frontend Delivery Report

Role: Frontend/Mobile Developer · Date: 2026-09-05 · Mode: Direct-edit

---

## 1. Feature Summary

Implemented the F06 build-time toolchain per `architecture.md`:

* **`looplet_content`** — the `Puzzle` model + JSON (de)serialization (`looplet_core`-only; no engine dependency).
* **`looplet_solver`** — forward-BFS `Solver.solve` (provable minimum / `Unsolvable` / `BudgetExceeded`) + `enumerateOptimalSolutions` + the deterministic `DifficultyScorer`.
* **`tools/looplet_authoring`** — the CLI: `solve` / `playtest` / `export` (with the refuse-broken-puzzle gate) / `check` (the CI content gate) / `fill` (seeded Turkish-frequency grid helper).
* A **5-puzzle smoke set** in `content/smoke/tr/`, `check`-green, covering all five mechanic classes.
* CI wiring: a `Content check` step + a `content:check` melos script.
* The carried F02 tidy: `GridState.applyMove` now reads all `EngineConfig` fields from one source.

Delivery scope = toolchain + smoke set (per `architecture.md` "Scope of the F06 Implementation Delivery"). `F06-CONTENT` (the full 30 Journey + Daily pool) is the tracked follow-on.

All tasks (F06.1-FE … F06.SMOKE-FE) complete. Gates green: `melos run format:check`, `melos run analyze` (6 packages + `flutter analyze`), `melos run test` (**200 tests**), `melos run content:check`.

---

## 2. Impacted Files

**Created**

* `packages/looplet_core/lib/src/content_primitives.dart` — `PuzzleType`, `DifficultyLabel`
* `packages/looplet_content/lib/src/puzzle.dart` — `Puzzle`, `PuzzleFormatException`
* `packages/looplet_content/test/puzzle_test.dart`
* `packages/looplet_solver/lib/src/{solve_result,solver,difficulty}.dart`
* `packages/looplet_solver/test/{solver_test,difficulty_test}.dart` + `test/support/reference.dart`
* `tools/looplet_authoring/lib/looplet_authoring.dart` + `lib/src/{cli,content_check,puzzle_def,dictionary_validator,move_shorthand,turkish_frequency}.dart`
* `tools/looplet_authoring/bin/looplet_authoring.dart` (rewritten)
* `tools/looplet_authoring/test/{cli_test,content_check_test,fill_test,smoke_content_test}.dart` + `test/fixtures/*.json`
* `tools/looplet_authoring/defs/smoke/level0{1,2,4,5,6}.json`
* `content/smoke/tr/level0{1,2,4,5,6}.json` + `content/journey/tr/` + `content/daily/tr/pool/` (placeholders)

**Updated**

* `packages/looplet_core/lib/looplet_core.dart` — export `content_primitives.dart`
* `packages/looplet_content/lib/looplet_content.dart` — re-export `PuzzleType`/`DifficultyLabel` from `looplet_core`; export `Puzzle`
* `packages/looplet_solver/lib/looplet_solver.dart` — real barrel
* `packages/looplet_engine/lib/src/grid_state.dart` — `applyMove` single-config-source tidy (F02 note)
* `tools/looplet_authoring/pubspec.yaml` — `args` + `looplet_dictionary` deps
* `.github/workflows/ci.yml` — `Content check` step
* `melos.yaml` — `content:check` script

**Removed**: `looplet_content` / `looplet_solver` placeholder + smoke-test files.

---

## 3. Task-to-Code Traceability

* **F06.1-FE** — Complete. `puzzle.dart`: `Puzzle` with all `architecture.md`-required fields; `fromJson` (typed `PuzzleFormatException` for unsupported `schemaVersion` / missing `optimalMoves` / missing `grid`|`targetWord`|`id` / bad `puzzleType`|`difficultyLabel`|`language` / malformed `"r,c"` / journey-without-level / daily-without-date; unknown keys ignored); lossless `toJson` (coords sorted). `PuzzleType` / `DifficultyLabel` moved to `looplet_core` (`content_primitives.dart`), re-exported by `looplet_content` — keeps `looplet_content` → `looplet_core` only. `difficultyBreakdown` **required** in the artifact. 17 tests.
* **F06.2-FE** — Complete. `solver.dart` `Solver.solve`: FIFO BFS from `GridState.initial`; successors `EngineConfig.legalMoves` sorted by a total `(axis, index, direction)` comparator; visited `Set<String>` on `canonicalKey`; parent `Map` for path reconstruction; `SearchBudget(maxDepth 16, maxNodes 5M, timeBudget 30s)`. `SolveResult` sealed (`Optimal(moves, sequence)` | `Unsolvable` | `BudgetExceeded(budget)`). A depth-wall hit → `BudgetExceeded` (not `Unsolvable`) via a `hitDepthWall` flag. `Stopwatch` used (allowed in `looplet_solver` per contract). 15 tests incl. minimality vs the **independent IDDFS reference** (`test/support/reference.dart` — iterative-deepening DFS, no visited set, a different algorithm) on no-tiles / locked / frozen; `Unsolvable`; `BudgetExceeded` (depth wall + node cap + unsolvable-under-low-wall); determinism (identical `moves` + byte-identical `sequence`); returned-sequence validity.
* **F06.3-FE** — Complete. `Solver.enumerateOptimalSolutions`: forward BFS builds `dist` (shortest depth) to every state within `optimal`, then a DFS confined to the "optimal DAG" (only edges to a state at `depth + 1`), bounded by `cap`. Deterministic order. `[]` for unsolvable, `[[]]` for pre-solved. 3 tests.
* **F06.4-FE** — Complete. `difficulty.dart`: `DifficultyWeights` / `DifficultyThresholds` (const defaults from `architecture.md`, overridable); `DifficultyScorer.score` implements all six metrics per the contract table — `o`; `cNorm` (distinct states at BFS depth `0<d<o` with a row ≥ 3 correct target positions, over states within `o`); `tdDegree` (min over optimal solutions of steps where max-correct-count decreases); `L`, `F`; `firstMoves`; `distinctOptimalSolutions` (≤ cap). Score formula + label. Deterministic. 8 tests (determinism, per-metric monotonicity, custom weights/thresholds, throws for unsolvable).
* **F06.5-FE** — Complete. `cli.dart` (`package:args` `CommandRunner`): `_BaseCommand` wraps `execute()` to turn domain exceptions into non-zero exit + stderr (usage errors still propagate). `solve` / `playtest` (`--moves "R0 D2 L4"` via `move_shorthand.dart`) / `export` (`--out`, `--content-version`; gate: non-zero exit + **no file** on `unsolvable` / `budgetExceeded` / `optimalMoves == 0` / malformed def). `puzzle_def.dart`: JSON def-file parser → `EngineConfig` + `Puzzle`. `dictionary_validator.dart`: `DictionaryWordValidator` over F01's `DictionaryService` via a disk-reading `DictionaryAssetSource` (adapter lives here, **not** in `looplet_solver`). 7 CLI tests.
* **F06.6-FE** — Complete. `content_check.dart` `runContentCheck`: per artifact — `Puzzle.fromJson` schema; re-solve and compare `optimalMoves`; `targetWord` is `isEligibleTarget` (F01); Journey level 1–3 ⇒ `columnMovesEnabled == false`; `difficultyLabel` in the §20 band for the level; Journey internal + Journey↔Daily dedup (by grid+target+locks+freezes signature); Daily `manifest.json` no-repeat-window (default 30 days). `check` command → non-zero exit naming each failure. Wired into `.github/workflows/ci.yml` (`Content check` step) + `melos.yaml` (`content:check`). 7 planted-bad-artifact tests + a `smoke_content_test.dart` that runs `check content/smoke`.
* **F06.7-FE** — Complete. `turkish_frequency.dart`: `turkishLetterFrequency` (~29-entry `const` map, approximate published Turkish frequencies, sourced note in the doc comment; no q/w/x); `SeededLetterSampler` (weighted, `Random(seed)`, emits Turkish-uppercase, reproducible); `hasNearTargetRun` (edit-distance ≤ 1 from target for any ≥4-letter row run). `fill` command: `--seed`, `--size`, `--target`, `--avoid-near-target` (default off), bounded retry, rejects an already-solved fill. 5 tests (seed reproducibility, seed variance, frequency bias, `--avoid-near-target` path). **F02 tidy:** `GridState.applyMove` now reads `columnMovesEnabled` / `gridSize` / `targetWord` / `frozenCells` from the stored `_config` (was: mixed `_config` + parameter); the `config` parameter is kept for signature stability and documented as authoritative-via-`_config`. F02 engine suite re-run: 83 tests green, analyze clean.
* **F06.SMOKE-FE** — Complete. 5 def files (`tools/looplet_authoring/defs/smoke/`) → `export`ed to `content/smoke/tr/`: level01 no-tiles columns-off (optimal 1, easy); level02 no-tiles columns-off (optimal 2, easy); level04 column-move-on-path (optimal 1, easy); level05 locked tile (optimal 2, medium); level06 frozen tile thaw+win (optimal 1, easy). `melos run content:check` green. One authoring correction made during the pass: level04's target `DENIZ` (Latin I) is not a dictionary word — the correct Turkish target is `DENİZ` (dotted İ); fixed. This is F01's `İ ≠ I` rule surfacing correctly through the whole pipeline.

---

## 4. Authority Reconciliation

* **`PuzzleType` / `DifficultyLabel` location.** `architecture.md` said "`looplet_content` defines `PuzzleType` / `DifficultyLabel`". But `looplet_solver.DifficultyScorer` returns a `DifficultyLabel`, and `looplet_solver` must not depend on `looplet_content` (dependency edges). Resolution: moved both enums to **`looplet_core`** (same rationale and pattern as F02's `MoveAxis` carve-out — value types that cross package boundaries), re-exported by `looplet_content`. `looplet_content` stays `looplet_core`-only; `looplet_solver` gets the enum via `looplet_core`. Winning authority: the dependency-edge constraint in `architecture.md` "Dependency Edges" + the established F02 pattern. Downstream: `platform.md` §11 should note `PuzzleType`/`DifficultyLabel` alongside the engine primitives (a one-liner for the Tech Lead — no behavior change).

---

## 5. Components

| Type | Package | Responsibility |
| --- | --- | --- |
| `Puzzle` / `PuzzleFormatException` | `looplet_content` | content schema + JSON |
| `SolveResult` / `Optimal` / `Unsolvable` / `BudgetExceeded` / `SearchBudget` | `looplet_solver` | solve outcome |
| `Solver` | `looplet_solver` | `solve` (forward BFS) + `enumerateOptimalSolutions` |
| `Difficulty` / `DifficultyWeights` / `DifficultyThresholds` / `DifficultyScorer` | `looplet_solver` | deterministic difficulty |
| CLI commands (`solve`/`playtest`/`export`/`check`/`fill`) | `tools/looplet_authoring` | authoring workflow + CI gate |
| `PuzzleDef` | `tools/looplet_authoring` | def-file → `EngineConfig` / `Puzzle` |
| `DictionaryWordValidator` + disk asset source | `tools/looplet_authoring` | production `WordValidator` for the solver |
| `SeededLetterSampler` / `turkishLetterFrequency` / `hasNearTargetRun` | `tools/looplet_authoring` | `fill` |
| `runContentCheck` | `tools/looplet_authoring` | the content gate |

---

## 9. Contract Compliance Check

* **`Puzzle` model + JSON shape** — Preserved. Grid row strings, `"r,c"` coords, unknown keys ignored, typed `PuzzleFormatException`, `optimalMoves` required + non-nullable.
* **`looplet_content` dependency** — Preserved. `looplet_core` only.
* **`looplet_solver` dependency** — Preserved. `looplet_engine` only; the dictionary adapter is in `tools/looplet_authoring`.
* **`Solver.solve` guarantee** — Preserved. `Optimal` is a provable minimum (BFS-by-construction, goal tested on dequeue); deterministic; `sequence.length == moves`; every step `applied`; folding reaches `isSolved`. `SearchBudget` defaults `16 / 5M / 30s`; depth-wall / node-cap / time-cap → `BudgetExceeded`.
* **Difficulty** — Preserved. Metric definitions per the contract table; weights/thresholds configurable; deterministic.
* **CLI** — Preserved. `solve` / `playtest` / `export` / `check` / `fill`; `export` gate exits non-zero + writes nothing on broken puzzles; `check` is the CI content gate.
* **Content layout + `check` rules** — Preserved. `content/journey/<lang>/`, `content/daily/<lang>/pool/` + `manifest.json`; Journey band consistency, dedup, Daily no-repeat-window, `optimalMoves` re-verification, target eligibility.
* **No RNG in `looplet_solver` / `looplet_content`** — Preserved. RNG is confined to `SeededLetterSampler` in `tools`; a `Stopwatch` is used in `looplet_solver` (explicitly allowed by the contract).
* **Navigation / UI / async** — Not Applicable (build-time tooling + CLI).

---

## 13. Performance Notes

* Smoke-set puzzles (optimal 1–2, or with locked/frozen tiles) solve in **< 1 ms** (JIT).
* A **fully-open** 5×5 with 25 distinct letters and **optimal 5** takes **~4.6 s** (JIT, `dart run`, unoptimized) — the reachable state space is large before any tile constraints. optimal 1–2 are instant; cost grows sharply with optimal depth on open grids.
* Implication for `F06-CONTENT` authoring (**flag for Tech Lead / Level Designer**): levels 11–15 (fully open, optimal 6–8) are the cost risk zone. Mitigations, all within the designed flow: run `export` as an AOT binary (`dart compile exe bin/looplet_authoring.dart` — expect 2–5× faster); levels 16–30 have locked/frozen tiles that *shrink* the space; and any candidate grid that blows the `SearchBudget` returns `budgetExceeded` → the designer picks an easier configuration (the intended feedback). If levels 11–15 prove impractical fully-open, add a locked-adjacent constraint or bump `timeBudget` for the authoring machine.
* `enumerateOptimalSolutions` and `DifficultyScorer` run 2–3 extra BFS passes to depth `optimal` — negligible for the shallow smoke puzzles; scales with the same `optimal`-depth cost as `solve`.

---

## 14. Assumptions

* `SeededLetterSampler` uses `dart:math` `Random(seed)` — allowed in `tools/looplet_authoring` (not shipped; `platform.md` §11 bans runtime RNG *on device* only). Seeded ⇒ reproducible.
* The Turkish frequency table is *approximate* published data (order-of-magnitude); it is a sampling *bias* for a designer's starting board, not a precise model. The exact source is a Level-Designer choice (`architecture.md` Open Technical Decisions).
* `check` re-solves every artifact with the **production** dictionary validator (read from `packages/looplet_dictionary/assets/`), so it detects drift after an F01 corpus change.
* The smoke set covers mechanic classes, not the full §20 difficulty spread; real hard/expert puzzles come with `F06-CONTENT`.

---

## 16. Needs Tech Lead Clarification

* Minor (already resolved, recorded in §4): `PuzzleType` / `DifficultyLabel` live in `looplet_core`, not `looplet_content` — please add a one-line note to `platform.md` §11 next revision. No behavior change.
* `F06-CONTENT` performance (§13): the fully-open levels 11–15 may need AOT `export` and/or a per-machine `timeBudget` bump, or a locked-tile constraint. Not blocking F06; relevant when `F06-CONTENT` starts.

---

## 17. Test Evidence by Task

| Task | File · count | Scenario proven |
| --- | --- | --- |
| F06.1-FE | `looplet_content/test/puzzle_test.dart` · 17 | lossless round-trip; daily vs journey field discrimination; unknown-key tolerance; rejects missing/`null`/typed `optimalMoves`, bad `schemaVersion`, missing `grid`/`targetWord`, bad `puzzleType`/`difficultyLabel`/`language`, malformed coord, journey-without-level, daily-without-date, non-object `difficultyBreakdown`; unmodifiable collections |
| F06.2-FE | `looplet_solver/test/solver_test.dart` · 15 (subset) | minimality **vs the independent IDDFS reference** on no-tiles (optimal 1, 2, column-on-path), locked-elsewhere, frozen-on-path (thaw+win); `Optimal(0, [])` for pre-solved; `Unsolvable` (small exhausted space); `BudgetExceeded` on depth wall / node cap / unsolvable-under-low-wall; determinism (byte-identical `sequence` ×2); returned sequence uses only `applied` moves and reaches `isSolved` |
| F06.3-FE | `solver_test.dart` (`enumerateOptimalSolutions` group) · 3 | finds every optimal solution for a small puzzle; deterministic order; respects `cap`; `[]` unsolvable / `[[]]` solved |
| F06.4-FE | `looplet_solver/test/difficulty_test.dart` · 8 | determinism (score + label + breakdown); every breakdown metric present; trivial puzzle → easy; +L raises score; +F raises score; more first-moves lowers score (route term); custom thresholds move the label; throws for unsolvable |
| F06.5-FE | `looplet_authoring/test/cli_test.dart` · 7 | `solve` prints optimal + difficulty + sequence; `solve` reports `unsolvable` with exit 0; `playtest` per-step + final solved; `export` writes a valid re-decodable artifact; `export` refuses unsolvable (non-zero, no file); refuses trivial (non-zero, no file); malformed def → non-zero |
| F06.6-FE | `looplet_authoring/test/content_check_test.dart` · 7 + `smoke_content_test.dart` · 1 | valid dir passes; catches missing `optimalMoves`, level-1–3 with columns enabled, stored-optimal drift, duplicate definition, ineligible target, Daily manifest repeat-within-window; `content/smoke` passes `check` |
| F06.7-FE | `looplet_authoring/test/fill_test.dart` · 5 | seed reproducibility; distinct seeds → distinct grids; common letters dominate rare 3:1 (frequency bias); `--target --avoid-near-target` path; F02 engine suite re-run green (83) |
| F06.SMOKE-FE | `content/smoke/tr/*.json` + `melos run content:check` | 5 mechanic-class puzzles exported + `check`-green; end-to-end `export` → `check` |

Totals: **200** workspace tests green (core 22, content 17, dictionary 32, engine 83, solver 23, authoring 19, app 4). `melos run format:check` / `analyze` (6 pkgs + `flutter analyze`) / `content:check` green. `melos run build:app` (Android) is CI-only locally.

---

## WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* Completed Tasks: F06.1-FE … F06.7-FE, F06.SMOKE-FE (+ carried F02 `applyMove` tidy)
* Remaining Tasks: none in frontend scope. `F06-CONTENT` is a separate follow-on.
* Blockers: none
* Status Suggestion: **Ready for QA** (client + CLI level, automated functional — `architecture.md` QA Focus)

---

## 19. Sonraki Komut

Run QA
