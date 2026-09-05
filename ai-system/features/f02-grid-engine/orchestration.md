# F02 — grid-engine: Orchestration

> Execution semantics authority: `/ai-system/role-execution-contract.md`.
> `feature-board.md` and `system-state.md` are the global surfaces; Tech Lead syncs them.

---

## Current Status

**In QA** → QA verdict: Approved with Notes (2026-09-05). Pending Tech Lead reconcile + `Done`.

---

## Current Owner

Tech Lead

---

## Current Phase

QA complete (client-only, automated) → Tech Lead reconcile + global sync

---

## Active Task Ledger

- [x] Task ID: F02.0-CORE | Assigned Role: Frontend/Mobile Developer | Status: Done | `looplet_core` primitives (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`), re-exported by `looplet_content`. 5 tests.
- [x] Task ID: F02.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `EngineConfig` + `_validate` (→ `EngineConfigError`) + `legalMoves`. 13 + 5 tests.
- [x] Task ID: F02.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | Pure `GridState` + `applyMove` (shift algorithm steps 1–8, row-only thaw len 4..n, L→R Turkish-normalized win). 12 + 8 + 8 tests.
- [x] Task ID: F02.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `canonicalKey` + `GridState` value equality. 10 tests.
- [x] Task ID: F02.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `GridEngine` façade — `undo` re-fold from `_initialState`, `restart`, `restoreMoves` (throws `StateError` on rejected move). 10 tests.
- [x] Task ID: F02.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `WordValidator` port + `NeverValidWordValidator`; `app/lib/engine/` `DictionaryWordValidator` + `wordValidatorProvider`. 2 app tests. `looplet_engine` pubspec unchanged (`looplet_core` only).
- [x] Task ID: F02.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | 83 engine tests + `acceptance_criteria_test.dart` (17, 1:1 with prd.md ACs) + `no_rng_guard_test.dart`. `frontend.md` with letter-storage decision (flat row-major `List<String>`) + micro-benchmark (~208k applyMove+canonicalKey ops/sec JIT).
- [x] Task ID: F02.1-QA | Assigned Role: QA | Status: Done | Every AC → executed test (`acceptance_criteria_test.dart` 1:1, `qa.md` §4); public API matches `architecture.md` (3 latitude deviations acceptable); shift/locked/win matrices verified + QA probe.
- [x] Task ID: F02.2-QA | Assigned Role: QA | Status: Done | Frozen thaw: t=0 + on-move, row-window scan len 4..n, word-not-through-cell, multi-frozen together, rows independent, **row-only (no column scan)**, permanence, undo re-freeze, thaw+win terminal — all verified (`qa.md` §5/§10 + QA probe).
- [x] Task ID: F02.3-QA | Assigned Role: QA | Status: Done | Determinism (40–50 folds → 1 key), `canonicalKey` structure (`§`, thawed coord, `İ≠I`), every rejection reason leaves state+count unchanged, 6 `EngineConfig` malformed inputs throw, `legalMoves` == applied-true set (exhaustive), no-RNG guard green.
- [x] Task ID: F02.4-QA | Assigned Role: QA | Status: Done | Evidence class `automated functional` confirmed sufficient (`architecture.md` QA Focus + `platform.md` §10). `melos run format:check`/`analyze`/`test` (145) executed green + independent 8-assertion QA probe. Verdict emitted (`qa.md`).

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

* Updated By: QA
* Timestamp: 2026-09-05
* Summary: F02 QA complete — verdict **Approved with Notes**. Scope: client-only, automated functional. QA ran `melos run format:check` / `analyze` / `test` (145 green) + an independent 8-assertion QA probe (created / run green / removed) against the real engine: locked rotation `E A C B D` + column anchor; frozen thaw **row-only** (a `MASAL` column does not thaw); undo re-freezes; thaw+win terminal; every rejection reason leaves state + count unchanged; determinism (40 folds → 1 key) + `canonicalKey` structure (`§`, thawed coord, `İ≠I`); `legalMoves` == applied-true set (exhaustive); 6 malformed `EngineConfig` inputs throw; 5-shift identity. Every `prd.md` requirement + AC mapped to an executed test (`qa.md` §3/§4). Contract fully preserved (`qa.md` §6). Three non-blocking notes for Tech Lead: (1) `applyMove` reads config from two sources — latent fragility, no defect; (2) Android CI build; (3) Phase-2 non-full-row-target path untested by design. No required fixes. `qa.md` written. Not committed to git.

---

## Next Role

Tech Lead

---

## Next Action

### Tech Lead

```text
Reconcile F02 QA verdict (Approved with Notes) and sync global state.

1. Global state sync (Tech Lead-owned):
   - feature-board.md: F02 grid-engine In Progress -> Done; Owner -> - ; QA -> QA. Update Last Updated / Active Phase /
     Active Owner (next up is F06 — solver/tooling, the last P0).
   - system-state.md: Active Feature -> F06 (next) or "—" pending activation; Current Phase/Role/Reason;
     Last Completed Action = QA F02 Approved with Notes 2026-09-05; Next Expected Action = activate F06.
   - features/f02-grid-engine/orchestration.md: terminal cleanup per role-execution-contract §6 (Status = Done,
     Current Owner = -, Active Task Ledger = None, Next Role = -/Closed, Next Action = Closed).

2. Non-blocking follow-up (optional, do NOT reopen F02): note in F06's brief that when Frontend/Mobile Developer
   next touches looplet_engine, GridState.applyMove should read all EngineConfig fields from one source
   (prefer the stored _config, or drop it and always thread the parameter). No defect today.

3. Informational: confirm the Android job in .github/workflows/ci.yml is green (melos run build:app not runnable
   locally — no Android SDK). flutter analyze / flutter test / (after F01) iOS release build all green locally.

4. Activate F06 (puzzle-content-and-solver-tooling): P0, depends on F01 (Done) + F02 (Done). This is the last P0 and
   the content-production pipeline that F05 and F07 need. It is Infrastructure + tooling; complexity is high (provable
   minimum-move search over the F02 canonicalKey state space, honoring locked/frozen; a level editor; difficulty
   scoring). Open features/f06-*/ with prd.md + architecture.md + orchestration.md; run the complexity decision
   (Technical Analyst may be warranted for the solver algorithm + difficulty-scoring parameterization).

Release gate: none for F02 (Release Scope = none).
```

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F02 grid-engine created and activated. `prd.md` + `architecture.md` (full contract) + orchestration. Complexity COMPLEX; no Analyst / no UI Designer (justified). Routing: Frontend/Mobile Developer (F02.0-CORE → F02.6-FE) → QA → Tech Lead. `platform.md` §11 amended for the engine-primitive-enum carve-out.
* v2 (2026-09-05) — Frontend/Mobile Developer: F02.0-CORE + F02.1-FE … F02.6-FE done. `looplet_core` primitives + `looplet_engine` (pure `GridState`/`applyMove` core + `GridEngine` façade + `WordValidator` port) + app adapter. 145 workspace tests green (engine 83); format/analyze green. 3 recorded impl decisions (letter storage = flat list; `restoreMoves` throws; `GridState` holds config) — none change the contract. Current Owner → QA; Next Role → QA (client-only). Uncommitted.
* v3 (2026-09-05) — QA: verdict **Approved with Notes**. Client-only automated functional. 145 tests + independent 8-assertion QA probe executed green. Every prd.md requirement + AC traced to an executed test; contract fully preserved. 3 non-blocking notes (dual config source in `applyMove`; Android CI; Phase-2 target path untested). No required fixes. Current Owner → Tech Lead; Next Role → Tech Lead for global-state sync + F06 activation.
