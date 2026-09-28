# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

Rework

## Current Owner

Frontend/Mobile Developer

## Next Role

Frontend/Mobile Developer

## Active Task Ledger

- [x] Task ID: F05-UI-D3 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-29 (981b807), ACCEPTED at the Tech Lead visual-gate checkpoint 2026-09-29 (architecture §18.7). ui-design.md is the D3 handoff (the pre-D3 file archived: history/f05-journey-progression-2026-09-29/ui-design-before-phase-d3.md): every Home state incl. the N1 terminal-with-replay (D3-07), the loop track with windowing A "sliding five" (adopted) and B (rendered alternative), the store-error screen, native launch iOS / Android, splash, 1.3× / AX5, device variants, the entrance prototype, window and contrast tables, acceptance list §11.1, manifest §12b. 41 renders + 4 contact sheets in design/ from design/src/gen-d3.mjs (reproduced byte for byte at the checkpoint). | Depends On: -
- [ ] Task ID: F05-FE-D3 | Assigned Role: Frontend/Mobile Developer | Status: Open | Summary: Implement the D3 handoff from `app/lib/design` — Home (`LoopTrack` + the `LoopNode` states), the §18.3 (2) CONTINUE rule, the C1 copy rule, splash, `StoreErrorScreen`, native launch assets, the `MaterialApp` ground, the C2 debug row, the C3 entrance; tests and named negative runs; `frontend.md` Visual Parity Evidence incl. the cold-start recording and the production-shaped cold boot (architecture §18.6, §18.7). Brief: Current Brief | Depends On: F05-UI-D3
- [ ] Task ID: F05-QA-D3 | Assigned Role: QA | Status: Queued | Summary: Final-stage independent visual QA of D3 (rubric ≥ 93 from runtime; F05 AC7–AC10 / AC12 incl. the N1 replay rule warm and cold; error screen + Retry; cold start with no white frame; D1 / D2 regression over Home ⇄ `/play`) (architecture §18.6) | Depends On: F05-FE-D3

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Accepted

## QA Scope

client-only

## QA Stage

final

## QA Result

None

## QA Modules

core, client-ui, visual-quality, stateful-flow

## Regression Depth

full

## Evidence Reuse

not-applicable

## Release Scope

none

## Release Result

None

## Visual Scope

new-surface

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for Implementation

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* Home · today `S-06b-home-today.png` — the composition to build;
* Home · design `S-06-home-design.png` — its future-scope items (settings, level-info card, chips) are **not** built;
* the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest. The Foundation's direction renders for Home (`A-06`, `B-06`, `C-06`, `C-06b`) are recorded in `design-foundation.md` §13 / §17.10.

The shipped baseline is conformance-audit.md §2, §3 and §12, captured at 615e94c: `design/audit/cur-home-new.png`, `cur-home-mid.png`, `cur-home-in-progress.png`, `cur-home-late-in-progress.png`, `cur-home-terminal.png`, `cur-a11y-ax5-home-terminal.png`, `cur-a11y-xxxl-home-terminal.png`, `cur-shell-splash.png`, `cur-shell-bootstrap-error.png`, and the pairs `pair-01-home-in-progress.jpg`, `pair-02-home-mid.jpg`.

The D1 / D2 surfaces that Home opens into and returns from (gate Passed 2026-09-28 / 2026-09-29) are recorded in the F03 orchestration and F03 `architecture.md` §19.12 / §20.11.

**The D3 handoff (accepted 2026-09-29, architecture §18.7):** `ui-design.md` §12a matrix and §12b manifest; the renders `design/D3-*.png` (the build targets: every Home state, the store error, launch and splash, 1.3× / AX5, device variants); windowing A adopted (`DR-D3-A`), B kept as the rendered alternative (`DR-D3-B`); the entrance prototype `design/src/D3-motion-prototype.html`; the expected-value tables `design/src/window-d3.txt` and `contrast-d3.txt`.

## Pending Evidence

