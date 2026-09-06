# F06 — puzzle-content-and-solver-tooling: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**Done — Closed** (QA: Approved with Notes; Tech Lead reconciled + closed 2026-09-06)

---

## Current Owner

— (feature closed)

---

## Current Phase

Closed. F06 delivery = the build-time toolchain (`looplet_content` `Puzzle` + `looplet_solver` + `tools/looplet_authoring` CLI) + a 5-puzzle smoke set + CI content-check wiring. QA Approved with Notes; all notes non-blocking and actioned at close-out (see Change Log v6). `F06-CONTENT` (full 30 Journey + ~60 Daily authoring) remains an open follow-on — see Open Tasks → Content.

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
- [x] Task ID: F06.1-QA | Assigned Role: QA | Status: Done | Solver minimality independently verified 3 ways (IDDFS reference + depth-`m-1` no-solution proof + hand-check) across no-tiles / optimal-1 / optimal-2 / column-on-path / locked / frozen-thaw+win; `Unsolvable` (exhausted small space) + `BudgetExceeded` (depth wall / node cap / unsolvable-under-low-wall) verified; determinism byte-stable over 20 solves; returned sequence uses only `applied` moves + folds to `isSolved`.
- [x] Task ID: F06.2-QA | Assigned Role: QA | Status: Done | `Puzzle` lossless JSON round-trip; `PuzzleFormatException` for every violation class (missing/typed `optimalMoves`, bad `schemaVersion`, malformed shape/coord/type, journey-without-level, daily-without-date, non-object `difficultyBreakdown`); unknown-key tolerance. 17 tests.
- [x] Task ID: F06.3-QA | Assigned Role: QA | Status: Done | Difficulty deterministic score + label + full breakdown for fixed weights/thresholds; per-metric monotonicity; custom thresholds move the label; `ArgumentError` for unsolvable. 8 tests + QA probe.
- [x] Task ID: F06.4-QA | Assigned Role: QA | Status: Done | CLI `solve`/`playtest`/`export`/`check`/`fill` verified — including by direct CLI invocation: `export` gate = non-zero exit + no file on unsolvable / trivial; `check` = non-zero exit + named failure on planted `optimalMoves` drift; every planted-bad `check` rule (7) caught; `fill` seed reproducibility + Turkish-frequency bias.
- [x] Task ID: F06.5-QA | Assigned Role: QA | Status: Done | `.github/workflows/ci.yml` `Content check` step + `melos run content:check` green on the committed 5-puzzle smoke set. RNG/clock scan: none in `looplet_solver`/`looplet_content` lib (one contract-allowed `Stopwatch`); `Random(seed)` confined to `tools/.../turkish_frequency.dart`. Evidence class `automated functional` confirmed sufficient (`architecture.md` QA Focus + `platform.md` §10). **Verdict: Approved with Notes → Tech Lead.**

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
- [x] (F06.1-QA) Solver minimality vs an independent exhaustive reference (no-tiles / locked / 1-frozen / 2-frozen); `Unsolvable` + `BudgetExceeded`; determinism + byte-stable tie-break; returned sequence uses only `applied` moves and reaches `isSolved`. — done; minimality also independently proven via a depth-`m-1` no-solution probe.
- [x] (F06.2-QA) `Puzzle` JSON lossless round-trip; `PuzzleFormatException` for missing `optimalMoves` / bad `schemaVersion` / malformed shape / bad coord / wrong type; unknown-key tolerance. — done.
- [x] (F06.3-QA) Difficulty determinism (fixed weights/thresholds); per-metric monotonicity; documented thresholds honored; `breakdown` fields present. — done.
- [x] (F06.4-QA) CLI: `solve` / `playtest` / `export` / `check` / `fill` behaviors; `export` gate exit codes + no-file guarantee; `check` catches every planted bad artifact (no `optimalMoves`; level-2 with columns enabled; Journey↔Daily dup; stored optimal ≠ fresh solve; ineligible target); `fill` seed reproducibility + frequency closeness. — done; `export` gate + `check` drift also verified by direct CLI invocation.
- [x] (F06.5-QA) Build-time `check content/` wired into CI and green on the committed smoke set; RNG confined to `fill`; evidence class `automated functional` confirmed sufficient. Emit verdict → Tech Lead. — done. **Verdict: Approved with Notes.**

### Content (follow-on — NOT part of the F06 implementation delivery)
- [ ] (F06-CONTENT) Author the full 30 Journey levels (honoring the source §20 difficulty curve) + the ~60-puzzle Daily pool + `daily/<lang>/manifest.json`; run `check`; commit to `content/`. Owner: Level Designer / user. Gated on F06 (toolchain) reaching `Done` with a QA-approved pipeline. Still MVP scope (product PRD §42) and a prerequisite for F05 and F07 reaching `Done`. Tunable values finalized here: `SearchBudget` numbers, `DifficultyWeights`/`DifficultyThresholds`, the Turkish frequency table source, MVP Daily pool size + band.

