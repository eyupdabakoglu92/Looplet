# F06 — puzzle-content-and-solver-tooling: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In Progress**

---

## Current Owner

Technical Analyst

---

## Current Phase

Analysis (contract brief drafted with open technical decisions; Technical Analyst pass before contract finalization)

---

## Active Task Ledger

- [ ] Task ID: F06.0-AN | Assigned Role: Technical Analyst | Status: Open | Summary: Analyze F06 per `prd.md` "Open Questions" + `architecture.md` "Open Technical Decisions". Produce `analysis.md` with options + trade-offs + a marked recommendation for: (1) solver algorithm + search bound + frozen-thaw branching + minimality-proof argument; (2) difficulty-score computable definitions + formula + `easy`/`medium`/`hard`/`expert` thresholds; (3) `Puzzle` JSON schema + whether `looplet_content` may depend on `looplet_engine`; (4) CLI command set + puzzle-definition input format (desktop preview: recommend no for MVP); (5) content-rule heuristics (Turkish-frequency biasing table; "misleading nonsense strings" rule); (6) Daily pool size + no-duplication + no-repeat-window rules; (7) `WordValidator` adapter placement. Plus: functional breakdown, edge cases, task breakdown (solver / content / CLI / QA), and a Delivery Note for Tech Lead separating decisions-to-lock from questions-that-stay-open.

---

## QA Scope

* client-only (package + CLI level, automated `dart test` + CLI invocation from tests; no device runtime — see `architecture.md` QA Focus and `platform.md` §10)

---

## Release Scope

* none

---

## Open Tasks

### Analysis
- [ ] (F06.0-AN) Technical analysis of F06 (see Active Task Ledger). Output: `features/f06-puzzle-content-and-solver-tooling/analysis.md`.

### Backend
- _(none — F06 has no server; the "backend" work here is the pure-Dart `looplet_solver` + `looplet_content`, sequenced under Frontend/Mobile Developer once the contract is finalized)_

### Frontend
- [ ] (F06.x-FE) Placeholder — populated by the Tech Lead after the Analyst pass + contract finalization. Expected shape: `looplet_content` `Puzzle` model + JSON; `looplet_solver` search + `SolveResult`; difficulty scorer; `tools/looplet_authoring` CLI (`solve` / `playtest` / `export` + definition input); content-generation helpers; the 30 Journey artifacts + Daily pool; the build-time content check; tests.

### QA
- [ ] (F06.x-QA) Placeholder — populated by the Tech Lead after contract finalization. Expected: solver minimality vs exhaustive-BFS reference; locked/frozen honoring; `unsolvable` / `budgetExceeded`; determinism + stable tie-break; `Puzzle` round-trip + schema rejection; difficulty determinism + thresholds; CLI behaviors incl. export gate; build-time content check catches planted bad artifacts; Turkish-frequency + seeded reproducibility.

---

## Blockers

* None. Analysis pass in progress.
* Dependency note: F01 (Done) + F02 (Done) — F06 builds directly on F02's `GridState` / `applyMove` / `canonicalKey` / `legalMoves` and F01's `WordValidator`.
* Carried non-blocking note (from F02 QA): when `looplet_engine` is next touched (likely by F06's solver work), tidy `GridState.applyMove` to read all `EngineConfig` fields from one source. No defect today.

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
* Summary: F02 closed (Done). F06 puzzle-content-and-solver-tooling activated. Created `prd.md` (derived, with an explicit "Open Questions" list) + `architecture.md` (initial contract brief — LOCKED build-time-only substrate + publish gates + artifact layout; PENDING ANALYSIS for solver algorithm, difficulty metrics, `Puzzle` schema, CLI scope, content heuristics, Daily pool rules, validator placement) + this orchestration. Complexity COMPLEX → **Technical Analyst pass**. `feature-board.md` + `system-state.md` synced same turn (F02 Done, F06 active / Analysis).

---

## Next Role

Technical Analyst

---

## Next Action

### Technical Analyst

```text
Analyze F06 puzzle-content-and-solver-tooling. Produce features/f06-puzzle-content-and-solver-tooling/analysis.md.

Authority: features/f06-.../prd.md (system requirements, Acceptance Criteria, Edge Cases, Open Questions),
features/f06-.../architecture.md (what is LOCKED vs PENDING ANALYSIS), product-prd.md §46–49,
project-authority/platform.md §13 (solver direction). Inherited: features/f02-grid-engine/architecture.md
(GridState / applyMove / canonicalKey / legalMoves — the solver's substrate) and F01's WordValidator port.

Resolve, with options + trade-offs + a marked Recommendation for each (Tech Lead makes the final call):

1. SOLVER ALGORITHM. platform.md §13 says "bidirectional BFS over a packed canonical grid-state hash;
   fall back to IDA* if memory-bound". Evaluate that against two facts: (a) the goal is a SET of states
   (any grid with a full left-to-right target row), not a single state; (b) frozen-thaw is irreversible
   (a backward move cannot un-thaw). Compare at least: forward BFS with a canonicalKey visited set + a
   depth/node/time bound; IDA* with an admissible heuristic (e.g. minimum shifts to bring the target
   letters into some row, ignoring collisions); bidirectional with an enumerated goal frontier. State the
   memory/time behavior on a 5×5 with locked + up to N frozen tiles, the search bound that separates
   "publishable" from budgetExceeded, and the argument for why the chosen method returns a PROVABLE minimum
   (including the frozen-thaw ordering branch).

2. DIFFICULTY SCORE. Give concrete, computable definitions for every §48 parameter: optimal move count;
   "correct-looking intermediate states"; "required temporary displacement"; locked count; frozen count;
   "number of plausible routes". Propose a score formula and the score→label thresholds
   (easy / medium / hard / expert). It must be deterministic.

3. PUZZLE SCHEMA. Exact JSON shape for the looplet_content Puzzle (grid as row strings vs arrays;
   locks/freezes representation; how the nested EngineConfig is expressed; contentVersion semantics).
   Recommend whether looplet_content may depend on looplet_engine for the EngineConfig type, or whether
   Puzzle stores raw fields and builds EngineConfig(...) on load (Tech Lead leans to the latter).

4. CLI SCOPE. Exact command set (solve / playtest / export + any others), the puzzle-definition input
   format (file? flags? interactive?), and confirm CLI-only for the MVP (no Flutter-desktop preview).

5. CONTENT-RULE HEURISTICS. The Turkish letter-frequency biasing method (a weighted sampling table —
   propose the source/approach, not the full table) and the "misleading nonsense strings" reduction rule.

6. DAILY POOL RULES. MVP pool size; no-duplication-with-Journey rule; no-repeat-within-window rule.

7. WORDVALIDATOR ADAPTER PLACEMENT. looplet_solver depends on looplet_dictionary directly, vs takes the
   WordValidator port with the adapter in tools/looplet_authoring. (Neither is on-device.)

Also produce: a technical functional breakdown, an edge-case list beyond prd.md, and a task breakdown
(solver / content model / CLI / content-set authoring / QA). In the Delivery Note for Tech Lead, separate
"decisions the Tech Lead can lock into architecture.md" from "questions that must stay open".

Do not write code or pick the final architecture — that is the Tech Lead's call. Next Role after analysis is
always Tech Lead.
```

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F06 created and activated after F02 `Done`. `prd.md` + initial `architecture.md` (LOCKED substrate + gates; PENDING ANALYSIS for 7 items) + orchestration. Complexity COMPLEX → Technical Analyst pass (F06.0-AN → `analysis.md`). Routing: Technical Analyst → Tech Lead (finalize contract) → Frontend/Mobile Developer → QA → Tech Lead.
