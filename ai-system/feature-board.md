# Feature Board — LOOPLET

Last Updated: 2026-09-24
Active Phase: F00 design-system accessibility rework — narrow polish rework (F00-FE-A11Y-REWORK2)
Active Owner: Frontend/Mobile Developer
Active Feature: F00
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F00 | design-foundation | Rework | Frontend/Mobile Developer | Rejected (final, visual-quality; 88/100) | P1 | Foundation Selected; F00-FE-A11Y-REWORK (QA-01/02/03) delivered, Accepted, and independently re-verified by QA in F00-QA-VISUAL2 (RESOLVED, 313/313 tests, F03 13/13). Tech Lead reconciliation 2026-09-24 corrected QA's own verdict: premium-ui-rubric.md's Verdict Bands are unconditional ("85–92: zorunlu rework"; "92 ve altı Approved with Notes ile geçirilemez") — 88/100 cannot be Approved with Notes regardless of why, so QA Result is Rejected, not Approved with Notes. Also corrected QA-04's status (2 of 3 items were already fixed in code; only the display/headline mid-word-wrap-at-extreme-scale item is genuinely open) and removed a stray app/9.png QA's commit had swept into the app tree. F00-FE-A11Y-REWORK2 active — narrow, scoped only to the one remaining QA-04 item — then F00-QA-VISUAL3 verifies it and rescores honestly. Visual Quality Gate stays Ready for QA (not Passed; needs >= 93). NO shipped-surface change. Visual Scope design-system. |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | Done | - | Approved with Notes (final, 2026-09-21) | P0 | Closed 2026-09-21: win-sequence rework, F03-QA-01..04 and the final QA (real OS interruption x3, device lock, real iOS Reduce Motion ON/OFF) done. Visual Scope none covered behaviour/accessibility only; the F03 visual surface is not accepted under the new rubric and is re-evaluated in the Design Adoption Route (may reopen as visual rework). Notes: workflow-follow-ups.md. |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F04's panel reduce-motion reads (completion_panel.dart) were changed by F03-QA-04 (accessibility only, ACs unchanged, tests green; verified at runtime by the F03 final QA); F03 rework changed panel timing/geometry and code (F03 architecture §18, 2026-09-20: deferred reveal, density, spine glow, Close tap target 44 pt); F04 ACs unchanged, F04 tests green, stays Done. |
| F05 | journey-progression | In Progress | Tech Lead | Pending current acceptance | P0 | Strict 30-level content delivered; F05-QA-STRICT queued behind F00-QA-VISUAL (one QA feature at a time); needs Tech Lead delivery reconciliation first, then QA. F05's home ring / column tutorial reduce-motion reads were changed by F03-QA-04 (accessibility only). Not activated for QA. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending, queued behind F00-QA-VISUAL (one QA feature at a time); not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* Next command: Run Frontend/Mobile Developer (task F00-FE-A11Y-REWORK2 in F00 orchestration; Current Frontend Brief — fix the one remaining QA-04 item with real runtime evidence, not a widget test alone). Then Run QA (F00-QA-VISUAL3: verify the fix, rescore honestly; QA-01/02/03 evidence stays fingerprint-valid). The F05 / F08 queue (F05 delivery reconciliation + F05-QA-STRICT, then F08 local evidence) waits behind the F00 QA slot — one QA feature at a time — and is not blocked by any open decision.
* F03 is Done (final QA Approved with Notes, 2026-09-21). The rework-control lock is released. Queue behind the F00 QA slot: (1) F05-QA-STRICT — needs Tech Lead delivery reconciliation of F05 (strict pack + code), then QA; F05.SHARED-RUNTIME can reuse F03's fresh runtime evidence for unchanged paths; (2) F08 local evidence (F08-LOCAL-EVIDENCE, then F08-QA-FUNCTIONAL). One QA feature at a time.
* Design adoption: [Design Adoption Route](workflow-follow-ups.md) — Phase A done; Phase B in rework (Foundation Selected 2026-09-21; design-system layer delivered 2026-09-21; QA-01/02/03 fixed and independently confirmed 2026-09-23; overall numeric verdict still short of the 93 gate — F00-FE-A11Y-REWORK2 narrows the remaining gap); Phase C/D (conformance, incl. F03/F04/F05 surfaces and the contract amendments logged as DESIGN-ADOPTION-CONTRACT-AMENDMENTS) follow once F00 reaches Passed.
* F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized. F07, F09–F13 remain Not Started.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
