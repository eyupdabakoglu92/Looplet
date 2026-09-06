# F06 — puzzle-content-and-solver-tooling: QA Report

Role: QA · Date: 2026-09-05

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK**
* Screenshot / browser tool: **YOK**
* Runtime validation method: **`automated functional`** — `melos run format:check` / `analyze` / `test` (200 workspace tests) / `content:check` executed by QA; plus an independent 9-assertion QA probe and direct CLI invocations (`export` gate, `check` drift) run from the shell.

Not `source-only`. F06 is build-time tooling with no device-runtime risk class (no sockets, navigation, persistence, realtime, multi-actor).

---

## 1. Feature Summary

* **Feature tested:** F06 — the build-time toolchain: `looplet_content` (`Puzzle` model + JSON), `looplet_solver` (forward-BFS `Solver.solve` + `enumerateOptimalSolutions` + `DifficultyScorer`), `tools/looplet_authoring` CLI (`solve` / `playtest` / `export` / `check` / `fill`), the 5-puzzle smoke set, and the CI content-check wiring. Plus the carried F02 `applyMove` config-source tidy.
* **QA scope:** client + CLI level, automated functional. Per `architecture.md` "QA Focus" and `platform.md` §10, no device runtime — F06 is build-time-only tooling.
* **Delivery scope:** toolchain + smoke set. **`F06-CONTENT`** (the full 30 Journey + ~60 Daily authoring) is a tracked follow-on and is **out of scope for this QA**.

---

## 2. Test Scope

* **Scope Type:** Client Only (packages + CLI, automated functional). No `backend.md` — no backend scope. `frontend.md` present; validated via it + source + executed tests + an independent probe + direct CLI runs.
* **Documents reviewed:** `prd.md`, `architecture.md` (the [LOCKED] contract), `analysis.md` (rationale), `orchestration.md`, `frontend.md`, `role-execution-contract.md`, `system-state.md`, `project-authority/platform.md` §3/§10/§11/§13, `project-authority/setup-manifest.md`.
* **Areas tested:** `Puzzle` JSON round-trip + schema rejection; solver minimality (independent verification) + `Unsolvable` / `BudgetExceeded` + determinism; `enumerateOptimalSolutions` (all optimal-length, all valid, deterministic, capped); difficulty determinism + per-metric monotonicity + label/threshold correctness + breakdown completeness; CLI `solve` / `playtest` / `export` (+ gate) / `check` (+ every planted-bad rule) / `fill` (seed reproducibility + Turkish-frequency bias + `--avoid-near-target`); the `check` CI wiring + `melos content:check` on the committed smoke set; RNG/clock confinement; the F02 `applyMove` tidy (83 engine tests re-run).
* **Not tested / out of scope:**
  * `Backend Build Gate` / `Backend quality` out of scope: F06 has no server (pure-Dart packages + a CLI).
  * `Security compliance out of scope`: build-time offline tooling operated by the team on trusted inputs — no auth, no PII, no network, no untrusted input, no injection surface (JSON parsed with `dart:convert` into typed models). Nothing to attack.
  * `Release compliance out of scope`: `orchestration.md → Release Scope = none`; `architecture.md` "Release / Deployment Impact" — nothing distributed to devices by F06.
  * `UI handoff / UI Design compliance out of scope`: no `ui-design.md`, no screens — build-time tooling + CLI.
  * `iOS platform compliance out of scope`: Flutter stack, no `game-dev.md`; F06 ships nothing to a device.
  * `Mode/configuration matrix out of scope`: F06's variants (`journey`/`daily`, tile classes, `columnMovesEnabled`) are covered directly in §4/§5.
  * `Integration findings out of scope`: no backend↔frontend integration; the F02/F01 dependency edges are verified in §6.
  * **`F06-CONTENT` out of scope**: the full content-set authoring is a follow-on task.
