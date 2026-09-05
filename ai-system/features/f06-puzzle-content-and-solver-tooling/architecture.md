# F06 — puzzle-content-and-solver-tooling: Architecture

> Status: CONTRACT AUTHORITY. Finalized 2026-09-05 from `analysis.md` (F06.0-AN). Delivery artifacts and QA notes do not override the semantics here. The `Open Technical Decisions` at the end are tunable *values*, not open *contracts* — implementation may start.

---

## Purpose

* **Feature objective:** the build-time toolchain that makes LOOPLET content trustworthy — `looplet_solver` (provable-minimum-move search), `tools/looplet_authoring` (CLI level editor), the `looplet_content` `Puzzle` model — plus the content-production pipeline that F05 / F07 / F08 depend on.
* **Contract scope:** the `Puzzle` schema + JSON; the `looplet_solver` API + its provable-minimum guarantee; the difficulty-score *definitions*; the CLI command surface + export gate; the build-time content check; the `content/` artifact layout.
* **Non-goals:** on-device solving (the app never imports `looplet_solver`); F04 star bands / F05 unlock UI / F07 Daily reset+scoring / F08 persistence (F06 only emits `optimalMoves` + artifacts); Daily distribution (F07/F08); a GUI editor; runtime procedural generation; Phase-2 mechanics; difficulty auto-tuning.

---

## Authorities & Inputs

* Upstream PRD: `features/f06-.../prd.md`; product PRD §5.5, §6.1 (F06), §12–13, §46–49.
* Consumed: `analysis.md` (F06.0-AN) — see `Consumed Signals` in `orchestration.md`.
* Inherited contracts **[LOCKED]**:
  * **F02** — the solver operates on `GridState` / `GridState.initial(config, validator)` / `GridState.applyMove(move, config, validator)` (checking `GridStep.applied` + `GridState.isSolved`) / `GridState.canonicalKey()` (search node identity) / `EngineConfig` / `EngineConfig.legalMoves(GridState)` (successors). A solution of length `m` is an ordered `List<Move>` that folds `GridState.initial` to an `isSolved` state with every step `applied`. F06 re-implements no shift/thaw/win logic.
  * **F01** — word validation via the `WordValidator` port. Shipped `optimalMoves` is only valid for the dictionary it was solved against.
* Project authority: `platform.md` §3 (monorepo layout + dependency edges), §4 (JSON `lowerCamelCase`, `YYYY-MM-DD` dates), §11 (no runtime RNG **on device**; authoring-time RNG allowed if seeded/reproducible), §13 (solver approach — **amended 2026-09-05** to forward BFS + bound). Release: `none`.

---

## Dependency Edges [LOCKED]

