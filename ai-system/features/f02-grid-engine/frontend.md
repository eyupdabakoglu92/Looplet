# F02 — grid-engine: Frontend Delivery Report

Role: Frontend/Mobile Developer · Date: 2026-09-05 · Mode: Direct-edit

---

## 1. Feature Summary

Implemented `looplet_engine` — the deterministic, headless 5×5 rules engine —
in two layers exactly per `architecture.md`:

* **pure core** — `GridState` + `GridState.applyMove(move, config, validator)`
  with no side effects, `GridState.canonicalKey()` for the F06 solver;
* **stateful façade** — `GridEngine` with applied-move history, `undo` (re-fold
  from t = 0), `restart`, `restoreMoves` (F08).

Added the engine primitive value types to `looplet_core` (F02.0-CORE), the
`WordValidator` port (so `looplet_engine` never imports `looplet_dictionary`),
and the app-side `DictionaryWordValidator` adapter + provider.

All F02 tasks (F02.0-CORE, F02.1-FE … F02.6-FE) complete. Gates green:
`melos run format:check`, `melos run analyze` (6 packages + `flutter analyze`),
`melos run test` (**145 tests**: core 22, dictionary 32, engine 83, scaffold 3,
app 4).

---

## 2. Impacted Files

**Created**

* `packages/looplet_core/lib/src/grid_primitives.dart` — `MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord`
* `packages/looplet_core/test/grid_primitives_test.dart`
* `packages/looplet_engine/lib/src/move.dart` — `Move` (named constructors, `axisDirectionMatches`, `isForward`)
* `packages/looplet_engine/lib/src/word_validator.dart` — `WordValidator`, `NeverValidWordValidator`
* `packages/looplet_engine/lib/src/grid_state.dart` — `MoveRejectReason`, `GridStep`, `GridState`
* `packages/looplet_engine/lib/src/engine_config.dart` — `EngineConfig`, `EngineConfigError`
* `packages/looplet_engine/lib/src/grid_engine.dart` — `GridEngine`
* `packages/looplet_engine/test/{support/helpers,shift,locked_tile,frozen_tile,win,grid_engine,determinism,legal_moves,engine_config,no_rng_guard,acceptance_criteria}_test.dart`
* `app/lib/engine/dictionary_word_validator.dart`, `app/lib/engine/engine_providers.dart`
* `app/test/engine_wiring_test.dart`

**Updated**

* `packages/looplet_core/lib/looplet_core.dart` — export `grid_primitives.dart`
* `packages/looplet_content/lib/looplet_content.dart` — re-export the four primitives from `looplet_core`
* `packages/looplet_engine/lib/looplet_engine.dart` — real barrel (placeholder removed)

**Removed**

* `packages/looplet_engine/lib/src/placeholder.dart`, `packages/looplet_engine/test/looplet_engine_test.dart`

---

## 3. Task-to-Code Traceability