- Evidence ID: F05.STRICT-EVIDENCE (consolidated; full text archived: [orchestration-before-phase-d3.md](../../history/f05-journey-progression-2026-09-29/orchestration-before-phase-d3.md))
  * Scenario: The F05 closure of 2026-09-27 — F06.CONTENT-PROMOTE-RECONCILE, F05.STRICT-CONTENT, F05.HOME-LIVE-STATE, F05.SHARED-RUNTIME
  * Owner Role: Tech Lead and QA
  * Result: PASS
  * Provenance / Note: F05 closed 2026-09-27 — F05-QA-STRICT2 Approved with Notes. Kept as a pointer: D3's QA reuses this behaviour evidence only where the D3 diff leaves the read-model, the gate and the navigation unchanged; the §18.3 (2) replay rule is new and is re-proven.

- Evidence ID: F05.D3-HANDOFF
  * Scenario: The D3 handoff — F05 ui-design.md with real renders of every §18.2 state (incl. the terminal-with-replay state of §18.3 (2)), the loop-track windowing at 0 / 4 / 12 / 25 / 30 of 30, the store-error screen, the native launch and splash (iOS; Android light and dark), AX5 for Home and the error screen, and the device variants
  * Required Class: static inspection of rendered artefacts (+ an executable prototype if Home motion is proposed)
  * Target / Environment: features/f05-journey-progression/ui-design.md and its render files (393 × 852, plus 390 × 844 and 440 × 956)
  * Owner Role: UI Designer
  * Prerequisite / External Decision: the N1 Product Owner revision resynced — met 2026-09-29 (PO-REV-2026-09-29-F05-CONTINUE)
  * Re-evaluation Trigger: F05-UI-D3 delivery
  * Blocks: Visual Quality Gate = Ready for Implementation; F05-FE-D3
  * Result: PASS
  * Provenance / Note: **Accepted by the Tech Lead at the visual-gate checkpoint, 2026-09-29 (HEAD 981b807; architecture §18.7): every referenced PNG exists; `node gen-d3.mjs` regenerates all 45 pages and tables byte for byte; the window table reproduced by hand.** Delivery: 2026-09-29 UI Designer, HEAD 9a36147 + working tree. ui-design.md (D3); 41 PNG renders + 4 contact sheets in features/f05-journey-progression/design/ from design/src/gen-d3.mjs + render-d3.sh (HTML/CSS → headless Chrome @2x; the launch asset @3x); `node gen-d3.mjs` regenerates every page byte for byte. Motion prototype design/src/D3-motion-prototype.html (`?t=`, `?rm=1`). Window table src/window-d3.txt; contrast src/contrast-d3.txt (locked outline raised to 3.41 : 1). Generated design artefacts, not runtime; Android rendered as a frame, not run. Windowing A recommended by the UI Designer and adopted at the checkpoint (§18.7 ruling 1).

- Evidence ID: F05.D3-PARITY
  * Scenario: The runtime matches the D3 handoff on the canonical simulators — every Home state beside its render; a cold-start recording from the native launch to Home with no white frame and no splash jump; the store-error screen forced, with no raw exception outside debug; the OS text sweep large → AX5 on Home and the error screen; the production-shaped cold boot from an empty and from an existing store; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F05.D3-HANDOFF accepted (gate Ready for Implementation) — met 2026-09-29
  * Re-evaluation Trigger: F05-FE-D3 delivery
  * Blocks: Visual Quality Gate = Ready for QA; F05-QA-D3
  * Result: PENDING

- Evidence ID: F05.D3-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on D3 — rubric ≥ 93 from runtime (every dimension ≥ 8, no fail condition); F05 AC7–AC10 / AC12 on the new Home incl. the §18.3 (2) replay rule warm and cold; the error screen and Retry; cold start with no white frame; D1 / D2 regression over Home ⇄ `/play`
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F05.D3-PARITY accepted (gate Ready for QA)
  * Re-evaluation Trigger: F05-QA-D3 delivery
  * Blocks: Visual Quality Gate = Passed; F05 Done; Phase D completion
  * Result: PENDING

## Open Decision Gates

