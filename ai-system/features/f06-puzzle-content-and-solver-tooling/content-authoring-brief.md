# F06-CONTENT — Journey Level Authoring Brief (the 30 handcrafted levels)

> **Tech Lead brief, 2026-09-09.** Produced at the F05-QA re-verify close-out (DURUM 5 "Approved with Notes") — F05 is **code-complete + QA-passed against the interim `mode:"smoke"` content**; its only remaining `Done` gate is `F06-CONTENT`. This document is the concrete, executable specification for the **30 Journey levels** portion of `F06-CONTENT`.
>
> **This is not implementation-role work.** Authoring 30 handcrafted puzzles — grid design, target-word choice, the difficulty curve, playtest tuning — is a **human content deliverable with no canonical role** (owner: **Level Designer / the user**; `product-prd.md` Global Risk: "manual and playtest-heavy"). An AI role may generate *draft* candidate grids via the `tools/looplet_authoring` CLI, but every shipped level needs a human playtest + curve-feel judgement before commit.
>
> Authorities consumed: `features/f06-.../architecture.md` (the `Puzzle` schema + the CLI + `export`/`check` gates — LOCKED & CLOSED); `features/f05-journey-progression/architecture.md` §4 (id scheme), §5.2 (manifest schema), §5.4 (the build gate + band rules), §5.5 (the interim mapping being replaced); `product-prd.md` §20 curve / AC3–AC6; `f01` `isEligibleTarget`. This brief adds **no new contract** — it restates the locked constraints in checklist form.

---

## 1. What this unblocks

* **F05 → `Done`** requires: the real 30 Journey levels + a `mode:"strict"` `journey_manifest_tr.json`, committed under `content/journey/tr/`, green through F06's `check` **and** F05's `melos run content:journey` strict gate (which now has executed failure coverage — F05-QA-2).
* **F07 (daily-challenge)** later needs a separate ~60-puzzle **Daily** pool + `content/daily/tr/manifest.json` — **out of scope for this brief** (see §12); do not block F05 on it.
* F05's app code, resolver, unlock, navigation, tutorial, home, and CTA weighting are all done and QA-passed — **no F05 code change is expected** from this work. If a level's structure surfaces an app bug, that is a new F05 finding, not part of authoring.

---

## 2. Deliverables (exact)

Commit under **`content/journey/tr/`** (currently just a `.gitkeep`):

| File | Count | Notes |
| --- | --- | --- |
| `journey-tr-01.json` … `journey-tr-30.json` | 30 | one `Puzzle` artifact per level, produced by `looplet_authoring export` (never hand-written) |
| `journey_manifest_tr.json` | 1 | `mode: "strict"`, `schemaVersion: 1`, 30 contiguous `levels[]` entries with `checksum` (sha256 of the asset bytes) |

**Then** (the interim → strict cutover — see §9): `melos run content:sync` mirrors `content/journey/tr/**` → `app/assets/journey/tr/**`, **replacing** the 5 interim re-`id`'d smoke copies + the interim `mode:"smoke"` manifest that F05-FE shipped.

`content/smoke/tr/level*.json` (the F06 smoke set) stays as-is — it is F06's own test fixture, unrelated to Journey shipping content.

---

## 3. Hard constraints (from `f05 architecture.md §4` + `f06 architecture.md` — non-negotiable, `check`/gate-enforced)

### 3.1 Identity

* Every artifact: `puzzleType: "journey"`, `id == "journey-tr-<NN>"` (zero-padded two digits — `journey-tr-01`, …, `journey-tr-30`), `journeyLevelNumber == <N>` (the integer, `1..30`), `language: "tr"`.
* **`Puzzle.id` is a durable key** — F04's `personal_best.levelId` and F03/F08 snapshot resume both key on it. **Once a level ships, its id must never change** (changing it orphans that player's best + any in-progress save). Get the id ⇄ number mapping right the first time; it is fixed for the life of the app.
* The manifest's `levels[n].id` must equal the asset's `puzzle.id` must equal `journey-tr-<NN>` — the F05 gate asserts all three are identical (`journey_gate_support.dart`).

### 3.2 Schema (every artifact — `Puzzle.fromJson` throws `PuzzleFormatException` otherwise)

Required fields: `schemaVersion` (int, `1`), `contentVersion` (String — use one value across the whole pack, e.g. `"2026.10-journey"`), `id`, `puzzleType` (`"journey"`), `journeyLevelNumber` (`1..30`), `language` (`"tr"`), `grid` (5 row strings, 5 chars each), `targetWord` (5 uppercase Turkish letters), `lockedCells` + `frozenCells` (each a list of `"row,col"` strings, `0`-indexed), `columnMovesEnabled` (bool), **`optimalMoves` (int ≥ 1 — solver-verified; the artifact is invalid without it — `export` writes it, never you)**, `difficultyScore` (num — `export` computes it), `difficultyLabel` (`"easy"` | `"medium"` | `"hard"` | `"expert"`), **`difficultyBreakdown`** (object — required; `export` writes it).

