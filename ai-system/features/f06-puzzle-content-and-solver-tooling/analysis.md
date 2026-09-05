# F06 — puzzle-content-and-solver-tooling: Technical Analysis

Role: Technical Analyst · Date: 2026-09-05
Output of task F06.0-AN. Options + trade-offs + a marked **Recommendation** per item. Final architecture / scope / lock decisions belong to the Tech Lead.

---

# 1. Feature Summary (Technical View)

F06 is a **build-time-only** toolchain, in three pure-Dart packages plus a CLI:

* `looplet_content` — the `Puzzle` model + JSON (de)serialization; the one content schema for F05 / F07 / F08.
* `looplet_solver` — given an `EngineConfig` + `WordValidator`, compute the **provable minimum** move count to a winning state (or `unsolvable` / `budgetExceeded`), honoring locked/frozen tiles by reusing F02's `GridState.applyMove` / `canonicalKey` / `EngineConfig.legalMoves`.
* `tools/looplet_authoring` — a CLI to define, solve, rate, playtest, export, and check puzzles; the export gate refuses unsolvable / optimal-less puzzles; the `check` command is the CI content gate.

The system must, from this feature: guarantee every shipped `Puzzle` carries a solver-verified `optimalMoves`; produce a deterministic difficulty score + `easy`/`medium`/`hard`/`expert` label; and produce the MVP content set (Journey levels + Daily pool) as versioned, `check`-passing artifacts.

The app never depends on `looplet_solver` or `tools/looplet_authoring`. Release scope: none.

---

# 2. User Stories

* As a Level Designer, I want to write a puzzle-definition file and run one command that tells me: solvable?, optimal moves, difficulty score + label, and one optimal solution — so I can iterate in seconds.
* As a Level Designer, I want `export` to refuse a broken puzzle (unsolvable, no optimal, trivial) — so a bad puzzle cannot reach `content/`.
* As a Level Designer, I want a `check` command over a directory of artifacts that fails CI on any schema / optimal / difficulty-band / duplication violation — so content regressions are caught automatically.
* As a Level Designer, I want a seeded grid-fill helper biased toward Turkish letter frequency that avoids offensive strings — so hand-authoring starts from a plausible board.
* As the system, I want `looplet_content` to (de)serialize a `Puzzle` losslessly and reject malformed artifacts with a typed error — so F05 / F07 / F08 have one trustworthy schema.
* As the system, I want the solver to be deterministic — same `(EngineConfig, WordValidator)` → same minimum — so `optimalMoves` is reproducible in CI.

---

# 3. Acceptance Criteria

Given/When/Then, testable, covering library + CLI behavior. (These refine `prd.md` §Acceptance Criteria; no conflicts found.)

### Solver

* **Given** a solvable `EngineConfig` (any tile config), **When** `Solver.solve` runs, **Then** it returns `Optimal(m, seq)` where folding `seq` over `GridState.initial` reaches `isSolved`, every step is `applied`, and `m` equals the exhaustive-BFS minimum on the bounded reference set.
* **Given** an `EngineConfig` from which no `isSolved` state is reachable, **When** `solve` runs, **Then** it returns `Unsolvable` (never a wrong number, never a non-terminating run).
* **Given** an `EngineConfig` whose minimum exceeds `SearchBudget`, **When** `solve` runs, **Then** it returns `BudgetExceeded(budget)` and the puzzle is not publishable.
* **Given** the same inputs, **When** `solve` runs twice, **Then** the returned `m` (and `Unsolvable`/`BudgetExceeded`) is identical and `seq` is byte-identical (deterministic tie-break).
* **Given** a puzzle with locked/frozen tiles, **When** `solve` returns `Optimal(m, seq)`, **Then** every move in `seq` is one `EngineConfig.legalMoves` would list from its predecessor state.

### Difficulty

* **Given** `(EngineConfig, SolveResult, optimalSolutions)`, **When** the scorer runs twice, **Then** `difficultyScore` and `difficultyLabel` are identical.
* **Given** the documented weight/threshold table, **When** a score is computed, **Then** the label is the table's band for that score.
* **Given** a puzzle with more distinct optimal first moves, **When** scored, **Then** its route term lowers the score relative to an otherwise-identical single-route puzzle.

### `Puzzle` model

* **Given** a `Puzzle`, **When** encoded to JSON and decoded, **Then** the result equals the original on every field.
* **Given** JSON with a missing `optimalMoves` / unsupported `schemaVersion` / missing `grid` or `targetWord` / bad `puzzleType` / malformed `"r,c"` coord, **When** decoded, **Then** a `PuzzleFormatException` is thrown.
* **Given** JSON with unknown extra keys, **When** decoded, **Then** they are ignored and decoding succeeds.

### CLI

