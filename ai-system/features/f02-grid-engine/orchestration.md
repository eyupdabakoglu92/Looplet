# F02 — grid-engine: Orchestration

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

QA (client-only, automated — `looplet_engine` + `looplet_core` primitives + app validator wiring)

---

## Active Task Ledger

- [x] Task ID: F02.0-CORE | Assigned Role: Frontend/Mobile Developer | Status: Done | `looplet_core` primitives (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`), re-exported by `looplet_content`. 5 tests.
- [x] Task ID: F02.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `EngineConfig` + `_validate` (→ `EngineConfigError`) + `legalMoves`. 13 + 5 tests.
- [x] Task ID: F02.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | Pure `GridState` + `applyMove` (shift algorithm steps 1–8, row-only thaw len 4..n, L→R Turkish-normalized win). 12 + 8 + 8 tests.
- [x] Task ID: F02.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `canonicalKey` + `GridState` value equality. 10 tests.
- [x] Task ID: F02.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `GridEngine` façade — `undo` re-fold from `_initialState`, `restart`, `restoreMoves` (throws `StateError` on rejected move). 10 tests.
- [x] Task ID: F02.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | `WordValidator` port + `NeverValidWordValidator`; `app/lib/engine/` `DictionaryWordValidator` + `wordValidatorProvider`. 2 app tests. `looplet_engine` pubspec unchanged (`looplet_core` only).
- [x] Task ID: F02.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Done | 83 engine tests + `acceptance_criteria_test.dart` (17, 1:1 with prd.md ACs) + `no_rng_guard_test.dart`. `frontend.md` with letter-storage decision (flat row-major `List<String>`) + micro-benchmark (~208k applyMove+canonicalKey ops/sec JIT).
- [ ] Task ID: F02.1-QA | Assigned Role: QA | Status: Open | Summary: AC + contract verification (every `prd.md` AC → a passing test; public API matches `architecture.md`; shift + locked + win matrices).
- [ ] Task ID: F02.2-QA | Assigned Role: QA | Status: Open | Summary: Frozen-tile behavior (timing, row-window scan, word-not-through-cell, multi-frozen, independence, row-only, permanence, undo-revert, thaw+win).
- [ ] Task ID: F02.3-QA | Assigned Role: QA | Status: Open | Summary: Determinism + `canonicalKey` + rejection matrix + `EngineConfig` validation + `legalMoves` == applied-true set + no-RNG guard.
- [ ] Task ID: F02.4-QA | Assigned Role: QA | Status: Open | Summary: Evidence class + CI; run `melos run format:check && analyze && test`; emit verdict → Tech Lead.

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
- [ ] (F02.1-QA) AC + contract verification: every `prd.md` AC → a passing test; public API matches `architecture.md` "API / Event Contract" verbatim; shift table + locked-rotation + win/no-win matrices covered.
- [ ] (F02.2-QA) Frozen-tile behavior: thaw timing (settled-only + t=0), row-window scan (len 4/5, word not through frozen cell), multi-frozen same row thaw together, different rows independent, **row-only (no column scan)**, permanence across moves, revert-on-undo of the causing move, thaw+win same move.
- [ ] (F02.3-QA) Determinism + rejections + validation: double independent fold `==` and equal `canonicalKey`; `canonicalKey` differs on any letter/thawed change; no-RNG guard test present and green; every rejection reason leaves state + `moveCount` unchanged; each malformed `EngineConfig` throws `EngineConfigError`; `legalMoves` matches the applied-true set and is empty when solved.
- [ ] (F02.4-QA) Evidence class + CI: confirm `automated functional` is sufficient (`architecture.md` QA Focus + `platform.md` §10); confirm CI runs the new suites; run `melos run format:check && melos run analyze && melos run test`. Emit verdict → Tech Lead.

---

## Blockers

* None.
* Dependency note: F01 dictionary-service is **Done** (2026-09-05). F02 consumes word validation via the injected `WordValidator` port, so it does not import `looplet_dictionary`; the app supplies a `DictionaryService` adapter (`app/lib/engine/dictionary_word_validator.dart`).
* Non-blocking (scaffold/CI): `melos run build:app` (Android AAB) still CI-only locally (no Android SDK). `flutter analyze` / `flutter test` green locally; iOS release build was green after F01.

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

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-05
* Summary: F02.0-CORE + F02.1-FE … F02.6-FE complete. `looplet_core` engine primitives (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`), re-exported by `looplet_content`. `looplet_engine`: `Move`, `WordValidator`/`NeverValidWordValidator`, `EngineConfig`+`EngineConfigError`+`legalMoves`, `MoveRejectReason`, `GridStep`, pure `GridState` (flat row-major storage, `applyMove` shift algorithm steps 1–8, row-only thaw len 4..n, L→R Turkish-normalized win, `canonicalKey`, value equality), `GridEngine` façade (`undo` re-fold, `restart`, `restoreMoves`). App: `DictionaryWordValidator` + `wordValidatorProvider` (no engine→`looplet_dictionary` dependency). 145 workspace tests green (engine 83 incl. 17 AC-traceability + no-RNG guard); `format:check` / `analyze` (6 pkgs + `flutter analyze`) green. Micro-benchmark ~208k applyMove+canonicalKey ops/sec (JIT). `frontend.md` written. Not committed to git.

