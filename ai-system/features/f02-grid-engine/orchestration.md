# F02 — grid-engine: Orchestration

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

Frontend Development (contract locked; implement `looplet_engine` pure core + façade)

---

## Active Task Ledger

- [ ] Task ID: F02.0-CORE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Add engine primitive value types to `looplet_core` — `MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord` (value equality + `hashCode` + row-major `compareTo`) — with unit tests. Export from the barrel.
- [ ] Task ID: F02.1-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `EngineConfig` (fields + constructor validation + `EngineConfigError extends ArgumentError`) and `EngineConfig.legalMoves(GridState)`. Written for a square `gridSize` from config, not hard-coded 5.
- [ ] Task ID: F02.2-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Pure `GridState` — `initial(config, validator)` (thaw + win evaluated at t=0), `letters`/`thawedCells`/`isSolved` (unmodifiable views), `statusAt`/`isMovable`, and `applyMove(move, config, validator) -> GridStep` implementing the full CONTRACT shift algorithm (steps 1–8), thaw evaluation (row-only, len-4 + len-5 windows, all-frozen-in-row thaw together, monotonic), and win evaluation (`anyRowEqualsTarget`, L→R only, Turkish-normalized, repeated letters).
- [ ] Task ID: F02.3-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `GridState.canonicalKey()` exactly per contract (Turkish-lower row-major letters + `§` + sorted thawed coords; excludes locked/target/columnMovesEnabled; no `hashCode`/iteration-order leakage). `GridState` value `==`/`hashCode` (letters + thawedCells + isSolved). `GridStep` type.
- [ ] Task ID: F02.4-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `GridEngine` façade — `config`/`state`/`moveCount`/`isSolved`/`appliedMoves`; `applyMove` (delegates to `state.applyMove`, appends to history iff `applied`); `undo` (removes last move, re-folds from `initialState`, `nothingToUndo`/`puzzleComplete` rejects); `restart` (clears history). Optional `restoreMoves(List<Move>)` batch for F08 if per-move replay is awkward (must equal one-by-one replay).
- [ ] Task ID: F02.5-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: `WordValidator` port + `NeverValidWordValidator` in `looplet_engine`. App-side `DictionaryWordValidator implements WordValidator` adapting F01 `DictionaryService` (`app/lib/`), plus a Riverpod provider that builds it from `dictionaryServiceProvider`. No engine→`looplet_dictionary` dependency. No game screen (F03).
- [ ] Task ID: F02.6-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Test suite — every `prd.md` AC; shift table (4 dirs ± wrap, rows+cols, 5-shift identity); locked rotation (worked example, 2 locked/line, each position, fully-immovable → not counted); frozen thaw (len-4/len-5 window, word not through frozen cell, multi-frozen same row, different rows independent, t=0 pre-worded, NO column scan, permanence, revert on undo); win/no-win (full-row any casing, `LASAM` no, column no, `MASAL` repeats, win+thaw same move, pre-solved t=0); move counting; undo/restart; rejection matrix (`columnMovesDisabled`/`outOfRange`/`lineFullyImmovable`/`puzzleComplete`/`nothingToUndo` each leaves state+count unchanged); `EngineConfig` validation throws; `legalMoves` == applied-true set; determinism (double-fold `==` + equal `canonicalKey`; differs on any change); no-RNG guard test (no `Random`/`DateTime.now`/`dart:io` in `looplet_engine`). Produce `frontend.md` with task-to-code traceability, the letter-storage decision + a states/sec micro-benchmark note, per-AC evidence.

---

## QA Scope

* client-only (package-level, automated `dart test`; no device runtime required — see `architecture.md` QA Focus and `platform.md` §10)

---

## Release Scope

* none

---

## Open Tasks

### Frontend
- [ ] (F02.0-CORE) `looplet_core` primitive value types (see ledger).
- [ ] (F02.1-FE) `EngineConfig` + validation + `legalMoves`.
- [ ] (F02.2-FE) Pure `GridState` + `applyMove` (shift algorithm, thaw eval, win eval) + `GridStep`.
- [ ] (F02.3-FE) `canonicalKey` + value equality.
- [ ] (F02.4-FE) `GridEngine` façade (undo re-fold, restart, moveCount).
- [ ] (F02.5-FE) `WordValidator` port + app-side `DictionaryWordValidator` adapter + provider.
- [ ] (F02.6-FE) Full test suite + `frontend.md`.

