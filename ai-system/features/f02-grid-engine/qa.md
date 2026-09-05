# F02 — grid-engine: QA Report

Role: QA · Date: 2026-09-05

---

## 0a. Evidence Mode Declaration

* Bash / build access: **VAR**
* e2e test suite (Playwright / Cypress / Detox): **YOK**
* Screenshot / browser tool: **YOK**
* Runtime validation method: **`automated functional`** — `melos run format:check` / `analyze` / `test` (145 workspace tests) executed by QA, plus an independent QA probe (8 assertions, created / run green / removed) hitting the trickiest contract points directly (locked rotation, row-only thaw, undo re-freeze, thaw+win, rejection matrix, determinism, `legalMoves` equivalence, config validation).

No `source-only` fallback — the suites and an independent probe were actually run. F02 is a pure-logic package with no device-runtime risk class (no sockets, navigation, persistence, multi-actor, timers, realtime).

---

## 1. Feature Summary

* **Feature tested:** F02 grid-engine — `looplet_engine` (pure `GridState`/`applyMove` core + `GridEngine` façade), `looplet_core` engine primitives (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`), the `WordValidator` port, and the app-side `DictionaryWordValidator` adapter + `wordValidatorProvider`.
* **QA scope:** client-only, package-level, automated functional. Per `architecture.md` "QA Focus" and `platform.md` §10, no device runtime is required for this feature.

---

## 2. Test Scope

* **Scope Type:** Client Only (automated functional). No `backend.md` → no backend scope. `frontend.md` present → validated via it + source + executed tests + independent probe.
* **Documents reviewed:** `prd.md`, `architecture.md`, `orchestration.md`, `frontend.md`, `role-execution-contract.md`, `system-state.md`, `project-authority/platform.md` §3/§10/§11, `project-authority/setup-manifest.md` (canonical commands).
* **Areas tested:** circular row/column shift (4 directions, wrap, 5-shift identity); locked-tile rotation (worked example, multi-locked, every position, fully-immovable no-op); frozen-tile thaw (t=0 + on-move, row-window scan length 4..n, word not through the frozen cell, multi-frozen same row, rows independent, **row-only / no column scan**, permanence, revert on undo, thaw+win same move); win detection (full L→R row, casing-insensitive, reverse/vertical no, repeated letters positional, pre-solved t=0, counter freeze + reject after win); move counting; `undo` (revert exact, `nothingToUndo`, `puzzleComplete`); `restart`; `restoreMoves` (== one-by-one replay, throws on bad move); rejection matrix (`columnMovesDisabled` / `lineFullyImmovable` / `outOfRange` / `puzzleComplete` / `nothingToUndo` — each leaves state + `moveCount` unchanged); `EngineConfig` validation (6 malformed inputs); `legalMoves` == applied-true set + empty when solved; determinism (double independent fold `==` + equal `canonicalKey`, 50×→1 key, no-RNG guard); `canonicalKey` structure (Turkish-lower letters, `§`, sorted thawed coords, `İ`≠`I`); app validator wiring.
* **Areas not tested / out of scope:**
  * `Backend Build Gate` / `Backend quality` out of scope: no backend code (no `backend.md`, no server, no Firebase in F02).
  * `Security compliance out of scope`: F02 is an internal, pure in-memory rules engine — no authentication/authorization, no access to other users' resources, no financial operations, no user-data storage/read, no admin/role separation, no external input surface (all inputs are typed Dart values from trusted callers; `EngineConfig` validation is structural, not a trust boundary). Nothing to attack.
  * `Release compliance out of scope`: `orchestration.md → Release Scope = none`; `release.md §2` sets F02 Release Scope `none` (internal library).
  * `UI handoff / UI Design compliance out of scope`: no `ui-design.md`, no screens, no route/header/back/chrome — headless engine.
  * `iOS platform compliance out of scope`: no `game-dev.md`, client stack is Flutter; F02 adds no tracking SDK / IAP / privacy-manifest surface.
  * `Game client quality` / `Game visual & feel quality` out of scope: not a game-client feature.
  * `UX/state handling out of scope` beyond §14: F02 has no UI; the "state" here is engine state, covered in §3–§5.
* **Bugfix?** No — new feature, first implementation.
* **Critical journeys (product-level):** (a) player slides rows/columns and the grid mutates deterministically, move-by-move; (b) the target forms → puzzle is solved, counter frozen; (c) a frozen tile thaws when its row spells a valid word; (d) undo/restart are trustworthy.
* **Forbidden / misuse journeys:** move after solved; undo after solved / with no history; column move when disabled; move on a fully-immovable line; out-of-range move index; malformed `EngineConfig`; a corrupt persisted move list into `restoreMoves`.
* **Navigation/header consistency:** N/A (no UI).
* **Evidence class summary:** `automated functional` (deterministic pure-Dart + flutter tests, executed) + independent QA probe.
* **Runtime validation method:** `automated functional`.

Out-of-scope conditional sections: `Mode/configuration matrix out of scope` — F02's only "modes" (`columnMovesEnabled` on/off) are covered directly in §4/§5. `Backend build gate / backend quality out of scope: no backend code.` `Security compliance out of scope: internal pure-logic engine, no trust boundary.` `Release compliance out of scope: Release Scope = none.` `UI handoff alignment / UI design compliance out of scope: headless, no ui-design.md.` `iOS platform compliance out of scope: Flutter stack, no game-dev.md.` `Integration findings out of scope: no backend↔frontend integration; app wiring verified in §4.`

---

## 3. Product Behavior Coverage

F02 is Infrastructure; `prd.md` states system requirements.

| System requirement (prd.md) | Test scenario | Evidence | Result |
| --- | --- | --- | --- |
| Single-cell circular shift as exactly one move, deterministic, countable | row/col shift in all 4 directions; wrap; 5-shift identity; `moveCount +1` per applied move | `shift_test.dart` (12), `acceptance_criteria_test.dart`; QA probe "5 forward shifts is identity" | PASS |
| Detect a win the instant the target fills a L→R row; then stop the counter and refuse further moves | row settles as target → `solvedThisStep`, `isSolved`, counter frozen, `applyMove`/`undo` → `puzzleComplete` | `win_test.dart` (8); QA probe | PASS |
| Hold a locked tile fixed while the rest of its line rotates around it | worked example `A B [C] D E → E A C B D`; locked anchors row and column; multi-locked | `locked_tile_test.dart` (8); QA probe | PASS |
| Keep a frozen tile immovable until a valid ≥4-letter L→R word forms in its row, then normal permanently | thaw at t=0 and on-move; row-only; word not through the cell; multi-frozen; permanence; **no column scan** | `frozen_tile_test.dart` (12); QA probe "ROW-ONLY" | PASS |
| Undo (revert last move + counter) and restart (to authored initial), each re-deriving thaw and solved | undo 5→4 == independent 4-move engine; `nothingToUndo`; undo re-freezes a move-5 thaw; restart from mid-game and from solved | `grid_engine_test.dart` (10), `frozen_tile_test.dart`; QA probe | PASS |
| Never use randomness; identical inputs → identical state; expose a canonical state key | double independent fold `==`; 50 folds → 1 key; no `Random`/`DateTime.now`/`Stopwatch`/`dart:io`/`Isolate.spawn` in `lib/` | `determinism_test.dart` (10), `no_rng_guard_test.dart` (1); QA probe | PASS |

No uncovered system requirement.

---

## 4. Acceptance Criteria Traceability

Every AC bullet in `prd.md` "Acceptance Criteria" → an executed test. `acceptance_criteria_test.dart` provides a 1:1 mapping (17 tests).

| AC (prd.md) | Test | Evidence | Result |
| --- | --- | --- | --- |
| row `ABCDE` right → `EABCD`, count +1 | `AC: row ... right` | `acceptance_criteria_test.dart`, `shift_test.dart` | PASS |
| row `ABCDE` left → `BCDEA` | `AC: row ... left` | same | PASS |
| column down → `EABCD`; up → `BCDEA` (top-to-bottom) | `AC: column down/up` | `acceptance_criteria_test.dart`, `shift_test.dart` | PASS |
| target formed (any casing) → solved, counter frozen, further moves rejected | `AC: target formed ...` | + `win_test.dart` "counter freezes ..." | PASS |
| reversed row / vertical column do not win | `AC: reversed / vertical` | + `win_test.dart` | PASS |
| locked at col 2 of `A B C D E`, right → `E A C B D` | `AC: locked tile ...` | + `locked_tile_test.dart` "worked example"; QA probe | PASS |
| line with ≤1 movable → `applied:false`, `lineFullyImmovable`, not counted | `AC: line with <=1 movable` | + `locked_tile_test.dart` (fully locked / single movable) | PASS |
| column move rejected when `columnMovesEnabled == false` | `AC: column move rejected ...` | + `shift_test.dart`; QA probe | PASS |
| valid ≥4-letter run in a frozen row thaws every frozen cell in that row | `AC: a valid >=4-letter run ...` | + `frozen_tile_test.dart` "two frozen tiles ... together" | PASS |
| frozen row equal to the target → thaw AND solved | `AC: frozen row that also equals the target` | + `frozen_tile_test.dart` "thaw + win"; QA probe | PASS |
| 5 moves then undo → state == after 4, count 4, move-5 thaw reverts | `AC: 5 moves then undo ...` | + `grid_engine_test.dart`, `frozen_tile_test.dart` "undo ... re-freezes"; QA probe | PASS |
| undo with no moves → `nothingToUndo`, nothing changes | `AC: undo with no moves` | + `grid_engine_test.dart` | PASS |
| restart → initial grid, count 0, thaw/solved re-derived | `AC: restart ...` | + `grid_engine_test.dart`, `win_test.dart` | PASS |
| any (config, moves) computed twice → equal `GridState` + equal `canonicalKey` | `AC: two independent folds` | + `determinism_test.dart`; QA probe (40 folds → 1 key) | PASS |
| `canonicalKey` equal on identical letters+status, differs on any change | `AC: canonicalKey equal ... differs` | + `determinism_test.dart` | PASS |
| malformed `EngineConfig` → throws | `AC: malformed EngineConfig throws` | + `engine_config_test.dart` (13); QA probe (6 inputs) | PASS |

Contract items from `architecture.md` "API / Event Contract" additionally checked in §6. No uncovered AC.

---

## 5. Boundary Matrix

F02 is a small state machine (idle → moves → solved-terminal) with thaw transitions and an undo/restart rewind.

| Boundary / transition | Result | Evidence |
| --- | --- | --- |
| t = 0 initial state (thaw + win evaluated) | PASS | `GridState.initial`; `frozen_tile_test.dart` "thaw at t=0", `win_test.dart` pre-solved |
| first applied move | PASS | `shift_test.dart`, `acceptance_criteria_test.dart` |
| move that thaws a frozen tile (mid-sequence) | PASS | `frozen_tile_test.dart` "thaws when a move forms a word" |
| move that thaws **and** wins on the same step | PASS | `frozen_tile_test.dart` "thaw + win"; QA probe |
| move into the solved terminal state | PASS | `win_test.dart` "win when a row settles ..." |
| any move after solved → `puzzleComplete`, no-op | PASS | `win_test.dart`, `acceptance_criteria_test.dart`; QA probe |
| `undo` one step (state + count exactly reverted) | PASS | `grid_engine_test.dart` "undo reverts exactly ..." |
| `undo` that reverts a thaw (tile → `frozen`) | PASS | `frozen_tile_test.dart` "undo ... re-freezes"; QA probe |
| `undo` back to zero → initial grid | PASS | `grid_engine_test.dart` "undo back to zero" |
| `undo` with empty history → `nothingToUndo` | PASS | `grid_engine_test.dart`; QA probe |
| `undo` after solved → `puzzleComplete` | PASS | `win_test.dart`; QA probe |
| `restart` from mid-game | PASS | `grid_engine_test.dart` |
| `restart` from the solved terminal state | PASS | `win_test.dart` "restart works after a win" |
| `restoreMoves` (F08 resume) == step-by-step replay | PASS | `grid_engine_test.dart` |
| `restoreMoves` with a rejected move → `StateError` | PASS | `grid_engine_test.dart` |
| line becomes fully immovable → `lineFullyImmovable` | PASS | `locked_tile_test.dart` (fully locked / single movable) |
| 5 forward shifts on an open 5-cycle → identity | PASS | `shift_test.dart`, QA probe |
| wrap-around at both ends, every direction | PASS | `shift_test.dart` (row/col, left/right/up/down) |
| `restoreMoves` / `undo` re-fold determinism (thaw history-accurate) | PASS | `determinism_test.dart` "façade == pure fold"; `frozen_tile_test.dart` |
| Phase-2 non-full-row target (`targetLength < gridSize`) | Not exercised — MVP `targetLength == gridSize == 5`. Impl scans `start in 0..size-targetLength` windows, so the code path exists; `architecture.md` "Open Technical Decisions" scopes MVP testing to 5×5. |

---

## 6. Contract Compliance Check

Reference: `architecture.md` "API / Event Contract", "Shift algorithm", "Thaw evaluation", "Win evaluation", "canonicalKey", "Error Semantics".

| Contract area | Result | Evidence |
| --- | --- | --- |
| Public API surface & signatures | **Preserved** | `EngineConfig` / `GridState` / `GridEngine` / `Move` (named ctors) / `GridStep` / `MoveRejectReason` / `WordValidator` / `NeverValidWordValidator` match the "API / Event Contract" block. `applyMove(Move, EngineConfig, WordValidator) → GridStep`; `GridEngine.applyMove(Move)` / `undo()` / `restart()`; `EngineConfig.legalMoves(GridState)`. |
| Contract-latitude deviations (frontend.md §14) | **Acceptable** | `GridState.initial` is a `factory` (contract wrote `static`) — identical call-site & behavior; `GridState` stores its `EngineConfig` so `statusAt`/`canonicalKey` need no param (contract signatures have none) — `applyMove` still takes `config`; `restoreMoves` added + throws on bad move — the "Open Technical Decisions" explicitly allow this non-breaking addition. None change observable behavior. |
| Shift algorithm (steps 1–8) | **Preserved** | Movable-position cyclic subsequence; forward `p_i ← l_{(i-1) mod k}`, backward inverse (Dart `%` non-negative); locked + unthawed-frozen are fixed points. Worked example `A B [C] D E → E A C B D` verified in `locked_tile_test.dart` + `acceptance_criteria_test.dart` + QA probe. |
| Thaw evaluation | **Preserved** | Only rows with a still-frozen cell; windows length 4..n; `validator.isValidWord(window, minLength: 4)`; all still-frozen cells in a word-forming row thaw together; monotonic; **row only** (QA probe: a `MASAL` column does not thaw `(2,2)`); evaluated at t=0 and after every applied move. |
| Win evaluation | **Preserved** | `join(run, TurkishCase.toLowerTr) == toLowerTr(targetWord)` for a `targetLength` run in a row; L→R only; repeated letters positional (`MSAAL` ≠ `MASAL`); reverse/vertical never win; evaluated at t=0 and after each applied move; win → terminal, move counted. |
| `canonicalKey` | **Preserved** | Turkish-lower letters row-major + `§` + `thawedCells` sorted by `compareTo` joined `row,col;…`; excludes locked cells / target / `columnMovesEnabled`; no `hashCode` / Set-iteration-order leakage. QA probe confirmed `§`, thawed coord, and `İ`→`i` / `I`→`ı`. |
| `GridState` value equality | **Preserved** | `==` over `_cells` + `_thawed` + `isSolved` (not `_config`); `hashCode` via `Object.hash` + `hashAll` + `hashAllUnordered`. |
| Rejection semantics | **Preserved** | Every `MoveRejectReason` returns `applied: false` + unchanged state; `GridEngine` does not append or change `moveCount`. QA probe ran all five in one engine — grid + count unchanged. |
| Error semantics | **Preserved** | `EngineConfig(...)` throws `EngineConfigError` (a subtype of `ArgumentError`) for the 6 malformed classes; rejected moves are values, not throws; `restoreMoves` throws `StateError` on a bad persisted move. |
| Determinism | **Preserved** | No RNG / clock / I/O in `looplet_engine/lib` (guard test, 5 patterns). Double independent fold → `==` + equal key; 40–50 folds → one key. |
| Dependency boundary | **Preserved** | `looplet_engine` `pubspec.yaml` = `looplet_core` + dev `test` only. `WordValidator` port; the `DictionaryService` adapter is in `app/lib/engine/`. `melos run analyze` clean. |
| `looplet_content` re-export | **Preserved** | Re-exports `MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord` from `looplet_core` per `platform.md` §11 carve-out. |
| `legalMoves` | **Preserved** | Exactly the applied-true set (exhaustively checked over all 20 candidates in `legal_moves_test.dart` + QA probe); empty when solved. |
| Contract version | v1; no breaking change (`platform.md` §11 additive carve-out for engine primitive enums). | |
| Navigation / async / lifecycle / auth / data handling | N/A — headless, no auth, no persistence (F08), no realtime. | |

---

## 9. Positive Scenarios

**Journey 1 — deterministic play toward a solve:**
Start: an authored 5×5 grid + a 5-letter target, no row equal to the target. Action: the player (F03) applies a sequence of `Move`s via `GridEngine.applyMove`; `moveCount` increments per applied move; each `GridStep` reports the settled grid. Visible result: when a row settles as the target (any casing), `GridStep.solvedThisStep` is true, `isSolved` is true, `moveCount` freezes, and the next `applyMove`/`undo` returns `puzzleComplete`. Verified: `win_test.dart` "win when a row settles ...", `acceptance_criteria_test.dart`, QA probe.

**Journey 2 — frozen-tile thaw during play:**
Start: a frozen tile in row `r`; row `r` has no valid word. Action: a move (row or column) changes row `r` so it contains a contiguous ≥4-letter run that the dictionary accepts. Visible result: `GridStep.thawedThisStep` is true; every frozen tile in row `r` becomes `thawed` and stays movable for the rest of the session. Verified: `frozen_tile_test.dart` "thaws when a move forms a word in the frozen row", QA probe; column-word does **not** thaw (row-only).

**Journey 3 — undo / restart trust:**
Start: 5 applied moves, the 5th of which thawed a tile. Action: `undo()`. Visible result: state equals an independently-built 4-move engine, `moveCount` is 4, and the tile that thawed on move 5 is `frozen` again. `restart()` from any point (incl. solved) returns the exact authored initial grid, `moveCount` 0. Verified: `grid_engine_test.dart`, `frozen_tile_test.dart`, `acceptance_criteria_test.dart`, QA probe.

**Journey 4 — app wiring:**
`wordValidatorProvider` resolves to a `WordValidator` delegating to the shipped Turkish dictionary; a `GridEngine` built with it thaws a frozen tile on the real word `MASAL`. Verified: `app/test/engine_wiring_test.dart` (executed green).

---

## 10. Negative / Edge Cases

| Case | Expected | Observed | Evidence |
| --- | --- | --- | --- |
| move after solved | `puzzleComplete`, no-op | as expected | `win_test.dart`, QA probe |
| `undo` after solved | `puzzleComplete`, no-op | as expected | `win_test.dart`, QA probe |
| `undo` with no history | `nothingToUndo`, no-op | as expected | `grid_engine_test.dart`, QA probe |
| column move with `columnMovesEnabled == false` | `columnMovesDisabled`, no-op | as expected | `shift_test.dart`, QA probe |
| move on a fully-locked / single-movable line | `lineFullyImmovable`, no-op, **not counted** | as expected | `locked_tile_test.dart`, `acceptance_criteria_test.dart`, QA probe |
| move `index` 5 / −1 / 99 | `outOfRange`, no-op | as expected | `shift_test.dart`, QA probe |
| `EngineConfig`: non-square / empty / multi-char cell / empty cell / non-letter cell / target length ≠ width / non-letter target / coord out of range (high + negative) / locked∩frozen | `EngineConfigError` (an `ArgumentError`) | all throw | `engine_config_test.dart` (13), QA probe (6) |
| `restoreMoves` with a move that would be rejected | `StateError` | as expected | `grid_engine_test.dart` |
| valid word down a frozen tile's **column** (row has none) | tile stays `frozen` | as expected | `frozen_tile_test.dart` "column never scanned", QA probe |
| reversed row / vertical target / scrambled repeated letters | not a win | as expected | `win_test.dart` |
| 5 forward shifts on an open 5-cycle | identity (grid unchanged, count 5) | as expected | `shift_test.dart`, QA probe |
| mutating `state.letters` / `state.thawedCells` / `appliedMoves` / `config.lockedCells` / `config.initialGrid` | `UnsupportedError` | as expected | `grid_engine_test.dart`, `engine_config_test.dart` |

No misuse path threw an unexpected exception, mutated engine state, or produced a wrong `true`.

---

## 14. Frontend Quality

Client-touching scope (pure-Dart packages + minimal app wiring; no UI).

* **Code quality:** `melos run analyze` clean across all 6 packages + `flutter analyze` clean; `melos run format:check` clean. No stubs / TODOs / hardcoded values in the F02 surface. `looplet_engine` placeholder removed.
* **Design:** clean two-layer separation — the pure `GridState`/`applyMove` core (used by the F06 solver) and a thin `GridEngine` façade (history + `undo`/`restart`/`restoreMoves`). `fold(_initialState, _moves)` is the single definition of current state, so forward play and undo cannot diverge (verified: `determinism_test.dart` "façade == pure fold"). Rejections are values, not exceptions. The `WordValidator` port keeps `looplet_engine` free of a `looplet_dictionary` dependency.
* **State management:** `GridState` fully immutable (flat row-major `List<String>.unmodifiable` + `Set<GridCoord>.unmodifiable`); `letters` getter materializes a nested unmodifiable view on demand. App: `wordValidatorProvider` session-level `FutureProvider`.
* **Performance:** letter storage = flat row-major `List<String>` (documented decision, `frontend.md` §13). Micro-benchmark ≈ 208k `applyMove` + `canonicalKey` ops/sec in JIT (unoptimized) — comfortably supports F06's 5×5 search; F06 does its own quantitative validation. One `List.of` copy per `applyMove`, no other per-step allocation beyond the movable-index/letter lists and the result `GridState`.
* **Non-blocking code observation (§20):** `GridState.applyMove` reads the locked/frozen classification from the instance's stored `_config` (via `statusAt`/`isMovable`) but reads `columnMovesEnabled` / `gridSize` / `targetWord` / `frozenCells` (thaw/win) from the **passed** `config` parameter. Every current caller (`GridEngine`, the pure fold, F06's intended use) passes the same instance, so there is no observable defect. It is a latent fragility worth tidying to a single source on a future touch.
* Runtime evidence summary: `automated functional` — 145 workspace tests + 8-assertion independent QA probe, all green.

---

## 16. Regression Risk

* **Shared components touched:** `looplet_core` (new: `grid_primitives.dart`; barrel export); `looplet_content` (barrel re-export only — its placeholder + smoke test unchanged); `looplet_engine` (new package body); `app/lib/engine/*` (new); `app/pubspec.yaml` (no change — `looplet_engine` path dep was already present from scaffold).
* **F01 impact:** none — `looplet_core`'s F01 symbols (`TurkishCase`, `normalizeTurkish`, `normalizeLatin`) and their tests are untouched (22 core tests green, includes the 18 F01 + 4 primitive tests... 18 F01-era + `grid_primitives_test` 5 → note count). `looplet_dictionary` untouched (32 tests green).
* **Downstream dependents today:** none consume `looplet_engine` yet except the new app wiring. F03 (play session), F04 (reads `isSolved`/`moveCount`), F06 (`GridState`/`canonicalKey`/`legalMoves`), F08 (`EngineConfig` + `appliedMoves` + `restoreMoves`) will build on the contract verified here.
* **`platform.md` §11 carve-out:** additive (engine primitive enums now in `looplet_core`, re-exported by `looplet_content`); no existing consumer of `looplet_content` enums exists yet.
* **`melos run build:app` (Android):** not run locally — no Android SDK on this machine (`flutter doctor`). Not an F02 defect; the workspace compiles (`flutter analyze` + `flutter test` green). CI runs the Android bundle build.
* **Conclusion:** regression risk minimal — new packages, no current importers beyond the new app wiring, all workspace gates green.

---

## 17. Final Verdict

**Approved with Notes**

* No blocking issues. No required fixes.
* Every `prd.md` system requirement and every Acceptance Criterion is covered by an executed automated test (`acceptance_criteria_test.dart` maps them 1:1); independently re-verified by an 8-assertion QA probe against the real engine.
* The full contract (`architecture.md` shift algorithm, thaw/win evaluation, `canonicalKey`, error semantics, determinism guard, dependency boundary) is honored. The three `frontend.md` §14 impl decisions fall within `architecture.md` "Open Technical Decisions" latitude and do not change observable behavior.
* Non-blocking notes for Tech Lead (§20): (1) `applyMove` reads engine config from two sources (`_config` for movability, the passed `config` for the rest) — harmless today (callers pass the matching instance), worth tidying on a future touch; (2) Android `melos run build:app` is CI-only on this environment; (3) MVP-only 5×5 test coverage — the non-full-row-target code path exists but is unexercised (as `architecture.md` scopes it).
* Evidence class `automated functional` is explicitly accepted for this pure-logic feature by `architecture.md` "QA Focus" and `platform.md` §10 — no device-runtime risk class applies.

---

# WORKFLOW VERDICT SUGGESTION (NON-AUTHORITATIVE)

## QA Result

* Approved with Notes — F02 grid-engine passes contract + product-behavior + AC + boundary coverage; 145 workspace tests + QA probe green; `format:check` / `analyze` / `test` green.

## Affected Areas

* None requiring rework. One code-cleanliness note (Frontend, non-blocking) + one CI confirmation (DevOps/CI, non-blocking).

## Blocking Issues

* None.

## Non-Blocking Notes

1. `GridState.applyMove` should read all `EngineConfig` fields from one source (prefer the stored `_config`, or drop the stored one and always use the parameter) — latent fragility, no current defect.
2. Confirm CI's Android `melos run build:app` job is green (not runnable locally — no Android SDK).
3. Non-full-row target (`targetLength < gridSize`) is a Phase-2 path; code exists, untested by design for the MVP.

## Suggested Fix Order

Not applicable (Approved with Notes — no blocking fixes). Tech Lead: sync global state (`feature-board.md`, `system-state.md`), optionally fold note 1 into a follow-up, then activate the next feature.

---

## 19. Sonraki Komut

```
Run Tech Lead
```

---

## 20. Tech Lead Note

<<<TEXT

F02 grid-engine — QA verdict: Approved with Notes. No rework; the engine is contract-compliant and fully covered by executed automated tests + an independent QA probe.

Tech Lead actions:
1. Sync global state — set F02 `Done` (Release Scope = none, so no release gate) in `feature-board.md` and `system-state.md`; clear `Current Owner`; terminal-cleanup `features/f02-grid-engine/orchestration.md` (Status = Done, Owner = -, Active Task Ledger = None, Next Action = Closed).
2. Non-blocking follow-up (Frontend, optional): `GridState.applyMove` reads locked/frozen classification from the stored `_config` but reads `columnMovesEnabled` / `gridSize` / `targetWord` / `frozenCells` from the passed `config` parameter. Every real caller passes the same instance, so there is no defect today — but it is a latent fragility. Recommend a one-line tidy (use `_config` consistently, or remove the stored field and always thread the parameter) the next time `looplet_engine` is touched (likely F06). Not worth reopening F02 for.
3. Informational: `melos run build:app` (Android App Bundle) was not runnable on the dev machine (no Android SDK). `flutter analyze`, `flutter test`, and (after F01) `flutter build ios --release --no-codesign` all passed locally. Ensure the Android job in `.github/workflows/ci.yml` is green.
4. Contract-scope note: `architecture.md` "Open Technical Decisions" scoped MVP testing to 5×5; the non-full-row-target win path (`targetLength < gridSize`) exists in code but is intentionally unexercised until Phase 2.

No Product/PO escalation required — no `prd.md` / `architecture.md` rule was found meaningless or harmful in real-world use.

TEXT
