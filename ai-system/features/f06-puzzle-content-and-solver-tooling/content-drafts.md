# F06-CONTENT-DRAFT — delivery report

**Role:** Frontend/Mobile Developer · **Task:** `F06-CONTENT-DRAFT` (Tech Lead
Incident Intake, 2026-09-09) · **Date:** 2026-09-10

**Spec:** `features/f06-puzzle-content-and-solver-tooling/content-authoring-brief.md`
(within its §13 "AI assistance for drafts only" allowance).

> **This pass does NOT close or advance F05.** It produces **candidate** Journey
> grids as a starting point for the human (Level Designer / user) playtest +
> difficulty-curve sign-off. Nothing here is shippable content. F05 stays
> `In Progress`, held on `F06-CONTENT`. F09 not activated.

---

## 1. What was produced

All under **`tools/looplet_authoring/drafts/journey/`** — a new, quarantined tree.
Nothing under `content/`, `app/assets/journey/`, or `app/` was touched.

| Path | Contents |
|------|----------|
| `drafts/journey/tr/journey-tr-01.json … journey-tr-30.json` | 30 candidate `Puzzle` artifacts. Built in-process (not by hand) — `PuzzleDef.toPuzzle(optimalMoves, difficulty, contentVersion: "draft")` with a **solver-verified** `optimalMoves` and a `DifficultyScorer` score/label/breakdown, same code path as `export`. |
| `drafts/journey/_defs/journey-tr-01.def.json … -30.def.json` | The definition inputs (`id`, `puzzleType`, `journeyLevelNumber`, `language`, `grid`, `target`, `locked`, `frozen`, `columns`). Re-run or re-tune any level from these. |
| `drafts/journey/journey_manifest_tr.draft.json` | Draft manifest — 30 contiguous entries (`n` / `id` / `asset` / `difficultyLabel` / sha256 `checksum`), `mode: "smoke"`. **Not** the shipped strict manifest. |
| `drafts/journey/REVIEW.md` | Per-level table (opt / label / score / locked / frozen / columns / scramble-k / seed) + **8 gaps & open questions** for the human + a "Next" checklist. |
| `drafts/journey/.run.log`, `.run2.log`, `.run3.log` | Generator accept-traces (per-level reason / timing / seed). |
| `tools/looplet_authoring/tool/generate_journey_drafts.dart` | The generator (see §2). A `tool/` script — never shipped, not wired into `melos`. |

### Deviation from the brief's file layout

The brief said "all under `tools/looplet_authoring/drafts/journey/tr/`". The draft
**manifest** and `_defs/` live one level up (`drafts/journey/`), not inside `tr/`,
because `check <dir>` recursively parses **every** `.json` under the directory and
tries `Puzzle.fromJson` on each — a manifest (no `assignments` key) would fail that
parse. Keeping `tr/` as a pure directory of `Puzzle` artifacts is what lets
`check drafts/journey/tr` run clean. Flagged here for the Tech Lead; trivially
moved if a different convention is preferred.

---

## 2. Method

A single Dart script, `tool/generate_journey_drafts.dart`, run in-process
(`import 'package:looplet_solver/…'` etc.) — no shelling to the CLI per level.

1. **Level → target.** Level `N` → `dictionary.json` `targets[N-1]`, uppercased
   (`TurkishCase.toUpperTr`). The 30 designated targets map 1:1 to levels 1–30.
   The script carries the target list as a literal and **aborts** if it drifts
   from the shipped dictionary order.
2. **Backward construction.** Build a *solved* 5×5 grid (target in a seeded row,
   seeded common-Turkish-letter filler elsewhere; optional locked cells on the
   target row with their letter already correct; optional frozen cells on a
   non-target row). Then **scramble** it with `k` raw cyclic shifts that mirror
   `GridState.applyMove` exactly (movable positions rotate, locked/frozen stay;
   column shifts only when `columnMovesEnabled`).
3. **Verify.** `Solver.solve` on the scrambled grid → the **provable** optimal.
   Accept iff: solvable within budget, not already solved, `optimal` in the
   band's window, **and** `DifficultyScorer`'s label ∈ `check`'s expected band
   for that level (the gate CI actually enforces — replicated in the script).
4. **Rejection-sample** across seeds / scramble depths until a candidate passes,
   then emit the artifact + def + manifest entry (sha256 via `shasum`).
5. `REVIEW.md` + a re-run of `check drafts/journey/tr`.

Backward construction (vs `fill` + hand-solving) was chosen because it guarantees
solvability and gives a known-good difficulty distribution to sample from. `fill`
is still the right tool for a *human* starting a grid by hand; the generator's
filler is the same frequency idea without the CLI round-trip.

---

## 3. Per-band outcome

| Band | Levels | Structure | opt produced | Label | Brief §4 target opt | Match? |
|------|--------|-----------|--------------|-------|---------------------|--------|
| on-ramp | 1–3 | columns **off** | **2** | easy | {3,4} | **NO — capped, see gap #1** |
| columns in | 4–6 | columns on | 3–4 | easy | 3–5 | yes |
| free play | 7–10 | columns on | 4 | easy | 4–6 | yes |
| free play, hard reachable | 11–15 | columns on | **5** | easy/medium | 6–8 | **short — see gap #7** |
| locked | 16–20 | 1 locked (target row) | 4–5 | medium | 6–9 | **short (opt); label OK** |
| frozen | 21–25 | 1 frozen (non-target row) | 4–5 | medium | 7–10 | **short (opt); label OK** |
| locked + frozen | 26–30 | 2 locked + 2 frozen | 5 | **hard** | 8–12 | **short (opt); label OK** |

