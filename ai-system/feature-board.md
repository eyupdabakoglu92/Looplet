# Feature Board — LOOPLET

Last Updated: 2026-09-28
Active Phase: Design Adoption Phase D2 — won moment + full-screen result (F03 carrier; implementation F03-FE-D2)
Active Owner: Frontend/Mobile Developer
Active Feature: F03
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F00 | design-foundation | Done | - | Approved with Notes (final, visual-quality; 90/100, scoped exception — design-system layer) | P1 | **Closed again 2026-09-27 after Phase C.** Its design layer was extended inside D1 (F03 architecture §19.8 (2), §19.9 (2): glyph cap, pressed fill, `loopBreak`, Play decorations, `LoopBackButton`, `TileFace.iconScale`); F00 stays Done. The conformance audit (`conformance-audit.md`, commit cc84440) was accepted with one correction, and Phase D: D1 Play (F03, closed 2026-09-28) → D2 won moment + result (F03, active) → D3 home + shell (F05) — workflow-follow-ups.md. **History:** Done 2026-09-26 — Foundation Selected (Direction C "Loop Glass"); the design-system layer and gallery passed via the scoped exception F00.VISUAL-93-THRESHOLD. |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | Rework | Frontend/Mobile Developer | D2 not yet in QA (final, visual-quality planned). D1: Approved with Notes 2026-09-28 (F03-QA-D1R, 93 / 100, gate Passed) | P0 | **Reopened 2026-09-28 as Design Adoption Phase D2 — won moment + full-screen result** (`motion-critical`, contract architecture §20), right after D1 closed (§19.12). Scope: the win sequence on the D1 board (incl. special tiles, C-11), the board → result transition, the full-screen result in every F04 variant, its exits (Next, Retry in place, back button, system back — no Close) and reduced motion; C-4 markers; C-9 up to AX5. Cross-feature, in the same reopen: F04 §7 / §8 (the panel becomes the full-screen result; F04 ACs unchanged) and the F05 AC1 / §8 wording resync (C-3). Tasks: F03-UI-D2 Done (handoff accepted 2026-09-28, gate Ready for Implementation, architecture §20.7: retry transition A adopted — the user may veto for B; corrections C1–C3) → F03-FE-D2 Open → F03-QA-D2 (Queued). **D1 (Play) closed 2026-09-28**, gate Passed; its code is committed in 489606d (tracked diff from 5798c70 = `88f1dca3…`, the QA fingerprint; re-verified 2026-09-28). Open outside D2: F03-MULTITOUCH-FIRST-POINTER, MOVESCARD-COUNTER-LINE-HEIGHT. |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F04's panel reduce-motion reads (completion_panel.dart) were changed by F03-QA-04 (accessibility only, ACs unchanged, tests green; verified at runtime by the F03 final QA); F03 rework changed panel timing/geometry and code (F03 architecture §18, 2026-09-20: deferred reveal, density, spine glow, Close tap target 44 pt); F04 ACs unchanged, F04 tests green, stays Done. **Phase D2 active since 2026-09-28** (F03 carrier): the panel becomes the full-screen result — no Close, a back button (F04 `architecture.md` §7 / §8 amended; F03 §20); AC1–AC10 unchanged, AC7 still met; F04 stays Done. |
| F05 | journey-progression | Done | - | Approved with Notes (final, 2026-09-27) | P0 | Closed 2026-09-27. The 30-level strict Journey with an enforced build gate (R1–R6 + LABEL with per-rule negative cases, bundle mirror, content:check path + shape recognition), the live home read-model (warm == cold, incl. replay; AC7 across a real kill) and unlock/CONTINUE/Next Level/terminal. Path to Done: F05-QA-STRICT Rejected 2026-09-26 (gate enforced no band rule; content:check bypass; stale in-session home) → F05-FE3 rework → Tech Lead negative-run reconciliation → F05-QA-STRICT2 Approved with Notes. Notes: N1 — with 30/30 complete the terminal state wins over an in-progress replay (architecture §8, → Design Adoption Phase D); N2 — duplicated label-band table; tdDegree 0 at 11–15 (accepted content). **Phase D:** the tutorial overlay is re-skinned in D1 under F03 (delivered 2026-09-28; passed at runtime in F03-QA-D1 and again with the grown header in F03-QA-D1R; D1 closed 2026-09-28; behaviour unchanged, F05 architecture §9 amended). AC1 / §8 wording resynced 2026-09-28 at the D2 activation (no `Close`; C-3, F03 §20.4). The home is re-composed in D3 with F05 as the carrier; N1 needs a product decision then. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending. Its `StoreErrorScreen` adopts the Foundation in Phase D3 as a cross-feature item (Turkish copy, no raw exception shown). Queued behind the Design Adoption Route (Phase D now), by the incident of 2026-09-26: its offline/resume runtime proof runs through the F03/F05 screens that Phase D changes, and its release gate is OPEN anyway. Not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* **Next command:** Run Frontend/Mobile Developer on F03-FE-D2 — implement the D2 handoff (Current Brief in the F03 orchestration; F03 `ui-design.md` §16, acceptance list §16.11.1; contract `architecture.md` §20 and the §20.7 rulings). Then the Tech Lead's mandatory parity checkpoint (Ready for QA) before F03-QA-D2.
* **Work queue**, one feature at a time (order set by the incident of 2026-09-26 and the Phase C outcome of 2026-09-27):
  1. ~~**D1 — Play** (F03)~~ — closed 2026-09-28, gate Passed (93 / 100).
  2. **D2 — Won moment + full-screen result** (F03 carrier, F04 amendments, `motion-critical`) — **active**: F03-UI-D2 (accepted) → **F03-FE-D2** → F03-QA-D2.
  3. **D3 — Home + app shell** (F05 carrier, `new-surface`; N1 product decision).
  4. F08 local evidence (F08-LOCAL-EVIDENCE, then F08-QA-FUNCTIONAL).
* **Design adoption:** [Design Adoption Route](workflow-follow-ups.md) — Phases A, B and C done; Phase D active (D1 done, D2 active).
* **Commit:** the D1 rework, its QA / closure records and the D2 activation were committed in 489606d; the F03-UI-D2 handoff in 6352a75. This checkpoint's records are uncommitted (documents only).
* F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized. F07, F09–F13 remain Not Started.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