### 3.3 Manifest (`journey_manifest_tr.json`, `f05 architecture.md §5.2`)

```json
{
  "schemaVersion": 1,
  "contentVersion": "2026.10-journey",
  "lang": "tr",
  "mode": "strict",
  "levels": [
    { "n": 1, "id": "journey-tr-01", "asset": "tr/journey-tr-01.json",
      "difficultyLabel": "easy", "checksum": "<sha256 hex of tr/journey-tr-01.json bytes>" },
    ...  // n contiguous 1..30; exactly 30 entries
  ]
}
```

* `mode` MUST be `"strict"` for the shipped pack — the F05 gate then **fails CI** on `< 30` levels, a missing/unresolvable asset, an id-scheme break, `optimalMoves < 1`, or a checksum mismatch.
* `asset` is `"tr/journey-tr-<NN>.json"` (relative to `assets/journey/` in the app bundle / `content/journey/` at source).
* `checksum` = the sha256 of the exact asset file bytes. Regenerate it whenever a level file changes (any re-`export`).

---

## 4. The difficulty curve — band by band

Source: `product-prd.md` §20 / AC3–AC6, `f05 architecture.md §5.4`. The F06 `check` enforces the **structural** rules (columns / locked / frozen) + the `difficultyLabel` band; the **optimal-move ranges and the "one new idea at a time" feel** are the human playtest's job.

