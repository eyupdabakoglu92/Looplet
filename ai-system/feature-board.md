# Feature Board — LOOPLET

Last Updated: 2026-09-29
Active Phase: Design Adoption Phase D3 — Home + app shell (F05 carrier, `new-surface`); D3 handoff F05-UI-D3
Active Owner: UI Designer
Active Feature: F05
Pending Product Revision: None
Revision Affected Features: None

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F00 | design-foundation | Done | - | Approved with Notes (final, visual-quality; 90/100, scoped exception — design-system layer) | P1 | **Closed again 2026-09-27 after Phase C.** Its design layer was extended inside D1 (F03 architecture §19.8 (2), §19.9 (2): glyph cap, pressed fill, `loopBreak`, Play decorations, `LoopBackButton`, `TileFace.iconScale`); F00 stays Done. The conformance audit (`conformance-audit.md`, commit cc84440) was accepted with one correction, and Phase D: D1 Play (F03, closed 2026-09-28) → D2 won moment + result (F03, closed 2026-09-29) → D3 home + shell (F05, active) — workflow-follow-ups.md. **History:** Done 2026-09-26 — Foundation Selected (Direction C "Loop Glass"); the design-system layer and gallery passed via the scoped exception F00.VISUAL-93-THRESHOLD. |
| F01 | dictionary-service | Done | - | Approved with Notes (historical scope) | P0 | Dictionary implementation accepted historically; production corpus review and Android confirmation remain follow-ups. |
| F02 | grid-engine | Done | - | Approved with Notes (historical scope) | P0 | Engine accepted historically; future scope/CI notes retained in workflow-follow-ups.md. |
| F06 | puzzle-content-and-solver-tooling | Done | - | Approved with Notes (historical scope) | P0 | Done covers toolchain + smoke set only. Journey acceptance now F05; OPEN Daily content follow-on belongs to F07 (workflow-follow-ups.md). |
| F03 | puzzle-play-session | Done | - | Approved with Notes (final, visual-quality; D2 re-QA F03-QA-D2R 94 / 100, gate Passed, 2026-09-29). D1: Approved with Notes 2026-09-28 (F03-QA-D1R, 93 / 100, gate Passed) | P0 | **Closed again 2026-09-29 after Design Adoption Phase D2 — won moment + full-screen result** (`motion-critical`, contract architecture §20, closure §20.11). Shipped: the win sequence on the D1 board (incl. special tiles, C-11), the board → result transition, the full-screen result in every F04 variant (C-4 markers, no Close; Next, Retry in place, back button, system back), reduced motion and C-9 up to AX5. Path: F03-UI-D2 → F03-FE-D2 (67d9ecb) → F03-QA-D2 Rejected (92 / 100, scroll band stuck after a text-size reduction) → F03-FE-D2R (77c33b9) → F03-QA-D2R Approved with Notes (94 / 100, every dimension ≥ 9). Cross-feature in the same reopen: F04 §7 / §8 (full-screen result; F04 ACs unchanged) and the F05 AC1 / §8 wording (C-3). **D1 (Play)** closed 2026-09-28 (§19.12). Open follow-ups: RESULT-APP-SWITCHER-SNAPSHOT, RESULT-F00-COMPONENT-ALIGN, F03-MULTITOUCH-FIRST-POINTER, MOVESCARD-COUNTER-LINE-HEIGHT. |
| F04 | star-rating-and-personal-best | Done | - | Approved with Notes (historical scope) | P1 | Historical scoped automated acceptance retained; later device-feel and shared persistence notes remain explicit. F04's panel reduce-motion reads (completion_panel.dart) were changed by F03-QA-04 (accessibility only, ACs unchanged, tests green; verified at runtime by the F03 final QA); F03 rework changed panel timing/geometry and code (F03 architecture §18, 2026-09-20: deferred reveal, density, spine glow, Close tap target 44 pt); F04 ACs unchanged, F04 tests green, stays Done. **Phase D2 closed 2026-09-29** (F03 carrier): the panel is now the full-screen result — no Close, a back button (F04 `architecture.md` §7 / §8 amended; F03 §20). F04 AC1–AC10 are unchanged and passed on the result in F03-QA-D2 / D2R (AC9 automated); F04 stays Done. |
| F05 | journey-progression | Rework | UI Designer | D3 final QA (visual-quality) queued — F05-QA-D3. Previous: Approved with Notes (final, 2026-09-27) | P0 | **Reopened 2026-09-29 as Design Adoption Phase D3 — Home + app shell** (`new-surface`, contract architecture §18). Scope: Home in every state (composition `S-06b`, the new loop track, `Looplet`), the Flutter splash, the native launch (no white frame, A-4), the F08 `StoreErrorScreen` (Turkish, no raw exception, A-3) and AX5 (A-2 home). **N1 decided by the user 2026-09-29:** after 30 / 30, an in-progress replay is surfaced (decision F05.D3-N1-REPLAY-PRECEDENCE, RESOLVED). It changed the AC7 / AC9 precedence: Product Owner revision **PO-REV-2026-09-29-F05-CONTINUE**, resynced by the Tech Lead the same day (feature PRD AC7 / AC9; §8 terminal precedence lapsed). **F05-UI-D3 Open** (→ F05-FE-D3 → F05-QA-D3). **History:** Closed 2026-09-27. The 30-level strict Journey with an enforced build gate (R1–R6 + LABEL with per-rule negative cases, bundle mirror, content:check path + shape recognition), the live home read-model (warm == cold, incl. replay; AC7 across a real kill) and unlock/CONTINUE/Next Level/terminal. Path to Done: F05-QA-STRICT Rejected 2026-09-26 (gate enforced no band rule; content:check bypass; stale in-session home) → F05-FE3 rework → Tech Lead negative-run reconciliation → F05-QA-STRICT2 Approved with Notes. Notes: N1 — with 30/30 complete the terminal state wins over an in-progress replay (architecture §8, → Design Adoption Phase D); N2 — duplicated label-band table; tdDegree 0 at 11–15 (accepted content). **Phase D:** the tutorial overlay is re-skinned in D1 under F03 (delivered 2026-09-28; passed at runtime in F03-QA-D1 and again with the grown header in F03-QA-D1R; D1 closed 2026-09-28; behaviour unchanged, F05 architecture §9 amended). AC1 / §8 wording resynced 2026-09-28 at the D2 activation (no `Close`; C-3, F03 §20.4). **D3 next:** the home is re-composed with F05 as the carrier (`new-surface`), and N1 needs a product decision at activation. |
| F07 | daily-challenge | Not Started | - | - | P1 | Not activated. Depends on F03/F04/F06/F08. OPEN F06-CONTENT Daily pool (~60), real producer/offline proof and manifest require F07 planning; see workflow-follow-ups.md. |
| F08 | offline-persistence-and-sync | In Progress | Tech Lead | Runtime Validation Pending | P0 | Local/emulator validation pending. Its `StoreErrorScreen` adopts the Foundation in Phase D3 as a cross-feature item (Turkish copy, no raw exception shown; F08 `architecture.md` App Init step 1 amended 2026-09-29, F05 §18.3 (7)). Queued behind the Design Adoption Route (Phase D now), by the incident of 2026-09-26: its offline/resume runtime proof runs through the F03/F05 screens that Phase D changes, and its release gate is OPEN anyway. Not dependent on paid deploy. Release task Blocked on explicit billing/deploy authorization; final QA still required. |
| F09 | onboarding-tutorial | Not Started | - | - | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | - | - | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | - | - | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | - | - | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | - | - | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

