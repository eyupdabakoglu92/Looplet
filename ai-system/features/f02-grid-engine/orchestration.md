# F02 — grid-engine: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**Done**

---

## Current Owner

-

---

## Current Phase

Closed

---

## Active Task Ledger

None — feature terminal (Done, 2026-09-05).

Historical task record (all complete):

- [x] F02.0-CORE (Frontend/Mobile Developer) — `looplet_core` engine primitives (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`), re-exported by `looplet_content`.
- [x] F02.1-FE … F02.6-FE (Frontend/Mobile Developer) — `looplet_engine`: `Move`, `WordValidator` port, `EngineConfig`+`legalMoves`, pure `GridState`/`applyMove` (shift algorithm, row-only thaw, L→R win), `canonicalKey` + value equality, `GridEngine` façade (`undo` re-fold / `restart` / `restoreMoves`), no-RNG guard. App: `DictionaryWordValidator` + `wordValidatorProvider`. 83 engine tests + 17 AC-traceability.
- [x] F02.1-QA … F02.4-QA (QA) — AC + contract traceability; frozen-tile behavior; determinism + rejections + validation; evidence-class + CI. Verdict: **Approved with Notes** (`qa.md`) — 145 workspace tests + independent probe green; 3 non-blocking notes (dual config source in `applyMove`; Android CI; Phase-2 target path untested); no required fixes.

---

## QA Scope

* client-only (package-level, automated `dart test`; no device runtime required — see `architecture.md` QA Focus and `platform.md` §10)

---

## Release Scope

* none

---

## Open Tasks

### Frontend
- [x] (F02.0-CORE) `looplet_core` primitives — done.
- [x] (F02.1-FE) `EngineConfig` + validation + `legalMoves` — done.
- [x] (F02.2-FE) Pure `GridState` + `applyMove` + `GridStep` — done.
- [x] (F02.3-FE) `canonicalKey` + value equality — done.
- [x] (F02.4-FE) `GridEngine` façade + `restoreMoves` — done.
- [x] (F02.5-FE) `WordValidator` port + app adapter + provider — done.
- [x] (F02.6-FE) 83 engine tests + AC-traceability + no-RNG guard + `frontend.md` — done.

### QA
- [x] (F02.1-QA) AC + contract verification — done (`qa.md` §3/§4/§6).
- [x] (F02.2-QA) Frozen-tile behavior — done (`qa.md` §5/§10 + QA probe).
- [x] (F02.3-QA) Determinism + rejections + validation — done (`qa.md` §5/§6/§10 + QA probe).
- [x] (F02.4-QA) Evidence class + CI; verdict emitted — done (`qa.md` §0a/§17).

---

## Blockers

* None. QA verdict **Approved with Notes** (2026-09-05) — no blocking issues, no required fixes.
* Non-blocking (Frontend, optional follow-up): `GridState.applyMove` reads locked/frozen classification from the stored `_config` but `columnMovesEnabled`/`gridSize`/`targetWord`/`frozenCells` from the passed `config` param. No defect today (every caller passes the matching instance); recommend tidying to one source next time `looplet_engine` is touched (likely F06). Not worth reopening F02. (`qa.md` §14/§20.)
* Non-blocking (CI): `melos run build:app` (Android AAB) still CI-only locally (no Android SDK). `flutter analyze` / `flutter test` green locally.
* Non-blocking (scope): non-full-row target (`targetLength < gridSize`) is a Phase-2 path — code exists, intentionally untested for the MVP (`architecture.md` "Open Technical Decisions").

---

## Last Decision

* 2026-09-05 — Tech Lead (F02 activation):
  * F02 activated after F01 `Done`. P0; F02 is the hard dependency for F03, F04, F05, F06, F07.
  * Complexity = **COMPLEX** (state machine, terminal-state rules, determinism matrix, new domain model) — but **no Technical Analyst**: product PRD §6.1/§7–8/§15–16/§20–22 already enumerate every AC, edge case, and domain field; no ambiguous requirement to translate, no external API/service to derive. Tech Lead locked all remaining semantics directly in `architecture.md`.
  * **No UI Designer** — headless engine, zero rendering. The play screen is F03.
  * Contract locked in `architecture.md`: two-layer design (pure `GridState`/`applyMove` core + `GridEngine` façade); shift algorithm (movable-subsequence cyclic rotation, locked/unthawed-frozen = fixed points); thaw = row-only, len-4 + len-5 windows, word need not pass through the frozen cell, all frozen cells in the row thaw together, monotonic forward, evaluated on settled state + t=0; win = full L→R row equals target (Turkish-normalized), reverse/vertical/diagonal never win, evaluated on settled state + t=0; win+thaw on one move → win is terminal, move counted; undo re-folds from t=0 (thaw can revert); rejection reasons as values (`columnMovesDisabled`/`lineFullyImmovable`/`outOfRange`/`puzzleComplete`/`nothingToUndo`) — never mutate state/count; `canonicalKey` = Turkish-lower row-major letters + sorted thawed coords, excludes locked/target/columnMovesEnabled; no runtime RNG (guard test).
  * **Platform authority carve-out:** engine primitive enums (`MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord`) live in `looplet_core` (not `looplet_content`) so `looplet_engine` → `looplet_core` only per `platform.md` §3. `platform.md` §11 amended in the same turn. `looplet_content` re-exports them.
  * `WordValidator` port keeps `looplet_engine` free of a `looplet_dictionary` dependency.
  * Release Scope = none.

---

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-05
* Summary: F02 closed. Reconciled QA verdict **Approved with Notes** — delivery reconciliation passed (task coverage complete, contract fully preserved per `qa.md` §6, evidence = 145 executed workspace tests + independent 8-assertion probe, no required fixes). Notes non-blocking; Release Scope = none → no release gate. Terminal cleanup applied. The `platform.md` §11 engine-primitive-enum carve-out (made at F02 activation) is consistent. `feature-board.md` + `system-state.md` synced same turn; F06 (puzzle-content-and-solver-tooling) activated with a Technical Analyst pass.

---

## Next Role

Closed

---

## Next Action

Closed. F02 grid-engine is Done (2026-09-05). Non-blocking follow-ups carried in `## Blockers` (dual config source in `applyMove` → tidy when `looplet_engine` is next touched, likely F06; Android CI confirmation; Phase-2 non-full-row-target path untested by design). Workflow continues at `features/f06-puzzle-content-and-solver-tooling/orchestration.md`.

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F02 grid-engine created and activated. `prd.md` + `architecture.md` (full contract) + orchestration. Complexity COMPLEX; no Analyst / no UI Designer (justified). Routing: Frontend/Mobile Developer (F02.0-CORE → F02.6-FE) → QA → Tech Lead. `platform.md` §11 amended for the engine-primitive-enum carve-out.
* v2 (2026-09-05) — Frontend/Mobile Developer: F02.0-CORE + F02.1-FE … F02.6-FE done. `looplet_core` primitives + `looplet_engine` (pure `GridState`/`applyMove` core + `GridEngine` façade + `WordValidator` port) + app adapter. 145 workspace tests green (engine 83); format/analyze green. 3 recorded impl decisions (letter storage = flat list; `restoreMoves` throws; `GridState` holds config) — none change the contract. Current Owner → QA; Next Role → QA (client-only). Uncommitted.
* v3 (2026-09-05) — QA: verdict **Approved with Notes**. Client-only automated functional. 145 tests + independent 8-assertion QA probe executed green. Every prd.md requirement + AC traced to an executed test; contract fully preserved. 3 non-blocking notes (dual config source in `applyMove`; Android CI; Phase-2 target path untested). No required fixes. Current Owner → Tech Lead; Next Role → Tech Lead for global-state sync + F06 activation.
* v4 (2026-09-05) — Tech Lead: F02 reconciled and **closed (Done)**. Delivery reconciliation passed; notes non-blocking; no release gate. Terminal cleanup applied. `feature-board.md` + `system-state.md` synced same turn. F06 (puzzle-content-and-solver-tooling) activated → Technical Analyst pass.