---

## Blockers

* None. F06.1-FE … F06.SMOKE-FE delivered (`frontend.md`); F06.1-QA … F06.5-QA complete (`qa.md`, Approved with Notes). 200 workspace tests + `format:check` + `analyze` + `content:check` green; independent QA probe + direct CLI verification green.
* Carried non-blocking note (Frontend → Tech Lead): `frontend.md` §4/§16 — `PuzzleType`/`DifficultyLabel` were placed in `looplet_core` (not `looplet_content`), same pattern as F02's `MoveAxis` carve-out, so `looplet_solver` can use `DifficultyLabel` without a `looplet_content` dependency. Needs a one-line `platform.md` §11 note; no behavior change.
* Non-blocking note (`F06-CONTENT` perf, `frontend.md` §13): a fully-open 5×5 with optimal 5 solves in ~4.6 s JIT — levels 11–15 (fully open, optimal 6–8) are the cost risk zone. Mitigations within the designed flow: AOT-compile `export`; locked/frozen levels 16–30 are cheaper; `budgetExceeded` → rework. Relevant when `F06-CONTENT` starts, not for F06 sign-off.
* Scope: `F06-CONTENT` (full 30 Journey + Daily pool authoring) is a follow-on — F06 (toolchain + smoke set) can reach `Done` without it; F05/F07 cannot reach `Done` without it.

---

## Last Decision

* 2026-09-06 — Tech Lead (F06 close-out): QA verdict **Approved with Notes** reconciled → **F06 `Done` / Closed**. No rework — every QA note is non-blocking and was actioned at close-out:
  * **Enum location** — `PuzzleType` / `DifficultyLabel` in `looplet_core` (re-exported by `looplet_content`): reconciled into `platform.md` §3 + §11 and this feature's `architecture.md` (Dependency Edges + Puzzle Model + Open Technical Decisions). Same carve-out as the F02 engine primitives; string values unchanged; downstream imports unchanged.
  * **`difficultyBreakdown` required** — locked in `architecture.md` (was "optional / confirm during F06.1"); a missing/non-object breakdown is a `PuzzleFormatException`.
  * **No `Puzzle.toEngineConfig()` in `looplet_content`** — this is intended (`architecture.md` "`Puzzle` → `EngineConfig`" already places the helper in a consumer that depends on `looplet_engine`). Carried into the F05 / F07 / F08 brief backlog; the CLI's `PuzzleDef.toEngineConfig()` is the template.
  * **`fill --frozen-safe` no-op stub**, **`F06-CONTENT` perf risk (fully-open levels 11–15, optimal 6–8)**, **tunable `SearchBudget` / `DifficultyWeights` / `DifficultyThresholds`** — all carried into `F06-CONTENT` (see Open Tasks → Content).
  * **Android `melos run build:app` CI-only locally** — informational; CI covers it.
  * Release gate: **none** (`architecture.md` "Release / Deployment Impact"; `release.md` — F06 Release Scope none). The one CI change (content-check job) shipped in F06.6-FE. No DevOps/Release Engineer gate.
* 2026-09-05 — Tech Lead (F06 activation): activated after F01 + F02 `Done` (last P0). Complexity **COMPLEX** → Technical Analyst pass. No UI Designer (build-time tooling + CLI). Routing: Technical Analyst → Tech Lead (finalize `architecture.md`) → Frontend/Mobile Developer → QA → Tech Lead. Scope split: F06 = toolchain + ~5-puzzle smoke set; `F06-CONTENT` = follow-on.

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-06
* Summary: **F06 reconciled and closed — `Done`.** QA verdict Approved with Notes; all 5 notes non-blocking and actioned at close-out (enum-location doc reconcile in `platform.md` §3/§11 + F06 `architecture.md`; `difficultyBreakdown` locked as required; the other 3 carried to `F06-CONTENT` / the F05-F08 brief backlog). No rework. Contract recorded as **locked & closed**. Global state synced: `feature-board.md` (F06 → Done), `system-state.md` (F06 closed, contract snapshot updated, next feature activated). Next feature: **F08 offline-persistence-and-sync** activated — Complexity COMPLEX → Technical Analyst pass (see `features/f08-offline-persistence-and-sync/`). `F06-CONTENT` remains an open tracked follow-on (Level Designer / user), prerequisite for F05 & F07 reaching `Done`, not a blocker for anything now active. Nothing committed to git.

---

## Next Role

— (feature closed; global next role is **Technical Analyst** for F08 — see `features/f08-offline-persistence-and-sync/orchestration.md`)

---

## Next Action

