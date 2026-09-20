# Feature Board — LOOPLET

Last Updated: 2026-09-21
Active Phase: F03 rework (F03-QA-03 / F03-QA-04)
Active Owner: Frontend/Mobile Developer
Active Feature: F03
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | Rework | Frontend/Mobile Developer | Rejected (final re-verify 2026-09-20) | P0 | QA closed F03-QA-01/02; F03-QA-03 (OS interruption commits a held drag) and F03-QA-04 (iOS Reduce Motion not honoured; six call sites incl. F04/F05 surfaces) routed to Frontend/Mobile Developer. Behavioural rework: Visual Scope none for this reopen. Whole-surface visual conformance runs through the Design Adoption Route (workflow-follow-ups.md). |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F04's panel reduce-motion read (completion_panel.dart) is in F03-QA-04's fix set (accessibility behaviour only, ACs unchanged); F03 rework changed panel timing/geometry and code (F03 architecture §18, 2026-09-20: deferred reveal, density, spine glow, Close tap target 44 pt); F04 ACs unchanged, F04 tests green, stays Done. |
| F05 | journey-progression | In Progress | Tech Lead | Pending current acceptance | P0 | Strict 30-level content delivered; F05-QA-STRICT queued behind F03 rework + re-QA (its shared win/exit path is changing). F05's home ring / column tutorial reduce-motion reads are in F03-QA-04's fix set (accessibility only). Not activated for QA. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending, queued behind F03 QA (one QA feature at a time); not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* Next command: Run Frontend/Mobile Developer (tasks F03-FE-CANCEL and F03-FE-REDUCEMOTION in F03 orchestration). Delivery returns to Tech Lead for reconciliation; then QA (F03-QA-REVERIFY2, modules core + client-ui + stateful-flow, depth full, evidence reuse allowed per the brief).
* Rework-control rule applies: no QA, DevOps or client-developer owner is assigned to F05/F08 until F03's re-QA verdict is reconciled. F05-QA-STRICT and F08 local evidence stay queued with Owner Tech Lead.
* Design adoption (ai-system upgrade cfd6b59, incident 2026-09-21): the project has no Design Foundation and legacy surfaces predate the Visual Quality Gate. Route: Design Adoption Route in [workflow-follow-ups.md](workflow-follow-ups.md). Phase B (Design Foundation, UI Designer) activates after F03's re-QA verdict is reconciled and needs a user selection decision; no feature with Visual Scope other than none is activated before a Selected Foundation.
* Decision F03.RUNTIME-LIMITS is RESOLVED = A (2026-09-20). F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized.
* F09–F13 remain Not Started; no new feature was activated.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
