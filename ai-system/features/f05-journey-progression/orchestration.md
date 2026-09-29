# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

In QA

## Current Owner

QA

## Next Role

QA

## Active Task Ledger

- [x] Task ID: F05-UI-D3 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-29 (981b807), ACCEPTED at the Tech Lead visual-gate checkpoint 2026-09-29 (architecture §18.7). ui-design.md is the D3 handoff (the pre-D3 file archived: history/f05-journey-progression-2026-09-29/ui-design-before-phase-d3.md): every Home state incl. the N1 terminal-with-replay (D3-07), the loop track with windowing A "sliding five" (adopted) and B (rendered alternative), the store-error screen, native launch iOS / Android, splash, 1.3× / AX5, device variants, the entrance prototype, window and contrast tables, acceptance list §11.1, manifest §12b. 41 renders + 4 contact sheets in design/ from design/src/gen-d3.mjs (reproduced byte for byte at the checkpoint). | Depends On: -
- [x] Task ID: F05-FE-D3 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: ACCEPTED at the Tech Lead implementation checkpoint 2026-09-29 (architecture §18.8; commit af5aec8, `app/` fingerprint `b4ad263e…` recomputed; suites and negative runs NA / NC re-run). DELIVERED 2026-09-29 (HEAD 7c1a946 + working tree, `app/` fingerprint `b4ad263e…`; frontend.md, the pre-D3 file archived as history/f05-journey-progression-2026-09-29/frontend-before-phase-d3.md). Home (`LoopTrack`, `LoopNode` open / locked / finish), `JourneyHomeView` (window rule, C1, N1 CTA), the shell (`shell/`: splash, store error, wordmark, layout), native launch (iOS + Android incl. API 31+), `MaterialApp` ground; 565 app tests + 13 / 13 integration_test on the iPhone 16; negative runs NA–NH caught; runtime parity on the 16 / 16e / Pro Max in design/runtime-d3/. Two runtime defects found and fixed (debug row on a live AX5 change; the debug text at AX5). Original brief: Implement the D3 handoff from `app/lib/design` — Home (`LoopTrack` + the `LoopNode` states), the §18.3 (2) CONTINUE rule, the C1 copy rule, splash, `StoreErrorScreen`, native launch assets, the `MaterialApp` ground, the C2 debug row, the C3 entrance; tests and named negative runs; `frontend.md` Visual Parity Evidence incl. the cold-start recording and the production-shaped cold boot (architecture §18.6, §18.7). Brief: Current Brief | Depends On: F05-UI-D3
- [ ] Task ID: F05-QA-D3 | Assigned Role: QA | Status: Open | Summary: Final-stage independent visual QA of D3 (rubric ≥ 93 from runtime; F05 AC7–AC10 / AC12 incl. the N1 replay rule warm and cold; error screen + Retry; cold start with no white frame; D1 / D2 regression over Home ⇄ `/play`) (architecture §18.6, §18.8). Brief: Current Brief | Depends On: F05-FE-D3

## Open Tasks

* F05-QA-D3 (QA) — Open.

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

allowed

## Release Scope

none

## Release Result

None

## Visual Scope

new-surface

## Design Foundation

ai-system/project-authority/design-foundation.md

## Visual Quality Gate

Ready for QA

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* Home · today `S-06b-home-today.png` — the composition to build;
* Home · design `S-06-home-design.png` — its future-scope items (settings, level-info card, chips) are **not** built;
* the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest. The Foundation's direction renders for Home (`A-06`, `B-06`, `C-06`, `C-06b`) are recorded in `design-foundation.md` §13 / §17.10.

The shipped baseline is conformance-audit.md §2, §3 and §12, captured at 615e94c: `design/audit/cur-home-new.png`, `cur-home-mid.png`, `cur-home-in-progress.png`, `cur-home-late-in-progress.png`, `cur-home-terminal.png`, `cur-a11y-ax5-home-terminal.png`, `cur-a11y-xxxl-home-terminal.png`, `cur-shell-splash.png`, `cur-shell-bootstrap-error.png`, and the pairs `pair-01-home-in-progress.jpg`, `pair-02-home-mid.jpg`.