* **Given** `solve <def>`, **When** run on a solvable puzzle, **Then** stdout shows solvability, `optimalMoves`, difficulty score + label + breakdown, and one optimal sequence; exit 0.
* **Given** `solve <def>` on an unsolvable puzzle, **Then** stdout shows `unsolvable`; exit 0 (it is a valid answer, not a tool error).
* **Given** `export <def> --out <path>` on an unsolvable / budget-exceeded / already-solved puzzle, **Then** exit is non-zero and no file is written.
* **Given** `export` on a valid puzzle, **Then** a `Puzzle` artifact is written and re-decodes losslessly with `optimalMoves` matching a fresh solve.
* **Given** `playtest <def> --moves "R0 D2 L4"`, **Then** each step's applied/rejected + reason is printed and the final `isSolved` is reported.
* **Given** `check <dir>` over a directory containing a planted bad artifact (no `optimalMoves`; level-2 with `columnMovesEnabled=true`; a Journey/Daily duplicate; a stored optimal that disagrees with a fresh solve), **Then** `check` exits non-zero and names each failure.
* **Given** `fill --seed N`, **When** run twice with the same seed, **Then** the candidate grid is identical; the letter distribution is measurably closer to Turkish frequency than uniform.

---

# 4. Functional Breakdown

| Sub-part | Package | Responsibility |
| --- | --- | --- |
| `Puzzle` model + JSON | `looplet_content` | fields, encode/decode, `DifficultyLabel`/`PuzzleType` enums, `PuzzleFormatException`, `Puzzle.toEngineConfig()` helper |
| BFS search | `looplet_solver` | `Solver.solve(EngineConfig, WordValidator, {SearchBudget}) → SolveResult`; visited set on `canonicalKey`; deterministic `legalMoves` order; parent map for path reconstruction |
| Optimal-solution enumeration | `looplet_solver` | `enumerateOptimalSolutions(..., {cap}) → List<List<Move>>` (bounded) — feeds difficulty |
| Difficulty scorer | `looplet_solver` (or `looplet_difficulty`) | the 6 §48 metrics + `DifficultyWeights` + `DifficultyThresholds` (configurable) → `Difficulty(score, label, breakdown)` |
| CLI | `tools/looplet_authoring` | `solve` / `playtest` / `export` / `check` / `fill`; def-file parser; artifact writer; export gate |
| Content check | `tools/looplet_authoring` | schema, re-verify `optimalMoves`, Journey band consistency, Journey/Daily dedup, Daily manifest window rule → CI gate |
| Grid-fill helper | `tools/looplet_authoring` | seeded Turkish-frequency sampler + offensive/near-target filter |
| Content set | `content/` | Journey artifacts + Daily pool + `daily/<lang>/manifest.json` |

---

# 5. Library / CLI API Requirements

*(F06 has no HTTP surface. This section specifies the Dart API + CLI contract instead.)*

## `looplet_solver`

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
  static SolveResult solve(EngineConfig config, WordValidator validator, {SearchBudget budget});
  static List<List<Move>> enumerateOptimalSolutions(EngineConfig config, WordValidator validator, {int cap = 1000});
}
```

* `solve` returns `Optimal` only when the minimum is **proven** within `budget`. `sequence.length == moves`. Deterministic.
* `enumerateOptimalSolutions` returns up to `cap` distinct optimal solutions (for difficulty); if the true count exceeds `cap`, it returns exactly `cap` and the scorer treats the count as "≥ cap".

## `looplet_solver` — difficulty

```dart
final class DifficultyWeights { /* wOptimal, wCorrectLooking, wTempDisplacement, wLocked, wFrozen, wRoutes */ }
final class DifficultyThresholds { /* easyMax, mediumMax, hardMax */ }
final class Difficulty { final num score; final DifficultyLabel label; final Map<String, num> breakdown; }

abstract final class DifficultyScorer {
  static Difficulty score(EngineConfig config, Optimal solved, List<List<Move>> optimalSolutions,
      {DifficultyWeights weights = const DifficultyWeights.defaults(), DifficultyThresholds thresholds = const DifficultyThresholds.defaults()});
}
```

## `looplet_content`

```dart
enum PuzzleType { journey, daily }
enum DifficultyLabel { easy, medium, hard, expert }

final class Puzzle {
  final int schemaVersion; final String contentVersion; final String id;
  final PuzzleType puzzleType; final int? journeyLevelNumber; final String? dailyDate;
  final String language;
  final List<String> grid;          // row strings
  final String targetWord;
  final Set<GridCoord> lockedCells; final Set<GridCoord> frozenCells;
  final bool columnMovesEnabled;
  final int optimalMoves;           // REQUIRED
  final num difficultyScore; final DifficultyLabel difficultyLabel;
  final Map<String, num>? difficultyBreakdown;

  static Puzzle fromJson(Map<String, Object?> json);   // throws PuzzleFormatException
  Map<String, Object?> toJson();
}