* **Bugfix?** No — new feature.
* **Critical journeys:** (a) `Solver.solve` returns a provable minimum → a fair `optimalMoves`; (b) `export` refuses a broken puzzle; (c) `check` fails CI on any content-rule violation; (d) `Puzzle` round-trips losslessly for F05/F07/F08.
* **Forbidden / misuse journeys:** `export` on unsolvable / budget-exceeded / trivial; malformed def file; hand-edited artifact with drifting `optimalMoves`; ineligible target; Journey/Daily duplicate; Daily-manifest repeat-within-window; Journey level 1–3 with columns enabled.
* **Navigation/header consistency:** N/A (no UI).
* **Evidence class summary:** `automated functional` (deterministic `dart test` + CLI invoked from tests + direct CLI runs + an independent probe).
* **Runtime validation method:** `automated functional`.

---

## 3. Product Behavior Coverage

`prd.md` states system requirements (F06 is Infrastructure + tooling).

| System requirement (prd.md) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| Compute the provable minimum move count, honoring locked/frozen | `Solver.solve` on no-tiles / locked / frozen puzzles | `solver_test.dart` (minimality vs independent IDDFS reference); **QA probe** (depth-`m-1` search returns non-`Optimal` for all 5 tile classes — a proof independent of any reference impl); hand-check `ASALM→MASAL == 1` | PASS |
| Report `unsolvable` / `budgetExceeded` so unverified puzzles never ship | small fully-exhausted space → `Unsolvable`; depth wall / node cap → `BudgetExceeded`; unsolvable-under-low-wall → `BudgetExceeded` not `Unsolvable` | `solver_test.dart` (4); CLI `export` refuses both (`exit 1`, no file — QA-verified directly) | PASS |
| Compute a deterministic difficulty score + `easy`/`medium`/`hard`/`expert` label | score twice → identical; label matches thresholds | `difficulty_test.dart` (8); **QA probe** (deterministic + manual threshold check) | PASS |
| Level Designer can define / solve / rate / playtest / export a puzzle | CLI `solve` / `playtest` / `export` on fixtures + smoke defs | `cli_test.dart` (7); 5 smoke puzzles exported end-to-end | PASS |
| Export refuses an unsolvable / optimal-less puzzle | `export` on `unsolvable.json` / `trivial.json` | `cli_test.dart`; **QA direct CLI**: `exit 1`, no file written, reason on stderr | PASS |
| One content schema (`Puzzle`) for F05 / F07 / F08 | `Puzzle.fromJson` / `toJson` round-trip; typed rejections | `puzzle_test.dart` (17) | PASS |
| Produce versioned artifacts + a build-time check that every artifact has a solver-verified `optimalMoves` | smoke set exported to `content/smoke/tr/`; `check` re-solves every artifact | `content_check_test.dart` (7) + `smoke_content_test.dart`; `melos run content:check` green; **QA direct CLI**: planted `optimalMoves: 9` → `check FAIL: stored optimalMoves 9 != fresh solve 1`, `exit 1` | PASS |

No uncovered system requirement.

---

## 4. Acceptance Criteria Traceability

Every AC in `prd.md` "Acceptance Criteria" → an executed test.

| AC (prd.md) | Test / evidence | Result |
| --- | --- | --- |
| solvable no-tiles puzzle → minimal move count + valid sequence (vs exhaustive reference) | `solver_test.dart` minimality group; QA probe | PASS |
| solvable locked/frozen puzzle → sequence uses only `applied` moves + reaches `isSolved` + minimal | `solver_test.dart` (locked / frozen); QA probe (`foldSeq(...).isSolved`) | PASS |
| unreachable winning state → `unsolvable` | `solver_test.dart` "unsolvable grid" (small exhausted space) | PASS |
| minimum exceeds the bound → `budgetExceeded` with the bound; not publishable | `solver_test.dart` BudgetExceeded group; `export` refuses `budgetExceeded` | PASS |
| same inputs twice → same minimum count | `solver_test.dart` determinism; QA probe (20 solves → 1 sequence) | PASS |
| `Puzzle` JSON round-trip equals the original | `puzzle_test.dart` "round-trips losslessly" | PASS |
| JSON missing `optimalMoves` / bad `schemaVersion` / shape violation → rejected | `puzzle_test.dart` "rejects malformed input" (13) | PASS |
| difficulty score + label deterministic; thresholds documented | `difficulty_test.dart`; QA probe; thresholds in `architecture.md` "Difficulty Score" | PASS |
| CLI `export` on unsolvable / no-`optimalMoves` → non-zero exit, no artifact | `cli_test.dart` export-gate group; QA direct CLI | PASS |
| CLI `solve` prints solvability + `optimalMoves`/`unsolvable`/`budgetExceeded` + difficulty + one sequence | `cli_test.dart` "solve prints ..."; QA direct CLI | PASS |
| CLI `playtest` applies a sequence + reports each step + solved state | `cli_test.dart` "playtest reports ..." | PASS |
| build-time check: every Journey artifact has a solver-verified `optimalMoves`, a consistent difficulty band, correct `columnMovesEnabled` for levels 1–3 | `content_check_test.dart` (planted: missing `optimalMoves`; level-2 with columns; drift; dedup; ineligible target; manifest repeat); `smoke_content_test.dart` | PASS |
| grid-fill helper → distribution measurably closer to Turkish frequency than uniform | `fill_test.dart` "letter distribution is biased ..." (common ≥ 3× rare) | PASS |

