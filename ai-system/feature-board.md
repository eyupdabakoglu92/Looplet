# Feature Board — LOOPLET

Last Updated: 2026-09-18
Active Phase: Evidence and QA queue reconciliation
Active Owner: Tech Lead
Active Feature: F05
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | In Progress | Tech Lead | Pending current acceptance | P0 | Acceptance validation reopened: required device/manual evidence in architecture §16/§18 is still pending. No new code defect asserted. |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. |
| F05 | journey-progression | In Progress | Tech Lead | Pending current acceptance | P0 | Active feature. Strict 30-level content delivered; F05-QA-STRICT queued. Tech Lead reconciles inherited F03/F08 runtime proof before final QA. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending and can proceed independently. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* Next command: Run Tech Lead.
* F05 remains the current feature; its strict-content QA task is queued, not deleted or approved.
* Reconcile F03's required device/manual evidence and F08's shared local persistence proof before claiming downstream final acceptance. Activate only one QA feature at a time.
* F08 release authorization gates the release stage only. No paid service, deployment, production action or store distribution was authorized by core migration.
* F09–F13 remain Not Started; no new feature was activated.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
