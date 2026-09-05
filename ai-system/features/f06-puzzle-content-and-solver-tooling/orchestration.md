# F06 — puzzle-content-and-solver-tooling: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress**

---

## Current Owner

Frontend/Mobile Developer

---

## Current Phase

Frontend Development (contract finalized from `analysis.md`; implement the toolchain + smoke set)

---

## Consumed Signals

* `analysis.md` consumed into `architecture.md` on 2026-09-05. Downstream roles use `architecture.md` as contract authority; read `analysis.md` only for the deeper rationale (§12 algorithm analysis, §16 task breakdown detail).
* Unresolved analysis questions: **None** — the 7 open items are resolved in `architecture.md`; what remains ("Open Technical Decisions") are tunable *values* (budget numbers, difficulty weights, frequency table source) that do not block implementation.

---

## Active Task Ledger

- [x] Task ID: F06.0-AN | Assigned Role: Technical Analyst | Status: Done | `analysis.md` delivered; consumed into `architecture.md` (7 open items resolved).
- [ ] Task ID: F06.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `looplet_content` `Puzzle` model + `fromJson`/`toJson` + `PuzzleType`/`DifficultyLabel` enums + `PuzzleFormatException`. `looplet_content` → `looplet_core` only. Tests: lossless round-trip; reject missing `optimalMoves` / bad `schemaVersion` / bad shape / bad `"r,c"` coord / wrong type; ignore unknown keys. (`difficultyBreakdown` required in the artifact — confirm here.)
- [ ] Task ID: F06.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `looplet_solver` `Solver.solve` — forward BFS over `GridState.canonicalKey` (visited `Set<String>` + parent `Map`), successors from `EngineConfig.legalMoves` sorted by a total `Move` order, FIFO, `SearchBudget` (maxDepth 16 / maxNodes 5M / timeBudget 30s). `SolveResult` sealed (`Optimal(moves, sequence)` | `Unsolvable` | `BudgetExceeded(budget)`). `looplet_solver` → `looplet_engine` only. Tests: minimality vs an INDEPENDENT exhaustive reference (brute-force DFS enumerating all solutions ≤ small bound — not the same BFS) on no-tiles / locked / 1-frozen / 2-frozen; `Unsolvable`; `BudgetExceeded`; determinism (identical `moves` + byte-identical `sequence`); returned sequence uses only `applied` moves and reaches `isSolved`.
- [ ] Task ID: F06.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `Solver.enumerateOptimalSolutions(config, validator, {cap})` — up to `cap` distinct optimal solutions in a deterministic order. Tests: small puzzle with a known count; `cap` behavior ("≥ cap").
- [ ] Task ID: F06.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `DifficultyScorer.score` + `DifficultyWeights`/`DifficultyThresholds` (const defaults, overridable). Implement the 6 metrics per `architecture.md` "Difficulty Score" table (`o`, `cNorm`, `tdDegree`, `L`, `F`, `firstMoves`, `distinctOptimalSolutions`), the score formula, and the label. Tests: determinism for fixed weights/thresholds; per-metric monotonicity; documented thresholds honored; a few hand-checked reference puzzles.
- [ ] Task ID: F06.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `tools/looplet_authoring` CLI (`package:args`) + JSON def-file parser + `solve` / `playtest` / `export` commands + the export gate + `Puzzle` artifact writer + the `WordValidator`→`DictionaryService` adapter (here, not in `looplet_solver`). Move shorthand `R<i>`/`L<i>`/`D<i>`/`U<i>`. Tests (CLI invoked from `dart test`): `export` exits non-zero + writes nothing on `unsolvable` / `budgetExceeded` / `optimalMoves == 0` / malformed def; `playtest` per-step reporting; `solve` output shape; a valid `export` re-decodes losslessly with `optimalMoves` == a fresh solve.
- [ ] Task ID: F06.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `check <dir|glob>` command — `Puzzle` schema; re-verify stored `optimalMoves` == fresh `Solver.solve`; Journey level 1–3 ⇒ `columnMovesEnabled == false`; `difficultyLabel` in the §20 band for the level number; Journey internal dedup; Journey↔Daily dedup; Daily `manifest.json` no-repeat-window (30d); shipped `targetWord` is `isEligibleTarget` (F01). Wire `looplet_authoring check content/` into `.github/workflows/ci.yml` as a required job. Tests: planted bad artifacts each caught with a named failure.
- [ ] Task ID: F06.7-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `fill --seed <n> [--frozen-safe] [--avoid-near-target]` — seeded Turkish letter-frequency weighted sampler (a ~29-entry `const` table; pick a published source) + offensive-string guard (always on) + `--avoid-near-target` edit-distance-1-from-target filter (default off) + bounded retry. Tests: seed reproducibility; statistical closeness to the frequency table vs uniform; RNG confined to the seeded generator; reject an already-solved fill. Also: while touching `looplet_engine` for the solver work, tidy `GridState.applyMove` to read all `EngineConfig` fields from one source (carried F02 non-blocking note).
- [ ] Task ID: F06.SMOKE-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Author a ~5-puzzle smoke set (one per §20 curve band: no-tiles / columns-disabled levels 1–3 / locked / frozen / locked+frozen), run each through `solve` → `export` → `check`, commit to `content/journey/tr/` (or a `content/smoke/` dir). Proves the pipeline end to end; `check content/` green in CI. **Not** the full 30 Journey + Daily pool — that is `F06-CONTENT` (follow-on, see Open Tasks).