* `packages/looplet_content` → `looplet_core` **only**. Defines `Puzzle` + JSON + `PuzzleType` / `DifficultyLabel` enums + `PuzzleFormatException`. **Does not depend on `looplet_engine`.** `Puzzle` stores raw fields; a consumer that already depends on `looplet_engine` builds the `EngineConfig`. `Puzzle.language` is a plain `String` validated against `{'tr', 'en'}`.
* `packages/looplet_solver` → `looplet_engine` **only** (+ dev `test`). Takes a `WordValidator` (F01's port, defined in `looplet_engine`). **Does not depend on `looplet_dictionary`.**
* `tools/looplet_authoring` → `looplet_engine` + `looplet_solver` + `looplet_content` + `looplet_dictionary` (for the `WordValidator` adapter) + `package:args` (Dart-team CLI arg parser — allowed here; this package is never shipped in the app). A Dart **executable** package.
* The `app` never depends on `looplet_solver` or `tools/looplet_authoring`. The `app` depends on `looplet_content` (F05/F07/F08 load `Puzzle` artifacts).

---

## `Puzzle` Model [LOCKED]

Every `Puzzle` artifact MUST carry: `schemaVersion` (int), `contentVersion` (String), `id` (String), `puzzleType` (`journey` | `daily`), `language` (`'tr'` | `'en'`), `grid` (list of row strings), `targetWord` (String), `lockedCells` + `frozenCells` (each a set of `"row,col"` strings), `columnMovesEnabled` (bool), **`optimalMoves` (int ≥ 0 — solver-verified; an artifact without it is invalid and cannot ship)**, `difficultyScore` (num), `difficultyLabel` (`easy`|`medium`|`hard`|`expert`). `journey` ⇒ `journeyLevelNumber` (1–30); `daily` ⇒ `dailyDate` (`YYYY-MM-DD`). `difficultyBreakdown` (object) is **optional** in the artifact — see Open Technical Decisions.

### JSON shape

```json
{
  "schemaVersion": 1,
  "contentVersion": "2026.09-a",
  "id": "journey-tr-14",
  "puzzleType": "journey",
  "journeyLevelNumber": 14,
  "language": "tr",
  "grid": ["KAMEL", "SİRAT", "DONUK", "BEYAZ", "TAŞIT"],
  "targetWord": "MASAL",
  "lockedCells": ["0,0", "2,3"],
  "frozenCells": ["4,4"],
  "columnMovesEnabled": true,
  "optimalMoves": 7,
  "difficultyScore": 9.4,
  "difficultyLabel": "hard",
  "difficultyBreakdown": { "o": 7, "cNorm": 0.31, "tdDegree": 1, "locked": 2, "frozen": 1, "firstMoves": 3, "distinctOptimalSolutions": 42 }
}
```

* `grid` — row strings, 5 single letters each (authored casing). Maps to `EngineConfig(initialGrid: [for r in grid] r.split(''), ...)`.
* `lockedCells` / `frozenCells` — `"row,col"` strings; parsed to `GridCoord`.
* Unknown extra keys are **ignored** (forward-compatible, like F01's dictionary asset).
* `Puzzle.fromJson(Map<String,Object?>)` throws `PuzzleFormatException` for: unsupported `schemaVersion`; missing/`null` `optimalMoves`; missing `grid` / `targetWord` / `id`; invalid `puzzleType` / `difficultyLabel` / `language`; malformed `"row,col"`; `journey` without `journeyLevelNumber` or `daily` without `dailyDate`.
* `Puzzle.toJson()` round-trips losslessly (every field).

### `Puzzle` → `EngineConfig` [LOCKED]

A helper `toEngineConfig(Puzzle)` (a free function in a consumer that depends on `looplet_engine` — e.g. `looplet_solver` or `app`) builds the `EngineConfig`. `looplet_content` itself never imports `looplet_engine`.

---

## `looplet_solver` API & Guarantee [LOCKED]

```dart
sealed class SolveResult {}
final class Optimal extends SolveResult { final int moves; final List<Move> sequence; }
final class Unsolvable extends SolveResult {}
final class BudgetExceeded extends SolveResult { final SearchBudget budget; }

final class SearchBudget {
  const SearchBudget({this.maxDepth = 16, this.maxNodes = 5000000, this.timeBudget = const Duration(seconds: 30)});
  final int maxDepth; final int maxNodes; final Duration timeBudget;
}

abstract final class Solver {
  static SolveResult solve(EngineConfig config, WordValidator validator, {SearchBudget budget = const SearchBudget()});
  static List<List<Move>> enumerateOptimalSolutions(EngineConfig config, WordValidator validator, {int cap = 1000});
}
```

### Algorithm [LOCKED]

**Forward BFS** over `GridState.canonicalKey()`:

1. FIFO queue seeded with `GridState.initial(config, validator)`.
2. On dequeue: if `state.isSolved` → reconstruct the path via the parent map and return `Optimal(depth, sequence)`. (The goal is a *set*; testing `isSolved` on dequeue handles it.)
3. Else expand: for each `move` in `config.legalMoves(state)` **sorted by a fixed `Move` comparator** (axis, then index, then direction — a total order), compute `state.applyMove(move, config, validator)`. If `step.applied` and `step.state.canonicalKey()` is unvisited: mark visited, record `parent[childKey] = (parentKey, move)`, enqueue at `depth + 1`.
4. Bounds: if `depth + 1 > budget.maxDepth`, or `visited.length > budget.maxNodes`, or elapsed `> budget.timeBudget` → stop and return `BudgetExceeded(budget)`.
5. Queue empties without a goal → `Unsolvable`.

* **Provable minimum:** BFS on an unweighted graph dequeues in non-decreasing distance from the source; the first `isSolved` dequeued is at minimum distance. Frozen-thaw only adds forward edges (it never lets a state be reached in fewer moves than BFS finds) so the BFS invariant holds. Locked tiles only prune `legalMoves`.
* **Determinism:** fixed successor order + FIFO + string-keyed `visited`/`parent` + first-discovered parent ⇒ `moves` and the byte-content of `sequence` are identical across runs. No RNG anywhere in `looplet_solver`.
* **`Optimal` invariants:** `sequence.length == moves`; folding `sequence` over `GridState.initial` reaches `isSolved`; every step is `applied`.
* **`enumerateOptimalSolutions`:** returns up to `cap` distinct optimal solutions in a deterministic order (for difficulty). If the true count exceeds `cap`, returns exactly `cap`; the scorer treats the count as "≥ cap".
* **IDA\* fallback:** documented as a per-puzzle escape hatch only — used if a specific puzzle a designer insists on blows `maxNodes`. Not part of the default path. **Bidirectional BFS is not used** (goal-is-a-set + frozen-thaw irreversibility break meet-in-the-middle).

---

## Difficulty Score [LOCKED — definitions] [OPEN — weights/thresholds]

Computed deterministically from the BFS tree (to depth `o = optimalMoves`) + the bounded optimal-solution list. `L = |lockedCells|`, `F = |frozenCells|`, target length 5.

| Metric | Definition |
| --- | --- |
| `o` | `optimalMoves` from the solver |
| `cNorm` (correct-looking intermediate states) | `C` = # distinct states at BFS depth `d`, `0 < d < o`, where some row has **≥ 3 of the 5 target letters in their correct target positions** but no row is fully correct. `cNorm = C / (# distinct states within depth o)`. |
| `tdDegree` (required temporary displacement) | For each enumerated optimal solution, `progress(step)` = max over rows of (# correct target positions). `tdDegree` = **min over optimal solutions of (# steps where `progress` decreases)**. `≥ 1` ⇒ every optimal solution forces breaking partial progress. |
| `L`, `F` | locked / frozen tile counts |
| `firstMoves` (plausible routes, primary) | # distinct optimal first moves (1–20) |
| `distinctOptimalSolutions` (plausible routes, secondary) | `min(count, cap)` from `enumerateOptimalSolutions` |

**Score formula** (weights are `DifficultyWeights` defaults — recalibrated during content authoring; the *formula shape* is locked):

```
score = wO*o + wC*cNorm + wTD*tdDegree + wL*L + wF*F − wR*(min(firstMoves, 8) / 8)
```
Recommended starting weights: `wO=1.0, wC=3.0, wTD=2.0, wL=0.8, wF=1.2, wR=1.5`.

**Label** via `DifficultyThresholds` (defaults recommended; recalibrated during authoring):
`easy` `score < 4` · `medium` `4 ≤ score < 8` · `hard` `8 ≤ score < 13` · `expert` `score ≥ 13`.

`DifficultyWeights` and `DifficultyThresholds` are value types with `const` defaults, overridable from the CLI (a small JSON) so the Level Designer recalibrates without a code change. The score + label MUST be deterministic for a fixed weights/thresholds value.

---

## CLI Surface (`tools/looplet_authoring`) [LOCKED]

| Command | Behavior | Exit |
| --- | --- | --- |
| `solve <def.json>` | print: solvable?; `optimalMoves` / `unsolvable` / `budgetExceeded`; difficulty score + label + breakdown; one optimal sequence (shorthand `R0 D2 L4 ...`) | 0 (non-zero only if the def file is malformed) |
| `playtest <def.json> --moves "R0 D2 L4"` | apply the sequence via the real engine; per-step `applied`/`rejected` + reason; final `isSolved` | 0 |
| `export <def.json> --out <path>` | run `solve`; if `Optimal` with `moves > 0` → write the `Puzzle` artifact (with a fresh difficulty score); else print the reason | **non-zero + no file** on `unsolvable` / `budgetExceeded` / `optimalMoves == 0` / malformed def |
| `check <dir\|glob>` | validate every artifact: `Puzzle` schema; stored `optimalMoves` **==** a fresh `Solver.solve`; Journey level 1–3 ⇒ `columnMovesEnabled == false`; `difficultyLabel` in the §20 band for the level number; no two Journey puzzles identical; no Daily puzzle identical to a Journey puzzle; Daily `manifest.json` reuses no `id` within the window; shipped-artifact `targetWord` is `isEligibleTarget` per F01 | **non-zero** on any failure, naming each (the CI content gate) |
| `fill --seed <n> [--frozen-safe] [--avoid-near-target]` | print a seeded Turkish-letter-frequency candidate grid | 0 |

* Definition-file format: **JSON** — `{ id, puzzleType, journeyLevelNumber?/dailyDate?, language, grid, target, locked, frozen, columns }`. Flags may override individual fields.
* Move shorthand: `R<i>` / `L<i>` (row right/left), `D<i>` / `U<i>` (column down/up).
* `export` runs the solver with the **production** `WordValidator` (over the real `DictionaryService`), so a shipped `optimalMoves` matches in-game reality.

---

## Content Artifacts & Build Check [LOCKED]

* Journey: `content/journey/<lang>/levelNN.json` (`NN` = `01`..`30`).
* Daily: `content/daily/<lang>/pool/<id>.json` + `content/daily/<lang>/manifest.json` (`{ language, window: [start, end], assignments: { "YYYY-MM-DD": "<id>" } }`). Daily *distribution* (fetch/cache/assign-at-runtime) is F07/F08.
* `looplet_authoring check content/` is added to `.github/workflows/ci.yml` as a required job once the first artifacts exist. It is pure Dart, headless.
* Rule table for `check`: Journey band consistency (label ↔ level number per source §20); `columnMovesEnabled == false` for levels 1–3; Journey internal dedup; Journey ↔ Daily dedup; Daily manifest no-repeat-window (default 30 days); stored `optimalMoves` re-verified; shipped `targetWord` dictionary-eligible; `Puzzle` schema valid.
* `fill` RNG MUST be seeded and reproducible; `looplet_solver` and `looplet_content` use **no** RNG.

---

## Validation Responsibility [LOCKED]

* **`looplet_content`:** `Puzzle` JSON shape + `schemaVersion` + required-field presence (esp. `optimalMoves`).
* **`looplet_solver`:** solution validity (every step `applied`, reaches `isSolved`) + minimality; `Unsolvable` / `BudgetExceeded` detection.
* **`tools/looplet_authoring`:** the `export` gate; the `check` content gate; def-file input validation.
* **`EngineConfig` (F02):** structural puzzle validity — F06 does not re-validate grid dimensions etc. (`export` surfaces the `EngineConfigError` if the def is structurally broken.)

---

## State / Flow Semantics [LOCKED]

* The solver is a pure function of `(EngineConfig, WordValidator, SearchBudget)`. No I/O, no clock except `timeBudget` measurement (a `Stopwatch` is permitted **in `looplet_solver`** — it is build-time tooling, not on-device; the `looplet_engine` no-RNG/no-clock guard does **not** extend to `looplet_solver`).
* `check` re-solves every artifact — it is the drift detector between a stored `optimalMoves` and current engine/validator behavior. After an F01 dictionary corpus change, all frozen-tile puzzles must be re-`export`ed; `check` fails until they are.
* No screens, navigation, persistence, or realtime — F06 emits `content/` files and CLI output.

---

## QA Focus [LOCKED]

* Solver minimality vs an **independent** exhaustive reference (a brute-force DFS-to-fixed-depth enumerating *all* solutions ≤ a small bound for tiny test puzzles — not the same BFS code) on: no-tiles, locked, single-frozen, multi-frozen.
* Locked/frozen honoring (returned sequence uses only `applied` moves); `Unsolvable` + `BudgetExceeded` detection; determinism (same minimum + byte-identical `sequence` twice; stable tie-break).
* `Puzzle` JSON lossless round-trip; `PuzzleFormatException` for missing `optimalMoves` / bad `schemaVersion` / malformed shape / bad coord / wrong type; unknown-key tolerance.
* Difficulty determinism (fixed weights/thresholds); per-metric monotonicity; documented thresholds honored; `breakdown` fields present.
* CLI: `solve` / `playtest` / `export` / `check` / `fill` behaviors; `export` exits non-zero + writes nothing on `unsolvable` / `budgetExceeded` / `optimalMoves == 0`; `check` catches every planted bad artifact (no `optimalMoves`; level-2 with columns enabled; Journey↔Daily dup; stored optimal ≠ fresh solve; ineligible target); `fill` seed reproducibility + statistical closeness to Turkish frequency vs uniform.
* Build-time `check content/` wired into CI and green on the committed smoke set; RNG confined to `fill`.
* **Evidence class:** `automated functional` (`dart test` + CLI invoked from tests). No device runtime.
* **QA scope:** client-only (package + CLI level), source + automated tests. `Security compliance out of scope` — offline tooling on trusted inputs, no auth / PII / network / user input.

---

## Release / Deployment Impact [LOCKED]

* Release scope: **none** — build-time tooling + committed content artifacts; nothing distributed to devices by F06. (Daily *distribution* is F07/F08.)
* One CI change: add `looplet_authoring check content/` as a required job (F06.6).

---

## Scope of the F06 Implementation Delivery [LOCKED — Tech Lead decision]

Per `analysis.md` §17.10, F06's implementation delivery is **the toolchain + a ~5-puzzle smoke set** (F06.1-FE … F06.7-FE + F06.1-QA … F06.5-QA). Authoring the **full 30 Journey levels + the ~60-puzzle Daily pool + manifest** is a **separate follow-on content task (`F06-CONTENT`)**, owned by a Level Designer (or the user), gated on this toolchain passing QA. `F06-CONTENT` is still MVP scope (product PRD §42) and is a prerequisite for F05 and F07 reaching `Done` — it is tracked on `feature-board.md` and `system-state.md` as a follow-on, not a separate feature.

The smoke set (≥ 5 Journey puzzles, one per §20 curve band, authored during F06.5/F06.6) must exercise: no-tiles, columns-disabled (levels 1–3), locked, frozen, and locked+frozen — end to end through `solve` → `export` → `check`.

---

## Open Technical Decisions (tunable values — do NOT block implementation)

* Exact `SearchBudget` numbers (`maxDepth` / `maxNodes` / `timeBudget`) — start with `16 / 5,000,000 / 30s`; finalize during `F06-CONTENT` authoring.
* Exact `DifficultyWeights` + `DifficultyThresholds` — start with the recommended values above; recalibrate once the 30 levels exist.
* Turkish letter-frequency table source + values — a ~29-entry `const` map in `tools/looplet_authoring`; pick a published table (TDK / BOUN corpus / standard). Level-Designer choice.
* `--avoid-near-target` filter (edit-distance-1 from the puzzle's target) — implement it, default **off** for the MVP; the offensive-string guard is always on.
* MVP Daily pool size (recommend ~60) + difficulty band (recommend medium/hard, not expert) — `F06-CONTENT`.
* `difficultyBreakdown` in shipped artifacts — **recommend required** (useful for `check` and designers); confirm during F06.1.