- Decision ID: F05.D3-N1-REPLAY-PRECEDENCE
  * Question: With all 30 levels complete and a replay of a level in progress, what does the Home CTA do — resume the replay, or keep the finished state ("Tekrar oyna" → level 1)?
  * Options / Trade-offs: (A) resume the replay — the one "continue" button never discards a half-played puzzle; AC7 wins over AC9 in their overlap, a product AC change that needs a Product Owner revision. (B) keep the finished state — today's shipped behaviour (§8, 2026-09-27); the replay is superseded when another level starts; no PRD change.
  * Recommendation: (A), per conformance-audit C-1
  * Blocks: F05-UI-D3 (the terminal-with-replay state) and F05-FE-D3 (the CONTINUE rule)
  * Blocking Scope: feature
  * Status: RESOLVED
  * Resolution: (A) resume the replay — chosen by the user in chat, 2026-09-29 (asked in Turkish; option "Yarım kalanı sürdür"). Recorded in architecture §18.3 (2). It changes the AC7 / AC9 precedence, so a Product Owner revision was routed before any F05 delivery: PO-REV-2026-09-29-F05-CONTINUE, resynced by the Tech Lead on 2026-09-29 (feature PRD AC7 / AC9; architecture §18.3 (2) effective).
  * Resolved At: 2026-09-29

## Blockers

None

## Next Action

Run Frontend/Mobile Developer on F05-FE-D3 — implement the D3 handoff (Current Brief; contract architecture §18.3, the §18.7 rulings and corrections C1–C3; `ui-design.md` §11 and the §11.1 acceptance list). Then hand back to the Tech Lead for the mandatory checkpoint (→ Ready for QA) before F05-QA-D3.

## Last Decision

2026-09-29 (D3 visual-gate checkpoint) — the Tech Lead **accepted F05-UI-D3**. Visual Quality Gate → **Ready for Implementation**; F05-FE-D3 open. Full record: `architecture.md` §18.7.

**Verified independently:** every handoff-gate item present; all 45 referenced PNGs and the F00 pointers exist; `node gen-d3.mjs` regenerates the 45 pages and tables byte for byte; every `window-d3.txt` row reproduced by hand; no future-scope item, no back affordance, one CTA; the shipped code the implementation map names exists (and the N1 override sits in Home, `done ? 1 : continueTarget`).

**Rulings on ui-design §14:** (1) windowing **A** adopted — not an Exploration Gate selection; B rejected (chapter pips are deferred metadata, a second indicator, a varying node count); (2) the `LoopNode` extension is inside the §18.3 (3) allowance — the existing call form unchanged, per-state `Semantics`, excluded inside the track, the track display-only; (3) the headlines are accepted as interim copy; (4) the pulse and the terminal bloom are dropped; (5) one action on the error screen.

**Corrections (binding for Frontend and QA):** C1 — the copy selection rule (the §8 `D3-01b` row wrongly said "caption only"; the headline switches to "Sıradaki…" once level 1 starts); C2 — the `kDebugMode` debug row sits outside the column, is omitted when it would hit the caption, and never causes the AX5 overflow; C3 — the entrance plays once per process at the first model frame, never on a return from `/play`.

**Also found at the checkpoint:** there is no `StoreErrorScreen` test today; F05-FE-D3 adds one. The matrix and manifest headings in `ui-design.md` were level 3, so the full audit could not find the manifest; the Tech Lead raised them to level 2 (structure only, §18.7).

The orchestration at the UI delivery is archived byte for byte as history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-29
* Summary: D3 visual-gate checkpoint — F05-UI-D3 accepted (architecture §18.7); gate Ready for Implementation; Delivery Review Accepted; F05-FE-D3 Open; owner → Frontend/Mobile Developer.

## Context & Follow-ups