No uncovered AC.

---

## 5. Boundary Matrix

F06's search + gate flow has meaningful boundaries.

| Boundary | Result | Evidence |
| --- | --- | --- |
| pre-solved puzzle → `Optimal(0, [])` | PASS | `solver_test.dart`; `enumerateOptimalSolutions` → `[[]]` |
| optimal 1 / 2 (minimal depth) | PASS | `solver_test.dart` + QA probe (depth-0 / depth-1 searches have no solution) |
| a column move on the optimal path | PASS | `solver_test.dart` "column move is the optimal move"; QA probe |
| locked tile on the puzzle (search prunes `legalMoves`) | PASS | `solver_test.dart` locked; QA probe |
| frozen tile that thaws on the winning move (irreversible transition mid-search) | PASS | `solver_test.dart` "frozen tile on the solving path (thaw + win)"; QA probe |
| depth wall (`maxDepth`) with a solvable puzzle → `BudgetExceeded` | PASS | `solver_test.dart` "depth wall" |
| node cap (`maxNodes`) → `BudgetExceeded` | PASS | `solver_test.dart` "node cap" |
| genuinely unsolvable but depth-walled → `BudgetExceeded` (not `Unsolvable`) — the `hitDepthWall` distinction | PASS | `solver_test.dart` "a genuinely unsolvable puzzle with a low depth wall ..." |
| fully-exhausted small reachable space → `Unsolvable` | PASS | `solver_test.dart` "unsolvable grid (small reachable space, fully exhausted)" |
| `enumerateOptimalSolutions` at `cap` | PASS | `solver_test.dart` "respects the cap"; QA probe (all length == optimal) |
| `export` gate: applied / unsolvable / budgetExceeded / trivial | PASS | `cli_test.dart` + QA direct CLI (`exit 1`, no file for unsolvable + trivial) |
| `check` per-rule failures (schema / drift / band / columns-1–3 / dedup / target-eligibility / manifest-window) | PASS | `content_check_test.dart` (7); QA direct CLI (drift) |
| `fill` bounded-retry exhaustion | PASS (returns `exit 1` with a message) | `fill_test.dart` (implicit — happy paths exercised; the retry ceiling is code-reviewed) |
| very large optimal DAG (`enumerateOptimalSolutions` blow-up) | Bounded by `cap`; DFS confined to the optimal-DAG via `dist[k] == d+1`. Not stress-tested at authoring scale — acceptable per `architecture.md` (`cap` default 1000). |

---

## 6. Contract Compliance Check

Reference: `architecture.md` [LOCKED] sections.

