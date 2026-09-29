# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

Done

## Current Owner

-

## Next Role

-

## Active Task Ledger

None

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

Approved with Notes

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

Passed

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

**The independent QA runtime (F05-QA-D3, 2026-09-29):** qa.md § Evidence Ledger E01–E21 and § Visual Quality Verdict (94 / 100); captures, recordings and composites in `qa/d3/` (`QA-16-*`, `QA-16e-*`, `QA-promax-*`, `PC-QA-D3-*`, `parity-qa.txt`, `raw/*.mov`). Gate **Passed** at the D3 closure (architecture §18.9).

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

- Evidence ID: F05.D3-VISUAL-QA
  * Scenario: An independent final-stage QA verdict on D3 — rubric ≥ 93 from runtime (every dimension ≥ 8, no fail condition); F05 AC7–AC10 / AC12 on the new Home incl. the §18.3 (2) replay rule warm and cold; the error screen and Retry; cold start with no white frame; D1 / D2 regression over Home ⇄ `/play`
  * Required Class: runtime
  * Target / Environment: iOS Simulator 18.6, iPhone 16 / 16e / Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: QA
  * Prerequisite / External Decision: F05.D3-PARITY accepted (gate Ready for QA) — met 2026-09-29 (architecture §18.8)
  * Re-evaluation Trigger: F05-QA-D3 delivery
  * Blocks: Visual Quality Gate = Passed; F05 Done; Phase D completion
  * Result: PASS
  * Provenance / Note: 2026-09-29 QA (F05-QA-D3), HEAD 078c926 clean, `app/` `b4ad263e…`, debug build on iOS Simulator 18.6 — iPhone 16 / 16e / Pro Max. qa.md E01–E21: analyze + test (app 565, 0 skip) + integration_test 13 / 13; negative runs NB-QA / ND-QA / NI-QA caught; cold start empty / existing / Reduce Motion recorded (no light frame, hand-off invisible); every Home state vs render (horizontal Δ ≤ 0.2 pt, CTA at the §6 anchor); N1 warm and cold without a seed override (real move, kill, resume incl. undo); AC8 / AC9 / AC12 (level 30 solved by real moves → terminal) / AC1; store error + Retry + log; live text sweep to AX5 on three devices; rubric 94 / 100, every dimension ≥ 9, no fail condition. Android and the profile / release store-error capture stay stated limits (F05.D3-RELEASE-ERROR-CAPTURE, release scope).


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

-

## Last Decision

2026-09-29 (D3 closure) — the Tech Lead reconciled F05-QA-D3 (`qa.md`, Approved with Notes, 94 / 100): **accepted; Visual Quality Gate Passed; F05 Done; Design Adoption Phase D complete.** Full record: architecture §18.9.

**Verified independently:**
* the `app/` fingerprint is unchanged (`b4ad263e…`); the QA commit e46f384 touches only `ai-system/`;
* every evidence file `qa.md` cites exists in `qa/d3/`;
* two measurements re-run with the F03 `parity-d2` tool match (N1 CTA band at 487.0 pt; pressed 332 / 339 pt);
* the three simulators are restored (`large`, Reduce Motion 0).

**Rulings** (§18.9):
1. The score and the evidence reuse are accepted.
2. The audit conflict QA raised was a Tech Lead error at §18.8 ruling 3. F05.D3-RELEASE-ERROR-CAPTURE leaves this ledger and is tracked under FIRST-APP-DISTRIBUTION; the process lesson is recorded as RELEASE-SCOPED-EVIDENCE.
3. Notes N1–N8 are routed to existing follow-ups.
4. The D3 contract amendments (C-1, C-6, C-7) are closed; A-2 home, A-3 and A-4 are fixed.

**State:** F05 Done; every task Done; Delivery Review Accepted; QA final, Approved with Notes; Release Scope none; every remaining Pending Evidence record PASS; the one decision RESOLVED; no blocker. **Resume point: F08 local evidence** — activated by the next Tech Lead turn (F08 orchestration).

The D3 ledger, the F05-QA-D3 brief and the implementation-checkpoint decision are archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-qa-d3-verdict.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-29
* Summary: D3 closure — F05-QA-D3 accepted (§18.9); Visual Quality Gate Passed; F05 Done; Phase D complete; F08 activation next (Tech Lead).

## Context & Follow-ups

