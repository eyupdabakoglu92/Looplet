# F07 — daily-challenge: Content Design

Role: Content Designer · Task: F07-CONTENT · Date: 2026-09-29 · Base: `ece09df` + the working tree below

---

## 1. Scope and traceability

| Brief item | Asset | State |
| --- | --- | --- |
| 1. 60 pool puzzles, 2026-11-01 … 2026-12-30 | `content/daily/tr/pool/daily-tr-2026-11-01.json` … `daily-tr-2026-12-30.json` (60 files) | Done. Each file was written by `looplet_authoring export` from its def, with `--content-version 2026-11-01.1`; none is hand-written. Each is `puzzleType: daily`, `dailyDate` = its day, `id: daily-tr-<date>`, `language: tr`. |
| 2. The definition files | `tools/looplet_authoring/drafts/daily/tr/_defs/daily-tr-<date>.def.json` (60 files) | Done. They live outside `content/` (A3 ruling 1). They are the re-export and re-date source. |
| 3. The manifest | `content/daily/tr/daily_manifest_tr.json` | Done. `schemaVersion 1`, `lang tr`, `contentVersion 2026-11-01.1`, `numberingEpoch 2026-11-01`, 60 contiguous assignments by id. |
| 4. This report | `features/f07-daily-challenge/content-design.md` | Done. |

**AC coverage:**

* **AC2** (one puzzle per language and date): each date has exactly one pool puzzle, and all are served from one pack.
* **AC3** (5×5, 5-letter target): every grid is 5×5 and every target has 5 letters; the session rules are F03's.
* **Product F06** ("must not duplicate Journey puzzles or repeat within a rolling window"): enforced by `check`, and stricter here (A3 ruling 3).

---

## 2. How the pool was made

**Drafting:**

* Drafts were produced by backward construction with a scratch authoring script. It is outside the repository and is not a tool: it follows the method of `tool/generate_journey_drafts.dart`, through the `looplet_authoring` / `looplet_solver` public library.
  1. Place the target in a random row and fill the other rows from the Turkish common-letter pool (no row is a target rotation).
  2. Place the class's locked cells on correct target-row letters, and its frozen cells in one non-target row (the Journey pattern).
  3. Apply a raw scramble of opt-floor + 1 or + 2 moves, with at least one column move.
  4. Prove the optimum with `Solver.solve` (6 s / 600 k nodes).
  5. Keep the candidate only if the optimum is in the class window and `DifficultyScorer` says `medium` or `hard`.
* The seeds are deterministic, and the first accepted seed was kept.
* Generation took about 21 min. An open day at 5 moves takes about 40 s per accepted candidate, mostly the scorer.

**Artifacts and ordering:**

* The committed artifacts come from the real CLI: `export` re-solves with the default budget and re-scores. 60 of 60 were written, with exit 0, in 19.5 min.
* The target order is the 30 dictionary targets shuffled with a fixed seed. Days 1–30 use that order, and days 31–60 repeat it, so each word comes back exactly 30 days later (§4).
* **Weekly mechanic rhythm (by weekday):**

  | Day | Class |
  | --- | --- |
  | Mon | open, opt 5–6 |
  | Tue | locked (1 cell) |
  | Wed | frozen (1 cell) |
  | Thu | open |
  | Fri | locked (2 cells) |
  | Sat | locked + frozen (2 / 2), the week's densest day |
  | Sun | frozen (2 cells) |

  Locked and frozen days use opt 4–5.

---

## 3. Per-day table

