# Feature Board — LOOPLET

Last Updated: 2026-09-26
Active Phase: F05 journey-progression — rework (F05-FE3-GATE + F05-FE3-HOME) after F05-QA-STRICT Rejected
Active Owner: Frontend/Mobile Developer
Active Feature: F05
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F00 | design-foundation | Done | - | Approved with Notes (final, visual-quality; 90/100, scoped exception) | P1 | Closed 2026-09-26. Foundation Selected; all four QA findings (QA-01/02/03/04) fixed and independently confirmed across three QA rounds (final: F00-QA-VISUAL3, 90/100, every dimension >= 8, no fail condition). Tech Lead personally verified QA's cited "structural" gaps rather than accepting them as-is: closed one (a partial iOS accessibility-category sweep, captured fresh, all clean); confirmed the other two (real hardware keyboard, a VoiceOver speech pass) are genuinely outside this session's tools — realistic ceiling ~91/100, short of the generic 93 line by rubric text (Motion) and by tooling, not by any remaining code defect. User resolved decision gate F00.VISUAL-93-THRESHOLD with a scoped, one-time exception (option C): Visual Quality Gate = Passed, QA Result = Approved with Notes, explicitly not a rubric rewrite and not precedent for other features. Visual Scope design-system. By scope, F00 changed no shipped screen: the new look exists only in `app/lib/design/` and the debug gallery. Bringing it into the real screens is the Design Adoption Route's Phase C (audit) and Phase D (screen by screen). Phase C is scheduled to start right after F05 closes, ahead of F08 (incident 2026-09-26). |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | Done | - | Approved with Notes (final, 2026-09-21) | P0 | Closed 2026-09-21: win-sequence rework, F03-QA-01..04 and the final QA (real OS interruption x3, device lock, real iOS Reduce Motion ON/OFF) done. Visual Scope none covered behaviour/accessibility only; the F03 visual surface is not accepted under the new rubric and is re-evaluated in the Design Adoption Route (may reopen as visual rework). Notes: workflow-follow-ups.md. |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F04's panel reduce-motion reads (completion_panel.dart) were changed by F03-QA-04 (accessibility only, ACs unchanged, tests green; verified at runtime by the F03 final QA); F03 rework changed panel timing/geometry and code (F03 architecture §18, 2026-09-20: deferred reveal, density, spine glow, Close tap target 44 pt); F04 ACs unchanged, F04 tests green, stays Done. |
| F05 | journey-progression | Rework | Frontend/Mobile Developer | Rejected (final, client-only; F05-QA-STRICT 2026-09-26) | P0 | **Passing (QA, re-verified by Tech Lead):** the real 30-level strict pack is clean (0 band-rule violations, content/ = app/assets/); the full campaign 1→30 → terminal → replay works against the real bundle; AC7 resume across a real process kill works on iPhone 16; regression is green (app 314/314, packages 197/197, F03 device 13/13). **Blocking defects:** F05-QA-STRICT-1 — the strict build gate enforces no structural band rule. The "4/4 including the band-rule case" claim from F06-CONTENT-PROMOTE and the Tech Lead's pre-QA reconciliation was false (empty test body); R4/R5 violations pass every gate. F05-QA-STRICT-3 — the home read-model never re-reads the active-session snapshot in-session: the in-progress state is missing after going back, and mid-replay CONTINUE targets a different level than after a relaunch (AC7). **Same rework:** F05-QA-STRICT-2 — a stray `levels` key bypasses content:check. **Contract:** amended §5.4/§6/§10/§15 (the root cause of STRICT-3 was §6's one-shot snapshot read). **Next:** F05-FE3-GATE + F05-FE3-HOME, then Tech Lead reconciliation, then a re-QA. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending. The F00 QA slot was released when F00 closed (Done 2026-09-26). F08 now waits behind the F05 rework and its re-QA, following the one-QA-feature-at-a-time order and the rework-control rule. Not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* Next command: Run Frontend/Mobile Developer on F05-FE3-GATE and F05-FE3-HOME (see the Current Rework Brief in the F05 orchestration; architecture.md §5.4/§6/§10/§15 amended 2026-09-26). The delivery returns to the Tech Lead for reconciliation, which is followed by an F05 re-QA.
* F03 is Done (final QA Approved with Notes, 2026-09-21). Work queue, one feature at a time (reordered by incident 2026-09-26):
  1. F05 — rework now, then re-QA. F05.SHARED-RUNTIME is already PASS; F05.STRICT-CONTENT and F05.HOME-LIVE-STATE are FAIL until the re-QA.
  2. **Design adoption** — Phase C (UI Designer + Tech Lead conformance audit of the F03/F04/F05 screens against the selected renders), then Phase D (redesign screen by screen, each passing independent visual QA).
  3. F08 local evidence (F08-LOCAL-EVIDENCE, then F08-QA-FUNCTIONAL).
* Design adoption: [Design Adoption Route](workflow-follow-ups.md) — Phase A and B done (F00 Done 2026-09-26, Visual Quality Gate Passed via a scoped one-time exception — see F00 orchestration.md's resolved F00.VISUAL-93-THRESHOLD, not a rubric change); Phase C (conformance audit of F03/F04/F05 surfaces against the Foundation, plus DESIGN-ADOPTION-CONTRACT-AMENDMENTS) is **scheduled** as the first activation after F05 closes, ahead of F08 (incident 2026-09-26: the redesign had no slot after F00 closed — a Tech Lead planning gap, now fixed).
* F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized. F07, F09–F13 remain Not Started.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