* **Phase D:** D1 (Play) closed 2026-09-28; D2 (won moment + result) closed 2026-09-29; **D3 (Home + shell) active** — the last slice.
* **D3 inputs:** PO-REV-2026-09-29-F05-CONTINUE (resynced); DESIGN-ADOPTION-CONTRACT-AMENDMENTS (D3 items C-1, C-6, C-7); the audit's D3 renders 19–26; A-2 home at AX5 (also F03-QA-D2R N5), A-3, A-4; the error-surface text-scale note (F03 §19.12 (6), OPTIONAL-QUALITY-NOTES).
* **May be taken if D3 touches the component:** MOVESCARD-COUNTER-LINE-HEIGHT, RESULT-F00-COMPONENT-ALIGN (architecture §18.5).
* **Carried F05 notes (closure 2026-09-27):**
  * N2 — the label-band table is duplicated (`journeyLabelBand` and `_expectedBands`);
  * N3 — the mirror test relies on `flutter test` running in `app/`;
  * 11–15 `tdDegree = 0` is accepted content;
  * a replayed completed level renders as in progress on the progress indicator, by §6 design.
* **Tracked elsewhere:** offline and storage-failure device branches (F08, SHARED-PERSISTENCE-PROOF); the first-app-distribution device smoke, the app icon and display name (FIRST-APP-DISTRIBUTION).
* **Checkpoint QA watch point (§18.7 ruling 1):** frontier windows draw nothing ahead of the current node; the label carries the whole Journey. QA judges it under the rubric.
* **After D3:** F08 local evidence (Design Adoption Route).

## History & Evidence References