| # | Date | Day | id | Target | Class (L/F) | opt | Label | Score |
| ---: | --- | --- | --- | --- | --- | ---: | --- | ---: |
| 1 | 2026-11-01 | Sun | `daily-tr-2026-11-01` | BALIK | frozen (0/2) | 4 | medium | 6.214 |
| 2 | 2026-11-02 | Mon | `daily-tr-2026-11-02` | RESİM | open (0/0) | 5 | medium | 4.635 |
| 3 | 2026-11-03 | Tue | `daily-tr-2026-11-03` | DAMLA | locked (1/0) | 4 | medium | 4.319 |
| 4 | 2026-11-04 | Wed | `daily-tr-2026-11-04` | BADEM | frozen (0/1) | 4 | medium | 4.836 |
| 5 | 2026-11-05 | Thu | `daily-tr-2026-11-05` | KALEM | open (0/0) | 5 | medium | 4.267 |
| 6 | 2026-11-06 | Fri | `daily-tr-2026-11-06` | ROMAN | locked (2/0) | 4 | medium | 5.433 |
| 7 | 2026-11-07 | Sat | `daily-tr-2026-11-07` | BAHÇE | locked+frozen (2/2) | 4 | medium | 7.165 |
| 8 | 2026-11-08 | Sun | `daily-tr-2026-11-08` | ZEMİN | frozen (0/2) | 4 | medium | 6.224 |
| 9 | 2026-11-09 | Mon | `daily-tr-2026-11-09` | TABAK | open (0/0) | 5 | medium | 4.44 |
| 10 | 2026-11-10 | Tue | `daily-tr-2026-11-10` | DENİZ | locked (1/0) | 4 | medium | 4.629 |
| 11 | 2026-11-11 | Wed | `daily-tr-2026-11-11` | TARİH | frozen (0/1) | 5 | medium | 5.829 |
| 12 | 2026-11-12 | Thu | `daily-tr-2026-11-12` | LİMON | open (0/0) | 5 | medium | 4.473 |
| 13 | 2026-11-13 | Fri | `daily-tr-2026-11-13` | ORMAN | locked (2/0) | 4 | medium | 5.265 |
| 14 | 2026-11-14 | Sat | `daily-tr-2026-11-14` | BULUT | locked+frozen (2/2) | 4 | medium | 6.718 |
| 15 | 2026-11-15 | Sun | `daily-tr-2026-11-15` | ŞEKER | frozen (0/2) | 4 | medium | 6.051 |
| 16 | 2026-11-16 | Mon | `daily-tr-2026-11-16` | TAVUK | open (0/0) | 5 | medium | 4.069 |
| 17 | 2026-11-17 | Tue | `daily-tr-2026-11-17` | ZAMAN | locked (1/0) | 4 | medium | 4.655 |
| 18 | 2026-11-18 | Wed | `daily-tr-2026-11-18` | ÇORAP | frozen (0/1) | 4 | medium | 4.849 |
| 19 | 2026-11-19 | Thu | `daily-tr-2026-11-19` | KABAK | open (0/0) | 5 | medium | 4.815 |
| 20 | 2026-11-20 | Fri | `daily-tr-2026-11-20` | MASAL | locked (2/0) | 5 | medium | 6.094 |
| 21 | 2026-11-21 | Sat | `daily-tr-2026-11-21` | FIRIN | locked+frozen (2/2) | 4 | medium | 7.519 |
| 22 | 2026-11-22 | Sun | `daily-tr-2026-11-22` | KAĞIT | frozen (0/2) | 5 | medium | 5.904 |
| 23 | 2026-11-23 | Mon | `daily-tr-2026-11-23` | KİTAP | open (0/0) | 5 | medium | 4.443 |
| 24 | 2026-11-24 | Tue | `daily-tr-2026-11-24` | SOKAK | locked (1/0) | 4 | medium | 4.514 |
| 25 | 2026-11-25 | Wed | `daily-tr-2026-11-25` | MAKAS | frozen (0/1) | 4 | medium | 4.512 |
| 26 | 2026-11-26 | Thu | `daily-tr-2026-11-26` | YATAK | open (0/0) | 5 | medium | 4.471 |
| 27 | 2026-11-27 | Fri | `daily-tr-2026-11-27` | SALON | locked (2/0) | 4 | medium | 5.542 |
| 28 | 2026-11-28 | Sat | `daily-tr-2026-11-28` | SEPET | locked+frozen (2/2) | 4 | medium | 7.669 |
| 29 | 2026-11-29 | Sun | `daily-tr-2026-11-29` | ASLAN | frozen (0/2) | 4 | medium | 5.658 |
| 30 | 2026-11-30 | Mon | `daily-tr-2026-11-30` | ÇANTA | open (0/0) | 5 | medium | 4.824 |
| 31 | 2026-12-01 | Tue | `daily-tr-2026-12-01` | BALIK | locked (1/0) | 4 | medium | 4.627 |
| 32 | 2026-12-02 | Wed | `daily-tr-2026-12-02` | RESİM | frozen (0/1) | 4 | medium | 4.665 |
| 33 | 2026-12-03 | Thu | `daily-tr-2026-12-03` | DAMLA | open (0/0) | 5 | medium | 4.452 |
| 34 | 2026-12-04 | Fri | `daily-tr-2026-12-04` | BADEM | locked (2/0) | 5 | hard | 8.347 |
| 35 | 2026-12-05 | Sat | `daily-tr-2026-12-05` | KALEM | locked+frozen (2/2) | 4 | medium | 7.402 |
| 36 | 2026-12-06 | Sun | `daily-tr-2026-12-06` | ROMAN | frozen (0/2) | 5 | medium | 6.851 |
| 37 | 2026-12-07 | Mon | `daily-tr-2026-12-07` | BAHÇE | open (0/0) | 5 | medium | 4.44 |
| 38 | 2026-12-08 | Tue | `daily-tr-2026-12-08` | ZEMİN | locked (1/0) | 4 | medium | 4.448 |
| 39 | 2026-12-09 | Wed | `daily-tr-2026-12-09` | TABAK | frozen (0/1) | 5 | medium | 5.641 |
| 40 | 2026-12-10 | Thu | `daily-tr-2026-12-10` | DENİZ | open (0/0) | 5 | medium | 4.441 |
| 41 | 2026-12-11 | Fri | `daily-tr-2026-12-11` | TARİH | locked (2/0) | 4 | medium | 5.439 |
| 42 | 2026-12-12 | Sat | `daily-tr-2026-12-12` | LİMON | locked+frozen (2/2) | 4 | medium | 7.502 |
| 43 | 2026-12-13 | Sun | `daily-tr-2026-12-13` | ORMAN | frozen (0/2) | 4 | medium | 6.224 |
| 44 | 2026-12-14 | Mon | `daily-tr-2026-12-14` | BULUT | open (0/0) | 5 | medium | 4.078 |
| 45 | 2026-12-15 | Tue | `daily-tr-2026-12-15` | ŞEKER | locked (1/0) | 4 | medium | 4.104 |
| 46 | 2026-12-16 | Wed | `daily-tr-2026-12-16` | TAVUK | frozen (0/1) | 4 | medium | 5.014 |
| 47 | 2026-12-17 | Thu | `daily-tr-2026-12-17` | ZAMAN | open (0/0) | 5 | medium | 4.815 |
| 48 | 2026-12-18 | Fri | `daily-tr-2026-12-18` | ÇORAP | locked (2/0) | 4 | medium | 5.196 |
| 49 | 2026-12-19 | Sat | `daily-tr-2026-12-19` | KABAK | locked+frozen (2/2) | 5 | hard | 8.115 |
| 50 | 2026-12-20 | Sun | `daily-tr-2026-12-20` | MASAL | frozen (0/2) | 4 | medium | 5.656 |
| 51 | 2026-12-21 | Mon | `daily-tr-2026-12-21` | FIRIN | open (0/0) | 5 | medium | 4.627 |
| 52 | 2026-12-22 | Tue | `daily-tr-2026-12-22` | KAĞIT | locked (1/0) | 4 | medium | 4.282 |
| 53 | 2026-12-23 | Wed | `daily-tr-2026-12-23` | KİTAP | frozen (0/1) | 4 | medium | 4.665 |
| 54 | 2026-12-24 | Thu | `daily-tr-2026-12-24` | SOKAK | open (0/0) | 5 | medium | 4.076 |
| 55 | 2026-12-25 | Fri | `daily-tr-2026-12-25` | MAKAS | locked (2/0) | 4 | medium | 5.097 |
| 56 | 2026-12-26 | Sat | `daily-tr-2026-12-26` | YATAK | locked+frozen (2/2) | 4 | medium | 7.884 |
| 57 | 2026-12-27 | Sun | `daily-tr-2026-12-27` | SALON | frozen (0/2) | 5 | medium | 6.849 |
| 58 | 2026-12-28 | Mon | `daily-tr-2026-12-28` | SEPET | open (0/0) | 5 | medium | 4.457 |
| 59 | 2026-12-29 | Tue | `daily-tr-2026-12-29` | ASLAN | locked (1/0) | 4 | medium | 4.105 |
| 60 | 2026-12-30 | Wed | `daily-tr-2026-12-30` | ÇANTA | frozen (0/1) | 5 | medium | 5.829 |

