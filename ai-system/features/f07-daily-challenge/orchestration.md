# F07 — daily-challenge: Orchestration

## Feature ID

F07

## Current Status

In Progress

## Current Owner

UI Designer

## Next Role

UI Designer

## Active Task Ledger

- [ ] Task ID: F07-UI | Assigned Role: UI Designer | Status: Open | Summary: The Daily surfaces on the Selected Foundation (architecture D8): the Home Daily entry (secondary; available / done today / needs connection), the Daily screen states (`loading`, `ready`, `doneToday`, `needsConnection`, `unavailable`), the daily Play header, and the daily result variant (official vs replay; Current + Best Streak; the reserved Share place for F13). At least two materially different rendered directions on identical content, then `ui-design.md` with the screen / state / viewport matrix and a Visual Evidence Manifest. Brief: Current Brief | Depends On: -
- [ ] Task ID: F07-TOOL | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: The daily pack (architecture D2): a `DailyPack` model in `looplet_content`; `looplet_authoring pack-daily` (manifest + pool → the served `daily_pack_{lang}.json`); `check` extended to every D2 (2) rule with named negative cases; a small dev pack from existing smoke / Journey-shaped definitions for delivery and tests (not product content) | Depends On: -
- [ ] Task ID: F07-CONTENT | Assigned Role: Content Designer | Status: Queued | Summary: The Turkish Daily pool (workflow-follow-ups F06-CONTENT-DAILY): about 60 solved daily puzzles under `content/daily/tr/pool/`, `daily_manifest_tr.json` (numbering epoch + assignments, 30-day no-repeat), `content-design.md`; `check` + `pack-daily` exit 0. Opens the sign-off gate F07.DAILY-POOL-SIGNOFF on delivery | Depends On: F07-TOOL
- [ ] Task ID: F07-FE | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: The app (architecture D3–D8): `DailyContentSource` + the debug pack override; cache population / prefetch / eviction; the D3 states; D4 dates and rollover; D5 transactional completion (entry + streak + enqueue); D6 streak; D7 Remote Config + kill-switch (`firebase_remote_config`, `http`); `/daily`, the Home entry, the daily Play header and result per `ui-design.md`; tests + named negatives; Visual Parity Evidence; emulator sync evidence | Depends On: F07-UI, F07-TOOL
- [ ] Task ID: F07-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Functional + visual QA on the emulator and the canonical simulator (architecture D10); the plan is locked at activation | Depends On: F07-FE, F07-CONTENT
- [ ] Task ID: F07-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: F07's release (architecture D11): pack hosting, publishing `daily_manifest_url`, rollback by repointing, the release smoke. Blocked on F08's deploy (F08.DEPLOY-RESUME → F08-DEVOPS) and F07's functional QA | Depends On: F07-QA-FUNCTIONAL
- [ ] Task ID: F07-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the release proof and any affected functional scope | Depends On: F07-DEVOPS

## Open Tasks