---

## Next Role

QA

---

## Next Action

### QA

```text
Verify F02 grid-engine (client-only, automated — no device runtime required per architecture.md QA Focus + platform.md §10).

Authority: features/f02-grid-engine/prd.md (Acceptance Criteria + Edge Cases), architecture.md (API / Event Contract,
Shift algorithm, Thaw/Win evaluation, canonicalKey, QA Focus), frontend.md (delivery report + test evidence by task).

F02.1-QA — AC + contract:
- Walk every AC bullet in prd.md; confirm acceptance_criteria_test.dart (17) + the matrix files cover each. Confirm the
  public API (EngineConfig / GridState / GridEngine / Move / GridStep / MoveRejectReason / WordValidator) matches
  architecture.md "API / Event Contract" (note the deviations recorded in frontend.md §14: GridState.initial as a
  factory, GridState holds its config, restoreMoves throws — none change behavior).
- Shift table (4 dirs ± wrap, rows + cols, 5-shift identity); locked rotation worked example E A C B D; win/no-win
  (reverse LASAM, vertical column, repeated letters MSAAL ≠ MASAL, casing-insensitive, pre-solved t=0).

F02.2-QA — Frozen tile:
- thaw at t=0; word not through the frozen cell (4-letter window); two frozen tiles in one row thaw together; frozen
  rows evaluated independently; **row only — the column is never scanned** (dedicated test); thaw permanent across a
  later word-breaking move; **undo of the causing move re-freezes the tile**; thaw + win on the same move → both flags,
  engine terminal.

F02.3-QA — Determinism / rejections / validation:
- double independent fold → GridState == and equal canonicalKey; façade == pure fold; 50 folds → one key; canonicalKey
  differs on any letter/thawed change, reflects the thawed set (§2,2), uses Turkish-lower (İ→i, I→ı).
- every MoveRejectReason (columnMovesDisabled / lineFullyImmovable / outOfRange / puzzleComplete / nothingToUndo)
  leaves state + moveCount unchanged.
- each malformed EngineConfig throws EngineConfigError; legalMoves matches the applied-true set exactly and is empty
  when solved.
- no-RNG guard test present and green (no Random / DateTime.now / Stopwatch / dart:io / Isolate.spawn in looplet_engine/lib).

F02.4-QA — Evidence class + CI:
- Confirm "automated functional" evidence is sufficient (architecture.md QA Focus + platform.md §10) — no device runtime.
- Confirm .github/workflows/ci.yml runs format:check + analyze + test across the workspace.
- Run from repo root: melos run format:check && melos run analyze && melos run test
- Emit a QA verdict. Next Role after QA is always Tech Lead.
```

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F02 grid-engine created and activated. `prd.md` + `architecture.md` (full contract) + orchestration. Complexity COMPLEX; no Analyst / no UI Designer (justified). Routing: Frontend/Mobile Developer (F02.0-CORE → F02.6-FE) → QA → Tech Lead. `platform.md` §11 amended for the engine-primitive-enum carve-out.
* v2 (2026-09-05) — Frontend/Mobile Developer: F02.0-CORE + F02.1-FE … F02.6-FE done. `looplet_core` primitives + `looplet_engine` (pure `GridState`/`applyMove` core + `GridEngine` façade + `WordValidator` port) + app adapter. 145 workspace tests green (engine 83); format/analyze green. 3 recorded impl decisions (letter storage = flat list; `restoreMoves` throws; `GridState` holds config) — none change the contract. Current Owner → QA; Next Role → QA (client-only). Uncommitted.