**The D3 runtime (F05-FE-D3, 2026-09-29):** frontend.md § Visual Parity Evidence — captures, recordings and composites in `design/runtime-d3/` (`RT-*`, `A11Y-*`, `COLD-*`, `PC-D3-*`, `parity-measurements.txt`). **Accepted at the implementation checkpoint 2026-09-29** (architecture §18.8). Vertical anchors are read against ui-design §6, not the render pixels (ruling 1). The debug row and the debug details box are the only debug-only deviations.

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
  * Result: PASS
  * Provenance / Note: **Accepted by the Tech Lead at the implementation checkpoint, 2026-09-29 (HEAD af5aec8, clean tree; architecture §18.8): the `app/` fingerprint `b4ad263e…` recomputed; `melos run analyze`, the scoped `dart format` check and `melos run test` re-run (app 565, all packages green); the negative runs NA and NC re-run and caught (5 and 2 failing); the parity measurements read. integration_test was not re-run (it needs the simulator).** Delivery: iOS Simulator scope. 2026-09-29 Frontend/Mobile Developer, HEAD 7c1a946 + working tree (`app/` `b4ad263e…`), debug build on iOS Simulator 18.6 — iPhone 16 / 16e / Pro Max. Every Home state beside its render (PC-D3-*: horizontal ≤ 0.5 pt; vertical −5…−7.5 pt, the render's own drift from §6, frontend.md §4 / §16 (1)); cold-start recordings from an empty and an existing store with no light frame and an invisible native → Flutter hand-off; Reduce Motion recording; the store error forced (debug) incl. AX5 and Retry; the text sweep large → AX5 → large; N1 tap → level 12 at its saved state. `melos run analyze` / `test` green (app 565); integration_test 13 / 13 on the iPhone 16. Split out: F05.D3-RELEASE-ERROR-CAPTURE (below); Android not run (ANDROID-CI-EVIDENCE).

- Evidence ID: F05.D3-RELEASE-ERROR-CAPTURE
  * Scenario: The store-error screen in a profile or release build shows no exception text (architecture §18.6)
  * Required Class: runtime
  * Target / Environment: a physical iPhone or a distribution build (the iOS Simulator cannot run profile / release builds)
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: a device or distribution build — rides FIRST-APP-DISTRIBUTION (DEFERRED; needs the user's explicit distribution approval)
  * Blocking Scope: release
  * Re-evaluation Trigger: the first device / distribution build
  * Blocks: the first-app-distribution device smoke only. It does **not** block F05-QA-D3 or the F05 closure (architecture §18.8 ruling 3).
  * Result: PENDING
  * Provenance / Note: **Ruled by the Tech Lead at the implementation checkpoint, 2026-09-29 (§18.8 ruling 3):** for D3 the rule is proven by the compile-time `kDebugMode` constant, the widget tests with `showDetails: false`, and the negative run NC (re-run at the checkpoint, 2 failing). The runtime capture follows at the first device or distribution build (FIRST-APP-DISTRIBUTION, `workflow-follow-ups.md`). Earlier record: 2026-09-29 Frontend/Mobile Developer. Covered meanwhile by widget tests (`showDetails: false`: no exception text; negative run NC) and the compile-time `kDebugMode` gate; the debug-build runtime shows the box apart from the player copy.

- Evidence ID: F05.D3-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on D3 — rubric ≥ 93 from runtime (every dimension ≥ 8, no fail condition); F05 AC7–AC10 / AC12 on the new Home incl. the §18.3 (2) replay rule warm and cold; the error screen and Retry; cold start with no white frame; D1 / D2 regression over Home ⇄ `/play`
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F05.D3-PARITY accepted (gate Ready for QA) — met 2026-09-29 (architecture §18.8)
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

Run QA on F05-QA-D3: the final-stage independent visual QA of D3 (Current Brief; contract architecture §18.6 and §18.8). Then back to the Tech Lead: closure (F05 → Done, Phase D complete) or rework routing.

## Last Decision

2026-09-29 (D3 implementation checkpoint) — the Tech Lead **accepted F05-FE-D3**:
* Delivery Review → **Accepted**;
* F05.D3-PARITY accepted;
* Visual Quality Gate → **Ready for QA**;
* F05-QA-D3 open.

Full record: `architecture.md` §18.8.

**Verified independently** (HEAD af5aec8, clean tree):
* the `app/` fingerprint `b4ad263e…` was recomputed;
* suites re-run on the host: analyze exit 0; `dart format` (app / packages / tools) exit 0; `melos run test` exit 0, app 565 and every package green;
* the negative runs NA (N1 CTA reverted → 5 failing) and NC (the details box outside debug → 2 failing) were re-run with `neg-d3.py`, and the tree was clean afterwards;
* `JourneyHomeView`, `HomeScreen`, `StoreErrorScreen` and `_BootstrapGate` were read against C1–C3 and §18.3 (2) / (7);
* `parity-measurements.txt` and the N1 and store-error composites were read;
* `git diff 5677471 HEAD` confirms Play, the read-model, content, persistence and the pubspecs are unchanged since F03-QA-D2R.

**Rulings on `frontend.md` §16:**
1. The §6 numbers are the layout authority. The renders' constant 4.8·s vertical drift is not a parity defect.
2. The iOS launch cross-fade under Reduce Motion is accepted as platform behaviour (a 0.2 s opacity fade between identical grounds).
3. The profile / release capture of the store error is moved to FIRST-APP-DISTRIBUTION (Blocking Scope release). For D3 the rule is proven by `kDebugMode`, the widget tests and NC.
4. The in-process Retry limit is pre-existing F08 behaviour, recorded as F08-RETRY-STORE-CONNECTION for the F08 local-evidence stage.

**Also ruled:** the debug details box (solid edge vs dashed, and its height) is debug-only and not scored; Android stays a stated limit.

**QA plan:** final, client-only; core + client-ui + visual-quality + stateful-flow; full regression; evidence reuse allowed within limits (§18.8).

The orchestration at the Frontend delivery is archived byte for byte as history/f05-journey-progression-2026-09-29/orchestration-at-fe-d3-delivery.md. It holds the F05-FE-D3 brief and the previous Last Decision (the §18.7 visual-gate checkpoint).

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-29
* Summary: D3 implementation checkpoint — F05-FE-D3 accepted; Delivery Review Accepted; gate Ready for QA; §16 rulings 1–4 (architecture §18.8); F05.D3-RELEASE-ERROR-CAPTURE → Blocking Scope release; Status In QA; owner → QA (F05-QA-D3).

## Context & Follow-ups

* **Phase D:** D1 (Play) closed 2026-09-28; D2 (won moment + result) closed 2026-09-29; **D3 (Home + shell) active** — the last slice.
* **D3 inputs:** PO-REV-2026-09-29-F05-CONTINUE (resynced); DESIGN-ADOPTION-CONTRACT-AMENDMENTS (D3 items C-1, C-6, C-7); the audit's D3 renders 19–26; A-2 home at AX5 (also F03-QA-D2R N5), A-3, A-4; the error-surface text-scale note (F03 §19.12 (6), OPTIONAL-QUALITY-NOTES).
* **May be taken if D3 touches the component:** MOVESCARD-COUNTER-LINE-HEIGHT, RESULT-F00-COMPONENT-ALIGN (architecture §18.5).
* **Carried F05 notes (closure 2026-09-27):**
  * N2 — the label-band table is duplicated (`journeyLabelBand` and `_expectedBands`);
  * N3 — the mirror test relies on `flutter test` running in `app/`;
  * 11–15 `tdDegree = 0` is accepted content;
  * a replayed completed level renders as in progress on the progress indicator, by §6 design.
* **Tracked elsewhere:**
  * the offline and storage-failure device branches (F08, SHARED-PERSISTENCE-PROOF);
  * the in-process Retry limit (F08-RETRY-STORE-CONNECTION, §18.8 ruling 4);
  * the first-app-distribution device smoke, the profile / release store-error capture (F05.D3-RELEASE-ERROR-CAPTURE), and the app icon and display name (FIRST-APP-DISTRIBUTION).
* **Checkpoint QA watch point (§18.7 ruling 1):** frontier windows draw nothing ahead of the current node; the label carries the whole Journey. QA judges it under the rubric.
* **After D3:** F08 local evidence (Design Adoption Route).

## History & Evidence References

* [Terminal orchestration before the D3 reopen](../../history/f05-journey-progression-2026-09-29/orchestration-before-phase-d3.md) (the 2026-09-27 closure, its full evidence and change log); [orchestration at the PO revision](../../history/f05-journey-progression-2026-09-29/orchestration-at-po-revision.md) (the D3 activation decision, Blocked); [orchestration at the UI delivery](../../history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md) (the F05-UI-D3 brief).
* [Orchestration at the Frontend delivery](../../history/f05-journey-progression-2026-09-29/orchestration-at-fe-d3-delivery.md) (the F05-FE-D3 brief, the §18.7 Last Decision).
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
* 2026-09-29 — Frontend/Mobile Developer: F05-FE-D3 delivered (frontend.md; the pre-D3 frontend.md archived); F05.D3-PARITY PASS (iOS Simulator scope); F05.D3-RELEASE-ERROR-CAPTURE opened PENDING; Delivery Review Pending; owner → Tech Lead.
* 2026-09-29 — Tech Lead: D3 implementation checkpoint.
  * **Verified:** fingerprint, suites and negative runs NA / NC re-run; code and parity read.
  * **Decided:** F05-FE-D3 accepted; the §16 rulings 1–4 and the F05-QA-D3 plan (architecture §18.8); F05.D3-RELEASE-ERROR-CAPTURE → Blocking Scope release; F08-RETRY-STORE-CONNECTION recorded.
  * **Next:** Delivery Review Accepted; gate Ready for QA; In QA; F05-QA-D3 Open; owner → QA.

## Current Brief

**F05-QA-D3 — final-stage independent visual QA of Design Adoption Phase D3: Home + app shell** (contract: architecture §18.3, §18.6; the rulings §18.7 and §18.8, which override `ui-design.md` and `frontend.md` where they differ)

**Build under test:** HEAD af5aec8 or later with `app/` fingerprint `b4ad263e…` (recompute it with the `frontend.md` command, and record any difference). Debug build on the iOS Simulator 18.6: iPhone 16 (primary, 393 × 852), 16e (390 × 844), 16 Pro Max (440 × 956). Profile and release builds cannot run on the simulator.

**Plan:**
* **Stage:** final. **Scope:** client-only. **Release Scope:** none.
* **Modules:** core, client-ui (navigation, CTA targets, back paths, the store-error route), visual-quality (independent rubric from runtime), stateful-flow (the live read-model warm and cold, relaunch and persistence, the bootstrap retry).
* **Regression depth:** full — startup, the routing shell and the app theme changed.
* **Evidence reuse:** allowed, per §18.8 — the D1 / D2 QA evidence for Play and the result (`app/lib/play/**` unchanged since F03-QA-D2R) and the F05-QA-STRICT2 behaviour evidence (read-model, unlock, gate, `Next Level`), each marked `REUSED` with its fingerprint. Invalidated and re-run: Home, the splash, the store error, the cold start, the app ground and the Home ⇄ `/play` round trip. The Frontend's captures and self-check are inputs, not QA evidence.

**Critical journeys** (start → action → visible result; runtime unless stated):
1. **Cold start from an empty store:** native launch → splash → Home "new" (0 / 30, "İlk döngüyü çöz.", "Devam et", "Seviye 1"). No white or light frame at any point; no jump at the native → Flutter hand-off. Screen-record it and read it frame by frame.
2. **Cold start from an existing store** in each §8 state (seeded; `design/src/seed-d3.sh` may be used):
   * new with level 1 started;
   * mid 4 / 30 with no session;
   * in progress 4 / 30, 12 / 30 and 25 / 30;
   * a replay before 30 / 30;
   * terminal 30 / 30;
   * **N1 — 30 / 30 with a replay of level 12 in progress.**

   Each is compared with its `D3-*` render: headline, label, caption, window and node states, and one CTA. The C1 copy rule and the window rule are exact (`window-d3.txt`).
3. **AC7 / N1:** tap "Devam et" in the N1 state → Play opens level 12 at its saved state (grid, moves, undo). Prove it **warm** (start the replay from Home, go back → Home shows 30 / 30 + "Seviye 12 · sürüyor") and **cold** (kill → relaunch → the same Home → CONTINUE resumes).
4. **AC9:** 30 / 30 with no session → "Tüm döngüler tamam." + "Tekrar oyna" → level 1. No crash, and the finish node is drawn.
5. **AC8 / AC10:** mid with no session → CONTINUE → the lowest unlocked incomplete level. `YOLCULUK · N / 30` and the track are accurate, and the progress `Semantics` read "N / 30 seviye tamamlandı — Seviye M".
6. **AC12 and the round trip (D1 / D2 regression):**
   * Home → CONTINUE → win → the full-screen result;
   * Next (N < 30) → level N+1; Next at 30 (or the last available level) → Home terminal;
   * the result's back button and system back → Home, updated in place with no entrance replay (C3);
   * Play's chevron → Home.

   Home stays mounted, and warm must equal cold.
7. **Store error (§18.3 (7), F08 AC9):** force a failing bootstrap (e.g. a non-database file as the store, as in `frontend.md`) → Turkish copy, `loopBreak`, one "Tekrar dene". No raw exception in the player copy; in debug the box is visibly apart. The `debugPrint` line is in the log.
   * Retry → splash → the error again while the store stays unreadable. This is expected (§18.8 ruling 4), not a defect.
   * Relaunch with a good store → Home.
8. **Text scale (C-9):** OS text large → 1.3× → AX5 → large, live while Home is mounted (N1 and in progress), and on the store error (top and scrolled to the end):
   * nothing is clipped, and no word breaks mid-word;
   * the headline stays at two lines; the caption breaks only before "·"; the CTA label stays on one line;
   * Home does not scroll up to AX5 on the three phones;
   * the debug row hides at AX5 and returns at large (debug only, C2);
   * above the cap the error screen scrolls under `ScrollBand`, and Retry is reachable.
9. **Motion:**
   * the entrance plays once per process, at the first model frame (card 0–240, CTA 60–300, caption 120–340 ms), and never on a return from `/play`;
   * **Reduce Motion:** card and CTA appear at once. The 0.2 s wordmark cross-fade is iOS platform behaviour (§18.8 ruling 2), judged under the rubric but not as a reduced-motion fail;
   * no idle motion.

**Misuse and boundary checks:**
* repeated or rapid CTA taps push `/play` once;
* the track is not tappable (no level select; AC2 by construction);
* no back affordance on the splash, Home or the store error;
* no future-scope item (settings, level-info card, streak or stars chip, gesture hint);
* no Material icon, `PlayTheme` or amber on Home, the splash or the store error;
* Turkish casing correct (`YOLCULUK`, `KAYITLI VERİLER`);
* app-switcher / background → foreground on Home does not replay the entrance or show a stale state.

**Automated (execute, do not just cite):** `melos run analyze`; `melos run test` (app 565 at the checkpoint); `flutter test integration_test` on the iPhone 16 (13 / 13 per the Frontend). Also run at least one named negative run yourself (NA … NH, `design/src/neg-d3.py`; restore and `cmp`), and read the checks that back each gate claim.

**Visual quality gate:**
* **Rubric:** the independent `premium-ui-rubric.md` score from the runtime, on Home (every state), the splash / launch and the store error. Pass bar: total ≥ 93, every dimension ≥ 8, no fail condition.
* **Reading the parity composites:**
  * vertical anchors are measured against ui-design §6 (e.g. the CTA top at 486.3 ± 2 pt on 393 × 852), not against the render pixels (§18.8 ruling 1);
  * horizontal parity and composition are read against the renders;
  * the debug row and the debug details box are the only debug-only deviations, and are not scored;
  * the frontier windows draw nothing ahead of the current node — the §18.7 watch point, judged under the rubric.

**Stated limits (report them; do not upgrade them to PASS):**
* Android launch and runtime (ANDROID-CI-EVIDENCE; resources are asserted by `launch_resources_test.dart`);
* the profile / release store-error capture (F05.D3-RELEASE-ERROR-CAPTURE, Blocking Scope release — it does not block this verdict);
* the pressed and focused CTA at runtime, and VoiceOver, where `simctl` cannot drive them;
* release-build pacing.

**Startup impact: yes.** The production-shaped cold boot is required: the real bootstrap and the real store, from empty and from existing (journeys 1–2). Mocks or overrides do not count.

**Approval exit:**
* Approved / Approved with Notes only if all of these hold: journeys 1–9 PASS on the runtime; AC7–AC10 and AC12 PASS; the rubric bar is met; no blocking finding.
* Otherwise Rejected (findings with root-cause hypotheses) or Runtime Validation Pending (the missing scenario with its owner and target).

Record the results in `qa.md`. Archive the current F05 `qa.md` byte for byte as `history/f05-journey-progression-2026-09-29/qa-before-phase-d3.md` first. Restore the simulators afterwards (text size `large`, Reduce Motion 0).


## Earlier briefs

* F05-UI-D3 (UI Designer, done 2026-09-29) — archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md.
* F05-FE-D3 (Frontend/Mobile Developer, done 2026-09-29) — archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-fe-d3-delivery.md.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md.
