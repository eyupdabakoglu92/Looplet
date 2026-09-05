# F06 — puzzle-content-and-solver-tooling: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress** → analysis delivered; pending Tech Lead contract finalization

---

## Current Owner

Tech Lead

---

## Current Phase

Analysis complete → Tech Lead contract finalization (lock the `analysis.md` §17 items into `architecture.md`, open FE/QA tasks)

---

## Active Task Ledger

- [x] Task ID: F06.0-AN | Assigned Role: Technical Analyst | Status: Done | `analysis.md` delivered — all 7 open items resolved with options + trade-offs + a marked recommendation: (1) **forward BFS** + `canonicalKey` visited + `SearchBudget` (bidirectional BFS from `platform.md` §13 dropped — goal-is-a-set + frozen-thaw irreversibility break meet-in-the-middle); (2) computable §48 metric definitions + score formula + label thresholds (weights/thresholds configurable); (3) `looplet_content` engine-free, `Puzzle` stores raw fields + `toEngineConfig()` in a consumer; (4) CLI-only, `solve`/`playtest`/`export`/`check`/`fill`; (5) seeded Turkish-frequency `fill` + offensive/near-target filter; (6) Daily pool ~60 + date→id manifest + no-repeat-window 30d; (7) `looplet_solver` → `looplet_engine` only, `WordValidator` adapter in `tools`. Plus functional breakdown, edge cases, task breakdown (F06.1–F06.8), Delivery Note (LOCK vs OPEN). Recommends F06 delivers **toolchain + smoke set**; full 30 Journey + ~60 Daily authoring = separate content task.

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
- _(none — F06 has no server; the "backend" work here is the pure-Dart `looplet_solver` + `looplet_content`, sequenced under Frontend/Mobile Developer once the contract is finalized)_

### Frontend
- [ ] (F06.x-FE) Placeholder — populated by the Tech Lead after the Analyst pass + contract finalization. Expected shape: `looplet_content` `Puzzle` model + JSON; `looplet_solver` search + `SolveResult`; difficulty scorer; `tools/looplet_authoring` CLI (`solve` / `playtest` / `export` + definition input); content-generation helpers; the 30 Journey artifacts + Daily pool; the build-time content check; tests.

### QA
- [ ] (F06.x-QA) Placeholder — populated by the Tech Lead after contract finalization. Expected: solver minimality vs exhaustive-BFS reference; locked/frozen honoring; `unsolvable` / `budgetExceeded`; determinism + stable tie-break; `Puzzle` round-trip + schema rejection; difficulty determinism + thresholds; CLI behaviors incl. export gate; build-time content check catches planted bad artifacts; Turkish-frequency + seeded reproducibility.

---

## Blockers

* None. Analysis complete (`analysis.md`); Tech Lead contract finalization next.
* Dependency note: F01 (Done) + F02 (Done) — F06 builds directly on F02's `GridState` / `applyMove` / `canonicalKey` / `legalMoves` and F01's `WordValidator`.
* Carried non-blocking note (from F02 QA): when `looplet_engine` is next touched (likely by F06's solver work), tidy `GridState.applyMove` to read all `EngineConfig` fields from one source. No defect today.
* Flagged for Tech Lead: `analysis.md` recommends forward BFS instead of `platform.md` §13's "bidirectional BFS" — §13 should be updated. Not a blocker (F06's `architecture.md` is the feature contract authority).

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

* Updated By: Technical Analyst
* Timestamp: 2026-09-05
* Summary: F06.0-AN complete. `analysis.md` delivered — all 7 open items resolved with options/trade-offs/recommendation. Headline recommendations: (1) **forward BFS** over `canonicalKey` + `SearchBudget` (maxDepth 16 / maxNodes 5M / 30s) — `platform.md` §13's bidirectional BFS dropped (goal-is-a-set + frozen-thaw irreversibility); minimality is BFS-by-construction; (2) computable §48 difficulty metric definitions + score formula + configurable weights/thresholds; (3) `looplet_content` stays engine-free (`Puzzle` raw fields + consumer-side `toEngineConfig()`); (4) CLI-only (`solve`/`playtest`/`export`/`check`/`fill`), JSON def-files; (5) seeded Turkish-frequency `fill` + offensive/near-target filter; (6) Daily pool ~60 + date→id manifest + 30d no-repeat, medium/hard band; (7) `looplet_solver` → `looplet_engine` only, dictionary adapter in `tools`. Task breakdown F06.1–F06.8; recommends F06 ships **toolchain + ~5-puzzle smoke set**, full 30 Journey + ~60 Daily = separate content task. Flagged: `platform.md` §13 should be updated by the Tech Lead.

