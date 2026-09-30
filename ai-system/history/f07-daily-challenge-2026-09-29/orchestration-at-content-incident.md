# F07 — daily-challenge: Orchestration

## Feature ID

F07

## Current Status

In Progress

## Current Owner

Frontend/Mobile Developer

## Next Role

Frontend/Mobile Developer

## Active Task Ledger

- [x] Task ID: F07-UI | Assigned Role: UI Designer | Status: Done | Summary: The Daily surfaces on the Selected Foundation (architecture D8): the Home Daily entry (secondary; available / done today / needs connection), the Daily screen states (`loading`, `ready`, `doneToday`, `needsConnection`, `unavailable`), the daily Play header, and the daily result variant (official vs replay; Current + Best Streak; the reserved Share place for F13). At least two materially different rendered directions on identical content, then `ui-design.md` with the screen / state / viewport matrix and a Visual Evidence Manifest. Brief: Current Brief | Depends On: -
- [x] Task ID: F07-TOOL | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: The daily pack (architecture D2): a `DailyPack` model in `looplet_content`; `looplet_authoring pack-daily` (manifest + pool → the served `daily_pack_{lang}.json`); `check` extended to every D2 (2) rule with named negative cases; a small dev pack from existing smoke / Journey-shaped definitions for delivery and tests (not product content). Brief: Current Brief | Depends On: -
- [x] Task ID: F07-CONTENT | Assigned Role: Content Designer | Status: Done | Summary: The Turkish Daily pool (workflow-follow-ups F06-CONTENT-DAILY): 60 solved daily puzzles under `content/daily/tr/pool/` on the provisional calendar 2026-11-01 … 12-30 (architecture A3 ruling 5), `daily_manifest_tr.json`, `content-design.md`; `check` + `pack-daily` exit 0. The Tech Lead opens the sign-off gate F07.DAILY-POOL-SIGNOFF at its checkpoint. Brief: Current Brief | Depends On: F07-TOOL
- [ ] Task ID: F07-FE | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: The app (architecture D3–D8): `DailyContentSource` + the debug pack override + the debug today override (A4 ruling 6); cache population / prefetch / eviction; the D3 states; D4 dates and rollover; D5 transactional completion (entry + streak + enqueue); D6 streak; D7 Remote Config + kill-switch (`firebase_remote_config`, `http`); `/daily`, the Home entry, the daily Play header and result per `ui-design.md`; tests + named negatives; Visual Parity Evidence against the selected Direction A (`F07-A-*`); emulator sync evidence; architecture A1 rulings; the pool playtest recipe. Brief: Current Brief | Depends On: F07-UI, F07-TOOL
- [ ] Task ID: F07-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Functional + visual QA on the emulator and the canonical simulator (architecture D10); the plan is locked at activation. The pool sign-off is not its prerequisite (A4) | Depends On: F07-FE, F07-CONTENT
- [ ] Task ID: F07-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: F07's release (architecture D11): pack hosting, publishing `daily_manifest_url`, rollback by repointing, the release smoke. Blocked on F08's deploy (F08.DEPLOY-RESUME → F08-DEVOPS), F07's functional QA and the pool sign-off (F07.DAILY-POOL-SIGNOFF) | Depends On: F07-QA-FUNCTIONAL
- [ ] Task ID: F07-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the release proof and any affected functional scope | Depends On: F07-DEVOPS

## Open Tasks

