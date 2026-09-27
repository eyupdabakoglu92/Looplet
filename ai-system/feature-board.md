# Feature Board — LOOPLET

Last Updated: 2026-09-28
Active Phase: Design Adoption Phase D1 — Loop Glass Play visual QA (F03-QA-D1, carrier F03)
Active Owner: QA
Active Feature: F03
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F00 | design-foundation | Done | - | Approved with Notes (final, visual-quality; 90/100, scoped exception — design-system layer) | P1 | **Closed again 2026-09-27 after Phase C.** Its design layer was extended inside D1 (F03 architecture §19.8 (2), §19.9 (2): glyph cap, pressed fill, `loopBreak`, Play decorations, `LoopBackButton`, `TileFace.iconScale`); F00 stays Done. The conformance audit (`conformance-audit.md`, commit cc84440) was accepted with one correction, and Phase D is planned: D1 Play (F03, active) → D2 won moment + result (F03) → D3 home + shell (F05) — workflow-follow-ups.md. **History:** Done 2026-09-26 — Foundation Selected (Direction C "Loop Glass"); the design-system layer and gallery passed via the scoped exception F00.VISUAL-93-THRESHOLD. |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | In QA | QA | In QA — F03-QA-D1 (final, visual-quality; D1 visual gate Ready for QA). The prior Approved with Notes of 2026-09-21 covered behaviour/accessibility only | P0 | **Reopened 2026-09-27 as Design Adoption Phase D1 — Loop Glass Play** (`existing-parity`, contract architecture §19). Scope: every non-won Play state, the load error, and the F05 column-tutorial overlay (cross-feature). It fixes the shipped defects A-1, A-2 (board), A-5 and A-6. Tasks: F03-UI-D1 Done (handoff accepted 2026-09-27; rulings §19.8) → F03-FE-D1 Done (delivered 2026-09-28; checkpoint accepted after re-run suites, seven negative runs and reproduced parity; rulings §19.9, incl. the won dock onto the goal for the hybrid period; gate Ready for QA) → F03-QA-D1 (active; visual gate ≥ 93). After D1 closes, F03 carries D2: the won moment + full-screen result, `motion-critical`, with F04 amendments. |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F04's panel reduce-motion reads (completion_panel.dart) were changed by F03-QA-04 (accessibility only, ACs unchanged, tests green; verified at runtime by the F03 final QA); F03 rework changed panel timing/geometry and code (F03 architecture §18, 2026-09-20: deferred reveal, density, spine glow, Close tap target 44 pt); F04 ACs unchanged, F04 tests green, stays Done. **Phase D2** (after D1) replaces the panel with the full-screen result — no Close, a back button — under the F03 carrier, with F04 contract amendments; AC7 is still met. |
| F05 | journey-progression | Done | - | Approved with Notes (final, 2026-09-27) | P0 | Closed 2026-09-27. The 30-level strict Journey with an enforced build gate (R1–R6 + LABEL with per-rule negative cases, bundle mirror, content:check path + shape recognition), the live home read-model (warm == cold, incl. replay; AC7 across a real kill) and unlock/CONTINUE/Next Level/terminal. Path to Done: F05-QA-STRICT Rejected 2026-09-26 (gate enforced no band rule; content:check bypass; stale in-session home) → F05-FE3 rework → Tech Lead negative-run reconciliation → F05-QA-STRICT2 Approved with Notes. Notes: N1 — with 30/30 complete the terminal state wins over an in-progress replay (architecture §8, → Design Adoption Phase D); N2 — duplicated label-band table; tdDegree 0 at 11–15 (accepted content). **Phase D:** the tutorial overlay is re-skinned in D1 under F03 (delivered 2026-09-28, under test in F03-QA-D1; behaviour unchanged, F05 architecture §9 amended). The home is re-composed in D3 with F05 as the carrier; N1 needs a product decision then. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending. Its `StoreErrorScreen` adopts the Foundation in Phase D3 as a cross-feature item (Turkish copy, no raw exception shown). Queued behind the Design Adoption Route (Phase D now), by the incident of 2026-09-26: its offline/resume runtime proof runs through the F03/F05 screens that Phase D changes, and its release gate is OPEN anyway. Not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* **Next command:** Run QA on F03-QA-D1 — the independent final-stage visual QA of the Loop Glass Play (Current Brief in the F03 orchestration; F03 architecture §19.7 and §19.9). Approval (rubric ≥ 93) lets the Tech Lead close D1 and activate D2.
* **Work queue**, one feature at a time (order set by the incident of 2026-09-26 and the Phase C outcome of 2026-09-27):
  1. **D1 — Play** (F03, now): F03-UI-D1 (done) → F03-FE-D1 (done) → F03-QA-D1 (active).
  2. **D2 — Won moment + full-screen result** (F03 carrier, F04 amendments, `motion-critical`).
  3. **D3 — Home + app shell** (F05 carrier, `new-surface`; N1 product decision).
  4. F08 local evidence (F08-LOCAL-EVIDENCE, then F08-QA-FUNCTIONAL).
* **Design adoption:** [Design Adoption Route](workflow-follow-ups.md) — Phases A, B and C done (the audit was accepted on 2026-09-27); Phase D active.
* F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized. F07, F09–F13 remain Not Started.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