---

## QA Scope

* client-only (package + CLI level, automated `dart test` + CLI invocation from tests; no device runtime — see `architecture.md` QA Focus and `platform.md` §10)

---

## Release Scope

* none

---

## Open Tasks

### Analysis
- [x] (F06.0-AN) Technical analysis of F06 — done. Output: `features/f06-puzzle-content-and-solver-tooling/analysis.md`.

### Backend
- _(none — F06 has no server; `looplet_solver` + `looplet_content` are pure Dart, sequenced under Frontend/Mobile Developer)_

### Frontend
- [ ] (F06.1-FE) `looplet_content` `Puzzle` model + JSON + enums + `PuzzleFormatException`.
- [ ] (F06.2-FE) `looplet_solver` forward-BFS `Solver.solve` + `SolveResult` + `SearchBudget`.
- [ ] (F06.3-FE) `Solver.enumerateOptimalSolutions` (bounded, deterministic).
- [ ] (F06.4-FE) `DifficultyScorer` + configurable weights/thresholds + the 6 metrics.
- [ ] (F06.5-FE) `tools/looplet_authoring` CLI — `solve` / `playtest` / `export` + export gate + def-file parser + `WordValidator` adapter.
- [ ] (F06.6-FE) `check` command + CI wiring.
- [ ] (F06.7-FE) `fill` helper (seeded Turkish-frequency + guards) + carried `applyMove` config-source tidy.
- [ ] (F06.SMOKE-FE) ~5-puzzle smoke set through `solve` → `export` → `check`; committed; CI green.

### QA
- [ ] (F06.1-QA) Solver minimality vs an independent exhaustive reference (no-tiles / locked / 1-frozen / 2-frozen); `Unsolvable` + `BudgetExceeded`; determinism + byte-stable tie-break; returned sequence uses only `applied` moves and reaches `isSolved`.
- [ ] (F06.2-QA) `Puzzle` JSON lossless round-trip; `PuzzleFormatException` for missing `optimalMoves` / bad `schemaVersion` / malformed shape / bad coord / wrong type; unknown-key tolerance.
- [ ] (F06.3-QA) Difficulty determinism (fixed weights/thresholds); per-metric monotonicity; documented thresholds honored; `breakdown` fields present.
- [ ] (F06.4-QA) CLI: `solve` / `playtest` / `export` / `check` / `fill` behaviors; `export` gate exit codes + no-file guarantee; `check` catches every planted bad artifact (no `optimalMoves`; level-2 with columns enabled; Journey↔Daily dup; stored optimal ≠ fresh solve; ineligible target); `fill` seed reproducibility + frequency closeness.
- [ ] (F06.5-QA) Build-time `check content/` wired into CI and green on the committed smoke set; RNG confined to `fill`; evidence class `automated functional` confirmed sufficient. Emit verdict → Tech Lead.

### Content (follow-on — NOT part of the F06 implementation delivery)
- [ ] (F06-CONTENT) Author the full 30 Journey levels (honoring the source §20 difficulty curve) + the ~60-puzzle Daily pool + `daily/<lang>/manifest.json`; run `check`; commit to `content/`. Owner: Level Designer / user. Gated on F06 (toolchain) reaching `Done` with a QA-approved pipeline. Still MVP scope (product PRD §42) and a prerequisite for F05 and F07 reaching `Done`. Tunable values finalized here: `SearchBudget` numbers, `DifficultyWeights`/`DifficultyThresholds`, the Turkish frequency table source, MVP Daily pool size + band.

---

## Blockers