* **F02.0-CORE** — Complete. `looplet_core/lib/src/grid_primitives.dart`: `MoveAxis`, `MoveDirection`, `TileStatus` enums; `GridCoord` with value `==` / `hashCode` / row-major `compareTo`. Barrel exports them; `looplet_content` re-exports (`show MoveAxis, MoveDirection, TileStatus, GridCoord`). `grid_primitives_test.dart` (5).
* **F02.1-FE** — Complete. `engine_config.dart`: `EngineConfig` factory + private ctor; `_validate` throws `EngineConfigError` (a subtype of `ArgumentError`) for empty/non-square grid, multi-grapheme/empty/non-letter cell (`\p{L}`), `targetWord.runes.length != gridSize` or non-letter target, out-of-range coord, `lockedCells ∩ frozenCells`. `initialGrid` deep-copied to unmodifiable; `lockedCells`/`frozenCells` unmodifiable. `legalMoves(GridState)` → exactly the moves that would `apply` (empty when solved; excludes disabled columns and fully-immovable lines). Written for a square `gridSize` from the config, not hard-coded 5.
* **F02.2-FE** — Complete. `grid_state.dart`: `GridState.initial` evaluates thaw then win at t = 0. `applyMove` implements `architecture.md` "Shift algorithm" steps 1–8: reject `puzzleComplete` / `columnMovesDisabled` / `outOfRange` (incl. `!move.axisDirectionMatches`); collect line coords in position order; partition movable (`normal`/`thawed`) vs fixed (`locked`/`frozen`); reject `lineFullyImmovable` when ≤ 1 movable; rotate the movable-position subsequence — forward (`right`/`down`) sets movable position `i` from letter `(i-1) mod k`, backward from `(i+1) mod k` (Dart `%` is non-negative); fixed cells untouched; then `_evaluateThaw` then `_evaluateWin`; return `GridStep(applied, state, thawedThisStep, solvedThisStep)`. `_evaluateThaw`: only rows with a still-frozen cell, windows length 4..n, `validator.isValidWord(window, minLength: 4)`, all still-frozen cells in a word-forming row thaw together, monotonic (`result ??= {...current}`), row-only (never scans the column). `_evaluateWin`: `join(run, TurkishCase.toLowerTr) == toLowerTr(targetWord)` for a `targetLength` run in some row, left-to-right only (for MVP `targetLength == gridSize` → full-row match).
* **F02.3-FE** — Complete. `GridState.canonicalKey()`: `TurkishCase.toLowerTr` of every cell row-major, then `§`, then `thawedCells` sorted by `compareTo` joined `row,col;…`. Excludes locked cells / target / `columnMovesEnabled`. No `hashCode` or `Set`-iteration-order leakage. `GridState` value `==` (`_cells` + `_thawed` + `isSolved`, **not** `_config`) and `hashCode` (`Object.hash` + `hashAll` + `hashAllUnordered`).
* **F02.4-FE** — Complete. `grid_engine.dart`: `GridEngine(config, {validator})` builds `_initialState` once. `applyMove` delegates to `state.applyMove`, appends to `_moves` and advances `_state` only when `applied`. `undo` → `puzzleComplete` if solved, `nothingToUndo` if empty, else `removeLast` + `_fold(_moves)` from `_initialState`. `restart` → clear + reuse `_initialState`. `restoreMoves(List<Move>)` folds and throws `StateError` if any move is rejected (F08 fallback); produces the same state as one-by-one replay. `appliedMoves` unmodifiable.
* **F02.5-FE** — Complete. `word_validator.dart`: `WordValidator` port + `NeverValidWordValidator`. `app/lib/engine/dictionary_word_validator.dart`: `DictionaryWordValidator implements WordValidator` delegating to F01 `DictionaryService.isValidWord`. `app/lib/engine/engine_providers.dart`: `wordValidatorProvider` (`FutureProvider<WordValidator>`) built from `dictionaryServiceProvider`. `looplet_engine/pubspec.yaml` unchanged — still `looplet_core` only.
* **F02.6-FE** — Complete. 83 engine tests across 11 files (see §17) + `acceptance_criteria_test.dart` mirroring every `prd.md` AC 1:1 + `no_rng_guard_test.dart` scanning `lib/` for `Random(` / `DateTime.now` / `Stopwatch(` / `import 'dart:io'` / `Isolate.spawn`. `frontend.md` (this file).

---

## 5. Components

| Type | Package | Responsibility |
| --- | --- | --- |
| `MoveAxis` / `MoveDirection` / `TileStatus` / `GridCoord` | `looplet_core` | engine primitive value types (re-exported by `looplet_content`) |
| `Move` | `looplet_engine` | one row/column single-cell shift; named constructors keep axis+direction valid |
| `WordValidator` / `NeverValidWordValidator` | `looplet_engine` | port for frozen-tile word checks (no `looplet_dictionary` dependency) |
| `EngineConfig` / `EngineConfigError` | `looplet_engine` | immutable static puzzle data + validation + `legalMoves` |
| `MoveRejectReason` / `GridStep` | `looplet_engine` | rejection reasons as values; step result |
| `GridState` | `looplet_engine` | immutable snapshot; pure `applyMove`; `canonicalKey`; value equality |
| `GridEngine` | `looplet_engine` | stateful play-session façade; history, `undo`, `restart`, `restoreMoves` |
| `DictionaryWordValidator` | `app` | adapts F01 `DictionaryService` → `WordValidator` |

---

## 7. State Management

* `GridEngine` holds `_initialState` + `List<Move> _moves` (applied moves only); `_state` = `fold(_initialState, _moves)`. `moveCount == _moves.length`. There is no separately-mutated live grid — `undo` and forward play cannot diverge because both go through the same `fold`.
* `GridState` is fully immutable; `_cells` (`List<String>.unmodifiable`, row-major flat) and `_thawed` (`Set<GridCoord>.unmodifiable`); `letters` getter materializes a nested unmodifiable view on demand.
* App: `wordValidatorProvider` is session-level (`FutureProvider`), resolves once the dictionary is ready. No game screen yet (F03).

---

## 9. Contract Compliance Check

