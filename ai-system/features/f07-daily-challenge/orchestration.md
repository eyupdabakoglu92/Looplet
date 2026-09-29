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
- [ ] Task ID: F07-CONTENT | Assigned Role: Content Designer | Status: Queued | Summary: The Turkish Daily pool (workflow-follow-ups F06-CONTENT-DAILY): about 60 solved daily puzzles under `content/daily/tr/pool/`, `daily_manifest_tr.json` (numbering epoch + assignments, 30-day no-repeat), `content-design.md`; `check` + `pack-daily` exit 0. Opens the sign-off gate F07.DAILY-POOL-SIGNOFF on delivery | Depends On: F07-TOOL
- [ ] Task ID: F07-FE | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: The app (architecture D3–D8): `DailyContentSource` + the debug pack override; cache population / prefetch / eviction; the D3 states; D4 dates and rollover; D5 transactional completion (entry + streak + enqueue); D6 streak; D7 Remote Config + kill-switch (`firebase_remote_config`, `http`); `/daily`, the Home entry, the daily Play header and result per `ui-design.md`; tests + named negatives; Visual Parity Evidence against the selected Direction A (`F07-A-*`); emulator sync evidence; architecture A1 rulings | Depends On: F07-UI, F07-TOOL
- [ ] Task ID: F07-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Functional + visual QA on the emulator and the canonical simulator (architecture D10); the plan is locked at activation | Depends On: F07-FE, F07-CONTENT
- [ ] Task ID: F07-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: F07's release (architecture D11): pack hosting, publishing `daily_manifest_url`, rollback by repointing, the release smoke. Blocked on F08's deploy (F08.DEPLOY-RESUME → F08-DEVOPS) and F07's functional QA | Depends On: F07-QA-FUNCTIONAL
- [ ] Task ID: F07-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the release proof and any affected functional scope | Depends On: F07-DEVOPS

## Open Tasks

* F07-TOOL — Done (2026-09-29), delivery in `frontend.md` (F07-TOOL section); awaiting the Tech Lead reconciliation.
* F07-UI — Done, accepted at A1; **Direction A selected** by the user (A2).
* Queued: F07-CONTENT (after F07-TOOL), F07-FE (after F07-TOOL), F07-QA-FUNCTIONAL, F07-QA-FINAL. Blocked: F07-DEVOPS (F08's deploy).

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

Run Tech Lead — reconcile the F07-TOOL delivery (`frontend.md`, F07-TOOL section: `DailyPack` + validator, `pack-daily`, `check` over D2 (2) with named negatives, the dev pack; §14 assumptions, §16 the non-blocking Daily-reuse note), then activate F07-CONTENT and F07-FE.

## Last Decision

2026-09-29 — Decision F07.DIRECTION-SELECT — A (the user; architecture A2).

* **Direction A "Hafta döngüsü" selected;** B is not built. The `F07-A-*` renders are the selected source; the A1 checkpoint rulings bind Frontend and QA.
* **Visual Quality Gate → Ready for Implementation.**
* **Routing:** F07-TOOL Open (Frontend/Mobile Developer); F07-FE follows after the F07-TOOL reconciliation.

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-29
* Summary: F07-TOOL Done — `DailyPack` + `CalendarDate` (`looplet_content`), `pack-daily`, `check` extended to D2 (2), named negatives, the dev pack fixture; gates green; Delivery Review Pending; owner → Tech Lead.

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

## Current Brief

**F07-TOOL — the daily pack tooling** (architecture D2, D9; Frontend/Mobile Developer — the F06 toolchain owner role)

**Read first:** `architecture.md` D2 (the pack format and its rules), D9 (validation responsibility), A1 ruling 1 (the day envelope the app will cache — the same `{dailyNumber, puzzle}` shape as a pack `days[]` entry); `packages/looplet_content` (`Puzzle`); `tools/looplet_authoring` (`cli.dart`, `content_check.dart` — `check` already reads a manifest's `assignments` and enforces the 30-day no-repeat window); `melos.yaml` `content:check`; `project-authority/setup-manifest.md`.

**Deliver:**
1. **`DailyPack` in `looplet_content`** (pure Dart): `schemaVersion`, `contentVersion`, `lang`, `numberingEpoch`, `days` (`dailyDate`, `dailyNumber`, `puzzle`); `fromJson` / `toJson` (lowerCamelCase, optional fields omitted); a validator returning **named** violations for every D2 (2) rule — sorted, contiguous and unique dates; `puzzle.dailyDate == dailyDate`; `type == daily`; `id == "daily-{lang}-{dailyDate}"`; parses with `optimalMoves ≥ 1`; `dailyNumber == days since numberingEpoch + 1` (calendar-date arithmetic, D4); the 30-day no-repeat over the puzzle definitions; `lang` matches every puzzle. The app (F07-FE) will reuse this validator at fetch time.
2. **`looplet_authoring pack-daily`**: `content/daily/{lang}/daily_manifest_{lang}.json` + `pool/` → `daily_pack_{lang}.json` in a build-output path that is not the source (name it; ignored by git); non-zero exit with the named violation on any rule failure; deterministic output (the same inputs give the same bytes).
3. **`check`** extended so every D2 (2) rule fails on the source manifest + pool, not only the no-repeat window.
4. **Tests with named negative cases** — one per D2 (2) rule, plus a positive pack round-trip; each negative shown failing for the intended reason.
5. **A dev pack** for F07-FE delivery and tests, built from existing smoke / Journey-shaped definitions as `type: daily` copies (a fixture, **not** product content; keep it out of `content/daily/tr/pool/`, which F07-CONTENT owns), covering today − 14 … today + 7 relative to a fixed test date and a variant that the D3 date logic can shift.
6. **`frontend.md` (F07-TOOL section):** task-to-code traceability, the commands run with their exit codes (`melos run analyze`, the package / tool tests, `melos run content:check`, `pack-daily` on the dev fixture), preserved behaviour of existing `check` rules, and anything the Content Designer needs to know (the manifest shape, how to run `pack-daily`).

**Rules:** no app code (F07-FE); no F08 change; no product Daily content (F07-CONTENT); no Flutter or dependency upgrade; a contract gap goes to the Tech Lead.

**Then:** close F07-TOOL; owner → Tech Lead; `Run Tech Lead` (reconciliation; then F07-CONTENT and F07-FE).