### QA
- [ ] (F02.1-QA) AC + contract verification: every `prd.md` AC → a passing test; public API matches `architecture.md` "API / Event Contract" verbatim; shift table + locked-rotation + win/no-win matrices covered.
- [ ] (F02.2-QA) Frozen-tile behavior: thaw timing (settled-only + t=0), row-window scan (len 4/5, word not through frozen cell), multi-frozen same row thaw together, different rows independent, **row-only (no column scan)**, permanence across moves, revert-on-undo of the causing move, thaw+win same move.
- [ ] (F02.3-QA) Determinism + rejections + validation: double independent fold `==` and equal `canonicalKey`; `canonicalKey` differs on any letter/thawed change; no-RNG guard test present and green; every rejection reason leaves state + `moveCount` unchanged; each malformed `EngineConfig` throws `EngineConfigError`; `legalMoves` matches the applied-true set and is empty when solved.
- [ ] (F02.4-QA) Evidence class + CI: confirm `automated functional` is sufficient (`architecture.md` QA Focus + `platform.md` §10); confirm CI runs the new suites; run `melos run format:check && melos run analyze && melos run test`. Emit verdict → Tech Lead.

---

## Blockers

* None.
* Dependency note: F01 dictionary-service is **Done** (2026-09-05). F02 consumes word validation via the injected `WordValidator` port, so it does not import `looplet_dictionary`; the app supplies a `DictionaryService` adapter (F02.5-FE).

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
* Summary: F02 grid-engine activated. Created `prd.md` (derived, execution-ready) + `architecture.md` (full contract — two-layer engine, shift/locked/frozen/win semantics all locked, `canonicalKey` spec, determinism guard, `WordValidator` port) + this orchestration. Complexity COMPLEX but no Analyst / no UI Designer (justified). Routed straight to Frontend/Mobile Developer: F02.0-CORE → F02.1-FE … F02.6-FE → QA (client-only) → Tech Lead. `platform.md` §11 amended for the engine-primitive-enum carve-out. `feature-board.md` + `system-state.md` synced same turn (F01 Done, F02 active).

---

## Next Role

Frontend/Mobile Developer

---

## Next Action

### Frontend/Mobile Developer

```text
Implement F02 grid-engine. Authority: features/f02-grid-engine/architecture.md (contract — follow the shift
algorithm steps 1–8, thaw evaluation, win evaluation, and canonicalKey spec verbatim); features/f02-grid-engine/prd.md
(Acceptance Criteria + Edge Cases); project-authority/platform.md §11 (Turkish HARD RULE, no runtime RNG).

Order:
1. F02.0-CORE — add MoveAxis, MoveDirection, TileStatus, GridCoord to looplet_core (value equality + hashCode +
   row-major compareTo); export from lib/looplet_core.dart; table tests. Then update looplet_content's barrel to
   re-export them (keep looplet_content's own placeholder otherwise — F02 does not implement the Puzzle model).
2. F02.1-FE — EngineConfig + constructor validation (dims, single-grapheme non-empty cells, targetWord.length ==
   gridSize + letters-only, coords in range, lockedCells ∩ frozenCells == ∅) throwing EngineConfigError; legalMoves.
3. F02.2-FE — pure GridState.initial + applyMove. Implement the shift algorithm EXACTLY as architecture.md steps 1–8
   (movable-position cyclic subsequence; forward = right/down = new p_i gets l_{(i-1) mod k}; backward = inverse).
   Thaw: row-only, windows [0..3],[1..4],[0..4], validator.isValidWord(window, minLength: 4), all frozen-unthawed
   cells in the row thaw together, monotonic. Win: join(row, TurkishCase.toLowerTr) == toLowerTr(targetWord), any row,
   L→R only. Evaluate thaw then win, at t=0 and after every applied move. GridStep with applied/rejectedReason/state/
   thawedThisStep/solvedThisStep.
4. F02.3-FE — canonicalKey + GridState value ==/hashCode.
5. F02.4-FE — GridEngine façade: applyMove appends only when applied; undo removes last move and recomputes
   state = fold(initialState, remainingMoves); restart clears history. Add restoreMoves(List<Move>) only if needed
   for F08 (must equal one-by-one replay).
6. F02.5-FE — WordValidator + NeverValidWordValidator in looplet_engine; DictionaryWordValidator (app/lib/) adapting
   F01 DictionaryService + a Riverpod provider. Do NOT add looplet_dictionary to looplet_engine's pubspec.
7. F02.6-FE — the full test matrix in the ledger; a guard test asserting looplet_engine source has no Random /
   DateTime.now / dart:io. frontend.md: task-to-code traceability, letter-storage decision + states/sec micro-benchmark,
   per-AC evidence.

Verify from repo root: melos run format:check && melos run analyze && melos run test
On completion set Next Role = QA (client-only) per architecture.md QA Focus.
```

---

## Change Log

* v1 (2026-09-05) — Tech Lead: F02 grid-engine created and activated. `prd.md` + `architecture.md` (full contract) + orchestration. Complexity COMPLEX; no Analyst / no UI Designer (justified). Routing: Frontend/Mobile Developer (F02.0-CORE → F02.6-FE) → QA → Tech Lead. `platform.md` §11 amended for the engine-primitive-enum carve-out.
