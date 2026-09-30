# F07 — daily-challenge: Orchestration

## Feature ID

F07

## Current Status

In Progress

## Current Owner

Content Designer

## Next Role

Content Designer

## Active Task Ledger

- [x] Task ID: F07-UI | Assigned Role: UI Designer | Status: Done | Summary: The Daily surfaces on the Selected Foundation (architecture D8): the Home Daily entry (secondary; available / done today / needs connection), the Daily screen states (`loading`, `ready`, `doneToday`, `needsConnection`, `unavailable`), the daily Play header, and the daily result variant (official vs replay; Current + Best Streak; the reserved Share place for F13). At least two materially different rendered directions on identical content, then `ui-design.md` with the screen / state / viewport matrix and a Visual Evidence Manifest. Brief: Current Brief | Depends On: -
- [x] Task ID: F07-TOOL | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: The daily pack (architecture D2): a `DailyPack` model in `looplet_content`; `looplet_authoring pack-daily` (manifest + pool → the served `daily_pack_{lang}.json`); `check` extended to every D2 (2) rule with named negative cases; a small dev pack from existing smoke / Journey-shaped definitions for delivery and tests (not product content). Brief: Current Brief | Depends On: -
- [x] Task ID: F07-CONTENT | Assigned Role: Content Designer | Status: Done | Summary: **Superseded as product content by the incident of 2026-09-30 (architecture A5); replaced by F07-CONTENT-R1.** The Turkish Daily pool (workflow-follow-ups F06-CONTENT-DAILY): 60 solved daily puzzles under `content/daily/tr/pool/` on the provisional calendar 2026-11-01 … 12-30 (architecture A3 ruling 5), `daily_manifest_tr.json`, `content-design.md`; `check` + `pack-daily` exit 0. The Tech Lead opens the sign-off gate F07.DAILY-POOL-SIGNOFF at its checkpoint. Brief: Current Brief | Depends On: F07-TOOL
- [ ] Task ID: F07-CORPUS | Assigned Role: Content Designer | Status: Open | Summary: The Turkish corpus (`daily-content-spec.md` §2.1; F01-PRODUCTION-CORPUS brought into F07): `dictionary.json` `targets` ≥ 120 (the 30 Journey targets kept) and `words` ≥ 2,000 (4–5 letters), with a named source, the exclusion rules and scripted checks; the Journey impact (`content:check`; re-export from the Journey defs only where a stored optimum changed). Brief: Current Brief | Depends On: -
- [ ] Task ID: F07-TOOL-DAILY | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: `looplet_authoring generate-daily` (the §3 algorithm) and `audit-daily` (every measurable §4 / §5 rule, a per-day PASS / FAIL table, exit 1 on any FAIL, a named negative test per rule) — `daily-content-spec.md` §6 | Depends On: -
- [ ] Task ID: F07-CONTENT-R1 | Assigned Role: Content Designer | Status: Queued | Summary: The Turkish Daily pool again, under `daily-content-spec.md` (§3–§5, §7): 60 days on the same calendar, 60 distinct non-Journey targets, `generate-daily` + `audit-daily` exit 0, `content:check` and `pack-daily` exit 0; replaces the F07-CONTENT pool | Depends On: F07-CORPUS, F07-TOOL-DAILY
- [ ] Task ID: F07-FE | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: The app (architecture D3–D8): `DailyContentSource` + the debug pack override + the debug today override (A4 ruling 6); cache population / prefetch / eviction; the D3 states; D4 dates and rollover; D5 transactional completion (entry + streak + enqueue); D6 streak; D7 Remote Config + kill-switch (`firebase_remote_config`, `http`); `/daily`, the Home entry, the daily Play header and result per `ui-design.md`; tests + named negatives; Visual Parity Evidence against the selected Direction A (`F07-A-*`); emulator sync evidence; architecture A1 rulings; a debug recipe to run any pool day (for QA; A5). Brief: the archived F07-FE brief ([orchestration at the incident](../../history/f07-daily-challenge-2026-09-29/orchestration-at-content-incident.md)), re-issued at activation | Depends On: F07-UI, F07-TOOL
- [ ] Task ID: F07-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Functional + visual QA on the emulator and the canonical simulator (architecture D10); the plan is locked at activation. Content acceptance is the audit + QA's content module; no user playtest (A5) | Depends On: F07-FE, F07-CONTENT-R1
- [ ] Task ID: F07-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: F07's release (architecture D11): pack hosting, publishing `daily_manifest_url`, rollback by repointing, the release smoke. Blocked on F08's deploy (F08.DEPLOY-RESUME → F08-DEVOPS), F07's functional QA and the target-list approval (F07.TARGET-LIST-APPROVAL) | Depends On: F07-QA-FUNCTIONAL
- [ ] Task ID: F07-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the release proof and any affected functional scope | Depends On: F07-DEVOPS

## Open Tasks

