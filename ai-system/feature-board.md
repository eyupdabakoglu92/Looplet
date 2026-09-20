# Feature Board — LOOPLET

Last Updated: 2026-09-20
Active Phase: F03 rework — win sequence and integration suite
Active Owner: UI Designer
Active Feature: F03
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | Rework | UI Designer | Rejected (final QA 2026-09-20) | P0 | Interaction, resume, back and misuse passed on simulators. Rejected for F03-QA-01 (F04 panel hides the win sequence/winning row) and F03-QA-02 (integration group 4). Route: UI Designer → Frontend/Mobile Developer → Tech Lead → QA. F03.RUNTIME-LIMITS RESOLVED = A (Accessibility grant is a pending user action). |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F03 rework may adjust panel timing/geometry (F03 architecture §18, 2026-09-20); F04 ACs unchanged, stays Done. |
| F05 | journey-progression | In Progress | Tech Lead | Pending current acceptance | P0 | Strict 30-level content delivered; F05-QA-STRICT queued behind F03 rework + re-QA (its shared win/exit path is changing). Not activated for QA. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending, queued behind F03 QA (one QA feature at a time); not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* Next command: Run UI Designer (task F03-UI-WON in F03 orchestration).
* F03 is the active feature in Rework after final QA returned Rejected. Planned chain: UI Designer → Frontend/Mobile Developer (F03-FE-WON, F03-FE-INTEG) → Tech Lead reconciliation → QA (F03-QA-REVERIFY).
* Rework-control rule: no QA, DevOps or client-developer owner is assigned to F05/F08 while F03 rework is open. F05-QA-STRICT and F08 local evidence stay queued with Owner Tech Lead.
* Decision F03.RUNTIME-LIMITS RESOLVED = A (2026-09-20): rotation / live lifecycle / AC9 highlight are closed by QA through Accessibility-enabled simulator automation. Pending user action: grant macOS Accessibility (and Automation for System Events) to the host app running Claude Code; QA probes it first at F03-QA-REVERIFY. It does not affect the rework chain.
* F08 release authorization gates the release stage only. No paid service, deployment, production action or store distribution is authorized.
* F09–F13 remain Not Started; no new feature was activated.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