| Contract area | Result | Evidence |
| --- | --- | --- |
| `looplet_content` dependency = `looplet_core` only | **Preserved** | `pubspec.yaml` (no `looplet_engine`); `melos run analyze` clean. `Puzzle` stores raw fields; no `toEngineConfig` in `looplet_content` (a consumer builds it — see §11 note). |
| `looplet_solver` dependency = `looplet_engine` only | **Preserved** | `pubspec.yaml`; the `WordValidator`→`DictionaryService` adapter is in `tools/looplet_authoring/lib/src/dictionary_validator.dart`, **not** `looplet_solver`. |
| `Puzzle` model — all required fields; JSON shape | **Preserved** | `puzzle.dart`; smoke artifacts carry `schemaVersion`, `contentVersion`, `id`, `puzzleType`, `language`, `grid` (row strings), `targetWord`, `lockedCells`/`frozenCells` (`"r,c"`), `columnMovesEnabled`, `optimalMoves` (required, non-nullable), `difficultyScore`, `difficultyLabel`, `difficultyBreakdown` (required), `journeyLevelNumber`. Unknown keys ignored (`puzzle_test.dart`). `PuzzleFormatException` for every violation class. |
| `Solver.solve` API + guarantee | **Preserved** | `SolveResult` sealed (`Optimal(moves, sequence)` \| `Unsolvable` \| `BudgetExceeded(budget)`). Forward BFS, `canonicalKey` visited, parent map, `_orderedLegalMoves` (total `(axis,index,direction)` order), FIFO. `SearchBudget` defaults `16 / 5,000,000 / 30s`. Minimality independently verified (QA probe: no solution at depth `m-1`). Deterministic: byte-identical `sequence` across 20 runs. `sequence.length == moves`; folds to `isSolved`; every step `applied`. |
| Depth-wall vs `Unsolvable` distinction | **Preserved** | `hitDepthWall` flag — a pruned-at-wall search returns `BudgetExceeded`; only a fully-exhausted space returns `Unsolvable` (`solver_test.dart` + QA probe). |
| `enumerateOptimalSolutions` | **Preserved** | Optimal-DAG DFS (`dist[k] == depth+1` filter), deterministic order, `cap`, `[]` unsolvable / `[[]]` solved. All returned solutions are length `optimal` and valid (QA probe). |
| Difficulty metric definitions (`architecture.md` table) | **Preserved** | `difficulty.dart`: `o`; `cNorm` (distinct states at BFS depth `0<d<o` with a row ≥ 3 correct target positions / states within `o`); `tdDegree` (min over optimal solutions of max-correct-count decreases — QA-verified on `SALMA→MASAL`: progress 1→0→5, one decrease → `tdDegree 1`); `L`, `F`; `firstMoves`; `distinctOptimalSolutions` (≤ cap). Score formula + label per contract. Weights/thresholds in configurable value types. |
| CLI surface | **Preserved** | `solve` / `playtest` / `export` / `check` / `fill`; JSON def-file; `R/L/D/U<i>` move shorthand. `export` gate: non-zero exit + no file on `unsolvable` / `budgetExceeded` / `optimalMoves == 0` / malformed def (QA-verified directly). Domain exceptions → non-zero exit + stderr (not a crash). |
| `check` rules | **Preserved** | schema; re-solve vs stored `optimalMoves`; Journey band consistency; `columnMovesEnabled == false` for levels 1–3; Journey internal + Journey↔Daily dedup (by grid+target+locks+freezes signature); Daily manifest no-repeat-window (30d default); `targetWord` is `isEligibleTarget` (F01). Each rule has a planted-bad test. |
| Content layout + CI wiring | **Preserved** | `content/journey/<lang>/`, `content/daily/<lang>/pool/` + placeholders; smoke set in `content/smoke/tr/`. `.github/workflows/ci.yml` has a `Content check` step; `melos content:check` script added. |
| No RNG / no wall clock in `looplet_solver` / `looplet_content` | **Preserved** | `grep` over both `lib/` trees: no `Random(` / `DateTime.now` / `dart:io` / `dart:math`. One `Stopwatch` in `solver.dart` — **contract-allowed** (`architecture.md` "State / Flow Semantics": a `Stopwatch` is permitted in `looplet_solver`, it is build-time tooling; the no-clock guard is `looplet_engine`-only). `Random(` appears only in `tools/looplet_authoring/.../turkish_frequency.dart` as `Random(seed)` (seeded, reproducible — verified by `fill_test.dart`). |
| Contract version | v1; additive. `platform.md` §13 amended by the Tech Lead (forward BFS). | |
| Auth / navigation / async / persistence | N/A — build-time tooling, no server, no UI, no store. | |

