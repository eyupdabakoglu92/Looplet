# F07 — daily-challenge: Orchestration

## Feature ID

F07

## Current Status

In Progress

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F07-UI | Assigned Role: UI Designer | Status: Done | Summary: The Daily surfaces on the Selected Foundation (architecture D8): the Home Daily entry (secondary; available / done today / needs connection), the Daily screen states (`loading`, `ready`, `doneToday`, `needsConnection`, `unavailable`), the daily Play header, and the daily result variant (official vs replay; Current + Best Streak; the reserved Share place for F13). At least two materially different rendered directions on identical content, then `ui-design.md` with the screen / state / viewport matrix and a Visual Evidence Manifest. Brief: Current Brief | Depends On: -
- [x] Task ID: F07-TOOL | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: The daily pack (architecture D2): a `DailyPack` model in `looplet_content`; `looplet_authoring pack-daily` (manifest + pool → the served `daily_pack_{lang}.json`); `check` extended to every D2 (2) rule with named negative cases; a small dev pack from existing smoke / Journey-shaped definitions for delivery and tests (not product content). Brief: Current Brief | Depends On: -
- [x] Task ID: F07-CONTENT | Assigned Role: Content Designer | Status: Done | Summary: The Turkish Daily pool (workflow-follow-ups F06-CONTENT-DAILY): 60 solved daily puzzles under `content/daily/tr/pool/` on the provisional calendar 2026-11-01 … 12-30 (architecture A3 ruling 5), `daily_manifest_tr.json`, `content-design.md`; `check` + `pack-daily` exit 0. The Tech Lead opens the sign-off gate F07.DAILY-POOL-SIGNOFF at its checkpoint. Brief: Current Brief | Depends On: F07-TOOL
- [ ] Task ID: F07-FE | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: The app (architecture D3–D8): `DailyContentSource` + the debug pack override; cache population / prefetch / eviction; the D3 states; D4 dates and rollover; D5 transactional completion (entry + streak + enqueue); D6 streak; D7 Remote Config + kill-switch (`firebase_remote_config`, `http`); `/daily`, the Home entry, the daily Play header and result per `ui-design.md`; tests + named negatives; Visual Parity Evidence against the selected Direction A (`F07-A-*`); emulator sync evidence; architecture A1 rulings | Depends On: F07-UI, F07-TOOL
- [ ] Task ID: F07-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Functional + visual QA on the emulator and the canonical simulator (architecture D10); the plan is locked at activation | Depends On: F07-FE, F07-CONTENT
- [ ] Task ID: F07-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: F07's release (architecture D11): pack hosting, publishing `daily_manifest_url`, rollback by repointing, the release smoke. Blocked on F08's deploy (F08.DEPLOY-RESUME → F08-DEVOPS) and F07's functional QA | Depends On: F07-QA-FUNCTIONAL
- [ ] Task ID: F07-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the release proof and any affected functional scope | Depends On: F07-DEVOPS

## Open Tasks