* **F07-FE — Open** (Frontend/Mobile Developer; the Current Brief).
* F07-CONTENT — Done, accepted at A4 (2026-09-29). The pool's sign-off is the user's decision gate F07.DAILY-POOL-SIGNOFF (OPEN, `release`).
* F07-TOOL — Done, accepted at A3. F07-UI — Done, accepted at A1; **Direction A selected** (A2).
* Queued: F07-QA-FUNCTIONAL, F07-QA-FINAL. Blocked: F07-DEVOPS (F08's deploy; the pool sign-off).

## Handoff Plan

None

## Delivery Review

Accepted

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
  * Scenario: The Turkish pool passes the executable content gates: `check` (a fresh solve of every artifact, target eligibility, dedup across smoke / Journey / Daily, every D2 (2) rule) and `pack-daily` (60 days, #1 … #60). The user's sign-off is not this item: it is the decision gate F07.DAILY-POOL-SIGNOFF.
  * Required Class: repeatable integration
  * Target / Environment: `looplet_authoring` over `content/` and `content/daily/tr/`
  * Owner Role: QA
  * Prerequisite / External Decision: F07-CONTENT (Done, accepted at A4)
  * Re-evaluation Trigger: any change under `content/daily/`, the dictionary asset or the authoring tool
  * Blocks: F07 functional acceptance
  * Delivery Evidence: Content Designer, 2026-09-29 (`content-design.md` §5). **Tech Lead re-run on 9af777f (A4):** `content:check` exit 0, 110 s; `pack-daily` exit 0, byte-identical pack (sha256 `fb33384d…db31`); three independent negatives on scratch copies (stale optimum, duplicate definition + `[noRepeat]`, `[puzzleDate]`), each exit 1, and the baseline exit 0. QA still evaluates independently.
  * Result: PENDING

- Evidence ID: F07.COLD-BOOT
  * Scenario: F07 adds start-up work — the Remote Config `fetchAndActivate`, the pack fetch after bootstrap, and the D3 eviction. A cold boot reaches Home with empty state and with existing state (a cached day, an in-progress daily run), online and offline, and a failed or slow Remote Config / pack fetch never delays Home or Journey (evidence standard §4)
  * Required Class: runtime
  * Target / Environment: the canonical iPhone 16 simulator, the real start-up path (debug build, the D2 (7) override for the pack); the release-shaped Remote Config fetch belongs to the F07-DEVOPS smoke
  * Owner Role: QA
  * Prerequisite / External Decision: F07-FE (the Frontend/Mobile Developer delivers the runtime capture)
  * Re-evaluation Trigger: F07-FE delivery
  * Blocks: F07 functional acceptance
  * Result: PENDING

- Evidence ID: F07.DEBUG-OVERRIDES
  * Scenario: The debug-only defines `LOOPLET_DAILY_PACK_URL` (D2 (7)) and `LOOPLET_DAILY_TODAY` (A4 ruling 6) take effect in debug builds and are inert in profile and release builds; no ATS exception reaches a release build
  * Required Class: automated functional
  * Target / Environment: tests with named negatives; a read of the release `Info.plist`
  * Owner Role: QA
  * Prerequisite / External Decision: F07-FE
  * Re-evaluation Trigger: F07-FE delivery
  * Blocks: F07 functional acceptance and release
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

- Decision ID: F07.DAILY-POOL-SIGNOFF
  * Question: Türkçe Günlük havuzu (60 bulmaca, 2026-11-01 … 12-30) yayına onaylanıyor mu? Kaynak: `features/f07-daily-challenge/content-design.md` §3 (gün gün tablo) ve §6; Tech Lead bulguları `architecture.md` A4. Bilinen üç sınır: (1) 30 hedef kelime ikişer kez kullanılıyor (30 gün arayla) ve hepsi Journey kelimeleri — mevcut sözlükte başka uygun hedef yok; bulmacaların (ızgaraların) hepsi farklı. (2) Kilitli ve buzlu taşlar #1'den itibaren var; Journey bunları 16. ve 21. seviyede tanıtıyor ve ipucu göstermiyor. (3) Buzlu taşlı 26 günün 18'inde buz hiçbir zaman çözülemiyor (103 kelimelik geçici sözlük); bu günlerde buzlu taş kilitli taş gibi davranıyor. Journey'de de 10 buzlu seviyenin 6'sı böyle. Kazanmak için buzun çözülmesi hiçbir günde gerekmiyor.
  * How to review: tablo ve render'lar şimdi incelenebilir. Uygulamada oynamak F07-FE teslim edilince mümkün olacak: `frontend.md`'deki "pool playtest" tarifi (`LOOPLET_DAILY_TODAY` + gerçek havuzun paketi). Önerilen örnek: #1, her sınıftan birer gün (açık, kilitli, buzlu, kilitli + buzlu) ve iki `hard` gün (#34, #49).
  * Options / Trade-offs: (A) Olduğu gibi onayla — üç sınır MVP için kabul; kalıcı çözüm F01-PRODUCTION-CORPUS (daha büyük hedef listesi ve sözlük; 31–60. günler ilk yayından önce yeniden yazılabilir). (B) Belirli günleri yeniden yazdır — oyun testinde beğenmediğin günleri #N ve nedeniyle listele; Content Designer yalnız onları yeniden üretir, gerisi onaylı kalır. (C) Buzlu günleri çözülebilir yap — Content Designer 18 günü, buzun gerçekten çözülebildiği yerleşimlerle yeniden üretir (sözlük aynı; fizibilite o turda doğrulanır). Günlük'te buz mekaniği anlam kazanır ama Journey ile tutarsızlaşır; bir içerik turu ekler. (D) Ürün kararına gönder — örneğin kilitli / buzlu taşlar için ilk karşılaşma ipucu (Journey 16 / 21'e de yarar): `Run Product Owner. Revise: …`; havuz onayı revizyondan sonra.
  * Recommendation: (A), oyun testi günleri adil bulursa — gönderilmiş Journey ile tutarlı, kök neden sözlük. Test kilitli / buzlu taşları kafa karıştırıcı bulursa (D).
  * Blocks: publishing the pool — F07-DEVOPS, F07-QA-FINAL and Done; not F07-FE or F07-QA-FUNCTIONAL (A4)
  * Blocking Scope: release
  * Status: OPEN

## Blockers

None

## Next Action

Run Frontend/Mobile Developer — F07-FE (the Current Brief).

In parallel, the user reviews the pool and answers `Run Tech Lead. Decision: F07.DAILY-POOL-SIGNOFF — <A / B / C / D>` (the playtest is possible once F07-FE has delivered its recipe).

## Last Decision

2026-09-29 — the F07-CONTENT checkpoint (architecture A4).

* **F07-CONTENT accepted** (9af777f): the Tech Lead re-ran `content:check` (exit 0) and `pack-daily` (byte-identical pack), ran three independent negatives, and recomputed the per-day table from the artifacts (60 / 60).
* **Finding:** 18 of the 26 frozen-tile days can never thaw with the provisional dictionary; Journey L22 and L24 too (FROZEN-ROW-THAW-CONTENT corrected).
* **Rulings:**
  1. 30 targets × 2 accepted for the MVP pool, subject to the sign-off (the brief's distinct-target goal withdrawn as infeasible);
  2. locked / frozen from #1 — an Assumption the playtest tests;
  3. the thaw finding is part of the sign-off; the dictionary ↔ optimum coupling is recorded;
  4. difficulty unchanged;
  5. placement and calendar unchanged;
  6. a debug-only today override for the playtest.
* **F07.DAILY-POOL-SIGNOFF opened** (`release`). **Routing:** F07-FE Open.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-29
* Summary: The F07-CONTENT checkpoint (A4) — accepted; rulings 1–6; F07.DAILY-POOL-SIGNOFF opened (`release`); F07-FE Open; owner → Frontend/Mobile Developer.

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
* 2026-09-29 — Tech Lead: F07-CONTENT checkpoint (architecture A4) — accepted after a re-run and independent negatives; the thaw finding; rulings 1–6; F07.DAILY-POOL-SIGNOFF opened (`release`); F07-FE Open; owner → Frontend/Mobile Developer. [Orchestration at the content delivery](../../history/f07-daily-challenge-2026-09-29/orchestration-at-content-delivery.md) (the F07-CONTENT brief).

## Current Brief

**F07-FE — the Daily in the app** (Frontend/Mobile Developer; architecture D3–D8, D10, A1 rulings 1–6, A3 ruling 4, A4 ruling 6)

**Read first:**
* `architecture.md`: Dependency Edges, D3–D10, A1 (the six UI rulings), A3 ruling 4, A4 ruling 6;
* `ui-design.md` §4–§11.1 and §12a — Direction A only. The **selected source** is the `F07-A-*` renders in `design/` (A2); B is not built;
* F08 `architecture.md`: Persistence Schema, the `sync_queue` contract, Offline Daily Cache (with the A1 envelope note), Streak-Integrity / Clock. F08's client surface is **frozen**: no schema or signature change (Dependency Edges);
* F03 `architecture.md` §20 (the result, the win timeline) and F05 `architecture.md` §18 / §18.10 (Home, the AX5 scroll amendment);
* `frontend.md`, F07-TOOL section: `DailyPack`, `CalendarDate`, the dev pack and its generator.

**Deliver** (each item traceable to code and tests in `frontend.md`, F07-FE section):
1. **Content source (D2 (7), D3):** `DailyContentSource.fetchPack(lang)` over HTTPS (`http`; 10 s timeout; one attempt per trigger); client validation with `DailyPack` (a rejected pack caches nothing, logs `daily_pack_invalid`, and gives `unavailable`); the five triggers; population of today … today + 7 into `daily_puzzle_cache` as the **day envelope** `{dailyNumber, puzzle}` (A1 ruling 1), never overwriting a date that has an official result; eviction at start (today − 14, keeping in-progress and unsynced dates). `LOOPLET_DAILY_PACK_URL` is the debug override.
2. **Dates (D4, A3 ruling 4, A4 ruling 6):** `CalendarDate` only. The start date is kept across midnight and across kill / relaunch; restore from the snapshot id plus the cache (a missing row → the snapshot is discarded → Home); rollover re-evaluation on opening `/daily` and on `resumed`, never mid-run. **`LOOPLET_DAILY_TODAY`** (debug only) fixes the Daily's today as A4 ruling 6 states.
3. **Completion (D5):** one Drift transaction — `recordCompletion`, then on a first run the D6 streak write and `DailyResultSyncService.enqueue` with the F08 fields and `clientAttemptNumber = 1`. A replay writes only the attempt. No `personal_best` write. If `enqueue` cannot join the caller's transaction, **stop and report** before changing anything.
4. **Streak (D6):** the rule and the effective display (0 unless the last completed date is today or yesterday).
5. **Remote Config (D7):** add `firebase_remote_config` (compatible with the pinned `firebase_core ^3.6.0` line) and `http`. No Flutter / Firebase upgrade; the lockfile changes only by these additions and their transitive needs — list them. In-app defaults; a non-blocking `fetchAndActivate` at start (1 h / 0 in debug); the `daily_enabled`, `daily_manifest_url` and `daily_sync_enabled` effects. **An in-progress daily run is never killed.** An injected fake for tests.
6. **Surfaces (D8, `ui-design.md` A):**
   * `/daily` with the five states;
   * the Home entry: secondary, slate, the A1 ruling 2 mapping (`unavailable` → hidden), `#N` only when known; Home scrolls only above the 1.3× cap (A1 ruling 4);
   * the daily Play header (`GÜNLÜK · #N` + the date);
   * the daily result (A1 ruling 5): the stats card with stars, `OPTİMAL` in the subtitle, no `EN İYİ`, the replay's official row, the streak card and its reveal, the chip precedence, the zero-height Share slot (ruling 3), no Next Level;
   * the navigation: `/daily` back → Home; the result → `/daily` or replay in place;
   * `WeekTrack`, `DailyEntryCard`, the `LoopNode` states, the icons `check` / `offline`; no token change;
   * Turkish copy only through `DailyStrings` (§11.1); no raw error text.
7. **Tests with named negatives** (evidence standard §3: each rule → an assertion → a negative that breaks it):
   * the D6 table — first day, consecutive, missed day, same-day replay, clock back, DST day, leap day, year boundary;
   * D4 — midnight crossing, rollover not mid-run, restore with a missing cache row;
   * D3 — population, no overwrite after an official result, eviction keeps in-progress / unsynced dates, each invalid-pack rule → `unavailable`;
   * D5 — first run → entry + streak + exactly one queue item, all in one transaction (a forced failure rolls back all three); replay → attempt only;
   * D7 — each kill-switch effect, and a running daily survives `daily_enabled = false`;
   * both debug overrides are inert in profile / release (F07.DEBUG-OVERRIDES).
8. **Emulator evidence (F07.FIRST-RUN-SYNC):** a real daily first run → exactly one server doc; a replay → no new queue item and the doc unchanged. Use the F08-FE13 wiring (`LOOPLET_FIREBASE_EMULATOR`, Java 21 first on `PATH` — setup-manifest) and the **real date** (the dev pack generator's `--anchor`), never `LOOPLET_DAILY_TODAY`.
9. **Cold boot (F07.COLD-BOOT):** a runtime capture on the canonical iPhone 16 simulator: empty state; existing state with a cached day; an in-progress daily run killed and relaunched; offline; a failing pack URL. Home and Journey are never delayed.
10. **Visual Parity Evidence** against the `F07-A-*` renders: runtime captures of every §12a row you implement (Home entry states, `/daily` states, the Play header, the result first run / replay / 0 → 1 Perfect), iPhone 16 / 16e / Pro Max, 1.3× and AX5, the reduced-motion path. Side-by-side with the render ids, and a gap list. The tolerances are `ui-design.md` §11.
11. **The pool playtest recipe** (for the user's sign-off, A4 ruling 6): the exact commands to build the real pool's pack, serve or point to it, and run a debug build on any pool day. Prove it once on one pool day (e.g. #1).

**Workspace gates before handing back:** `melos run format:check`, `melos run analyze`, `melos run test`, `melos run content:check` — each with its exit code and counts.

**Rules:**
* No change to F08's schema, repos or sync service; no change to `content/`, the pool or the authoring tool. A needed change → a blocker to the Tech Lead.
* No deploy, no console change, no real Firebase project use; Remote Config is never emulated.
* Claude does not change system settings. The real no-network run (F07.OFFLINE-DAILY) is the user's, at QA.
* A `ui-design.md` conflict or a gap you cannot close within the tolerances → `Needs Tech Lead Clarification` in `frontend.md`; do not invent a new pattern.

**Then:** close F07-FE → owner Tech Lead → `Run Tech Lead`. The implementation checkpoint reconciles the delivery, sets the Visual Quality Gate, and locks the F07-QA-FUNCTIONAL plan.
