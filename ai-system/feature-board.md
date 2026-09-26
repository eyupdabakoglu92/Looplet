# Feature Board — LOOPLET

Last Updated: 2026-09-27
Active Phase: F05 journey-progression — final-stage re-QA (F05-QA-STRICT2) after the F05-FE3 rework
Active Owner: QA
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
| F05 | journey-progression | In QA | QA | None (final re-QA F05-QA-STRICT2; prior F05-QA-STRICT Rejected 2026-09-26) | P0 | **Previous round (F05-QA-STRICT, 2026-09-26) — Rejected.** Passing: the real 30-level strict pack is clean; the full campaign 1→30 → terminal works against the real bundle; AC7 resume across a real kill works on iPhone 16. Blocking: F05-QA-STRICT-1 — the strict gate enforced no band rule (the earlier "4/4 incl. band-rule case" claim was false); F05-QA-STRICT-2 — a stray `levels` key bypassed content:check; F05-QA-STRICT-3 — the home read-model was stale in-session (AC7 on the replay path). Contract amended §5.4/§6/§10/§15. **Rework F05-FE3 (2026-09-27), delivered and Tech Lead-reconciled with the Tech Lead's own negative runs:** R1–R6 + LABEL enforced with per-rule negative cases, the bundle mirror is checked, the bypass is closed, and the home read-model is live on both sources (warm == cold); app 336/336, packages 202/202. **Now:** F05-QA-STRICT2 is active. The design adoption follows once F05 closes. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending. The F00 QA slot was released when F00 closed (Done 2026-09-26). F08 now waits behind the F05 rework and its re-QA, following the one-QA-feature-at-a-time order and the rework-control rule. Not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* Next command: Run QA on F05-QA-STRICT2 (Current QA Brief in the F05 orchestration) — a final-stage re-QA of the F05-FE3 rework plus the shared runtime touched by the ActiveSessionRepo change. The verdict returns to the Tech Lead.
* F03 is Done (final QA Approved with Notes, 2026-09-21). Work queue, one feature at a time (reordered by incident 2026-09-26):
  1. F05 — re-QA now (F05-QA-STRICT2). F05.STRICT-CONTENT, F05.HOME-LIVE-STATE and F05.SHARED-RUNTIME are PENDING until QA re-verifies them.
  2. **Design adoption** — Phase C (UI Designer + Tech Lead conformance audit of the F03/F04/F05 screens against the selected renders), then Phase D (redesign screen by screen, each passing independent visual QA).
  3. F08 local evidence (F08-LOCAL-EVIDENCE, then F08-QA-FUNCTIONAL).
* Design adoption: [Design Adoption Route](workflow-follow-ups.md) — Phase A and B done (F00 Done 2026-09-26, Visual Quality Gate Passed via a scoped one-time exception — see F00 orchestration.md's resolved F00.VISUAL-93-THRESHOLD, not a rubric change); Phase C (conformance audit of F03/F04/F05 surfaces against the Foundation, plus DESIGN-ADOPTION-CONTRACT-AMENDMENTS) is **scheduled** as the first activation after F05 closes, ahead of F08 (incident 2026-09-26: the redesign had no slot after F00 closed — a Tech Lead planning gap, now fixed).
* F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized. F07, F09–F13 remain Not Started.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