---

## 4. Editorial targets

| Target (brief) | Result | Met? |
| --- | --- | --- |
| `medium` or `hard`, never `expert` | 58 medium, 2 hard (#34, #49), 0 expert, 0 easy | Yes |
| `optimalMoves` about 3–6 | 34 × 4, 26 × 5 | Yes |
| Columns on | 60 / 60 | Yes |
| Every 7-day window has at least 3 of the 4 classes | 0 windows fail; each full week has all 4 | Yes |
| No class on more than 2 consecutive days | the longest run is 1 | Yes |
| **60 distinct targets, none a Journey target** | **30 distinct, each used twice (30 days apart); all 30 are Journey targets** | **No — infeasible with the current corpus (below)** |
| A fair weekly rhythm; nothing needs to ramp | The same weekly shape every week. Saturday (locked + frozen) scores 6.7–8.1 and is the week's highest-scoring day in 7 of 8 weeks; in the week of 2026-11-30, Friday #34 scores 8.35. Open days are the lightest (4.07–4.82). Only 2 of 8 Saturdays reach `hard`. | Partly — by score. Feel needs the playtest. |

**Why the target-word goal is infeasible (evidence):**

* `packages/looplet_dictionary/assets/tr/dictionary.json` has `targets` = **30 words**. `isEligibleTarget` accepts only these, and `check` fails any other target.
* All 30 are the Journey targets, `journey-tr-01 … 30` (read on 2026-09-29).
* So no eligible target exists outside the Journey set, and at most 30 distinct words are possible. That is a corpus limit. The rule stays: every target passes `check`.
* **Chosen mitigation:** use each word exactly twice, as far apart as possible (30 days), and never on the same weekday class twice. The target is shown to the player; the puzzle is the grid.
* **Proper fix:** a larger curated target list — workflow-follow-ups **F01-PRODUCTION-CORPUS** (Product Owner / Content Designer). That is outside F07-CONTENT: a dictionary asset change touches F01 / F02 and the app bundle. With more targets, the second use of each word (days 31–60) can be re-authored from the defs without touching days 1–30.

---

## 5. Evidence records

| Claim | Class | Command / action | Target | Result | Provenance / isolation |
| --- | --- | --- | --- | --- | --- |
| All 60 artifacts are solver-verified exports | repeatable integration | `export <def> --repo-root ../.. --out ../../content/daily/tr/pool/<id>.json --content-version 2026-11-01.1` ×60 (AOT build of `bin/looplet_authoring.dart` at `ece09df`) | the 60 defs | 60 × `wrote … (optimalMoves n, label)`; loop exit 0; 1168 s | this host, 2026-09-29; the production dictionary asset |
| The whole content tree passes the gate | repeatable integration | `melos run content:check` | `content/` (smoke, Journey, Daily) | exit 0, SUCCESS; **110 s** (35 s before the pool; **+75 s** for the CI content step) | a fresh solve of every artifact, target eligibility, dedup across smoke / Journey / Daily, and every D2 (2) rule through `buildDailyPack` |
| The served pack builds | repeatable integration | `dart run bin/looplet_authoring.dart pack-daily ../../content/daily/tr --repo-root ../..` | the committed source | exit 0; `60 days 2026-11-01 … 2026-12-30, #1 … #60, contentVersion 2026-11-01.1`; 54,106 bytes, sha256 `fb33384d…db31` | written to `build/daily/` (git-ignored), then deleted |
| The gate catches a broken source (negative) | repeatable integration | a scratch copy of `content/daily/tr` with the `2026-11-15` assignment removed → `pack-daily <copy> --out <scratch>/out/…` | a scratch copy only | exit 1; `[datesContiguous] 2026-11-16: missing 2026-11-15 …`; `nothing written`; no out directory | nothing in the repo changed |
| The editorial table | source-only | a read-only script over the manifest + pool + `content/journey/tr` | the committed content | the numbers in §3–§4 | derived from the artifacts, not the drafts |
| The toolchain is unchanged | automated functional | `cd tools/looplet_authoring && dart test` | the tool suite | 54 / 54 passed | no code changed in this task |

---

## 6. Open items for the Tech Lead and the sign-off

1. **Human playtest and sign-off — pending, F07.DAILY-POOL-SIGNOFF.**
   * All 60 puzzles are AI-drafted; none has been played by a person.
   * The review should cover readability, whether each day feels fair, and whether the weekly rhythm feels right.
   * Each day is playable from its def: `solve drafts/daily/tr/_defs/<id>.def.json` for the optimal line, and `playtest … --moves "…"`.
2. **Target words repeat** (§4). Decide whether to ship with 30 words used twice, or to wait for F01-PRODUCTION-CORPUS and re-author days 31–60.
3. **Locked and frozen tiles in the Daily, before the Journey teaches them.**
   * Journey introduces locked tiles at level 16 and frozen tiles at level 21, and only columns have a micro-tutorial.
   * The Daily shows locked tiles from #3 and frozen tiles from #1. This is a UX question for the playtest, the Tech Lead or the Product Owner; for example, open-only days until a later date. It is not a content defect.
4. **Frozen placement follows the Journey pattern:** off the target row. A frozen tile constrains moves but never needs thawing to win (Journey REVIEW gap #2).
5. **Difficulty labels:** only 2 Saturdays reach `hard`. Raising the rest needs a deeper optimum (above 5 with columns, minutes per candidate — F06 brief §11) or a scorer re-tune (CONTENT-TOOLING-TUNING).
6. **The calendar is provisional** (A3 ruling 5). If the live start date differs, re-date the pool as a block from the defs (DAILY-POOL-CALENDAR).

---

## Delivery suggestion

**Content Validation Pending.**

* Every gate-enforced rule passes, and the pack builds.
* Waiting on: the human playtest and sign-off (F07.DAILY-POOL-SIGNOFF), and the Tech Lead's ruling on §6 items 2 and 3.

## Sonraki Komut

Run Tech Lead