* F07-CONTENT — Done (2026-09-29): 60 pool puzzles, the manifest, `content-design.md`; awaiting the Tech Lead content checkpoint (F07.DAILY-POOL-SIGNOFF; `content-design.md` §6).
* F07-TOOL — Done, accepted at A3 (2026-09-29).
* F07-UI — Done, accepted at A1; **Direction A selected** by the user (A2).
* Queued: F07-FE (activated at the F07-CONTENT checkpoint, A3), F07-QA-FUNCTIONAL, F07-QA-FINAL. Blocked: F07-DEVOPS (F08's deploy).

## Handoff Plan

None

## Delivery Review

Pending

## QA Scope

end-to-end

## QA Modules

core, client-ui, visual-quality, stateful-flow, backend-security, content

## Regression Depth

not-set

## Evidence Reuse

not-evaluated

## QA Stage

none

## QA Result

None

## Release Scope

production-readiness

## Release Result

None

## Visual Scope

new-surface

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for Implementation

## Visual Evidence

F07-UI delivery (UI Designer, 2026-09-29) — `ui-design.md` §12b manifest; all in `features/f07-daily-challenge/design/`:
* direction renders: A `F07-A-01 … 06`, B `F07-B-01 … 06`; side by side `F07-sheet-1-directions-A-vs-B.png`;
* A candidate state set, Play header, result, text scale / devices, motion stills: `F07-A-*`, sheets 2–4;
* sources, fit and contrast: `design/src/gen-f07.mjs`, `fit-f07.txt`, `contrast-f07.txt`.
Verified at A1 (renders counted, fit table read with its negative case). **Selected: Direction A** (the user, F07.DIRECTION-SELECT — A, A2): the `F07-A-*` renders are the selected source.

## Pending Evidence

- Evidence ID: F07.STREAK-ROLLOVER
  * Scenario: The D6 streak table (first day, consecutive, missed day, replay, clock back, DST day, leap day, year boundary) and the D4 date attribution (a run crossing midnight counts for its start date; rollover only when not mid-run)
  * Required Class: automated functional + runtime
  * Target / Environment: unit / widget tests with named negatives; the canonical iPhone 16 simulator for the runtime rollover
  * Owner Role: QA
  * Prerequisite / External Decision: F07-FE
  * Re-evaluation Trigger: F07-FE delivery
  * Blocks: F07 functional acceptance
  * Result: PENDING

- Evidence ID: F07.FIRST-RUN-SYNC
  * Scenario: A first daily completion writes the official result + streak + exactly one queue item in one transaction; the emulator receives exactly one doc; a replay writes only an attempt (official result, streak, queue and server doc unchanged)
  * Required Class: automated functional + repeatable integration
  * Target / Environment: unit tests; the Firebase emulator (`demo-looplet`, the F08-FE13 debug wiring)
  * Owner Role: QA
  * Prerequisite / External Decision: F07-FE; the emulator tooling (Java 21, setup-manifest)
  * Re-evaluation Trigger: F07-FE delivery
  * Blocks: F07 functional acceptance
  * Result: PENDING

- Evidence ID: F07.OFFLINE-DAILY
  * Scenario: Offline with today cached → the Daily is playable and its result is queued; offline with nothing cached → `needsConnection`, and Journey still plays (F08 QA Focus "Offline Daily"; workflow-follow-ups SHARED-PERSISTENCE-PROOF)
  * Required Class: runtime
  * Target / Environment: a real no-network run on the canonical simulator (the user turns the network off; Claude does not change system settings)
  * Owner Role: QA
  * Prerequisite / External Decision: F07-FE; the user's no-network run
  * Re-evaluation Trigger: F07-FE delivery
  * Blocks: F07 functional acceptance
  * Result: PENDING

- Evidence ID: F07.KILL-SWITCH
  * Scenario: `daily_enabled = false` hides the Home entry and shows `unavailable` on a restored Daily without killing a run in progress; `daily_sync_enabled = false` → no send in a release-shaped build (workflow-follow-ups F07-KILL-SWITCH)
  * Required Class: automated functional
  * Target / Environment: tests with an injected Remote Config fake; named negatives
  * Owner Role: QA
  * Prerequisite / External Decision: F07-FE
  * Re-evaluation Trigger: F07-FE delivery
  * Blocks: F07 functional acceptance and release
  * Result: PENDING

- Evidence ID: F07.CONTENT-GATE
  * Scenario: The Turkish pool passes `check` and `pack-daily` (every D2 (2) rule; 30-day no-repeat) and is signed off by the user (F07.DAILY-POOL-SIGNOFF)
  * Required Class: repeatable integration + human decision
  * Target / Environment: `looplet_authoring` over `content/daily/tr/`
  * Owner Role: Content Designer (delivery), then QA
  * Prerequisite / External Decision: F07-TOOL; F07-CONTENT; the sign-off gate
  * Re-evaluation Trigger: F07-CONTENT delivery
  * Blocks: F07 functional acceptance and release
  * Delivery Evidence: Content Designer, 2026-09-29 (`content-design.md` §5) — `melos run content:check` exit 0 (110 s); `pack-daily` exit 0, 60 days #1 … #60; a scratch negative → `[datesContiguous]`, exit 1. Still open: the user's sign-off (F07.DAILY-POOL-SIGNOFF, not yet opened) and QA
  * Result: PENDING

## Open Decision Gates

- Decision ID: F07.DIRECTION-SELECT
  * Question: Günlük (Daily) ekranları hangi yönle yapılsın? Görsel karşılaştırma: `features/f07-daily-challenge/design/F07-sheet-1-directions-A-vs-B.png` (üst sıra A, alt sıra B; aynı içerik).
  * Options / Trade-offs: (A) "Hafta döngüsü" — seri, Ana ekrandaki döngü izinin diliyle son 7 gün olarak çizilir; kaçırılan gün zincirde boşluk olarak görünür; Ana ekran girişi üç satırlık bir kart (AX5'te Ana ekran kaydırılır — A1 ruling 4). (B) "Günün bileti" — büyük `#34` numaralı bilet, delikli koçan ve "BUGÜN TAMAM" damgası; Ana ekran girişi tek satırlık kapsül; seri yalnız sayılarla gösterilir. B seçilirse UI Designer tüm durum setini B için yeniden üretir (F07-FE bir tur gecikir).
  * Recommendation: (A) — ürünün imza motifini günlük alışkanlığa taşır; seri bir şekil olarak okunur (UI Designer self-score 94, B ≈ 90; provisional)
  * Blocks: F07-FE (the implementation and its Visual Parity Evidence); not F07-TOOL or F07-CONTENT
  * Blocking Scope: feature
  * Status: RESOLVED
  * Resolution: Option (A) by the user — Direction A "Hafta döngüsü"; Visual Quality Gate → Ready for Implementation; F07-TOOL activated (architecture A2)
  * Resolved At: 2026-09-29

## Blockers

None

## Next Action

Run Tech Lead — the F07-CONTENT checkpoint:
* reconcile `content-design.md`;
* rule on §6: 30 target words used twice (the corpus limit, F01-PRODUCTION-CORPUS), and locked / frozen tiles in the Daily before the Journey teaches them;
* open F07.DAILY-POOL-SIGNOFF;
* activate F07-FE.

## Last Decision

2026-09-29 — the F07-TOOL checkpoint (architecture A3).

* **F07-TOOL accepted** (209daf1): the tests re-run (44 / 54), plus three independent negatives on scratch copies.
* **Rulings:**
  1. the served-as-is pool model, with the manifest shape locked;
  2. the readings of D2 (2);
  3. no definition repeats in the MVP pool (DAILY-POOL-REUSE);
  4. `CalendarDate` is the one date implementation;
  5. the provisional calendar 2026-11-01 … 12-30; the re-date and cadence at the release gate (DAILY-POOL-CALENDAR).
* **Routing:** F07-CONTENT Open (Content Designer); F07-FE after the content checkpoint.

## Last Update

* Updated By: Content Designer
* Timestamp: 2026-09-29
* Summary: F07-CONTENT Done — 60 exported pool puzzles (2026-11-01 … 12-30), the manifest, 60 defs, `content-design.md`. `content:check` and `pack-daily` exit 0; the target-word goal is infeasible (30 eligible targets, all Journey). Delivery Review Pending; owner → Tech Lead.

## Context & Follow-ups

* F08 is paused (F08 A21); its client contract is frozen for F07. The fake producer stays debug-only until F08 is Done.
* F05 stays Done; the Home Daily entry is a cross-feature amendment recorded in F05 `architecture.md` §18 (note) and here (D8).
* F10 later owns the main-menu layout; F13 adds Share; F12 adds the daily analytics events.
* Design Adoption Phase E: new features start on the Foundation (workflow-follow-ups → Design Adoption Route).

## History & Evidence References

* [Product PRD](../../product/product-prd.md) → "daily-challenge (F07)".
* [F08 architecture](../f08-offline-persistence-and-sync/architecture.md) → the client surface F07 builds on; A21 (the decision and the dependency ruling).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-29 — Tech Lead: F07 activated (F08.FUNCTION-DEPLOY-GO — C). prd, architecture D1–D11, orchestration; F07-UI Open; owner → UI Designer.
* 2026-09-29 — UI Designer: F07-UI Done — directions A "Hafta döngüsü" (recommended) / B "Günün bileti", 63 renders + 4 sheets, `ui-design.md`; NTLC-1…5; owner → Tech Lead.
* 2026-09-29 — Tech Lead: F07-UI checkpoint (architecture A1) — accepted; rulings 1–6; F07.DIRECTION-SELECT opened; F07-TOOL briefed; owner Tech Lead (awaiting the decision). [Orchestration at the UI delivery](../../history/f07-daily-challenge-2026-09-29/orchestration-at-ui-delivery.md) (the F07-UI brief).
* 2026-09-29 — Tech Lead: Decision F07.DIRECTION-SELECT — A (architecture A2) — Direction A selected; gate Ready for Implementation; F07-TOOL Open; owner → Frontend/Mobile Developer.
* 2026-09-29 — Frontend/Mobile Developer: F07-TOOL Done — `DailyPack` / validator, `pack-daily`, `check` D2 (2), dev pack; content 44 / authoring 54 / app 588 tests green, `content:check` exit 0; Delivery Review Pending; owner → Tech Lead. [frontend.md](frontend.md) (F07-TOOL).
* 2026-09-29 — Tech Lead: F07-TOOL checkpoint (architecture A3) — accepted; rulings 1–5 (pool model, D2 readings, no reuse, `CalendarDate`, the provisional calendar); F07-CONTENT Open; owner → Content Designer. [Orchestration at the TOOL delivery](../../history/f07-daily-challenge-2026-09-29/orchestration-at-tool-delivery.md) (the F07-TOOL brief).
* 2026-09-29 — Content Designer: F07-CONTENT Done — 60 pool puzzles + manifest + defs; `content:check` / `pack-daily` exit 0; the negative run recorded; 30 targets × 2 (corpus limit); Content Validation Pending; owner → Tech Lead. [content-design.md](content-design.md).

## Current Brief

**F07-CONTENT — the Turkish Daily pool** (Content Designer; architecture D2, D9, A3 rulings 1, 3 and 5; workflow-follow-ups F06-CONTENT-DAILY)

**Read first:**
* `architecture.md` D2 and A3;
* `frontend.md`, F07-TOOL section, "Notes for the Content Designer" — the manifest, the commands, the pool rules;
* `prd.md` AC2 / AC3;
* the F06 [content-authoring brief](../f06-puzzle-content-and-solver-tooling/content-authoring-brief.md) §5 (Turkish target words), §6 (the per-puzzle workflow) and §11 (solver cost);
* the dev fixture `tools/looplet_authoring/test/fixtures/daily_dev/` as a shape example. It is **not** content: do not copy its definitions, which are Journey / smoke copies and fail the dedup rule.

**Deliver:**
1. **60 pool puzzles:** `content/daily/tr/pool/daily-tr-YYYY-MM-DD.json` for **2026-11-01 … 2026-12-30** (the provisional calendar, A3 ruling 5). Each is produced by `looplet_authoring export`, never written by hand, with:
   * `puzzleType: daily`, `dailyDate`, `id: daily-tr-<date>`, `language: tr`;
   * one `contentVersion` for the batch: `2026-11-01.1`.
2. **The definition files** at `tools/looplet_authoring/drafts/daily/tr/_defs/` (outside `content/`, A3 ruling 1), so that the pool can be re-exported or re-dated.
3. **`content/daily/tr/daily_manifest_tr.json`:** `schemaVersion 1`, `lang tr`, `contentVersion 2026-11-01.1`, `numberingEpoch 2026-11-01`, and 60 contiguous `assignments` by id.
4. **`features/f07-daily-challenge/content-design.md`:**
   * a per-day table: date, `#N`, id, target word, mechanic class (open / locked / frozen / locked + frozen), `optimalMoves`, `difficultyLabel`;
   * how each editorial target below was met, or why not;
   * the tools and exact commands run, with exit codes;
   * which puzzles are AI-drafted and not yet human-playtested (the sign-off covers the playtest);
   * known gaps.

**Rules — gate-enforced** (`check` / `pack-daily`; each must hold):
* every D2 (2) rule;
* the stored `optimalMoves` equals a fresh solve, and is ≥ 1;
* the target is `isEligibleTarget` (F01);
* no definition duplicates a Journey, smoke or other pool puzzle (A3 ruling 3);
* the grid is 5×5 and the target 5 letters (AC3).

**Editorial targets** (not gate-enforced; report them in the table):
* `difficultyLabel` is `medium` or `hard`, and never `expert` (the F06 recommendation). `optimalMoves` is about 3–6: above about 6 with column moves, solving costs minutes (F06 brief §11).
* Columns are on: a rows-only puzzle is capped at 2 moves.
* The mechanic classes vary. In every 7-day window, at least three of the four classes appear, and no class appears on more than 2 consecutive days.
* 60 distinct target words: common, recognisable Turkish words, none equal to a Journey target.
* A fair difficulty rhythm across the week. Nothing needs to ramp: every day is someone's first Daily.

**Verification:**
* `melos run content:check` → exit 0 with the pool committed.
* From `tools/looplet_authoring`: `dart run bin/looplet_authoring.dart pack-daily ../../content/daily/tr --repo-root ../..` → exit 0, `60 days 2026-11-01 … 2026-12-30, #1 … #60`. The output under `build/` is not committed.
* **One recorded negative run on a scratch copy** (not committed): for example, a gap in the assignments → `[datesContiguous]`, exit 1.
* Record the `content:check` duration: 60 more solves lengthen the CI content step.

**Rules:**
* No code or tool change. A tool defect → a blocker to the Tech Lead (a Developer fixes it).
* No product criterion change.
* The app, F08 and `content/journey/` are untouched.
* If a target proves infeasible (for example, not enough eligible words or solver time), report it with evidence; do not relax a rule.

**Then:** close F07-CONTENT → owner Tech Lead → `Run Tech Lead`. The Tech Lead's content checkpoint reconciles the pool and opens **F07.DAILY-POOL-SIGNOFF**, the user's review and playtest; the sign-off itself is not part of this task. That checkpoint then activates F07-FE.
