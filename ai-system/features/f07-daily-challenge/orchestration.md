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
- [x] Task ID: F07-CONTENT | Assigned Role: Content Designer | Status: Done | Summary: **Superseded as product content by the incident of 2026-09-30 (architecture A5); replaced by F07-CONTENT-R1.** The Turkish Daily pool (workflow-follow-ups F06-CONTENT-DAILY): 60 solved daily puzzles under `content/daily/tr/pool/` on the provisional calendar 2026-11-01 … 12-30 (architecture A3 ruling 5), `daily_manifest_tr.json`, `content-design.md`; `check` + `pack-daily` exit 0. Historical acceptance record only; the old user sign-off model was superseded by A5/A6. | Depends On: F07-TOOL
- [x] Task ID: F07-CONTENT-PREFLIGHT | Assigned Role: Content Designer | Status: Done | Summary: Source/usage and corpus feasibility, candidate counts, exclusion/editorial rubric, representative pilot plan and permanent-tool gaps under daily-content-spec revision 2. Do not expand runtime corpus or batch-author before tool readiness. | Depends On: -
- [ ] Task ID: F07-CORPUS | Assigned Role: Content Designer | Status: Queued | Summary: Curate the sourced Turkish corpus under daily-content-spec §2: ≥120 targets, keep Journey targets and legitimate existing words, full-list checks via committed tools, editorial target review, Journey/Daily impact and bundle parity. 2,000 usable words is a research target, not permission to pad quality. Brief additions from A7 ruling 5: per-word rationales (not category templates), a sourced and versioned exclusion list with its over-match recorded, measured filler/thaw yield. | Depends On: F07-TOOL-DAILY-R1
- [x] Task ID: F07-TOOL-DAILY | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: Delivered permanent sourced corpus import/audit, bounded generate-daily and audit-daily Q1–Q12, solver/scorer/counterfactual limits, fingerprinted technical-pilot evidence, and production pack rejection for missing/stale quality evidence. Developer verification and limitations are recorded in quality-tooling-delivery.md; Tech Lead checkpoint A7: logic reconciled, pilot PASS not reproducible (2026-11-04 Q4 UNKNOWN, enumeration 29.7 s vs 30 s) — review Pending, rework F07-TOOL-DAILY-R1. | Depends On: F07-CONTENT-PREFLIGHT
- [x] Task ID: F07-TOOL-DAILY-R1 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: Tooling rework from A7 rulings 1–3: verdicts not decided by the wall clock (node/depth decide; time is an outer ceiling ≤300 s; stop cause and margin reported); measured o = 6 and o = 7 feasibility with sound pruning and a named pruned-vs-exhaustive test, or measurements returned for a Tech Lead profile decision; repo-relative `sourceDir` with a negative test; regenerated technical pilot re-audited twice identically (once under load). Brief: Current Brief | Depends On: F07-TOOL-DAILY
- [ ] Task ID: F07-CONTENT-PILOT | Assigned Role: Content Designer | Status: Queued | Summary: At least 8 accepted representative examples (2 per mechanic class), real forward proofs, negative fixtures, editorial review, yield/time and fingerprints; hand off to Tech Lead for pilot acceptance before batch generation. | Depends On: F07-CORPUS, F07-TOOL-DAILY-R1
- [ ] Task ID: F07-CONTENT-R1 | Assigned Role: Content Designer | Status: Queued | Summary: Re-author 60 days with 60 distinct non-Journey targets under daily-content-spec revision 2; full audit, content:check, pack-daily, editorial review and current evidence. Activate only after Tech Lead accepts the pilot. | Depends On: F07-CONTENT-PILOT
- [ ] Task ID: F07-FE | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: The app (architecture D3–D8): `DailyContentSource` + the debug pack override + the debug today override (A4 ruling 6); cache population / prefetch / eviction; the D3 states; D4 dates and rollover; D5 transactional completion (entry + streak + enqueue); D6 streak; D7 Remote Config + kill-switch (`firebase_remote_config`, `http`); `/daily`, the Home entry, the daily Play header and result per `ui-design.md`; tests + named negatives; Visual Parity Evidence against the selected Direction A (`F07-A-*`); emulator sync evidence; architecture A1 rulings; a debug recipe to run any pool day (for QA; A5). Brief: the archived F07-FE brief ([orchestration at the incident](../../history/f07-daily-challenge-2026-09-29/orchestration-at-content-incident.md)), re-issued at activation | Depends On: F07-UI, F07-TOOL
- [ ] Task ID: F07-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Functional + visual QA on the emulator and the canonical simulator (architecture D10); the plan is locked at activation. Content acceptance is the audit + QA's content module; no user playtest (A5) | Depends On: F07-FE, F07-CONTENT-R1
- [ ] Task ID: F07-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: F07's release (architecture D11): pack hosting, publishing `daily_manifest_url`, rollback by repointing, the release smoke. Blocked on F08's deploy (F08.DEPLOY-RESUME → F08-DEVOPS), F07's functional QA and current content quality evidence (A6; target-list policy decision resolved) | Depends On: F07-QA-FUNCTIONAL
- [ ] Task ID: F07-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the release proof and any affected functional scope | Depends On: F07-DEVOPS