| Levels | `columnMovesEnabled` | `lockedCells` | `frozenCells` | `optimalMoves` (target) | `difficultyLabel` | The one new idea | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **1–3** | **`false`** (gate-enforced) | empty | empty | **3–4** (gate-enforced: `∈ {3,4}`) | `easy` | row shifts only; "every move counts" | Level 1 is the very first real puzzle a player sees — make it legible and winnable, opt exactly 3. |
| **4–6** | **`true`** | empty | empty | 3–5 | `easy` | **column shifts** — F05 shows the micro-tutorial on first entry to this band | At least one level here must be genuinely solvable *only* with a column move (so the tutorial's gated column drag has a point). |
| **7–10** | `true` | empty | empty | **4–6** | `easy` → `medium` | rows + columns combined; misleading intermediate states | The ramp from "learned columns" to "must plan a 2-axis route". |
| **11–15** | `true` | empty | empty | **6–8** | `medium` | **heavy temporary displacement** — the optimal route requires moving a correct tile *away* before bringing it back | Not a hard structural check — it is a difficulty-score / playtest property. **Perf risk zone** — see §11. |
| **16–20** | `true` | **non-empty** (gate-enforced) | empty | 6–9 | `medium` → `hard` | **locked tiles** — immovable fixed points the movable subsequence rotates around | Use 1–2 locked cells early in the band, more later. |
| **21–25** | `true` | empty | **non-empty** (gate-enforced) | 7–10 | `hard` | **frozen tiles** — thaw only when a row forms a valid word (F01/F02 rule); branching on thaw order | Start with one frozen tile; by 25 a two-frozen-in-a-row thaw is fair. |
| **26–30** | `true` | **non-empty** | **non-empty** (both gate-enforced) | 8–12 | `hard` → `expert` | **locked + frozen combined** — the campaign's hardest puzzles | Level 30 is the finale — hard but fair; the terminal state rewards finishing it. |

**Curve principles (playtest-owned):**
* Monotonic non-decreasing difficulty *feel* across the 30 (small dips are OK inside a band, never a cliff).
* Each band introduces **exactly one** new mechanic; earlier mechanics recur.
* No two Journey puzzles identical (`check`-enforced); no Journey puzzle identical to a smoke puzzle.
* `product-prd.md §41` KPI context: **Level 5 Reach > 60 %** — levels 1–5 must be gentle enough that a first-session player clears them; this band drives the validation gate.

---

## 5. Turkish target-word rules

* `targetWord` is 5 letters, uppercase, Turkish alphabet (note İ/I, Ş, Ğ, Ç, Ö, Ü — Turkish-locale case, `looplet_core` `TurkishCase`).
* Must be **`isEligibleTarget`** per F01's `DictionaryService` (a real, non-proper, non-profane, non-abbreviation Turkish word present in the shipped corpus). `check` fails a shipped artifact whose `targetWord` is not dictionary-eligible.
* The word must be **formable** in the grid (the solver proves a finite `optimalMoves`); `export` refuses `unsolvable` / `optimalMoves == 0`.
* Prefer common, recognisable words for the early bands; the difficulty comes from the grid + tiles, not from an obscure target.
* F01's production Turkish corpus is itself a Product Owner / content follow-on — if a desired target word is missing, that is an F01 corpus request, not a reason to ship an ineligible word.

---

## 6. The authoring workflow (per level)

All commands from `tools/looplet_authoring/` (or `melos exec --scope="looplet_authoring" -- "dart run bin/looplet_authoring.dart <cmd>"`):

1. **Draft a definition file** — JSON: `{ id, puzzleType: "journey", journeyLevelNumber: <N>, language: "tr", grid: [...5 rows...], target: "<WORD>", locked: [...], frozen: [...], columns: <bool> }`. (`fill --seed <n> [--frozen-safe] [--avoid-near-target]` prints a seeded Turkish-frequency candidate grid to start from.)
2. **`solve <def.json>`** — prints solvable? / `optimalMoves` / `unsolvable` / `budgetExceeded`, the difficulty score + label + breakdown, and one optimal sequence (shorthand `R0 D2 L4 …`). Iterate the grid/tiles until `optimalMoves` lands in the band's target range and the label matches the band.
3. **`playtest <def.json> --moves "R0 D2 L4 …"`** — apply a sequence through the real engine; per-step `applied`/`rejected` + reason, final `isSolved`. Sanity-check the intended solution *and* a plausible player mis-route (does it dead-end cleanly? is there a misleading near-miss?).
4. **Human playtest** — actually play it. Is the "one new idea" clear? Is it the right hardness for its position? Does an optimal solve *feel* like the optimal? Adjust and re-`solve`.
5. **`export <def.json> --out content/journey/tr/journey-tr-<NN>.json`** — runs `solve` with the **production** `WordValidator`; on `Optimal` with `moves > 0` writes the full `Puzzle` artifact (fresh difficulty score + breakdown). **Non-zero exit + no file** on `unsolvable` / `budgetExceeded` / `optimalMoves == 0` / malformed def.
6. Repeat for all 30. Keep the def files (a `content/journey/tr/_defs/` dir or similar) so levels can be re-`export`ed after a dictionary corpus change.
7. **Write `journey_manifest_tr.json`** (§3.3) — `mode: "strict"`, 30 entries, fresh sha256 checksums.
8. **`check content/`** (`melos run content:check`) — validates every artifact: schema; stored `optimalMoves` == a fresh solve; levels 1–3 `columnMovesEnabled == false`; `difficultyLabel` in the §20 band for the level number; no two Journey puzzles identical; no Journey ↔ smoke dup; `targetWord` dictionary-eligible. **Must be green.**

---

## 7. Per-level acceptance checklist

For each `journey-tr-<NN>.json`:

- [ ] `id == "journey-tr-<NN>"`, `journeyLevelNumber == <N>`, `puzzleType == "journey"`, `language == "tr"`
- [ ] `grid` is 5×5, `targetWord` is 5 letters + `isEligibleTarget`
- [ ] band structural rules hold (columns / locked / frozen per §4)
- [ ] `optimalMoves` in the band's target range; `optimalMoves >= 1`; written by `export` (solver-verified)
- [ ] `difficultyLabel` in the §20 band for `<N>`; `difficultyScore` + `difficultyBreakdown` present (written by `export`)
- [ ] not identical to any other Journey level or any smoke level
- [ ] one human playtest done — the new idea reads, the hardness fits the position, an optimal solve feels optimal
- [ ] level 4–6: at least one in the band genuinely needs a column move
- [ ] level 1: opt exactly 3, maximally legible (first real puzzle)
- [ ] level 30: hard-but-fair finale

Pack-level:
- [ ] `journey_manifest_tr.json`: `mode: "strict"`, exactly 30 contiguous entries, correct `asset` paths, fresh sha256 checksums
- [ ] `melos run content:check` green
- [ ] monotonic difficulty *feel* across the 30 (full playthrough)

---

## 8. Tunable values to finalize here (carried from the F06 close-out — `f06 orchestration.md → Open Tasks → Content`)

Authoring is the point where these locked-as-*definitions* values get their final *numbers*:

* **`SearchBudget`** — `maxDepth` / `maxNodes` / `timeBudget`. Default (`maxDepth 16` / `maxNodes 5M` / `30 s`) is fine for locked/frozen levels; the fully-open 11–15 band (opt 6–8) is the cost risk (§11). Bump `timeBudget` per-machine or AOT-compile `export` if a level `budgetExceeded`s; a level that cannot be proven minimal within budget is **not shippable** (redesign it).
* **`DifficultyWeights` / `DifficultyThresholds`** — the score → label mapping. Tune so the §20 bands land on `easy/medium/hard/expert` as intended; `check` enforces label ↔ band once tuned.
* **Turkish letter-frequency table** for `fill` — pick the corpus/source; `fill` RNG stays seeded + reproducible.
* Decision on **`fill --frozen-safe`** — implement it properly or drop the flag (currently a no-op stub).

Record the final values in `f06 architecture.md` "Open Technical Decisions" (they are *values*, not contract changes) or a short note in this file.

---

## 9. Interim → strict cutover (what changes when this lands)

F05-FE shipped an **interim** pack that this work replaces:
* `app/assets/journey/tr/journey-tr-01..05.json` — re-`id`'d copies of `content/smoke/tr/level{01,02,04,05,06}.json` (they do **not** meet the band rules — the interim manifest `_note` says so).
* `app/assets/journey/tr/journey_manifest_tr.json` — `mode: "smoke"`, 5 entries.
* `melos.yaml` `content:sync` — a **documented no-op stub** (`content/journey/` was empty).

Cutover steps:
1. Author + `export` all 30 into `content/journey/tr/` (§6).
2. Write `content/journey/tr/journey_manifest_tr.json` with `mode: "strict"` (§3.3).
3. **Make `melos run content:sync` real** — it already contains the `rsync content/journey/ → app/assets/journey/` body guarded by `if [ -d content/journey ]`; with real files present it now mirrors. Run it; it replaces the 5 interim files + the interim manifest under `app/assets/journey/tr/`. Delete any stale interim file it does not overwrite.
4. `melos run content:check` (F06 gate) + `melos run content:journey` (F05 strict gate) + `melos run test` + `flutter build ios --release --no-codesign` — all green.
5. **Then** `Run QA` (F05 strict-content pass — the strict gate green + the band rules + a full regression) → `Run Tech Lead` (**F05 → `Done`**).

The known interim edge (`qa.md §17` N1 — a player who beats all 5 interim levels while not at 30/30 gets `continueTarget = 6` → load error) **disappears** once all 30 exist: `continueTarget` only exceeds 30 when `allComplete` (→ terminal). No app change needed.

---

## 10. Definition of Done (F06-CONTENT — Journey portion)

* 30 `content/journey/tr/journey-tr-01..30.json` artifacts, each `export`-produced, band-compliant, human-playtested.
* `content/journey/tr/journey_manifest_tr.json` — `mode: "strict"`, 30 contiguous entries, fresh checksums.
* `melos run content:check` green (F06 gate); `melos run content:journey` green in strict mode (F05 gate); `melos run test` + iOS release build green.
* Committed under `content/`; `content:sync` mirror run so `app/assets/journey/tr/` holds the real 30.
* Tunable values (§8) finalized and recorded.
* → `Run QA` (F05 strict pass) → `Run Tech Lead` (F05 `Done`).

---

## 11. Perf note (levels 11–15)

`f06 frontend.md §13` / F06 Global Risks: a fully-open 5×5 with `optimalMoves 5` solves in ~4.6 s JIT; the 11–15 band (fully open, target opt 6–8) is where `export`/`check` can get slow or `budgetExceeded`. Mitigations, in order: AOT-compile `export` (`dart compile exe`); bump `SearchBudget.timeBudget` on the authoring machine; lean on the fact that 16–30 (locked/frozen) prune faster. A level that cannot be proven minimal within a sane budget is a **design problem** — redesign it (fewer plausible routes, a locked tile to prune the space), don't ship an unverified `optimalMoves`.

---

## 12. Daily pool (~60) — NOT this brief

`F06-CONTENT` also owes F07 a ~60-puzzle **Daily** pool + `content/daily/tr/manifest.json` (no-repeat window, `puzzleType: "daily"`, `dailyDate`, Journey↔Daily dedup via `check`). **F07 is Not Started and well downstream** — do not author Daily content now, and do not block F05 on it. When F07 activates, a separate brief covers it.

---

## 13. Ownership & how to proceed

* **Owner:** Level Designer / the user. No canonical AI role authors shippable puzzle content.
* **AI assistance is allowed for drafts only:** an implementation-style pass may use `fill` + `solve` + `playtest` to produce *candidate* grids and a first-cut manifest, but every level still needs a human playthrough + curve-feel sign-off before commit, and the user owns the final call on each level.
* **To resume F05 toward `Done`:** author the 30 levels per this brief → commit under `content/journey/tr/` → run the §9 cutover → `Run QA` → `Run Tech Lead`.
* **While this is outstanding:** F05 holds at `In Progress` (code-complete + QA-passed, `Done` awaiting content). F09 is **not** activated (F05 is the active feature until it closes).