Every level's **label** is inside `check`'s expected set for its level number, so
`check` passes. The **`optimalMoves` depth** falls short of the brief's ranges
from level 11 on — a deliberate trade documented as gap #7 (`DifficultyScorer`
runs three *unbudgeted* BFS passes to `optimal` depth; past optimal ≈ 6 with
column moves each candidate costs minutes). The deep bands hit their required
label through the locked/frozen score terms instead of raw depth. Raising the
real depth is a hand-tune / a solver-perf task, not a generator tweak.

---

## 4. Gate results

| Gate | Result |
|------|--------|
| `dart run bin/looplet_authoring.dart check drafts/journey/tr --repo-root ../..` | **`check: OK`** (all 30) — clean run, machine idle. Also `check: OK` from an AOT `dart compile exe` build. |
| `dart analyze` — `tools/looplet_authoring` + `looplet_{core,engine,content,solver,dictionary}` | clean (the one pre-existing `looplet_solver` `curly_braces` info is not from this pass) |
| `dart format --output=none --set-exit-if-changed tools/looplet_authoring/` | clean |
| `dart test` (`tools/looplet_authoring`) | 19 / 19 pass |
| `dart run … check ../../content` (the real `content:check` target) | `check: OK` — unaffected (drafts are not under `content/`) |
| `flutter analyze` (app) | `No issues found!` |
| `flutter test test/journey` (F05 suite) | 41 / 41 pass |

**Not run this turn:** the full `melos run test` (every package + `flutter test`
whole-app) and `flutter build`. Rationale: the only files added are a non-shipped
`tools/` script and a quarantined `drafts/` tree — no `lib/`, no `app/`, no
`pubspec`, no `melos.yaml` change — so the whole-app suite result is unchanged
from `main`. Flagged for the Tech Lead to confirm / run if the exit-criteria bar
is strict.

### ⚠️ `check` under machine load (REVIEW.md gap #7)

On a loaded workstation (`load avg 8+`), `check drafts/journey/tr` intermittently
reported `budgetExceeded on re-solve` on a **different** 2–5 level subset each run
(`Solver.solve`'s default `SearchBudget.timeBudget` is 30 s wall-clock; ~30 s of
*user* CPU was burned over a ~60-min wall window at `0% cpu`). A shifting failure
set = **wall-clock starvation**, not a node wall (deterministic) or an unsolvable
grid (the generator proved every one `Optimal` in < 6 s of dedicated CPU). On an
idle machine it is `check: OK`. **Before promotion**, run `check` on an idle box /
a CI runner; if deep levels still flirt with 30 s, bump `SearchBudget.timeBudget`
(brief §8) and/or ship an AOT `check` in CI (brief §11).

---

## 5. What the human must still do to promote these to shippable content

Per `REVIEW.md` "Gaps & open questions" (8 items) — the headline ones:

1. **Levels 1–3 ship `opt 2`, not 3–4.** A pure rows-only 5×5 with a 5-letter
   target can never exceed `optimal 2` (`min(k, 5-k) ≤ 2`). Decide: accept
   `opt 2` as the tutorial on-ramp / add one locked tile at 1–3 to force a
   3-step row solve / shorten the early targets (dictionary change).
2. **Frozen tiles are cosmetic** in bands 21–30 — placed on a *non-target* row so
   solvability is guaranteed. A real frozen-gated design needs the tile on the
   target row + a guaranteed in-row thaw word; `fill --frozen-safe` (the intended
   helper) is a **no-op stub** today.
3. **Difficulty depth 11→30 is short of the brief** (gap #7). Hand-deepen or wait
   on a solver-perf pass.
4. **Curve is banded, not tuned.** L13 landed `easy`; 11/14/15 and 22–25 are flat.
   Playtest, then re-order / re-scramble and re-assign level numbers.
5. **Filler letters are frequency-random**, screened only for "no row is a target
   rotation" — a readability pass will help.
6. **Tunables are all at `const` defaults** — brief §8 finalization is still open.

Then the unchanged **F05 `Done` path**: promote accepted drafts to
`content/journey/tr/journey-tr-NN.json` + a `mode:"strict"` `journey_manifest_tr.json`
→ `melos run content:check` + `melos run content:journey` green → brief §9 cutover
(`content:sync` mirror; delete the 5 interim smoke copies) → `Run QA` (F05 strict
pass) → `Run Tech Lead` (**F05 → `Done`**).

---

## 6. Files changed

**Added (all untracked, nothing committed):**

- `tools/looplet_authoring/tool/generate_journey_drafts.dart`
- `tools/looplet_authoring/drafts/journey/tr/journey-tr-{01..30}.json`
- `tools/looplet_authoring/drafts/journey/_defs/journey-tr-{01..30}.def.json`
- `tools/looplet_authoring/drafts/journey/journey_manifest_tr.draft.json`
- `tools/looplet_authoring/drafts/journey/REVIEW.md`
- `tools/looplet_authoring/drafts/journey/.run{,2,3}.log`
- `ai-system/features/f06-puzzle-content-and-solver-tooling/content-drafts.md` (this file)

**Edited:** `ai-system/features/f05-journey-progression/orchestration.md` (close
`F06-CONTENT-DRAFT`, Current Owner → Tech Lead, Change Log). No shipped code, no
`pubspec`, no `melos.yaml`, no `content/`, no `app/`.

---

## 7. Next command

`Run Tech Lead` — reconcile the draft pass, then hand back to the Level Designer /
user for playtest + curve sign-off (the F05 `Done` path is unchanged).
