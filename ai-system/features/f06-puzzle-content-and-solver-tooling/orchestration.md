# F06 — puzzle-content-and-solver-tooling: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In QA**

---

## Current Owner

QA

---

## Current Phase

QA (package + CLI level, automated functional — `looplet_content` / `looplet_solver` / `tools/looplet_authoring` + smoke set)

---

## Consumed Signals

* `analysis.md` consumed into `architecture.md` on 2026-09-05. Downstream roles use `architecture.md` as contract authority; read `analysis.md` only for the deeper rationale (§12 algorithm analysis, §16 task breakdown detail).
* Unresolved analysis questions: **None** — the 7 open items are resolved in `architecture.md`; what remains ("Open Technical Decisions") are tunable *values* (budget numbers, difficulty weights, frequency table source) that do not block implementation.

---

## Active Task Ledger

- [x] Task ID: F06.0-AN | Assigned Role: Technical Analyst | Status: Done | `analysis.md` delivered; consumed into `architecture.md`.
- [x] Task ID: F06.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `looplet_content` `Puzzle` + JSON + `PuzzleFormatException`; `PuzzleType`/`DifficultyLabel` moved to `looplet_core` (re-exported), keeping `looplet_content` → `looplet_core` only; `difficultyBreakdown` required. 17 tests.
- [x] Task ID: F06.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `Solver.solve` forward BFS + `SolveResult` + `SearchBudget` (16/5M/30s). Minimality verified vs an INDEPENDENT IDDFS reference; `Unsolvable` / `BudgetExceeded` (depth wall / node cap); determinism (byte-stable `sequence`). 15 tests.
- [x] Task ID: F06.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `enumerateOptimalSolutions` (optimal-DAG DFS, deterministic, `cap`). 3 tests.
- [x] Task ID: F06.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `DifficultyScorer` + `DifficultyWeights`/`DifficultyThresholds`; all 6 metrics per contract; deterministic. 8 tests.
- [x] Task ID: F06.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `tools/looplet_authoring` CLI (`package:args`): `solve`/`playtest`/`export` + export gate + JSON def parser + dictionary adapter (in `tools`, not `looplet_solver`). 7 tests.
- [x] Task ID: F06.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `check` command (all rules) + `.github/workflows/ci.yml` "Content check" step + `melos content:check`. 7 planted-bad tests + smoke-content test.
- [x] Task ID: F06.7-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `fill` (seeded Turkish-frequency sampler + offensive guard + `--avoid-near-target` off-by-default). 5 tests. **F02 `applyMove` config-source tidy applied** — 83 engine tests re-run green.
- [x] Task ID: F06.SMOKE-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | 5-puzzle smoke set (`content/smoke/tr/level0{1,2,4,5,6}.json`) covering no-tiles / columns-off / column-on-path / locked / frozen, exported + `check`-green. (One authoring fix: `DENİZ` needs the dotted İ — F01's İ≠I rule surfacing correctly.)

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
- [x] (F06.1-FE) `looplet_content` `Puzzle` model — done.
- [x] (F06.2-FE) `looplet_solver` forward-BFS `Solver.solve` — done.
- [x] (F06.3-FE) `Solver.enumerateOptimalSolutions` — done.
- [x] (F06.4-FE) `DifficultyScorer` + weights/thresholds + 6 metrics — done.
- [x] (F06.5-FE) CLI `solve` / `playtest` / `export` + gate + adapter — done.
- [x] (F06.6-FE) `check` command + CI wiring — done.
- [x] (F06.7-FE) `fill` helper + F02 `applyMove` tidy — done.
- [x] (F06.SMOKE-FE) 5-puzzle smoke set exported + `check`-green — done.

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

* None. F06.1-FE … F06.SMOKE-FE delivered (`frontend.md`). 200 workspace tests + `content:check` green.
* Carried non-blocking note (Frontend → Tech Lead): `frontend.md` §4/§16 — `PuzzleType`/`DifficultyLabel` were placed in `looplet_core` (not `looplet_content`), same pattern as F02's `MoveAxis` carve-out, so `looplet_solver` can use `DifficultyLabel` without a `looplet_content` dependency. Needs a one-line `platform.md` §11 note; no behavior change.
* Non-blocking note (`F06-CONTENT` perf, `frontend.md` §13): a fully-open 5×5 with optimal 5 solves in ~4.6 s JIT — levels 11–15 (fully open, optimal 6–8) are the cost risk zone. Mitigations within the designed flow: AOT-compile `export`; locked/frozen levels 16–30 are cheaper; `budgetExceeded` → rework. Relevant when `F06-CONTENT` starts, not for F06 sign-off.
* Scope: `F06-CONTENT` (full 30 Journey + Daily pool authoring) is a follow-on — F06 (toolchain + smoke set) can reach `Done` without it; F05/F07 cannot reach `Done` without it.

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

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-05
* Summary: F06.1-FE … F06.SMOKE-FE complete. `looplet_content` `Puzzle` model + JSON; `looplet_solver` forward-BFS `Solver.solve` (minimality verified vs an independent IDDFS reference) + `enumerateOptimalSolutions` + `DifficultyScorer` (6 metrics, configurable weights/thresholds); `tools/looplet_authoring` CLI (`solve`/`playtest`/`export` + gate / `check` + CI wiring / `fill` seeded Turkish-frequency). 5-puzzle smoke set exported + `check`-green. `PuzzleType`/`DifficultyLabel` placed in `looplet_core` (re-exported) so `looplet_solver` needs no `looplet_content` dep — recorded in `frontend.md` §4 (one-line `platform.md` §11 note for Tech Lead; no behavior change). Carried F02 tidy applied (`GridState.applyMove` single config source; 83 engine tests re-run green). 200 workspace tests + `format:check` + `analyze` + `content:check` green. `frontend.md` written. Not committed to git.

---

## Next Role

QA

---

## Next Action

### QA

```text
Verify F06 (client + CLI level, automated functional — no device runtime per architecture.md QA Focus + platform.md §10).

Authority: features/f06-puzzle-content-and-solver-tooling/prd.md (Acceptance Criteria, Edge Cases),
architecture.md ([LOCKED] contract — Solver API + guarantee, Puzzle schema, Difficulty definitions, CLI surface,
content-check rules, QA Focus), frontend.md (delivery report + test evidence + the perf/enum-location notes).

F06.1-QA — Solver minimality + outcomes:
- Confirm minimality is checked vs an INDEPENDENT reference (looplet_solver/test/support/reference.dart is IDDFS,
  no visited set — a different algorithm from Solver's BFS). Spot-check the agreement on no-tiles / locked / frozen.
- Unsolvable (fully-exhausted small space) and BudgetExceeded (depth wall / node cap; and unsolvable-under-low-wall →
  BudgetExceeded not Unsolvable) each verified.
- Determinism: identical `moves` + byte-identical `sequence` across runs; returned sequence uses only `applied` moves
  and reaches isSolved.

F06.2-QA — Puzzle model:
- Lossless JSON round-trip; PuzzleFormatException for missing/null/typed optimalMoves, bad schemaVersion, missing
  grid/targetWord, bad puzzleType/difficultyLabel/language, malformed "r,c", journey-without-level, daily-without-date,
  non-object difficultyBreakdown; unknown-key tolerance.

F06.3-QA — Difficulty:
- Deterministic score + label + breakdown for fixed weights/thresholds; every breakdown metric present; per-metric
  monotonicity (more L / more F raise; more firstMoves lowers); custom thresholds move the label; throws for unsolvable.

F06.4-QA — CLI:
- solve / playtest / export / check / fill behaviors. export gate: NON-ZERO exit + NO FILE on unsolvable /
  budgetExceeded / optimalMoves == 0 / malformed def. check catches every planted bad artifact (no optimalMoves;
  level 1-3 with columns enabled; stored optimal != fresh solve; duplicate definition; ineligible target;
  Daily-manifest repeat-within-window). fill: seed reproducibility + Turkish-frequency bias + --avoid-near-target path.

F06.5-QA — Content gate + evidence:
- `.github/workflows/ci.yml` runs the Content check step; `melos run content:check` green on content/smoke (5 puzzles,
  all 5 mechanic classes). Confirm no RNG in looplet_solver / looplet_content (only tools/fill has a seeded Random;
  a Stopwatch in looplet_solver is contract-allowed). Confirm evidence class `automated functional` is sufficient
  (architecture.md QA Focus + platform.md §10) — F06 is build-time tooling, no device runtime.
- Note for the verdict: F06 delivery = toolchain + smoke set; `F06-CONTENT` (full 30 Journey + Daily pool) is a
  tracked follow-on, not in scope for this QA.

Run from repo root: melos run format:check && melos run analyze && melos run test && melos run content:check
Emit a QA verdict. Next Role after QA is always Tech Lead.
```
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
* v4 (2026-09-05) — Frontend/Mobile Developer: F06.1-FE … F06.SMOKE-FE done. `looplet_content` `Puzzle` + `looplet_solver` (forward BFS + `enumerateOptimalSolutions` + `DifficultyScorer`) + `tools/looplet_authoring` CLI + 5-puzzle smoke set + CI content-check wiring. Carried F02 `applyMove` tidy applied. 200 workspace tests + `content:check` green. `PuzzleType`/`DifficultyLabel` in `looplet_core` (recorded `frontend.md` §4). Current Owner → QA; Next Role → QA (client + CLI level, automated functional).