---

## Next Role

Tech Lead

---

## Next Action

### Tech Lead

```text
Finalize the F06 contract from analysis.md.

1. Move analysis.md §17 "LOCK" items into features/f06-.../architecture.md, converting each [PENDING ANALYSIS]
   section to [LOCKED]:
   - Solver = forward BFS over GridState.canonicalKey visited set + parent map, fixed Move successor order, FIFO;
     first isSolved dequeued = provable minimum (goal tested on dequeue). SolveResult = Optimal(moves, sequence) |
     Unsolvable | BudgetExceeded(budget); deterministic, byte-stable sequence. SearchBudget defaults
     maxDepth 16 / maxNodes 5,000,000 / timeBudget 30s (tunable; mechanism locked). IDA* = documented per-puzzle
     fallback only. Bidirectional BFS NOT adopted.
   - looplet_content depends on looplet_core only; Puzzle stores raw fields; a consumer builds EngineConfig via
     toEngineConfig(). Puzzle.language is a validated String.
   - looplet_solver depends on looplet_engine only; WordValidator->DictionaryService adapter lives in
     tools/looplet_authoring.
   - Puzzle JSON shape per analysis.md §5 (grid row strings; "r,c" coords; unknown keys ignored; typed
     PuzzleFormatException; optimalMoves required + non-nullable).
   - CLI-only. Commands solve / playtest / export / check / fill. export gate: non-zero exit + no file on
     unsolvable / budgetExceeded / optimalMoves == 0. check is the CI content gate; add to .github/workflows/ci.yml.
   - Difficulty: lock the metric DEFINITIONS (analysis.md §12 table); keep weights + thresholds in a configurable
     DifficultyWeights/DifficultyThresholds value (const defaults, recalibrated after F06.8).
   - Content layout content/journey/<lang>/levelNN.json, content/daily/<lang>/pool/*.json,
     content/daily/<lang>/manifest.json; check enforces Journey band consistency + Journey internal + Journey<->Daily
     dedup + Daily no-repeat-window (30d).

2. Keep OPEN (record in architecture.md "Open Technical Decisions", do not block implementation): exact SearchBudget
   numbers + difficulty weights/thresholds (finalize during F06.8); Turkish frequency table source; near-target filter
   strength for MVP; MVP Daily pool size + band; difficultyBreakdown required vs optional; package:args in the tool.

3. Decide the SCOPE SPLIT (analyst recommendation): F06 implementation = F06.1–F06.7 (toolchain) + a ~5-puzzle smoke
   set; full 30 Journey + ~60 Daily authoring = a separate follow-on content task (owner TBD), still required before
   F05/F07 ship. Confirm or override.

4. Decide whether to amend project-authority/platform.md §13 (bidirectional BFS -> forward BFS + bound). Analyst
   recommends yes.

5. Replace the F06 orchestration "Frontend" / "QA" placeholder tasks with the concrete F06.1-FE … F06.7-FE +
   F06.1-QA … F06.5-QA tasks from analysis.md §16; set Next Role = Frontend/Mobile Developer.

6. Carry the F02 non-blocking note: while touching looplet_engine for F06's solver, tidy GridState.applyMove to
   read all EngineConfig fields from one source.

Consumed Signals: analysis.md consumed into architecture.md on 2026-09-05 (once step 1 is done). Next Role after
Tech Lead = Frontend/Mobile Developer.
```

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F06 created and activated after F02 `Done`. `prd.md` + initial `architecture.md` (LOCKED substrate + gates; PENDING ANALYSIS for 7 items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F06.0-AN → `analysis.md`). Routing: Technical Analyst → Tech Lead (finalize contract) → Frontend/Mobile Developer → QA → Tech Lead.
* v2 (2026-09-05) — Technical Analyst: F06.0-AN done. `analysis.md` delivered (7 items resolved + recommendation; functional breakdown; edge cases; task breakdown F06.1–F06.8; LOCK-vs-OPEN Delivery Note). Recommends forward BFS (not bidirectional), engine-free `looplet_content`, CLI-only, toolchain + smoke-set scope. Current Owner → Tech Lead; Next Role → Tech Lead to finalize `architecture.md`.