---

## 6.5 Security Compliance Check

Security scope: **out of scope**. F06 is offline build-time tooling operated by the team on trusted inputs (def files, checked-in artifacts). No authentication/authorization, no access to another user's resources, no financial operations, no user-data storage/read, no admin/role separation, no network, no untrusted input surface. JSON is parsed with `dart:convert` into typed models with explicit validation (not an injection sink). `Security compliance out of scope: internal offline tooling, no trust boundary` — recorded here per the scope-matrix convention.

---

## 9. Positive Scenarios

**Journey 1 — a fair `optimalMoves`:**
Start: a Level Designer writes a def file for a solvable puzzle. Action: `looplet_authoring solve <def>`. Result: stdout shows `optimalMoves: N` where `N` is the **provable minimum** — QA independently confirmed by (a) an IDDFS reference (different algorithm), (b) a depth-`N-1`-capped search that finds no solution, and (c) a hand-check (`ASALM→MASAL == 1`, sequence `R0`). `export` then writes an artifact whose `optimalMoves` re-verifies.

**Journey 2 — a broken puzzle cannot ship:**
Start: a def file that is unsolvable (or trivial, or budget-exceeded). Action: `looplet_authoring export <def> --out <path>`. Visible result: `exit 1`, a reason on stderr (`refusing to export ...: unsolvable` / `... trivial (optimalMoves 0)`), and **no file at `<path>`** — QA verified directly via the CLI.

**Journey 3 — CI catches content drift:**
Start: an artifact whose stored `optimalMoves` was hand-edited to a wrong value. Action: `looplet_authoring check content/`. Visible result: `check FAIL: <path>: stored optimalMoves 9 != fresh solve 1`, `exit 1` — QA verified directly. `check` is wired into `.github/workflows/ci.yml`.

**Journey 4 — F05/F07/F08 can load content:**
`Puzzle.fromJson(toJson())` equals the original on every field (`puzzle_test.dart`); a `daily` puzzle carries `dailyDate` and no `journeyLevelNumber`; unknown keys are tolerated.

---

## 10. Negative / Edge Cases

| Case | Expected | Observed | Evidence |
| --- | --- | --- | --- |
| `export` unsolvable / trivial | `exit 1`, no file, reason on stderr | as expected | QA direct CLI + `cli_test.dart` |
| `export` / `solve` malformed def (bad JSON, missing field) | `exit 1`, message; no crash | as expected | `cli_test.dart` "malformed def file → non-zero exit" |
| `check` — missing `optimalMoves` / level-1–3 with columns / drift / duplicate / ineligible target / manifest repeat-in-window | `exit 1`, each failure named | all caught | `content_check_test.dart` (7); QA direct CLI (drift) |
| solver on an unsolvable puzzle with a small reachable space | `Unsolvable` (terminates) | as expected | `solver_test.dart` |
| solver depth-walled on a solvable puzzle | `BudgetExceeded` | as expected | `solver_test.dart` |
| `enumerateOptimalSolutions` on unsolvable / solved | `[]` / `[[]]` | as expected | `solver_test.dart` |
| `DifficultyScorer` on an unsolvable puzzle | `ArgumentError` | as expected | `difficulty_test.dart` |
| `fill` reproducibility | identical grid for identical seed | as expected | `fill_test.dart` |
| `fill --target` matching by chance | rejected + resampled | code path exercised | `fill_test.dart` |
| Turkish `İ` vs `I` in a target (`DENIZ` vs `DENİZ`) | `DENIZ` (undotted) is not a dictionary word → `check` fails; `DENİZ` (dotted) passes | as observed during F06.SMOKE-FE authoring — fixed | `frontend.md` §3; `content/smoke/tr/level04.json` uses `DENİZ` |

No misuse path produced a crash, a wrong `Optimal`, or a written artifact where the gate should have refused.

---

## 14. Frontend Quality

Client-touching scope (pure-Dart packages + a CLI; no UI).