* [Terminal orchestration before the D3 reopen](../../history/f05-journey-progression-2026-09-29/orchestration-before-phase-d3.md) (the 2026-09-27 closure, its full evidence and change log); [orchestration at the PO revision](../../history/f05-journey-progression-2026-09-29/orchestration-at-po-revision.md) (the D3 activation decision, Blocked); [orchestration at the UI delivery](../../history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md) (the F05-UI-D3 brief).
* Earlier snapshots: [at the F05-QA-STRICT verdict](../../history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md); [at the F05-FE3 delivery](../../history/f05-journey-progression-2026-09-27/orchestration-at-fe3-delivery.md); [before closure](../../history/f05-journey-progression-2026-09-27/orchestration-before-closure.md); [original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* Reports: [QA report](qa.md), [delivery report](frontend.md), [UI design](ui-design.md) (the D3 handoff; the Direction A home is archived), [contract](architecture.md) (§18 D3, checkpoint rulings §18.7).
* [Portfolio follow-ups](../../workflow-follow-ups.md) (Design Adoption Route); [Phase C audit](../f00-design-foundation/conformance-audit.md).
* Canonical execution: role-execution-contract.md.

## Change Log

* 2026-09-18 to 2026-09-27 — migration, content promotion, strict gate, live home, F05-QA-STRICT Rejected, F05-FE3 rework, F05-QA-STRICT2 Approved with Notes, **Done** (log in the archived terminal orchestration).
* 2026-09-28 — Tech Lead (at the F03 D2 activation): AC1 / §8 wording resynced — no `Close` (C-3); F05 stayed Done.
* 2026-09-29 — Tech Lead: D3 activation.
  * **Decided:** architecture §18 (contract and rulings); Visual Scope `new-surface`; gate Pending; F08 §App Init step 1 amended (C-6).
  * **With the user:** N1 → surface the replay (F05.D3-N1-REPLAY-PRECEDENCE RESOLVED).
  * **Next:** Blocked on the Product Owner revision (AC7 / AC9 precedence); then the Tech Lead resync opens F05-UI-D3.
* 2026-09-29 — Product Owner: PO-REV-2026-09-29-F05-CONTINUE (product PRD F05 AC7 / AC9 precedence; affected F05).
* 2026-09-29 — Tech Lead: PO revision resync.
  * **Decided:** feature PRD AC7 / AC9 resynced; §8 terminal precedence lapsed; §6 / §15 amended; §18.3 (2) effective; revision flag cleared.
  * **Next:** Rework; F05-UI-D3 Open; owner → UI Designer.
* 2026-09-29 — UI Designer: F05-UI-D3 delivered (ui-design.md D3; renders in design/; the pre-D3 ui-design.md archived); F05.D3-HANDOFF PASS; Delivery Review Pending; owner → Tech Lead.
* 2026-09-29 — Tech Lead: D3 visual-gate checkpoint.
  * **Decided:** F05-UI-D3 accepted; windowing A adopted; §14 rulings 1–5 and corrections C1–C3 (architecture §18.7); pointers added to ui-design.md.
  * **Next:** gate Ready for Implementation; Delivery Review Accepted; F05-FE-D3 Open; owner → Frontend/Mobile Developer.

## Current Brief

**F05-FE-D3 — implement the D3 handoff: Home + app shell** (contract: architecture.md §18.3; the checkpoint rulings and corrections §18.7, which override `ui-design.md` where they differ)

**User-visible symptom** (§18.1): Home, the first screen of every launch, still has the pre-Foundation look (uppercase `LOOPLET`, the amber 30-tick ring, an amber `DEVAM ET`, the system font) between a Loop Glass Play and result. The shell shows a white native launch frame (A-4), an English error screen with the raw exception (A-3), and Home clips at AX5 with a 10 px debug overflow (A-2 home). After 30 / 30 an in-progress replay is hidden behind the terminal state (N1; the user's decision is to surface it).

**Affected journey and entry paths** (§18.2): cold start (native launch → splash → Home) from an empty store and from an existing one; cold start with a failing store → the error screen → Retry; Home in every state → CONTINUE → `/play`; back, system back, the result's back and Next at level 30 → Home (warm, Home stays mounted); relaunch (cold) with a session in progress, including a replay after 30 / 30.

**Authority:**
* `ui-design.md` (D3) §4–§12 — the layout table §6, the node states §7, the state table §8, the handoff §11 (must-not-break / flexible / do-not-cheapen, implementation map) and the **§11.1 acceptance list**, copy and `Semantics` §12;
* the renders `design/D3-*.png`, the prototype `design/src/D3-motion-prototype.html` (`?t=`, `?rm=1`), the expected values `design/src/window-d3.txt` and `contrast-d3.txt`, the launch asset `design/D3-asset-launch-backdrop.png`;
* architecture §18.3 and **§18.7** (rulings 1–5, corrections C1–C3).

**Fix scope:**
1. **Home** (`home_screen.dart`): `LoopBackdrop`; `LoopletWordmark` at (25, 58)·s; the content column (card → CTA → caption) per ui-design §6; `GlassCard` with the swirl arcs, the `YOLCULUK · N / 30` label, the two-line headline with one lime word, and `LoopTrack`; `LimePill(glow: true)` + `LoopIcon.arrowRight`; the caption. Remove `_JourneyRing` (and its pulse and bloom), `_Wordmark`, `_ContinueCta`, and `PlayStage` / `PlayTheme` from Home.
2. **The CONTINUE rule** (§18.3 (2), C1): CTA → `continueTarget`; terminal ⇔ `continueTarget == null`, never `allComplete`. The C1 headline / CTA / caption rule exactly.
3. **Design layer** (§18.7 ruling 2): `LoopTrack` (window rule, geometry, segments, lead-in, tail) and the `LoopNode` states `open` / `locked` / `finish`, with the existing `LoopNode(number:, current:)` form unchanged; per-state `Semantics` standalone, excluded inside the track; display-only. Component tests; the F00 design tests stay green unmodified. No token value change, no new dependency.
4. **Loading and motion:** before the model loads Home equals the splash frame (no empty card, no spinner); the entrance per ui-design §5 and C3 (once per process, never on a return from `/play`); reduced motion (`reduceMotionRequested()`) — no animation; no idle motion.
5. **Text scale** (§18.3 (6), §11.1 (11)): container text through `loopCappedTextScaler`; free text at the OS scale, words never broken, the caption breaking only before "·"; Home does not scroll up to AX5 on 390 × 844 – 440 × 956.
6. **Splash** (`_SplashScreen`): `LoopBackdrop` + the wordmark at its Home position, fading in 160 ms (instant under reduced motion).
7. **Store-error screen** (`StoreErrorScreen`, §18.3 (7)): the ui-design §6 card (label, `loopBreak`, headline, body) and one `LimePill` Retry; a shell strings table (TR + EN, §12); `debugPrint` the message in every build; the separated details box only under `kDebugMode`; above the cap the column scrolls with `ScrollBand`. Retry behaviour and F08 AC9 unchanged.
8. **Native launch and app ground** (§18.3 (8), ui-design §11 Must): iOS `LaunchScreen.storyboard` background `#070C25` + the launch image, aspect fill; Android `drawable/` and `drawable-v21/launch_background.xml` (solid `#070C25` + the image); `LaunchTheme` **and** `NormalTheme` in `values/` and `values-night/` on that drawable — no `?android:colorBackground`. `MaterialApp`: scaffold ground `#070C25`, `title: 'Looplet'`.
9. **The debug row** (C2): `kDebugMode` only, outside the column, bottom-anchored, omitted when it would hit the caption; no overflow at AX5 in debug.
10. **Strings:** `JourneyStrings` per ui-design §12 (TR and the EN dev table); Turkish casing authored or `tr`-aware only.

**Tests:**
* **Update** (§18.4): `journey_home_test` (incl. "all 30 complete → terminal ring + REPLAY" and the bloom cases, which go with the bloom), `journey_home_live_test`, `journey_next_level_test`, `journey_progress_model_test`, `widget_test`. Every F05 AC keeps a passing test.
* **Add:** a `StoreErrorScreen` widget test (none exists today: Turkish copy, no exception text outside debug, Retry invalidates the bootstrap, AX5 scroll); `LoopTrack` / `LoopNode` component tests over every `window-d3.txt` row and the C1 cases (replay at 1, 2, 12 of 12, 29, 30; frontier at 1–5 and 26–30; terminal), no overlap and nothing outside the card; the C1 copy rule; the N1 CTA warm and cold; C3; the §11.1 (1) anchors at 1.0× (±2 pt) and no scroll up to AX5 on 390 / 393 / 440 widths; `Semantics` labels and order; a launch-resource test (both themes on the drawable, iOS background colour).
* **Named negative runs** (§18.7), each caught by a failing test and then restored: the N1 CTA reverted to terminal precedence; the window's replay offset removed; the raw exception shown outside `kDebugMode`; `NormalTheme` back on `?android:colorBackground`.
* **Suites:** `melos run analyze`; `dart format --set-exit-if-changed app packages tools` (the repo-wide check is red on a pre-existing probe, CI-FORMAT-GATE); `melos run test`; `flutter test integration_test` on the iPhone 16 simulator.

**Evidence** — `frontend.md` § Visual Parity Evidence, gate schema (§18.6 and §18.7 "Evidence expected from Frontend"): runtime screenshots and parity composites for the §12a rows; the cold-start recording (empty and existing store, the native → Flutter hand-off frame named) and the entrance with and without Reduce Motion; the text sweep; the error screen forced in a profile or release build and in debug, with the log line; the production-shaped cold boot (**startup impact: yes**). Record revision, device, time and owner; state Android as a limit (ANDROID-CI-EVIDENCE). Before rewriting `frontend.md`, archive the current F05 file byte for byte as `history/f05-journey-progression-2026-09-29/frontend-before-phase-d3.md`.

**Non-goals** (§18.5): no engine, scoring, unlock, persistence, snapshot, lifecycle or route change; the §6 derivation and the F09 seam unchanged; Play, the tutorial and the result (D1 / D2); F10 / F07 / F09 / F11 / F12 items; the app icon and the OS display name; no token change or new dependency. MOVESCARD-COUNTER-LINE-HEIGHT and RESULT-F00-COMPONENT-ALIGN are not in scope (Home does not use those components; the press stays as shipped).

**Exit:** F05-FE-D3 Done with `frontend.md`; F05.D3-PARITY PASS with provenance; Delivery Review = Pending. Hand back to the Tech Lead (the mandatory checkpoint → Ready for QA) before F05-QA-D3. Any deviation from ui-design §11 / architecture §18.7 beyond the §11 "Flexible" list goes to Needs Tech Lead Clarification.

## Earlier briefs

* F05-UI-D3 (UI Designer, done 2026-09-29) — archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md.