* None. Contract finalized in `architecture.md`; F06.1-FE … F06.SMOKE-FE ready for Frontend/Mobile Developer.
* Dependency note: F01 (Done) + F02 (Done) — F06 builds directly on F02's `GridState` / `applyMove` / `canonicalKey` / `legalMoves` and F01's `WordValidator`.
* Carried into F06.7-FE (from F02 QA): tidy `GridState.applyMove` to read all `EngineConfig` fields from one source while `looplet_engine` is open for the solver work. No defect today.
* `platform.md` §13 amended 2026-09-05 (bidirectional BFS → forward BFS + `SearchBudget`); §3 layout note + `Open Technical Decisions` updated (CLI-only).
* Scope note: `F06-CONTENT` (full 30 Journey + Daily pool authoring) is a follow-on, NOT part of this delivery — see Open Tasks → Content. F06 (toolchain + smoke set) can reach `Done` without it; F05/F07 cannot reach `Done` without it.

---

## Last Decision

* 2026-09-05 — Tech Lead (F06 activation):
  * F06 activated after F01 + F02 `Done`. P0; the last P0. F05 (Journey) and F07 (Daily) depend on its content-production pipeline; F04 depends on its `optimalMoves`.
  * Complexity = **COMPLEX** with genuinely open technical decisions (provable-minimum search with an is-a-set goal + irreversible frozen-thaw; computable §48 difficulty metrics; `Puzzle` schema; editor scope; content heuristics). Unlike F01/F02, the product PRD does **not** pre-resolve these → **Technical Analyst pass warranted** before contract finalization.
  * **No UI Designer** — build-time tooling + CLI, no player-facing screens. (F05's Journey screens are F05's; F06 only emits artifacts.)
  * `architecture.md` initial brief: **[LOCKED]** — build-time only (app never imports `looplet_solver`); the solver operates on F02's `GridState`/`applyMove`/`canonicalKey`/`legalMoves`; `SolveResult` = optimal(moves, sequence) | unsolvable | budgetExceeded, deterministic, provable minimum; every `Puzzle` artifact must carry a solver-verified `optimalMoves` or it cannot ship; CLI `export` gate; build-time content check; `content/journey/<lang>/levelNN.json` + `content/daily/<lang>/pool/*.json`; Release Scope = none. **[PENDING ANALYSIS]** — the 7 items above.
  * Routing: Technical Analyst (F06.0-AN → `analysis.md`) → Tech Lead (finalize `architecture.md`, open FE/QA tasks) → Frontend/Mobile Developer → QA → Tech Lead.

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-05
* Summary: F06 contract finalized. Consumed `analysis.md` into `architecture.md` — all [PENDING ANALYSIS] sections → [LOCKED]: forward BFS + `SearchBudget` (bidirectional BFS dropped); `looplet_content` engine-free (`Puzzle` raw fields + `toEngineConfig()` helper); `looplet_solver` → `looplet_engine` only (dict adapter in `tools`); `Puzzle` JSON shape; CLI-only (`solve`/`playtest`/`export`/`check`/`fill`); difficulty metric *definitions* locked, weights/thresholds configurable; `content/` layout + `check` rules. Amended `platform.md` §13 (bidirectional → forward BFS) + §3/§13 notes (CLI-only). **Scope split accepted:** F06 delivers the toolchain (F06.1-FE … F06.7-FE) + a ~5-puzzle smoke set (F06.SMOKE-FE); the full 30 Journey + ~60 Daily authoring is `F06-CONTENT` (follow-on, Level-Designer-owned, still MVP, prerequisite for F05/F07 `Done`). Opened F06.1-FE … F06.SMOKE-FE + F06.1-QA … F06.5-QA. Current Owner → Frontend/Mobile Developer.

---

## Next Role

Frontend/Mobile Developer

---

## Next Action

### Frontend/Mobile Developer