* **Code quality:** `melos run analyze` clean across all 6 packages + `flutter analyze`; `format:check` clean. No stubs / TODOs in the F06 surface. Placeholders removed from `looplet_content` / `looplet_solver`.
* **Design:** clean separation — `looplet_content` (schema, engine-free), `looplet_solver` (pure search + scoring, dictionary-free via the port), `tools/looplet_authoring` (composition + I/O + the dictionary adapter). The solver reuses F02's `GridState` / `canonicalKey` / `legalMoves` with no re-implementation. `SolveResult` is a sealed type; the CLI turns domain exceptions into exit codes rather than crashing.
* **Determinism:** verified — 20 solves → one sequence; RNG confined to the seeded `fill` sampler; a `Stopwatch` in `solver.dart` is contract-allowed and does not affect the result (only the time-budget cutoff).
* **Minimality (safety-critical):** independently verified three ways (IDDFS reference, depth-`m-1` no-solution proof, hand-check). This is the highest-risk correctness property (unfair stars if wrong); it holds across all five tile classes on the tested puzzles.
* **F02 tidy:** `GridState.applyMove` now reads all `EngineConfig` fields from the stored `_config`; the parameter is documented as authoritative-via-`_config`. F02's 83 engine tests re-run green — no regression.
* Runtime evidence summary: `automated functional` — 200 workspace tests + `content:check` + a 9-assertion independent QA probe + direct CLI runs, all green.

---

## 16. Regression Risk

* **Shared components touched:** `looplet_core` (new `content_primitives.dart` + barrel export — additive); `looplet_content` (new `Puzzle`, barrel now re-exports `PuzzleType`/`DifficultyLabel` from `looplet_core` — additive; no existing consumer); `looplet_solver` (new package body); `looplet_engine/lib/src/grid_state.dart` (`applyMove` internal tidy — behavior-preserving, 83 tests re-run green); `tools/looplet_authoring` (new); `melos.yaml` + `.github/workflows/ci.yml` (new `content:check` step); `content/` (new smoke artifacts + placeholder dirs).
* **Downstream dependents:** none consume `looplet_solver` yet (build-time only; the app never imports it). `looplet_content.Puzzle` will be consumed by F05/F07/F08 — the schema verified here is what they will build against.
* **F01 / F02 impact:** F01 untouched (32 dictionary + 22 core tests green — core now 22 incl. the pre-existing primitives; content primitives added). F02: the `applyMove` tidy is behavior-preserving; 83 engine tests + the F02 QA probe behavior unchanged.
* **`platform.md` §13 amendment (by Tech Lead):** forward BFS replaces bidirectional — a documentation change matching the implementation; no code impact.
* **`melos run build:app` (Android):** not run locally (no Android SDK). `flutter analyze` / `flutter test` green; the app was independently confirmed to build for the iOS simulator during the interim incident. CI runs the Android bundle build.
* **Conclusion:** regression risk minimal — new packages, no runtime consumers, the one existing-code change (F02 tidy) is behavior-preserving and re-tested.

---

## 17. Final Verdict

**Approved with Notes**

* No blocking issues. No required fixes.
* Every `prd.md` system requirement and every Acceptance Criterion is covered by an executed automated test; the safety-critical minimality property is **independently verified** (IDDFS reference + depth-`m-1` no-solution proof + hand-check).
* The full [LOCKED] contract (`Solver` API + guarantee, `Puzzle` schema, difficulty definitions, CLI surface + export gate, `check` rules, dependency edges, no-RNG) is honored. `export` gate exit codes / no-file and `check` drift detection were verified by direct CLI invocation.
* `format:check` / `analyze` (6 pkgs + `flutter analyze`) / `test` (200) / `content:check` all green.
* Non-blocking notes for the Tech Lead (§20): (1) `PuzzleType` / `DifficultyLabel` live in `looplet_core`, not `looplet_content` as `architecture.md` states — needs a one-line `platform.md` §11 / `architecture.md` note, no behavior change; (2) no `Puzzle.toEngineConfig()` public helper exists yet — F05/F08 must add consumer-side conversion (which is what `architecture.md` intends); (3) `fill --frozen-safe` is a declared no-op stub; (4) `F06-CONTENT` performance risk for fully-open levels 11–15 (`frontend.md` §13); (5) Android CI build not runnable locally.
* Evidence class `automated functional` is explicitly accepted for this build-time feature by `architecture.md` "QA Focus" and `platform.md` §10.
* **Scope:** this verdict covers the F06 toolchain + smoke set. `F06-CONTENT` (full 30 Journey + Daily pool) is a separate follow-on and was not QA'd here.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* Approved with Notes — F06 toolchain passes contract + product-behavior + AC + boundary coverage; minimality independently verified; 200 tests + `content:check` + probe + direct CLI runs green.