final class PuzzleFormatException implements Exception { final String message; }
```

`Puzzle.toEngineConfig()` — a helper (in a consumer that already depends on `looplet_engine`, **not** in `looplet_content`) that builds `EngineConfig(initialGrid: [for r in grid] r.split(''), targetWord: targetWord, lockedCells: lockedCells, frozenCells: frozenCells, columnMovesEnabled: columnMovesEnabled)`.

## CLI (`tools/looplet_authoring`)

| Command | Behavior | Exit |
| --- | --- | --- |
| `solve <def>` | print solvability, `optimalMoves`/`unsolvable`/`budgetExceeded`, difficulty score+label+breakdown, one optimal sequence | 0 always (unless the def file itself is malformed → non-zero) |
| `playtest <def> --moves "<seq>"` | apply the sequence via the real engine; per-step applied/rejected + reason; final `isSolved` | 0 |
| `export <def> --out <path>` | run `solve`; if `Optimal` and `optimalMoves > 0` → write the `Puzzle` artifact; else print reason | non-zero + no file on unsolvable / budgetExceeded / `optimalMoves == 0` / malformed def |
| `check <dir\|glob>` | validate every artifact: schema; `optimalMoves` present **and** equal to a fresh solve; Journey `columnMovesEnabled` + difficulty band vs level number (§20); Journey/Daily dedup; Daily manifest no-repeat-window | non-zero on any failure (CI gate) |
| `fill --seed <n> [--frozen-safe] [--avoid-near-target]` | print a seeded Turkish-frequency candidate grid | 0 |

Definition-file format: **JSON** (no new dependency), e.g.
```json
{ "id": "journey-tr-14", "puzzleType": "journey", "journeyLevelNumber": 14, "language": "tr",
  "grid": ["KAMEL","SİRAT","DONUK","BEYAZ","TAŞIT"], "target": "MASAL",
  "locked": ["0,0","2,3"], "frozen": ["4,4"], "columns": true }