* **F07-CORPUS — Open** (Content Designer; the Current Brief).
* Queued: F07-TOOL-DAILY (Frontend/Mobile Developer), F07-CONTENT-R1 (Content Designer), F07-FE (Frontend/Mobile Developer; not started, independent of content), F07-QA-FUNCTIONAL, F07-QA-FINAL. Blocked: F07-DEVOPS (F08's deploy; F07.TARGET-LIST-APPROVAL).
* Done: F07-UI (A1; Direction A, A2), F07-TOOL (A3), F07-CONTENT (A4; superseded as product content at A5).

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
  * Prerequisite / External Decision: F07-CONTENT-R1 (the A4 pool is superseded, A5)
  * Re-evaluation Trigger: F07-CORPUS and F07-CONTENT-R1 deliveries; any change under `content/`, the dictionary asset or the authoring tool
  * Blocks: F07 functional acceptance
  * Delivery Evidence: Content Designer, 2026-09-29 (`content-design.md` §5). **Tech Lead re-run on 9af777f (A4):** `content:check` exit 0, 110 s; `pack-daily` exit 0, byte-identical pack (sha256 `fb33384d…db31`); three independent negatives on scratch copies (stale optimum, duplicate definition + `[noRepeat]`, `[puzzleDate]`), each exit 1, and the baseline exit 0. QA still evaluates independently.
  * Result: PENDING

- Evidence ID: F07.CONTENT-QUALITY
  * Scenario: Every Daily day passes every measurable rule of `daily-content-spec.md` §4 / §5 (Q1–Q12: distinct non-Journey targets, meaningful tiles, a proven thaw for each frozen row, the difficulty rhythm, not-too-close starts, word filler, no offensive words, no near-duplicates)
  * Required Class: repeatable integration
  * Target / Environment: `looplet_authoring audit-daily` over `content/daily/tr/` (its rules proven by named negative tests); QA re-runs it and replays at least 5 days with `solve` / `playtest`, including the Q5 / Q6 proof sequences
  * Owner Role: QA
  * Prerequisite / External Decision: F07-TOOL-DAILY; F07-CONTENT-R1
  * Re-evaluation Trigger: F07-CONTENT-R1 delivery
  * Blocks: F07 functional acceptance
  * Result: PENDING

- Evidence ID: F07.CORPUS-IMPACT
  * Scenario: After the corpus change, all committed content still passes `content:check` (Journey, smoke, Daily); any Journey level whose optimum changed is re-exported from its def with the same grid and tiles; F01's dictionary tests pass
  * Required Class: repeatable integration + automated functional
  * Target / Environment: `melos run content:check`, `melos run test`
  * Owner Role: QA
  * Prerequisite / External Decision: F07-CORPUS
  * Re-evaluation Trigger: F07-CORPUS delivery
  * Blocks: F07 functional acceptance and release (the Journey change is also an F05 content change)
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
  * Status: RESOLVED
  * Resolution: Superseded by the user's incident (2026-09-30, architecture A5) — the pool is not signed off; content quality belongs to the roles under `daily-content-spec.md` (a measured audit + QA), with no user playtest; the pool is re-authored in F07-CONTENT-R1
  * Resolved At: 2026-09-30

- Decision ID: F07.TARGET-LIST-APPROVAL
  * Question: Genişletilmiş sözlüğün onayı (F07-CORPUS: ≥ 120 hedef, ≥ 2.000 kelime). Ürün PRD'si F01 bunu zorunlu tutuyor: hedefler "manually-approved", iki liste de "manually reviewed". Oyun testi değil; kelime listesi onayı.
  * Options / Trade-offs: (A) Kullanıcı F07-CORPUS teslim edilince listeleri okur ve onaylar (~120 hedef kısa; ~2.000 kelime pratik değil). (B) Ürün kuralı değişsin: `Run Product Owner. Revise: F01 — sözlük ve hedef listesi Content Designer'ın yazılı kural setine ve otomatik kontrollerine göre onaylanır, QA bağımsız örneklem kontrolü yapar` — kullanıcıya hiç gelmez; PO revizyonu ve Tech Lead resync gerekir.
  * Recommendation: (B) — kullanıcının "içerik bana gelmesin" yönlendirmesine uygun; kural seti `daily-content-spec.md` §2.1'de hazır. (A) tek seferlik ve kısa bir iş.
  * Blocks: publishing the Daily (F07-DEVOPS, F07-QA-FINAL, Done); not F07-CORPUS, F07-TOOL-DAILY, F07-CONTENT-R1, F07-FE or functional QA
  * Blocking Scope: release
  * Status: OPEN

## Blockers

None

## Next Action

Run Content Designer — F07-CORPUS (the Current Brief).

For the user (only when ready): F07.TARGET-LIST-APPROVAL — `Run Tech Lead. Decision: F07.TARGET-LIST-APPROVAL — A` after reading the list, or `Run Product Owner. Revise: …` for option B. It blocks only publishing.

## Last Decision

2026-09-30 — the user's content incident (architecture A5).

* **Classified:** Existing Active Feature Rework (F07 content); root cause in the Tech Lead's F07-CONTENT brief — unmeasured quality, a user playtest as the acceptance, a generator outside the tools.
* **Measured on the A4 pool:** 0 / 300 filler rows hold a real word; 18 / 26 frozen days can never thaw; 1 / 60 days needs a temporary displacement; 9 / 60 starts are too close; tiles often do not change the optimum (A5).
* **Rulings:** `daily-content-spec.md` is the content contract; acceptance is measured (the audit + QA), no user playtest; the corpus is expanded inside F07; the generator / audit is a Developer tool; F07.DAILY-POOL-SIGNOFF superseded; F07.TARGET-LIST-APPROVAL opened (`release`); the A4 pool stays in the repo until R1 replaces it and is not publishable.
* **Routing:** F07-CORPUS Open → F07-TOOL-DAILY → F07-CONTENT-R1; F07-FE Queued (independent).

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-30
* Summary: The content incident (A5) — `daily-content-spec.md`; F07-CORPUS Open, F07-TOOL-DAILY / F07-CONTENT-R1 Queued, F07-FE back to Queued; F07.DAILY-POOL-SIGNOFF superseded, F07.TARGET-LIST-APPROVAL opened; owner → Content Designer.

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
* 2026-09-30 — Tech Lead: the content incident (architecture A5) — `daily-content-spec.md`; F07-CORPUS Open; F07-TOOL-DAILY, F07-CONTENT-R1 Queued; F07-FE back to Queued; F07.DAILY-POOL-SIGNOFF superseded; F07.TARGET-LIST-APPROVAL opened; owner → Content Designer. [Orchestration at the incident](../../history/f07-daily-challenge-2026-09-29/orchestration-at-content-incident.md) (the F07-FE brief).

## Current Brief

**F07-CORPUS — the Turkish corpus** (Content Designer; `daily-content-spec.md` §2.1; architecture A5; product PRD F01; workflow-follow-ups F01-PRODUCTION-CORPUS)

**Read first:**
* `daily-content-spec.md` — all of it; §0 explains why this task exists, §2.1 is this task;
* product PRD "dictionary-service (F01)" — the exclusion rules and the target rule;
* `packages/looplet_dictionary/assets/tr/dictionary.json` — the schema (`_note`, `schemaVersion`, `language`, `words`, `targets`, `exclusionsApplied`) and the current 103 words / 30 targets;
* F06 `content-authoring-brief.md` §5 (Turkish target words), §6 step 6 (re-export from defs).

**Deliver:**
1. **`dictionary.json`**, same schema:
   * `words`: at least **2,000** common Turkish words of 4–5 letters, lowercase, Turkish-normalized (`i`/`ı` distinct), no duplicates;
   * `targets`: at least **120** five-letter words, **including the 30 current targets unchanged** (the Journey uses them), every target also in `words`;
   * the current 103 words stay unless one breaks a rule (list any removal with its reason);
   * `_note` and `exclusionsApplied` updated: the source, the date, the rules.
2. **The source and the method, recorded:** the source list(s) by name and version (for example, TDK Güncel Türkçe Sözlük entries plus a named frequency list), the frequency cut-off, how inflected forms were excluded.
3. **Scripted checks, with their output in the report** (the script may live in the scratchpad; its exact command and result go in the report):
   * length 4–5 (`targets` exactly 5); the Turkish alphabet only;
   * no duplicates; `targets ⊆ words`;
   * the exclusion rules — proper nouns, profanity / slang / insults, abbreviations, archaic words — including a scan against a **named** profanity list;
   * one negative run: a scratch copy with a planted violation of each check fails that check.
4. **Target quality** (the Content Designer decides; nothing goes to the user): common, concrete, fine for a child; no two targets from the same root; no near-duplicate pair (one letter apart) among the new targets.
5. **The impact run:**
   * `melos run content:check` over all content. If a Journey level's stored optimum changed (more words → more thaws), re-export **only that level** from `tools/looplet_authoring/drafts/journey/_defs/` with the same grid, target and tiles, and list old → new optimum and label. If a label leaves its Journey band, stop and report (a blocker to the Tech Lead; do not redesign Journey levels).
   * The current Daily pool may fail `check` the same way; re-export it from its defs so `content:check` stays green. It is replaced in F07-CONTENT-R1 anyway.
   * `melos run test` — a failing dictionary test is a blocker for the Developer, not something to edit.
6. **`content-design.md`**, replacing its content with an F07-CORPUS section: counts, the source, the checks and their exit codes, the Journey impact table, and the list of the **new targets** (the user may be asked to read it — F07.TARGET-LIST-APPROVAL option A).

**Rules:**
* No code or tool change; no app change beyond the asset; no product criterion change.
* Quality decisions are yours, within the spec; an ambiguity goes to the Tech Lead, never to the user.
* A target you cannot meet (for example, fewer than 120 good five-letter words) → report with numbers and what was tried; do not lower the bar.

**Then:** close F07-CORPUS → owner Tech Lead → `Run Tech Lead`. The corpus checkpoint activates F07-TOOL-DAILY (the Developer's generator and audit), then F07-CONTENT-R1.