## Affected Areas

* None requiring rework. Documentation (Tech Lead): the `PuzzleType`/`DifficultyLabel` location note.

## Blocking Issues

* None.

## Non-Blocking Notes

1. `PuzzleType` / `DifficultyLabel` are in `looplet_core` (re-exported by `looplet_content`), not `looplet_content` as `architecture.md` "Puzzle Model" / "Dependency Edges" imply — same pattern as F02's `MoveAxis` carve-out. Add a one-liner to `platform.md` §11 and correct the F06 `architecture.md` wording. No code change.
2. `architecture.md` mentions a `Puzzle.toEngineConfig()` helper "in a consumer" — none exists yet. The CLI uses `PuzzleDef.toEngineConfig()` and `content_check.dart` a private `_toEngineConfig(Puzzle)`. F05 / F08 will need their own consumer-side `Puzzle → EngineConfig`; worth flagging in their briefs.
3. `fill --frozen-safe` flag is declared `reserved` (a no-op). Acceptable for the MVP designer helper; note it or implement it in `F06-CONTENT`.
4. `F06-CONTENT` perf: fully-open levels 11–15 (optimal 6–8) may need AOT `export` or a per-machine `timeBudget` bump (`frontend.md` §13).
5. Android `melos run build:app` not runnable on the dev machine (no Android SDK); CI covers it.

## Suggested Fix Order

Not applicable (Approved with Notes — no blocking fixes). Tech Lead: sync global state (`feature-board.md`, `system-state.md`), apply the two doc corrections (notes 1–2), then decide whether to activate `F06-CONTENT` or the next feature (F03 or F08).

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F06 puzzle-content-and-solver-tooling (toolchain + smoke set) — QA verdict: Approved with Notes. No rework; the toolchain is contract-compliant and the safety-critical solver minimality is independently verified.

Tech Lead actions:
1. Sync global state — set F06 `Done` (Release Scope = none, no release gate) in `feature-board.md` and `system-state.md`; clear `Current Owner`; terminal-cleanup `features/f06-.../orchestration.md`. Keep the `F06-CONTENT` follow-on row.
2. Doc corrections (non-blocking, no re-QA):
   - `platform.md` §11: add `PuzzleType` / `DifficultyLabel` to the list of shared value types that live in `looplet_core` and are re-exported by `looplet_content` (alongside the engine primitives).
   - `features/f06-.../architecture.md` "Puzzle Model" / "Dependency Edges": correct the wording — the enums are in `looplet_core`, not `looplet_content` (which stays `looplet_core`-only and re-exports).
3. When briefing F05 / F08: they need a consumer-side `Puzzle → EngineConfig` conversion (`architecture.md` intends the helper to live in a consumer that depends on `looplet_engine`; `looplet_content` has none). The CLI's `PuzzleDef.toEngineConfig()` is a template.
4. `F06-CONTENT` (follow-on): perf note from `frontend.md` §13 — fully-open levels 11–15 (optimal 6–8) may need an AOT-compiled `export` or a bumped `timeBudget`; `--frozen-safe` is a stub to implement or drop; finalize the tunable `SearchBudget` / `DifficultyWeights` / `DifficultyThresholds` values against the real 30 levels.
5. Informational: Android `melos run build:app` not runnable locally (no Android SDK); the app was separately confirmed to build for the iOS simulator during the interim incident.

No Product/PO escalation required.

TEXT