* **Public API surface** — Preserved. `EngineConfig` / `GridState` / `GridEngine` / `Move` / `GridStep` / `MoveRejectReason` / `WordValidator` match `architecture.md` "API / Event Contract". Signatures: `GridState.initial(config, validator)` (implemented as a `factory`), `applyMove(Move, EngineConfig, WordValidator) -> GridStep`, `GridEngine.applyMove(Move)` / `undo()` / `restart()` / `restoreMoves`, `EngineConfig.legalMoves(GridState)`.
* **Shift algorithm** — Preserved. Movable-subsequence cyclic rotation around locked/unthawed-frozen fixed points; forward/backward exactly per contract; worked example `A B [C] D E → E A C B D` verified (`locked_tile_test.dart`, `acceptance_criteria_test.dart`).
* **Frozen thaw** — Preserved. Row-only; windows length 4..n; word need not pass through the frozen cell; all still-frozen cells in a word-forming row thaw together; frozen rows evaluated independently; **column never scanned** (dedicated test); monotonic forward; re-derived on `undo`/`restart`; evaluated at t = 0.
* **Win** — Preserved. Full L→R row equals target (Turkish-normalized), repeated letters positional, reverse/vertical do not win, evaluated at t = 0 and after every applied move; on win the counter freezes and `applyMove` / `undo` are rejected `puzzleComplete`.
* **Determinism** — Preserved. No `Random` / `DateTime` / `Stopwatch` / `dart:io` / `Isolate` in `looplet_engine/lib` (guard test). `canonicalKey` uses the explicit Turkish map, `compareTo`-sorted thawed coords, no hashcode leakage. Double independent fold → `==` + equal key (50× → one key).
* **Rejections** — Preserved. Every `MoveRejectReason` returns `applied: false` with the unchanged state; `GridEngine` does not append or change `moveCount`.
* **`canonicalKey` scope** — Preserved. Excludes locked cells / target / `columnMovesEnabled`; includes normalized letters + thawed set.
* **Dependency boundary** — Preserved. `looplet_engine` → `looplet_core` only; `WordValidator` port; the `DictionaryService` adapter lives in `app/`.
* **`looplet_content` re-export** — Preserved. Re-exports the four primitives per `platform.md` §11 carve-out.
* **Navigation / async / lifecycle** — Not Applicable (headless).

---

## 12. Implemented Files

| File | Change | Notes |
| --- | --- | --- |
| `looplet_core/lib/src/grid_primitives.dart` | new | 3 enums + `GridCoord` (Comparable) |
| `looplet_engine/lib/src/move.dart` | new | `Move.rowLeft/rowRight/columnUp/columnDown`; `isForward`; `axisDirectionMatches` |
| `looplet_engine/lib/src/word_validator.dart` | new | port + `NeverValidWordValidator` |
| `looplet_engine/lib/src/engine_config.dart` | new | factory + `_validate` (throws `EngineConfigError`); `legalMoves`; `_movableCount` |
| `looplet_engine/lib/src/grid_state.dart` | new | flat row-major `List<String>` storage; `applyMove`; `_evaluateThaw`; `_rowHasValidWord`; `_evaluateWin`; `canonicalKey`; value equality |
| `looplet_engine/lib/src/grid_engine.dart` | new | façade; `_fold` (throws on rejected move); `restoreMoves` |
| `app/lib/engine/dictionary_word_validator.dart` | new | F01 adapter |
| `app/lib/engine/engine_providers.dart` | new | `wordValidatorProvider` |
| `looplet_content/lib/looplet_content.dart` | updated | re-export primitives |

---

## 13. Performance Notes