* **Phase D3 closed 2026-09-29** (Home + app shell, `new-surface`, architecture §18; final QA Approved with Notes, 94 / 100; closure §18.9). With it **Design Adoption Phase D is complete**: D1 (Play, 2026-09-28) and D2 (result, 2026-09-29) are in F03 §19.12 / §20.11.
* **Resume point — F08 local evidence** (F08-LOCAL-EVIDENCE → F08-QA-FUNCTIONAL). For F08.LOCAL-RESUME, reuse can now include F05-QA-D3 E09: an exact resume of a replay across a real kill, incl. undo, on the D3 screens.
* **Open follow-ups carrying D3 notes** (workflow-follow-ups.md):
  * FIRST-APP-DISTRIBUTION — the profile / release store-error capture, and the release pacing of the Home entrance;
  * F08-RETRY-STORE-CONNECTION — Retry reopening the connection, and the one-frame Retry feedback;
  * RESULT-F00-COMPONENT-ALIGN — the `LimePill` arrow at AX5;
  * OPTIONAL-QUALITY-NOTES — the AX5 headline / free-text hierarchy, and `highest_unlocked_level` = 31;
  * F00-ARTEFACT-SIZE — `qa/d3/` ≈ 62 MB;
  * ANDROID-CI-EVIDENCE.
* **Carried F05 notes (closure 2026-09-27):** N2 — the duplicated label-band table; N3 — the mirror test relies on `flutter test` running in `app/`; 11–15 `tdDegree = 0` is accepted content.
* **Tracked elsewhere:** offline and storage-failure device branches (F08, SHARED-PERSISTENCE-PROOF); F10 re-homes this Home surface (menu, settings, level select); F09 onboarding seam.

## History & Evidence References

* [Terminal orchestration before the D3 reopen](../../history/f05-journey-progression-2026-09-29/orchestration-before-phase-d3.md) (the 2026-09-27 closure, its full evidence and change log); [orchestration at the PO revision](../../history/f05-journey-progression-2026-09-29/orchestration-at-po-revision.md) (the D3 activation decision, Blocked); [orchestration at the UI delivery](../../history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md) (the F05-UI-D3 brief).
* [Orchestration at the F05-QA-D3 verdict](../../history/f05-journey-progression-2026-09-29/orchestration-at-qa-d3-verdict.md) (the D3 ledger, the QA brief, the §18.8 Last Decision).
* [Orchestration at the Frontend delivery](../../history/f05-journey-progression-2026-09-29/orchestration-at-fe-d3-delivery.md) (the F05-FE-D3 brief, the §18.7 Last Decision).
* Earlier snapshots: [at the F05-QA-STRICT verdict](../../history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md); [at the F05-FE3 delivery](../../history/f05-journey-progression-2026-09-27/orchestration-at-fe3-delivery.md); [before closure](../../history/f05-journey-progression-2026-09-27/orchestration-before-closure.md); [original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* Reports: [QA report](qa.md) (F05-QA-D3; the pre-D3 report archived as [qa-before-phase-d3.md](../../history/f05-journey-progression-2026-09-29/qa-before-phase-d3.md)), [delivery report](frontend.md), [UI design](ui-design.md) (the D3 handoff; the Direction A home is archived), [contract](architecture.md) (§18 D3, checkpoint rulings §18.7).
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
* 2026-09-29 — QA: F05-QA-D3 final visual QA — Approved with Notes (94 / 100); qa.md rewritten (the pre-D3 qa.md archived as history/f05-journey-progression-2026-09-29/qa-before-phase-d3.md); evidence qa/d3/; F05.D3-VISUAL-QA PASS; owner → Tech Lead.
* 2026-09-29 — Tech Lead: D3 closure.
  * **Verified:** fingerprint unchanged; QA evidence present; two measurements reproduced; simulators restored.
  * **Decided:** architecture §18.9 — verdict accepted; the §18.8 ruling-3 ledger error corrected (F05.D3-RELEASE-ERROR-CAPTURE → FIRST-APP-DISTRIBUTION); notes N1–N8 routed; D3 contract amendments closed.
  * **State:** Visual Quality Gate Passed; F05 **Done**; Phase D complete; the ledger and the QA brief archived as history/f05-journey-progression-2026-09-29/orchestration-at-qa-d3-verdict.md. Next: F08 activation (Tech Lead).


## Earlier briefs

* F05-UI-D3 (UI Designer, done 2026-09-29) — archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-ui-d3-delivery.md.
* F05-FE-D3 (Frontend/Mobile Developer, done 2026-09-29) — archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-fe-d3-delivery.md.
* F05-QA-D3 (QA, done 2026-09-29, Approved with Notes) — archived byte for byte in history/f05-journey-progression-2026-09-29/orchestration-at-qa-d3-verdict.md.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md.