```
Flags may override individual fields for quick iteration.

---

# 6. Data Model (Conceptual)

* **Puzzle** — see §5. `journey` ⇒ `journeyLevelNumber` set, `dailyDate` null; `daily` ⇒ vice versa.
* **SolveResult** — sealed: `Optimal(moves, sequence)` | `Unsolvable` | `BudgetExceeded(budget)`.
* **Difficulty** — `score`, `label`, `breakdown{o, cNorm, tdDegree, locked, frozen, firstMoves, distinctOptimalSolutions}`.
* **DailyManifest** — `{ language, window: [startDate, endDate], assignments: {date → puzzleId} }` (F06 emits it; F07/F08 consume it).
* **Search node** (internal) — `canonicalKey` string; parent map `canonicalKey → (parentKey, Move)`.
* Relationships: `Puzzle` → `EngineConfig` (via `toEngineConfig()`); `Solver` consumes `EngineConfig` + `WordValidator`; `DifficultyScorer` consumes `EngineConfig` + `Optimal` + optimal-solution list; CLI orchestrates all three and writes `Puzzle` JSON.

---

# 7. Validation Rules

## Input Validation

* Def-file: `puzzleType` ∈ {journey, daily}; `journey` ⇒ `journeyLevelNumber` 1–30; `daily` ⇒ `dailyDate` `YYYY-MM-DD`; `grid` 5×5 single letters; `target` 5 letters; `locked`/`frozen` `"r,c"` in range, disjoint; `language` ∈ {tr, en}. (Grid structural validity is enforced by `EngineConfig` when the def is turned into one.)
* `Puzzle` JSON: `schemaVersion` known; `optimalMoves` present (int ≥ 0); required fields present; enums valid.

## Business Validation

* `export` gate: `SolveResult` must be `Optimal` with `moves > 0`.
* `check`: stored `optimalMoves` must equal a fresh `Solver.solve`; Journey level 1–3 ⇒ `columnMovesEnabled == false`; difficulty label must fall in the §20 band for the level number (band table documented); no two Journey puzzles identical; no Daily puzzle identical to any Journey puzzle; Daily manifest reuses no `puzzleId` within the configured window (recommend 30 days).
* Target word SHOULD be dictionary-eligible (F01 `isEligibleTarget`); `check` **fails** for a Journey/Daily artifact whose target is not eligible; `solve` only **warns** (a designer may probe non-words).

---

# 8. Edge Cases

* Puzzle solved at t = 0 → `solve` correctly returns `Optimal(0, [])`; `export` and content rules reject `optimalMoves == 0` as trivial.
* Multiple frozen tiles, thaw order branches → the search explores each order as ordinary state transitions; BFS still returns the proven minimum (see §12 minimality argument).
* Frozen tile whose only thaw path needs a column move on a `columnMovesEnabled == false` puzzle → `Unsolvable`; CLI surfaces it so the designer fixes the config.
* `columnMovesEnabled == false` + all rows open → branching ≈ 10; fast.
* Highly symmetric grid → many equal-cost optimal solutions; `solve` returns one (deterministic tie-break); `enumerateOptimalSolutions` hits `cap` and the scorer treats the count as "≥ cap".
* `enumerateOptimalSolutions` memory blow-up → hard `cap` + early exit; never unbounded.
* Frozen-word that equals the target (thaw + win on the same move, per F02) → a valid final transition; the "correct-looking intermediate states" metric should count the pre-final state where the row is one move from spelling the target.
* Hand-edited artifact JSON where `optimalMoves` no longer matches the grid → `check` fails loudly (re-solve mismatch).
* Two Journey levels accidentally identical → `check` flags (Journey internal dedup, not only vs Daily).
* Daily manifest with a past `dailyDate` → allowed (backfill); `check` may warn.
* `fill` produces a grid that is already solved or contains an excluded/near-target string → reject-and-resample with the seeded RNG (bounded retries, then fail with a clear message).
* Non-deterministic `Set`/`Map` iteration leaking into the chosen `sequence` → the solver must order successors by a fixed `Move` comparator and reconstruct the path via first-discovered parents; a test asserts byte-identical `sequence` across runs.
* Search bound hit on a puzzle the designer *wants* → `budgetExceeded`; the documented remedy is to lower the puzzle's difficulty, not to raise the bound silently (raising the bound is a Tech Lead decision recorded in `architecture.md`).

---

# 9. Error Scenarios

| Situation | Result |
| --- | --- |
| Malformed def-file (bad JSON, missing required field, bad coord) | CLI prints the error; exit non-zero; no solve/export |
| `EngineConfig` structural violation (F02 throws `EngineConfigError`) | CLI catches, prints, exit non-zero |
| Puzzle unsolvable | `solve` prints `unsolvable`, exit 0; `export` exit non-zero, no file |
| Minimum exceeds `SearchBudget` | `solve` prints `budgetExceeded (depth 16 / 5M nodes / 30s)`, exit 0; `export` exit non-zero, no file |
| `optimalMoves == 0` (trivial) | `export` exit non-zero, no file |
| `Puzzle` JSON missing `optimalMoves` / bad `schemaVersion` / bad shape | `PuzzleFormatException`; `check` exit non-zero naming the file + reason |
| `check`: stored optimal ≠ fresh solve | exit non-zero, names the file, shows both values |
| `check`: Journey level 1–3 with columns enabled, or difficulty out of band, or duplicate | exit non-zero, names the file + rule |
| `fill` cannot satisfy constraints within retry budget | exit non-zero with a clear "could not generate a valid grid for seed N" |

No exception should escape the CLI unhandled; every failure is a named message + a non-zero exit.

---

# 10. Client / UI Expectations

**None — F06 has no player-facing UI.** The "client" is the CLI (stdout/stderr + exit codes) and, downstream, the `content/` artifacts that F05 / F07 load. No screen, loading, empty, or error UI; no navigation/header/back. (F05's Journey screens and F07's Daily screens consume F06's output but are their own features.)

---

# 11. Integration Rules

* **Solver ↔ F02 engine:** the solver treats `GridState` as opaque — it only uses `GridState.initial`, `GridState.applyMove` (checking `GridStep.applied` + `isSolved`), `GridState.canonicalKey` (node identity), and `EngineConfig.legalMoves` (successors). No re-implementation of shift/thaw/win logic. If F02's `applyMove` semantics change, the solver's results change with them — this is intended (single source of truth).
* **Solver ↔ F01:** frozen-thaw word checks flow through the injected `WordValidator`. The solver must be given a validator whose behavior matches production (the real `DictionaryService`), or its `optimalMoves` will not match in-game reality. `check` re-solves with the production validator to catch drift.
* **`Puzzle` ↔ consumers:** `looplet_content.Puzzle` is the only content type F05 / F07 / F08 import. Field naming: `lowerCamelCase` JSON per `platform.md` §4. Coords as `"row,col"`. Dates as `YYYY-MM-DD`. Unknown keys ignored (forward-compat). `optimalMoves` is non-nullable in the model; a JSON without it fails to decode.
* **`Puzzle` → `EngineConfig`:** deterministic; the same `Puzzle` always yields an equal `EngineConfig`, so F04's star bands (`optimalMoves` vs player moves) and F08's session restore (rebuild engine from the persisted `Puzzle`) are consistent.
* **Content check → CI:** `looplet_authoring check content/` is added to `.github/workflows/ci.yml` as a required gate once the first artifacts land; it must be runnable headless (pure Dart, no device).
* **Daily manifest → F07/F08:** F06 emits `daily/<lang>/manifest.json` (date → puzzleId) + the pool artifacts; F07/F08 own fetching/caching/assignment-at-runtime. F06's `check` enforces the no-repeat-window and no-dup-with-Journey rules on the manifest it emits.
* Route graph / union-enum exhaustive behavior / persisted state: N/A (no UI, no store).

---

# 12. Non-Functional Considerations

## Performance / the solver algorithm — **the core technical decision**

**Search substrate:** node = `GridState.canonicalKey()` (normalized 25 letters + sorted thawed-cell set); successors = `EngineConfig.legalMoves(state)` (≤ 20, fewer with disabled columns / immovable lines); every move is cost 1 (product PRD §47).

**Structural facts that constrain the algorithm:**
1. **The goal is a set**, not a single state — any grid with a full left-to-right target row wins.
2. **Individual moves are reversible** on the letter-permutation part (`rowRight` ↔ `rowLeft`, `columnUp` ↔ `columnDown`) — so within a fixed thawed-set the move graph is undirected, cost-1 edges.
3. **Frozen-thaw is irreversible** — `applyMove` only ever *adds* to `thawedCells`; a backward move cannot un-thaw. The full state graph layers by `|thawedCells|` with one-way edges between layers.
4. While a tile is frozen it is a shift fixed-point, so the reachable letter-permutation set is *smaller* while frozen and *grows* on thaw; different thaw orders reach genuinely different regions.

### Option A — forward BFS + `canonicalKey` visited set + bound *(RECOMMENDED)*

* FIFO queue from `GridState.initial`; on dequeue, test `isSolved`; expand via `legalMoves` in a fixed `Move` order; skip already-visited `canonicalKey`; record `parent[key] = (parentKey, move)` for path reconstruction.
* **Provable minimum by construction:** BFS on an unweighted graph dequeues nodes in non-decreasing distance from the source; the first `isSolved` node dequeued is at minimum distance. Fact 3 (thaw adds only forward edges) does **not** break this — it can only make some states reachable that otherwise weren't; it never lets a state be reached in *fewer* moves than BFS would find, and BFS already tests every dequeued state for the goal. Fact 1 (goal set) is handled trivially — test `isSolved` on dequeue. Fact 4 is just a smaller/branching successor set, which BFS handles.
* **Memory:** the visited `Set<String>` + parent `Map<String,(String,Move)>`. Bounded by the number of distinct states within `maxDepth` of the initial. For a 5×5 shift puzzle this is typically 10^4–10^6 within radius ~12–16; frozen tiles *reduce* it (fewer movable cells) with a small multiplier for thaw-order layers. Worst case (levels 26–30, locked + multi-frozen) is still authoring-time on a workstation. Guard with `maxNodes` (recommend 5,000,000) and `timeBudget` (recommend 30 s); hitting either ⇒ `BudgetExceeded` ⇒ not shipped.
* **Search bound `maxDepth`:** the §20 curve tops at optimal 8–12; recommend **16** (margin). A puzzle needing > 16 optimal is out of the MVP's difficulty design anyway.
* **Determinism:** fixed `legalMoves` order + FIFO + `Set`/`Map` keyed by string + first-discovered parent ⇒ the reconstructed `sequence` is byte-stable.
* **Trade-off:** memory grows with the reachable set. Mitigation: store only `Map<String,int> depth` (no parent) and reconstruct the path by a backward walk (find any predecessor at `depth-1`) — halves memory, adds CPU. Start with the parent map (simpler); switch if profiling on levels 26–30 shows pressure.

### Option B — IDA* with an admissible heuristic

* O(depth) memory; no visited-set explosion.
* Needs a **tight admissible heuristic** for shift puzzles. Candidates: (i) `0/1` (degenerates to iterative-deepening DFS — exponential re-expansion without a transposition table, unacceptable); (ii) "min shifts to bring the 5 target letters into some single row, ignoring collisions" — computable but loose, since one column shift can fix a cell in every row and one row shift can fix several cells at once, so the bound under-counts heavily and prunes little; (iii) a pattern database — but a PDB keyed on this puzzle's *specific* locked/frozen config is per-puzzle and not amortizable across the 30 levels.
* Frozen-thaw is fine for IDA* (just a transition) but a transposition table (to avoid re-expansion) reintroduces the memory question, bounded by the current f-limit's reachable set.
* **Trade-off:** wins on memory, risks losing badly on time with a weak heuristic on the hardest puzzles — exactly the puzzles where a trustworthy optimal matters most.

### Option C — bidirectional BFS *(as suggested in `platform.md` §13 — NOT recommended)*

* Meet-in-the-middle needs a well-defined goal frontier and reversible transitions.
* Fact 1: the goal is a set; the minimal reachable winning states are not cheaply enumerable (row r = target, the other 20 cells in *some reachable* arrangement).
* Fact 3: frozen-thaw is irreversible — a backward search from a goal state cannot reconstruct pre-thaw states, so the forward and backward searches pass through disjoint regions for any frozen puzzle and never "meet" correctly.
* Bidirectional BFS could be an optimization for the **frozen-free** subset (levels 1–20), but "one solver, one code path" is far more maintainable, and Option A already handles the full Journey optimal range comfortably.

### Recommendation

**Option A (forward BFS + `canonicalKey` visited + `SearchBudget`).** It is the textbook-correct tool for "shortest move sequence to any winning state on an unweighted graph," it is trivially a *provable* minimum, and it handles locked/frozen/goal-set without special cases. Keep IDA* as the documented fallback *for a specific puzzle* that a designer insists on and that blows the node cap. **`platform.md` §13's "bidirectional BFS" direction should be updated by the Tech Lead** — it does not survive the goal-is-a-set + thaw-irreversibility analysis.

Recommended `SearchBudget` defaults (tune during content authoring): `maxDepth 16`, `maxNodes 5,000,000`, `timeBudget 30 s`.

## Difficulty score — computable definitions for the §48 parameters

All computed deterministically from the solver's search tree (BFS to depth `optimal`, plus the bounded optimal-solution list). Let `o = optimalMoves`, `L = |lockedCells|`, `F = |frozenCells|`, `T = targetWord` (length 5).

| §48 parameter | Computable definition | Direction |
| --- | --- | --- |
| **optimal move count** | `o`, from the solver | ↑ harder |
| **correct-looking intermediate states** | `C` = number of distinct states at BFS depth `d`, `0 < d < o`, where **some row has ≥ 3 of the 5 target letters in their correct target positions** but no row is fully correct. Normalize: `cNorm = C / (distinct states within depth o)`. High `cNorm` = many "false hope" boards. | ↑ harder |
| **required temporary displacement** | For each enumerated optimal solution, track `progress(step)` = max over rows of (# correct target positions). `tdDegree` = **min over optimal solutions of (# steps where `progress` decreases)**. `tdDegree ≥ 1` ⇒ every optimal solution forces you to break partial progress. | ↑ harder |
| **locked tile count** | `L` | ↑ harder |
| **frozen tile count** | `F` | ↑ harder |
| **number of plausible routes** | Primary: `firstMoves` = # distinct optimal first moves (1–20). Secondary: `distinctOptimalSolutions` = `min(count, cap)` from `enumerateOptimalSolutions`. More routes ⇒ **easier** (more ways to stumble onto it). | ↓ easier |

**Score formula** (recommended starting weights — put them in a configurable table, recalibrate after authoring the 30 levels):

```
score = 1.0*o + 3.0*cNorm + 2.0*tdDegree + 0.8*L + 1.2*F − 1.5*(min(firstMoves, 8) / 8)
```

**Label thresholds** (align with the §20 bands; tune):

| Label | Score | ~Level band (§20) |
| --- | --- | --- |
| `easy` | `< 4` | 1–6 (optimal 3–4) |
| `medium` | `4 ≤ score < 8` | 7–15 (optimal 4–8) |
| `hard` | `8 ≤ score < 13` | 16–25 |
| `expert` | `≥ 13` | 26–30 (locked+frozen, optimal 8–12) |

The **definitions** above are what the Tech Lead should lock; the **weights and thresholds** should live in a `DifficultyWeights` / `DifficultyThresholds` value (const defaults + a small overridable JSON in the tool) so the Level Designer can recalibrate without a code change.

## Security

* N/A as a runtime attack surface — F06 is offline tooling operated by the team on trusted inputs. The only "input validation" is structural (def-file / artifact shape). No auth, no PII, no network, no user input. `Security compliance out of scope` with this rationale (per the QA scope-matrix convention).

## Scalability

* The MVP needs ~30 Journey + ~60 Daily solves — trivial volume. The concern is per-puzzle worst-case solve time on levels 26–30, bounded by `SearchBudget`. Batch-solving all artifacts in `check` should stay well under a CI minute (each solve ≤ 30 s worst case, most < 1 s).

## Release / deployment / rollback

* Release scope: **none** — no device distribution. Content artifacts are committed to `content/`; a bad artifact is fixed by re-authoring + re-`export`, not a rollback. The `check` CI gate prevents a bad artifact from merging.
* One CI change: add `dart run looplet_authoring check content/` (or `melos` script) as a required job.

---

# 13. Dependencies

* **F01 dictionary-service (Done)** — `WordValidator` behavior for frozen-thaw + target eligibility; the production `DictionaryService` must back the validator used for shipped `optimalMoves`.
* **F02 grid-engine (Done)** — `GridState` / `applyMove` / `canonicalKey` / `EngineConfig` / `legalMoves` are the search substrate. F06 adds no engine logic.
* `platform.md` §3 dependency edges; §13 (solver direction — recommend updating).
* External: none. No third-party packages beyond `test` (dev) and possibly `args` (cdnjs/pub — a standard Dart CLI arg parser) for the CLI. **Recommend** `package:args` (official Dart team package) for the CLI; flag for Tech Lead since `looplet_engine`/`looplet_solver` must stay dependency-minimal but `tools/looplet_authoring` is a tool, not shipped.
* Downstream: F04 (`optimalMoves`), F05 (Journey artifacts), F07 (Daily pool + manifest), F08 (`Puzzle` for session restore).

---

# 14. Assumptions

* The solver runs against a `WordValidator` that mirrors production `DictionaryService`; a fake validator is acceptable only for unit tests of pure search behavior (no-frozen puzzles).
* Authoring-time RNG (grid `fill`) is allowed by `platform.md` §11 ("no runtime RNG **on device**") — it must be seeded and reproducible; `looplet_solver` and `looplet_content` use **no** RNG.
* `looplet_content` should **not** depend on `looplet_engine` (mirrors F01/F02 dependency hygiene); `Puzzle` stores raw fields and a consumer builds `EngineConfig`. `Puzzle.language` is a plain `String` validated against `{tr, en}` to avoid a `looplet_dictionary` dependency.
* `looplet_solver` should depend on `looplet_engine` **only**; the `WordValidator`→`DictionaryService` adapter lives in `tools/looplet_authoring` (which legitimately depends on `looplet_dictionary`).
* The MVP editor is **CLI-only**; a Flutter-desktop preview is a Future Consideration.
* F06's implementation delivery is the **toolchain + a small smoke set of puzzles**; authoring the full 30 Journey + ~60 Daily is a follow-on content pass (see Delivery Note) — otherwise F06 balloons and blocks on Level-Designer availability.
* Daily pool size ~60 with a date→id `manifest.json`; no-repeat window 30 days; Daily difficulty biased medium/hard (not expert — Daily has unlimited moves, so brutal puzzles only frustrate).
* `check` re-runs the solver on every artifact to detect drift between a stored `optimalMoves` and the current engine/validator behavior.

---

# 15. Open Questions

* Exact `SearchBudget` numbers — recommended `maxDepth 16 / maxNodes 5M / timeBudget 30s`; confirm during content authoring.
* Exact difficulty weights + thresholds — recommended above; recalibrate after the 30 levels exist.
* Turkish letter-frequency table — which published source (TDK / BOUN corpus / a standard table)? ~29-entry const map; Tech Lead / Level Designer to pick.
* "Misleading nonsense strings" rule strength — offensive-string guard is a must; the edit-distance-1-from-target filter is optional/toggleable — keep for MVP?
* Does F06's delivery include the full content set, or toolchain + smoke set + a separate content task? (Recommend the latter.)
* `package:args` for the CLI — acceptable in `tools/looplet_authoring`?
* `looplet_content.Puzzle` `difficultyBreakdown` — required in shipped artifacts (useful for designers / `check`) or optional?
* Should `platform.md` §13 be updated to reflect "forward BFS + bound" instead of "bidirectional BFS"? (Recommend yes.)

---

# 16. Task Breakdown

## Core / Backend tasks (pure Dart — under Frontend/Mobile Developer per `platform.md`)

* **F06.1** — `looplet_content`: `Puzzle` model + `fromJson`/`toJson` + `PuzzleType`/`DifficultyLabel` enums + `PuzzleFormatException`. Tests: lossless round-trip; reject missing `optimalMoves` / bad `schemaVersion` / bad shape / bad coord; ignore unknown keys.
* **F06.2** — `looplet_solver`: `Solver.solve` (forward BFS + `canonicalKey` visited + parent map + fixed `Move` order + `SearchBudget`) + `SolveResult` sealed types. Tests: minimality vs exhaustive-BFS reference (no-tiles / locked / 1-frozen / 2-frozen); `Unsolvable`; `BudgetExceeded`; determinism (identical `moves` + byte-identical `sequence` across runs); returned sequence uses only `applied` moves and reaches `isSolved`.
* **F06.3** — `looplet_solver.enumerateOptimalSolutions` (bounded by `cap`, deterministic order). Tests: known small puzzle with N optimal solutions; `cap` behavior.
* **F06.4** — `DifficultyScorer` + `DifficultyWeights`/`DifficultyThresholds` + the 6 metric implementations + `breakdown`. Tests: determinism; monotonicity per metric (more locked ⇒ higher score; more first-moves ⇒ lower score); documented thresholds honored; a few hand-checked reference puzzles.
* **F06.5** — `tools/looplet_authoring` CLI skeleton (`args` parser) + def-file JSON parser + `solve` / `playtest` / `export` commands + the export gate + artifact writer. Tests: CLI invoked from `dart test`; `export` exits non-zero + writes nothing on unsolvable / budgetExceeded / `optimalMoves == 0`; `playtest` step reporting; `solve` output shape.
* **F06.6** — `check` command (schema; re-verify `optimalMoves`; Journey band + `columnMovesEnabled` vs level number; Journey internal dedup; Journey↔Daily dedup; Daily manifest no-repeat-window; target eligibility for shipped artifacts) + wire `check content/` into `.github/workflows/ci.yml`. Tests: planted bad artifacts each caught with a named failure.
* **F06.7** — `fill` helper: seeded Turkish-frequency weighted sampler + offensive-string guard + optional near-target filter + bounded retry. Tests: seed reproducibility; statistical closeness to the frequency table vs uniform; no RNG outside the seeded generator.
* **F06.8** *(content pass — recommend a separate task/owner after F06.1–F06.7 are QA-approved)* — author the 30 Journey artifacts honoring the §20 curve + the Daily pool (~60) + `manifest.json`; run `check`; commit to `content/`. F06's own smoke set: ~5 Journey puzzles (one per curve band) authored during F06.5/F06.6 to exercise the pipeline end-to-end.

## Client tasks (Frontend / Game Client)

* None — F06 produces no player-facing UI. (F05 will add a loader for `content/journey/...`; F07 for `content/daily/...` — their features.)

## QA tasks

* **F06.1-QA** — solver minimality vs exhaustive reference (all tile classes); `Unsolvable` + `BudgetExceeded`; determinism + stable tie-break; returned sequence validity (only `applied` moves, reaches `isSolved`).
* **F06.2-QA** — `Puzzle` JSON lossless round-trip; rejection of missing `optimalMoves` / bad `schemaVersion` / malformed shape / bad coord; unknown-key tolerance.
* **F06.3-QA** — difficulty determinism; per-metric monotonicity; documented thresholds; `breakdown` fields present.
* **F06.4-QA** — CLI: `solve` / `playtest` / `export` / `check` / `fill` behaviors; `export` gate exit codes + no-file guarantee; `check` catches every planted bad artifact (no `optimalMoves`; level-2 with columns enabled; Journey↔Daily dup; stored optimal ≠ fresh solve; ineligible target); `fill` seed reproducibility + frequency closeness.
* **F06.5-QA** — build-time `check content/` wired into CI and green on the committed smoke set; RNG confined to `fill`.
* Evidence class: `automated functional` (`dart test` + CLI invoked from tests). No device runtime.

---

# 17. Delivery Note for Tech Lead

## Decisions the Tech Lead can LOCK into `architecture.md` now

1. **Solver = forward BFS** over `GridState.canonicalKey` visited set + parent map, fixed `Move` successor order, FIFO; first `isSolved` dequeued = provable minimum. Goal tested on dequeue (goal is a set). `SolveResult` = `Optimal(moves, sequence)` | `Unsolvable` | `BudgetExceeded(budget)`, deterministic, byte-stable `sequence`.
2. **`SearchBudget`** with defaults `maxDepth 16 / maxNodes 5,000,000 / timeBudget 30s`; `BudgetExceeded` ⇒ not publishable. (Numbers tunable; the *mechanism* is locked.)
3. **IDA*** kept only as a documented per-puzzle fallback; **bidirectional BFS from `platform.md` §13 is dropped** — recommend updating `platform.md` §13.
4. **`looplet_content` does NOT depend on `looplet_engine`**; `Puzzle` stores raw fields; a consumer builds `EngineConfig`. `Puzzle.language` is a validated `String`.
5. **`looplet_solver` depends on `looplet_engine` only**; the `WordValidator`→`DictionaryService` adapter lives in `tools/looplet_authoring`.
6. **`Puzzle` JSON shape** as in §5 (grid row strings; `"r,c"` coords; unknown keys ignored; typed `PuzzleFormatException`; `optimalMoves` required and non-nullable).
7. **CLI-only** (no desktop). Commands `solve` / `playtest` / `export` / `check` / `fill`. `export` gate: non-zero exit + no file on unsolvable / budgetExceeded / `optimalMoves == 0`. `check` is the CI content gate.
8. **Difficulty metric definitions** (§12 table) — locked. The **weights + label thresholds** — recommended values in §12, but keep them in a configurable table, recalibrated after F06.8.
9. **Content layout**: `content/journey/<lang>/levelNN.json`, `content/daily/<lang>/pool/*.json`, `content/daily/<lang>/manifest.json`. `check` enforces Journey band consistency, Journey internal + Journey↔Daily dedup, and Daily no-repeat-window (recommend 30 days).
10. **Scope split**: F06 implementation = toolchain (F06.1–F06.7) + a ~5-puzzle smoke set. The full 30 Journey + ~60 Daily authoring is a **separate content task** gated on the toolchain passing QA (recommend a Level-Designer-owned follow-on; still needed before F05/F07 ship).

## Questions that should stay OPEN (Tech Lead / Level Designer, not blocking implementation)

* Exact `SearchBudget` numbers and difficulty weights/thresholds — finalize during F06.8.
* Turkish letter-frequency table source.
* "Misleading nonsense strings" filter: keep the edit-distance-1-from-target part for MVP, or offensive-string guard only?
* MVP Daily pool size (recommend ~60) and difficulty band (recommend medium/hard).
* `difficultyBreakdown` required vs optional in shipped artifacts.
* `package:args` allowed in `tools/looplet_authoring`.

## Contract risks / architectural risks

* **Solver correctness is safety-critical for the product** (unfair stars if `optimalMoves` is wrong). Mitigation locked in: `check` re-solves every artifact in CI; QA validates minimality against an exhaustive-BFS reference. The exhaustive reference itself must be independent code (not the same BFS) — recommend a brute-force DFS-to-fixed-depth that enumerates *all* solutions ≤ some small bound for tiny test puzzles.
* **`WordValidator` drift**: shipped `optimalMoves` is only valid for the dictionary it was solved against. If the Turkish corpus changes (F01 open content item), all frozen-tile puzzles must be re-solved. `check` catches this; the process needs to be documented (re-run `export` / a `resolve` command after a dictionary bump).
* **`platform.md` §13 conflict**: the analysis contradicts the stated "bidirectional BFS" direction. Not a silent override — flagged here for the Tech Lead to update §13.

## Analyst Recommendation (summary)

* **Recommendation:** forward BFS + `SearchBudget`; `looplet_content` engine-free; `looplet_solver` dictionary-free (adapter in `tools`); CLI-only; difficulty definitions per §12 with tunable weights; F06 delivers toolchain + smoke set, full content is a follow-on.
* **Alternatives considered:** IDA* + heuristic (memory-friendly, time-risky with a weak heuristic on the hardest puzzles); bidirectional BFS (breaks on goal-is-a-set + frozen-thaw irreversibility); `looplet_content` depending on `looplet_engine` (simpler `toEngineConfig`, but breaks the dependency-hygiene pattern F01/F02 established).
* **Trade-offs:** forward BFS trades memory for guaranteed-simple correctness — acceptable at authoring time with the node/time cap; the smoke-set scope split trades "F06 ships all content" for "F06 ships a proven pipeline fast" and unblocks the Tech Lead to sequence F03/F08 in parallel with content authoring.

---

# 18. Sonraki Komut

```
Run Tech Lead
```

Tech Lead için bağlam: bu analizi incele; §17'deki "LOCK" maddelerini `architecture.md` içine taşı; "OPEN" maddelerini açık bırak; `platform.md` §13'ü güncellemeyi değerlendir; F06 implementasyon planını (F06.1–F06.7 + smoke set; full content ayrı task) oluştur ve FE/QA task'larını aç.

---

# 19. Orchestration Signals for Tech Lead

* Analysis ready: **Yes** — all 7 open items have options + a marked recommendation; functional breakdown, edge cases, and task breakdown included.
* Blocker: **None** — F01 + F02 are Done; the solver substrate exists and is QA-approved.
* Product clarification needed: **No** — no `prd.md` vs product-PRD conflict found. (The Turkish-frequency table source and the exact Daily pool size are Level-Designer choices, not product-authority questions.)
* Tech Lead decision needed: **Yes** — lock the §17 items into `architecture.md`; decide the smoke-set scope split; decide whether to amend `platform.md` §13.
* Ready for contract planning: **Yes.**