## Open Tasks

* F07-CONTENT-PREFLIGHT — Done; source/design checkpoint in content-preflight.md.
* F07-TOOL-DAILY — Done as a delivery; Tech Lead checkpoint A7: Delivery Review Pending (pilot PASS not reproducible; weekend profile unverified).
* F07-TOOL-DAILY-R1 — Done (Frontend/Mobile Developer, 2026-09-30); at the mandatory Tech Lead checkpoint. Pilot re-audit PASS twice with identical verdicts; o = 6 / 7 measured infeasible under the node bound (cNorm) — Needs Tech Lead Clarification in `quality-tooling-delivery.md`.
* Queued: Tech Lead checkpoint → F07-CORPUS → F07-CONTENT-PILOT → Tech Lead pilot checkpoint → F07-CONTENT-R1; F07-FE remains independently queued.
* F07-QA-FUNCTIONAL / F07-QA-FINAL queued. F07-DEVOPS blocked by F08 deploy readiness; content quality remains a required acceptance dependency.
* Historical F07-CONTENT is superseded; no production corpus/pilot/pool is approved by A6.

## Handoff Plan

None

## Delivery Review

Pending

## Content Quality Contract

daily-content-spec.md

## Content Quality Gate

Pending

## Content Quality Evidence

Developer technical evidence: `quality-tooling-delivery.md` (R1 section); `evidence/technical-pilot-v1-audit.json` — regenerated by F07-TOOL-DAILY-R1 with the changed tools (same source bytes): PASS, `independentQa: false`, reproduced twice with identical verdicts and peak nodes, once under load (the A7 non-reproduction is superseded pending Tech Lead review); `evidence/technical-pilot-v1-provenance.json` (`reaudits`); `evidence/r1-depth-measurement.json` (o = 6 / 7 feasibility). Production corpus, Content Designer pilot, 60-day pool and independent QA remain pending.

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