* **None for F06** — the toolchain is delivered, QA-approved, and closed.
* **`F06-CONTENT` (open follow-on, not scheduled this cycle):** author the full 30 Journey levels + the ~60-puzzle Daily pool + `daily/<lang>/manifest.json`; run `check`; commit under `content/`. Owner: Level Designer / user. Prerequisite for F05 and F07 reaching `Done`. Carries the tunable-value finalization (`SearchBudget`, `DifficultyWeights`, `DifficultyThresholds`, Turkish frequency table source, MVP Daily pool size + band), the `frontend.md` §13 perf mitigation (AOT-compile `export` or per-machine `timeBudget` bump for fully-open levels 11–15), and a decision on `fill --frozen-safe` (implement or drop). Tech Lead schedules this when F05 / F07 need real content.

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F06 created and activated after F02 `Done`. `prd.md` + initial `architecture.md` (LOCKED substrate + gates; PENDING ANALYSIS for 7 items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F06.0-AN → `analysis.md`). Routing: Technical Analyst → Tech Lead (finalize contract) → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-05) — Technical Analyst: F06.0-AN done. `analysis.md` delivered (7 items resolved + recommendation; functional breakdown; edge cases; task breakdown F06.1–F06.8; LOCK-vs-OPEN Delivery Note). Recommends forward BFS (not bidirectional), engine-free `looplet_content`, CLI-only, toolchain + smoke-set scope. Current Owner → Tech Lead; Next Role → Tech Lead to finalize `architecture.md`.
* v3 (2026-09-05) — Tech Lead: F06 contract **finalized**. `analysis.md` consumed into `architecture.md` (all [PENDING ANALYSIS] → [LOCKED]). `platform.md` §13 amended (forward BFS + `SearchBudget`; bidirectional dropped) + §3/§13 CLI-only notes. Scope split accepted: F06 = toolchain + ~5-puzzle smoke set; `F06-CONTENT` (full 30 Journey + Daily pool) = Level-Designer follow-on, still MVP, prerequisite for F05/F07 `Done`. Opened F06.1-FE … F06.SMOKE-FE + F06.1-QA … F06.5-QA. Current Owner → Frontend/Mobile Developer; Next Role → Frontend/Mobile Developer.
* v4 (2026-09-05) — Frontend/Mobile Developer: F06.1-FE … F06.SMOKE-FE done. `looplet_content` `Puzzle` + `looplet_solver` (forward BFS + `enumerateOptimalSolutions` + `DifficultyScorer`) + `tools/looplet_authoring` CLI + 5-puzzle smoke set + CI content-check wiring. Carried F02 `applyMove` tidy applied. 200 workspace tests + `content:check` green. `PuzzleType`/`DifficultyLabel` in `looplet_core` (recorded `frontend.md` §4). Current Owner → QA; Next Role → QA (client + CLI level, automated functional).
* v5 (2026-09-05) — QA: F06.1-QA … F06.5-QA done. `qa.md` written — **verdict: Approved with Notes**, no blocking issues, no rework. All gates re-run green (`format:check` / `analyze` / `test` = 200 / `content:check`). Solver minimality independently verified 3 ways (IDDFS reference + depth-`m-1` no-solution probe + hand-check) across all 6 tile classes; `Unsolvable` vs `BudgetExceeded` (incl. `hitDepthWall`) verified; `export` gate + `check` drift verified by direct CLI; RNG/clock confined (one contract-allowed `Stopwatch`; seeded `Random` only in `tools/turkish_frequency.dart`); evidence class `automated functional` confirmed sufficient. 5 non-blocking notes carried to Tech Lead (enum location doc fix; no `Puzzle.toEngineConfig()` yet; `--frozen-safe` stub; `F06-CONTENT` levels 11–15 perf; Android `build:app` CI-only locally). Current Owner → Tech Lead; Next Role → Tech Lead (reconcile → `Done`, sync global state, apply 2 doc corrections, activate next feature).
* v6 (2026-09-06) — Tech Lead: **F06 reconciled → `Done` / Closed.** QA Approved with Notes accepted as non-blocking; no rework. Actioned: enum-location reconcile (`platform.md` §3 + §11 carve-out extended to `PuzzleType` / `DifficultyLabel`; F06 `architecture.md` Dependency Edges + Puzzle Model + Open Technical Decisions corrected); `difficultyBreakdown` locked as **required** in `architecture.md`; `architecture.md` header → LOCKED & CLOSED. Remaining 3 notes (`--frozen-safe` stub, levels 11–15 perf, tunable values) carried to `F06-CONTENT`; `Puzzle → EngineConfig` consumer-helper note carried to the F05/F07/F08 brief backlog; Android build note informational. Contract recorded locked & closed. Global state synced: `feature-board.md` (F06 → Done, F08 → In Progress / Technical Analyst), `system-state.md` (F06 closed + contract snapshot; F08 activated). Next feature **F08 offline-persistence-and-sync** — COMPLEX → Technical Analyst. Current Owner → — (closed); global Next Role → Technical Analyst (F08).