```text
Implement the F06 toolchain + smoke set. Authority: features/f06-puzzle-content-and-solver-tooling/architecture.md
(contract — the [LOCKED] sections; the "Open Technical Decisions" are tunable start-values, use the recommended ones).
Deeper rationale in analysis.md (§12 algorithm, §16 task detail). Inherited: F02 architecture.md (GridState /
applyMove / canonicalKey / legalMoves) + F01 WordValidator.

Order (Active Task Ledger):
1. F06.1-FE — looplet_content Puzzle model + fromJson/toJson + PuzzleType/DifficultyLabel + PuzzleFormatException.
   looplet_content -> looplet_core ONLY. Round-trip + rejection tests. difficultyBreakdown: include as required.
2. F06.2-FE — looplet_solver Solver.solve: forward BFS over GridState.canonicalKey (visited Set<String> + parent Map),
   successors = config.legalMoves(state) sorted by a total Move order, FIFO, SearchBudget(maxDepth: 16,
   maxNodes: 5000000, timeBudget: 30s). SolveResult sealed (Optimal / Unsolvable / BudgetExceeded). looplet_solver ->
   looplet_engine ONLY. A Stopwatch IS allowed in looplet_solver (build-time tooling; the no-clock guard is
   looplet_engine-only). Tests: minimality vs an INDEPENDENT exhaustive reference (brute-force DFS enumerating all
   solutions <= a small bound — NOT the same BFS code) on no-tiles / locked / 1-frozen / 2-frozen; Unsolvable;
   BudgetExceeded; determinism (identical moves + byte-identical sequence); returned sequence uses only applied moves
   and reaches isSolved.
3. F06.3-FE — Solver.enumerateOptimalSolutions(config, validator, {cap}) — deterministic order, "<= cap" semantics.
4. F06.4-FE — DifficultyScorer.score + DifficultyWeights/DifficultyThresholds (const defaults from architecture.md,
   overridable). Implement o / cNorm / tdDegree / L / F / firstMoves / distinctOptimalSolutions per the
   architecture.md "Difficulty Score" table; the score formula; the label. Determinism + monotonicity tests.
5. F06.5-FE — tools/looplet_authoring CLI (package:args). JSON def-file parser. solve / playtest / export commands +
   export gate (non-zero exit + no file on unsolvable / budgetExceeded / optimalMoves == 0 / malformed def).
   The WordValidator->DictionaryService adapter lives HERE (tools depends on looplet_dictionary; looplet_solver does
   NOT). Move shorthand R/L/D/U + index. CLI-invoked-from-dart-test tests.
6. F06.6-FE — check <dir|glob> command (schema; re-verify optimalMoves vs a fresh solve; Journey band + columns for
   levels 1-3; Journey internal + Journey<->Daily dedup; Daily manifest no-repeat-window 30d; targetWord eligibility).
   Wire `looplet_authoring check content/` into .github/workflows/ci.yml. Planted-bad-artifact tests.
7. F06.7-FE — fill --seed helper (seeded Turkish letter-frequency table ~29 entries — pick a published source; a
   const map is fine; record the source in a comment) + offensive-string guard (always) + --avoid-near-target
   (default off) + bounded retry. Seed-reproducibility + frequency-closeness tests. ALSO: tidy GridState.applyMove in
   looplet_engine to read all EngineConfig fields from one source (carried F02 non-blocking note) — re-run the F02
   engine suite to confirm no regression.
8. F06.SMOKE-FE — author ~5 Journey puzzles (one per curve band: no-tiles / columns-disabled / locked / frozen /
   locked+frozen) via def-files, run solve -> export -> check, commit under content/journey/tr/ (or content/smoke/),
   confirm `check content/` green.

Verify from repo root: melos run format:check && melos run analyze && melos run test
Produce features/f06-.../frontend.md: task-to-code traceability; the solver's worst-case node/time on the smoke set;
the difficulty weights/thresholds used; per-AC evidence. On completion set Next Role = QA.
```

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F06 created and activated after F02 `Done`. `prd.md` + initial `architecture.md` (LOCKED substrate + gates; PENDING ANALYSIS for 7 items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F06.0-AN → `analysis.md`). Routing: Technical Analyst → Tech Lead (finalize contract) → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-05) — Technical Analyst: F06.0-AN done. `analysis.md` delivered (7 items resolved + recommendation; functional breakdown; edge cases; task breakdown F06.1–F06.8; LOCK-vs-OPEN Delivery Note). Recommends forward BFS (not bidirectional), engine-free `looplet_content`, CLI-only, toolchain + smoke-set scope. Current Owner → Tech Lead; Next Role → Tech Lead to finalize `architecture.md`.
* v3 (2026-09-05) — Tech Lead: F06 contract **finalized**. `analysis.md` consumed into `architecture.md` (all [PENDING ANALYSIS] → [LOCKED]). `platform.md` §13 amended (forward BFS + `SearchBudget`; bidirectional dropped) + §3/§13 CLI-only notes. Scope split accepted: F06 = toolchain + ~5-puzzle smoke set; `F06-CONTENT` (full 30 Journey + Daily pool) = Level-Designer follow-on, still MVP, prerequisite for F05/F07 `Done`. Opened F06.1-FE … F06.SMOKE-FE + F06.1-QA … F06.5-QA. Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer.