* **F07-UI — Open** (UI Designer): the Daily surfaces, rendered directions and handoff (Current Brief).
* Queued: F07-TOOL, F07-CONTENT, F07-FE, F07-QA-FUNCTIONAL, F07-QA-FINAL. Blocked: F07-DEVOPS (F08's deploy).

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

Pending

## Visual Evidence

None

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

None

## Blockers

None

## Next Action

Run UI Designer — F07-UI (Current Brief): at least two rendered directions for the Daily surfaces on the Foundation, then `ui-design.md` with the Visual Evidence Manifest. Then the Tech Lead checkpoint, which opens F07.DIRECTION-SELECT for the user.

## Last Decision

2026-09-29 — Tech Lead activation of F07 after the user's decision F08.FUNCTION-DEPLOY-GO — C (F08 `architecture.md` A21).

* **Dependency ruling:** F07 builds on F08's Functional Approved client surface; F07's release waits on F08's deployed callable (F08.DEPLOY-RESUME).
* **Contract:** architecture D1–D11 — the pack format and Remote Config pointer, fetch / cache / eviction, dates and rollover (the start date wins), the transactional first run, the streak rule, the kill-switch, the surfaces and routes (a secondary Home entry; no Share in F07), validation, evidence and release.
* **Scope:** Visual Scope `new-surface` → UI Designer first; Release Scope `production-readiness`; AC7's Share part carried by F13 AC1 (Assumption, prd Open Questions (1)).
* **Brought in from workflow-follow-ups:** F06-CONTENT-DAILY (F07-CONTENT), F07-KILL-SWITCH (D7), SHARED-PERSISTENCE-PROOF's F07.OFFLINE-DAILY, and the daily-streak chip of USER-REFERENCE-CONTENT-DELTAS (a proposal the UI Designer may use).

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-29
* Summary: F07 activated (prd, architecture, orchestration); F07-UI Open; owner → UI Designer.

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

## Current Brief

**F07-UI — the Daily surfaces on the Foundation** (architecture D8; Visual Scope `new-surface`)

**Read first:**
* `prd.md` — AC1–AC7 and the edge cases;
* `architecture.md` — D3 (the states), D4 (dates), D6 (the displayed streak), D7 (the kill-switch effect), D8 (surfaces and routes);
* `project-authority/design-foundation.md` — Selected, Direction C "Loop Glass";
* `features/f00-design-foundation/ui-design.md` — components, states, accessibility;
* `design/design-doctrine.md`, `design/premium-ui-rubric.md`, `design/visual-quality-gate.md`;
* the shipped siblings:
  * Home — F05 `architecture.md` §18, F05 `ui-design.md` (D3);
  * Play and the result — F03 `ui-design.md`, D1 / D2, F03 `architecture.md` §19 / §20;
* `templates/feature-ui-design.template.md`;
* `project-authority/platform.md` §14 — the canonical capture targets: iPhone 16 (primary), 16e, 16 Pro Max.

**Deliver:**
1. **At least two materially different rendered directions on identical content**, covering at least:
   * the Home with its Daily entry (available, and done today);
   * the Daily screen in `ready` and `needsConnection`;
   * the daily result — a first run with streak 5 / best 12, and a replay showing the official result unchanged.
   * Real renders, not text or wireframes. Your recommendation is not a selection: the user picks (F07.DIRECTION-SELECT, opened at the checkpoint).
2. **For the recommended direction, the full state set:**
   * the Home entry: available / done today / needs connection / hidden;
   * Daily: `loading`, `ready`, `doneToday`, `needsConnection`, `unavailable`;
   * the daily Play header (`GÜNLÜK · #N` + date);
   * the result: first run / replay, streak 0 → 1 after a missed day, best preserved;
   * the reserved Share place (empty in F07);
   * at the three viewports, and at AX5 for the free text (C-9).
3. **`ui-design.md`:**
   * the screen / state / viewport matrix;
   * component, typography, colour, asset and interaction decisions — reuse `app/lib/design` components, and name any new one;
   * motion: the entry and result transitions, consistent with D2's result motion, or an explicit `not applicable`, with the Reduce Motion behaviour;
   * Turkish interim copy through a strings table;
   * the source render records and the **Visual Evidence Manifest**.

**Rules:**
* **Home keeps one primary lime CTA** (F05 §18). The Daily entry is secondary.
* **No Share control in F07** — leave its place only.
* Never colour-only.
* No raw error text anywhere.
* The streak shows the **effective** value (D6).
* Do not design F10's menu, F13's share card or F12.
* If a contract point blocks a good design, stop and report it to the Tech Lead rather than working around it.

**Non-goals:** no app code; no copy finalisation (PO / localization later); no change to the Foundation tokens. A token gap goes to the Tech Lead.

**Then:** close F07-UI, owner → Tech Lead, `Run Tech Lead` (the visual-gate checkpoint; the user then selects the direction).