* **Letter storage decision (Open Technical Decision, F02.2-FE):** `GridState` stores letters as a **flat `List<String>` of length `gridSize²`, row-major**, immutable. Rationale: `applyMove` copies the grid every step (F06's hot path); a flat-list copy + `row*size+col` indexing is cheaper than nested lists, and the contract `letters` getter (rare, F03 render only) materializes a nested unmodifiable view on demand.
* **Micro-benchmark** (`dart run`, JIT, unoptimized; M-series Mac): `GridState.applyMove` + `canonicalKey()` ≈ **208,000 ops/sec** (2M iterations in ~9.6 s, with a fresh `GridState.initial` every 30 steps). AOT will be materially faster. `canonicalKey` (a ~30-char `StringBuffer`) dominates; the solver can dedupe on the key. This comfortably supports F06's 5×5 state-space search; F06 does its own quantitative validation per `architecture.md`.
* No allocation in `applyMove` beyond one `List<String>.of` copy, the movable-index list, the movable-letter list, and the result `GridState`.

---

## 14. Assumptions

* `EngineConfig` cell validation uses `RegExp(r'^\p{L}$', unicode: true)` — any Unicode letter, single grapheme (`runes.length == 1`). It does not restrict to the Turkish alphabet (the dictionary does that for words; grid letters are authored by F06).
* `restoreMoves` throws `StateError` on a rejected persisted move (rather than silently skipping) so F08 can detect corruption and fall back to a clean start. Added as the `architecture.md` "Open Technical Decisions" allowed non-breaking addition.
* `GridState` carries a reference to its `EngineConfig` so `statusAt` / `isMovable` / `canonicalKey` work with no extra parameter (the contract signatures have none). `applyMove` still takes `config` per the contract; callers pass the same instance.
* `GridState.initial` is implemented as a `factory` constructor (contract wrote it as `static GridState.initial(...)`); call site is identical.

---

## 16. Needs Tech Lead Clarification

None. The `architecture.md` "Open Technical Decisions" left the letter-storage representation, the `restoreMoves` batch API, and `gridSize` generality to implementation — all three are decided and recorded above; none change the contract.

---

## 17. Test Evidence by Task

| Task / behavior | Type | File · count | Scenario proven |
| --- | --- | --- | --- |
| F02.0-CORE | unit | `grid_primitives_test.dart` · 5 | `GridCoord` `==`/`hashCode`/row-major sort/Set-key dedup; enum value lists |
| F02.1-FE — config validation | unit | `engine_config_test.dart` · 13 | well-formed 5×5; non-square; empty; multi-char / empty / non-letter cell; target length ≠ width; non-letter target; coord out of range (high + negative); locked∩frozen; `EngineConfigError is ArgumentError`; exposed collections unmodifiable |
| F02.1-FE — `legalMoves` | unit | `legal_moves_test.dart` · 5 | open grid → 20; columns disabled → 10 rows-only; fully-immovable line drops its 2 moves; empty when solved; **`legal.contains(move) == applyMove(...).applied` for all 20 moves** |
| F02.2-FE — shift table | unit | `shift_test.dart` · 12 | row right/left wrap; only targeted row/col; 5-shift identity; left∘right = no-op; column down/up wrap; columnMovesDisabled; outOfRange (index high/low) |
| F02.2-FE — locked rotation | unit | `locked_tile_test.dart` · 8 | worked example `EACBD`; left = inverse of right; locked letter preserved at every column; 2 locked → `EACDB`; fully locked → `lineFullyImmovable` not counted; single movable → immovable; exactly-2 movable → swap counted; locked anchors its column |
| F02.2-FE — frozen thaw | unit | `frozen_tile_test.dart` · 12 | thaw at t = 0; word not through frozen cell (4-window); 2 frozen same row together; different rows independent; **no column scan**; thaw on a later move (no win); thaw + win same move; thaw permanent after breaking the word; **undo of the causing move re-freezes**; frozen tile immovable until it thaws |
| F02.2-FE — win / no-win | unit | `win_test.dart` · 8 | win on settle; casing-insensitive (`masal` row); reversed `LASAM` no; vertical column no; repeated letters positional (`MSAAL` ≠ `MASAL`); counter frozen + moves/undo rejected after win; restart after win |
| F02.4-FE — façade | unit | `grid_engine_test.dart` · 10 | count only on applied; undo 5→4 == independent 4-move engine; `nothingToUndo`; undo to zero == initial; restart; `appliedMoves` unmodifiable; `restoreMoves` == one-by-one replay; `restoreMoves` throws on bad move; state views unmodifiable |
| F02.3-FE — determinism / canonicalKey | unit | `determinism_test.dart` · 10 | double fold `==` + equal key + equal hashCode; façade == pure fold; key equal on identical state, differs on one-less move; key reflects thawed set (`§2,2`); Turkish-lower (`İ`→`i`, `I`→`ı`); stable across calls; 50 folds → one key |
| F02.6-FE — no-RNG guard | unit | `no_rng_guard_test.dart` · 1 | `looplet_engine/lib` has no `Random(` / `DateTime.now` / `Stopwatch(` / `import 'dart:io'` / `Isolate.spawn` (comments stripped) |
| F02 — AC traceability | unit | `acceptance_criteria_test.dart` · 17 | one test per `prd.md` Acceptance Criterion bullet |
| F02.5-FE — app wiring | flutter test | `app/test/engine_wiring_test.dart` · 2 | `wordValidatorProvider` resolves to a `WordValidator` delegating to the shipped dictionary (`MASAL` true, `zzzz` false); a `GridEngine` built with the real validator thaws a frozen tile on the real word `MASAL` |

Totals: **145** workspace tests green. `melos run format:check`, `melos run analyze` (6 packages + `flutter analyze`) green. `melos run build:app` (Android) is CI-only locally (no Android SDK).

---

## WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* Completed Tasks: F02.0-CORE, F02.1-FE, F02.2-FE, F02.3-FE, F02.4-FE, F02.5-FE, F02.6-FE
* Remaining Tasks: none in frontend scope
* Blockers: none
* Status Suggestion: **Ready for QA** (client-only, automated — `architecture.md` QA Focus)

---

## 19. Sonraki Komut

Run QA