## Current Routing

* **Next command:** Run UI Designer on F05-UI-D3 — the D3 handoff: Home + app shell (Current Brief in the F05 orchestration; contract F05 `architecture.md` §18). Then the Tech Lead's visual-gate checkpoint.
* **Active feature: F05** — Design Adoption Phase D3 (Home + app shell), Rework. PO-REV-2026-09-29-F05-CONTINUE (the N1 replay precedence) was resynced on 2026-09-29; no product revision is pending.
* **Work queue**, one feature at a time (order set by the incident of 2026-09-26 and the Phase C outcome of 2026-09-27):
  1. ~~**D1 — Play** (F03)~~ — closed 2026-09-28, gate Passed (93 / 100).
  2. ~~**D2 — Won moment + full-screen result** (F03)~~ — closed 2026-09-29, gate Passed (94 / 100).
  3. **D3 — Home + app shell** (F05 carrier, `new-surface`) — **active**: PO revision (N1) and resync done → **F05-UI-D3** → F05-FE-D3 → F05-QA-D3.
  4. F08 local evidence (F08-LOCAL-EVIDENCE, then F08-QA-FUNCTIONAL).
* **Design adoption:** [Design Adoption Route](workflow-follow-ups.md) — Phases A, B and C done; Phase D active (D1 and D2 done, D3 active).
* **Commits:**
  * D1: the rework, its QA / closure records and the D2 activation in 489606d.
  * D2: the F03-UI-D2 handoff in 6352a75; the F03-FE-D2 delivery in 67d9ecb; the F03-QA-D2 verdict in f28aedb; the reconciliation in 3cd4a3b; the F03-FE-D2R rework in 77c33b9 (`app/` tree `5298c81a…`); the F03-QA-D2R verdict in 5677471.
  * The D2 closure and the D3 activation in 171f0c1. The PO revision and this resync are uncommitted (documents only).
* F08 release authorization gates the release stage only; no paid service, deployment, production action or store distribution is authorized. F07, F09–F13 remain Not Started.

## Open Portfolio Follow-ups

[workflow-follow-ups.md](workflow-follow-ups.md) retains OPEN Daily-content, distribution, CI and downstream work with owner, scope and activation trigger. It is planning input, not a substitute execution ledger. Tech Lead incorporates applicable items when activating the owning feature.

## History

The full pre-migration portfolio, ordering/rationale, old notes and decisions are preserved byte-for-byte in [the original board](history/core-sync-2026-09-18/feature-board.md). Current records do not silently mark archived follow-ons complete.

[Migration record](history/core-sync-2026-09-18/README.md).