- Evidence ID: F07.TOOL-DAILY-REVIEW
  * Scenario: Reconcile the permanent corpus/generator/auditor implementation, its fail-closed production pack gate, named negative tests and the eight-example technical pilot. Confirm that Developer feasibility evidence is not mistaken for editorial or independent-QA acceptance.
  * Required Class: repeatable integration + authority review
  * Target / Environment: `quality-tooling-delivery.md`, `tools/looplet_authoring`, `packages/looplet_solver`, and `evidence/technical-pilot-v1-audit.json`
  * Owner Role: Tech Lead
  * Prerequisite / External Decision: F07-TOOL-DAILY delivery
  * Re-evaluation Trigger: Any change to the quality contract, solver, engine, corpus importer, generator, auditor, pack gate or technical-pilot bytes
  * Blocks: F07-CORPUS activation
  * Delivery Evidence: Developer, 2026-09-30 — 29 solver tests, 96 authoring tests, 93 workflow tests, clean static analysis; durable pilot PASS with `independentQa: false`; old runtime corpus and old Daily pool rejected by the new gates.
  * Delivery Evidence (R1): Frontend/Mobile Developer, 2026-09-30 — solver 40 / 40 (new pruning-soundness tests), authoring 105 / 105 (new search-determinism tests), analyze clean, `content:check` SUCCESS; pilot re-audit PASS twice (idle and under `dart test` load), identical verdicts / proofs / difficulty / peak nodes; o = 6 / 7: Q4 UNKNOWN (nodes) on all four measured candidates (cNorm), Q6 UNKNOWN (nodes) at o = 7. `quality-tooling-delivery.md` R1.
  * Tech Lead re-run (A7, on 1032f8a): test counts, analysis, corpus audits and three pack-gate negatives reproduced. Pilot re-audit twice (loaded and idle host), same `inputHash` / `analysisInputHash`: **FAIL**, 2026-11-04 Q4/Q9 UNKNOWN — optimal enumeration 29.7 s against the 30 s budget. Re-evaluated after F07-TOOL-DAILY-R1.
  * Result: PENDING

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
  * Scenario: The Turkish pool passes the executable content gates: `check` (a fresh solve of every artifact, target eligibility, dedup across smoke / Journey / Daily, every D2 (2) rule) and `pack-daily` (60 days, #1 … #60). This proves structural correctness only; quality additionally requires F07.CONTENT-QUALITY under A6.
  * Required Class: repeatable integration
  * Target / Environment: `looplet_authoring` over `content/` and `content/daily/tr/`
  * Owner Role: QA
  * Prerequisite / External Decision: F07-CONTENT-R1 (the A4 pool is superseded, A5)
  * Re-evaluation Trigger: F07-CORPUS and F07-CONTENT-R1 deliveries; any change under `content/`, the dictionary asset or the authoring tool
  * Blocks: F07 functional acceptance
  * Delivery Evidence: Content Designer, 2026-09-29 (`content-design.md` §5). **Tech Lead re-run on 9af777f (A4):** `content:check` exit 0, 110 s; `pack-daily` exit 0, byte-identical pack (sha256 `fb33384d…db31`); three independent negatives on scratch copies (stale optimum, duplicate definition + `[noRepeat]`, `[puzzleDate]`), each exit 1, and the baseline exit 0. QA still evaluates independently.
  * Result: PENDING

- Evidence ID: F07.CONTENT-QUALITY
  * Scenario: Every Daily day passes every applicable required rule of `daily-content-spec.md` revision 2 §4–§7; advisory Q9 and permitted N/A are reported separately; real forward/counterfactual proofs and reasoned editorial review are required
  * Required Class: repeatable integration
  * Target / Environment: `looplet_authoring audit-daily` over `content/daily/tr/` (its rules proven by named negative tests); QA re-runs it and independently reviews/replays at least 8 days with `solve` / `playtest`, including the Q5 / Q6 proof sequences
  * Owner Role: QA
  * Prerequisite / External Decision: F07-TOOL-DAILY; F07-CONTENT-R1
  * Re-evaluation Trigger: Any change to the corpus, engine, tools, config, reference paths or content invalidates affected quality evidence
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
  * Question: The acceptance model for the expanded Turkish corpus.
  * Options / Trade-offs: User list review or documented content curation/automated validation plus independent QA.
  * Recommendation: Strengthened B, as reviewed with the user.
  * Blocks: No unresolved user decision; actual corpus/content evidence still blocks acceptance and release through the task/evidence ledger.
  * Blocking Scope: release
  * Status: RESOLVED
  * Resolution: User approved the content-quality proposal in chat (2026-09-30). PO-REV-2026-09-30-CONTENT-QUALITY applied and F01/F07 resynced (A6): full automated rules, all-target editorial review and independent risk-based QA; no routine user list review. This does not approve an undelivered corpus or pool.
  * Resolved At: 2026-09-30

## Blockers

None

## Next Action

Run Tech Lead. Reconcile F07-TOOL-DAILY-R1 (`quality-tooling-delivery.md` R1) and decide the heavy-day profile against the cNorm measurement; if accepted, activate F07-CORPUS. The provisional corpus and the Developer pilot are not content/QA acceptance.

## Last Decision

2026-09-30 — F07-TOOL-DAILY checkpoint, architecture A7: logic and pack gate reconciled; the pilot PASS does not reproduce (wall-clock margin) and the o = 6–7 weekend profile is unverified; Delivery Review Pending; F07-TOOL-DAILY-R1 Open; F07-CORPUS depends on it.

Previous: 2026-09-30 — user-approved content quality revision, architecture A6.

* Shared content quality standard and structural workflow gates adopted; Content Quality Gate Pending.
* F01 approval policy revised/resynced (PO-REV-2026-09-30-CONTENT-QUALITY); F07.TARGET-LIST-APPROVAL RESOLVED for the model only.
* daily-content-spec revision 2 corrects state/thaw/proof/partial-week/corpus ambiguities. Permanent tools and a representative pilot are prerequisites.
* Route: preflight → tools → corpus → pilot → Tech Lead checkpoint → batch → independent QA. No downstream work is claimed complete.

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-30
* Summary: F07-TOOL-DAILY-R1 Done — nodes-before-clock guard with stop causes, 300 s ceiling, admissible/consistent pruning (results equal to exhaustive search), repo-relative report source, regenerated pilot PASS twice identically; o = 6 / 7 infeasible under the node bound (cNorm). Delivery Review Pending; owner → Tech Lead.

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

* 2026-09-30 — User-approved content quality revision (A6): shared standard/gates, F01 product-policy revision, corrected daily contract, preflight/tool/corpus/pilot/batch dependencies; target-list decision resolved. [Prior state](../../history/f07-daily-challenge-2026-09-29/orchestration-before-quality-revision.md).
* 2026-09-30 — Frontend/Mobile Developer: F07-TOOL-DAILY Done — permanent sourced corpus import/audit, bounded generation and Q1–Q12 audit, bounded solver/scorer/counterfactuals, stale-proof production pack rejection, named negative tests and a fingerprinted 8-example technical pilot; Delivery Review Pending; owner → Tech Lead. [quality-tooling-delivery.md](quality-tooling-delivery.md).
* 2026-09-30 — Tech Lead: F07-TOOL-DAILY checkpoint (architecture A7) — not accepted: the pilot re-audit FAILs twice with identical fingerprints (2026-11-04 Q4 UNKNOWN, enumeration 29.7 s vs 30 s); o = 6–7 profile unverified; `sourceDir` absolute. F07-TOOL-DAILY-R1 Open; F07-CORPUS → depends on R1; owner → Frontend/Mobile Developer.
* 2026-09-30 — Frontend/Mobile Developer: F07-TOOL-DAILY-R1 Done — deterministic stop causes, pruned solve/enumeration/witness searches proven equal to exhaustive, portable reports, pilot re-audit PASS twice identically; o = 6 / 7 measured (cNorm exceeds the node bound → Q4 UNKNOWN); Delivery Review Pending; owner → Tech Lead. [quality-tooling-delivery.md](quality-tooling-delivery.md) (R1).

## Current Brief

**F07-TOOL-DAILY-R1 — Frontend/Mobile Developer.** Authority: `architecture.md` A7 (rulings 1–3), `daily-content-spec.md` revision 2 §3–§6, `prompt-content-quality-standard.md`. Your prior delivery: `quality-tooling-delivery.md`.

**Symptom (Tech Lead measurement, A7):** with byte-identical inputs (same `inputHash` / `analysisInputHash`), `audit-daily` over `evidence/technical-pilot-v1` returns FAIL on this host twice — 2026-11-04 `lokma` Q4/Q9 UNKNOWN, `SearchLimitExceeded(optimal enumeration)`. `Solver.enumerateOptimalSolutionsWithCoverage` for that day takes 29.7 s against the 30 s time budget (complete, 33 solutions). The enumeration first builds a full breadth-first ball to depth o (~20^o). `searchWitness` (Q5 absence, regression, useful thaw) is plain breadth-first to depth o as well.

**Scope:**

1. **Deterministic verdicts.** Node and depth limits decide; time is an outer safety ceiling (you may raise it per analysis up to 300 s, or improve the algorithm). Every UNKNOWN records its cause (`time` / `nodes` / `depth`), nodes used and elapsed time. Do not change the 5,000,000-node / depth-16 bounds, any Q-rule, threshold, scorer weight or label boundary.
2. **o = 6 and o = 7 feasibility (§4 weekend profile).** Measure enumeration (Q4), Q5 absence, the regression proof and the useful-thaw search on at least two generated candidates each at o = 6 and o = 7 (staging only; not content). If they exceed the node bound, add sound pruning (for example an admissible lower bound from the solver's heuristic, applied to enumeration and to absence searches) and prove soundness with a named test: on small fixtures the pruned result (solution set, absence verdict) equals the exhaustive one, plus a negative with a deliberately inadmissible bound that the test catches. If o = 6–7 stays infeasible, stop and report the measurements; do not narrow the profile yourself (A7 ruling 2).
3. **Portability.** Store `sourceDir` repo-relative in reports and resolve it from `--repo-root` in the batch gate; named negative test for a report whose source path does not resolve. Document in the tool README that a production pack needs the same Dart runtime as its full audit (`runtime/dart` fingerprint; A7 ruling 3).
4. **Regenerate the technical pilot** (`evidence/technical-pilot-v1*` or a `-v2`, your choice, with provenance) against the changed tools, and re-audit it **twice** with identical per-rule verdicts, one run concurrent with `dart test`. Record both commands, exit codes, per-day elapsed and node figures.

**Preserved behavior:** `melos run content:check` OK on all committed content; difficulty scores/labels unchanged wherever the old enumeration completed (show one before/after, e.g. 2026-11-04 medium 5.2728); pack-gate negatives still exit 1; no change to the runtime dictionary, `content/`, the app or the curation data.

**Non-goals:** corpus editorial work (F07-CORPUS), Daily content, the app (F07-FE), CI changes.

**Exit criteria:** analyze clean; solver / authoring / workflow tests green with the new named tests; `content:check` OK; the pilot re-audit PASS twice with identical verdicts; the o = 6 / o = 7 measurement table; an R1 section in `quality-tooling-delivery.md` with task-to-code traceability and evidence records. Set Delivery Review = Pending and return to Tech Lead.
