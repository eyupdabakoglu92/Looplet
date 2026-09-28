# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

Rework

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F05-UI-D3 | Assigned Role: UI Designer | Status: Done | Summary: DELIVERED 2026-09-29 — ui-design.md rewritten as the D3 handoff (the pre-D3 file archived: history/f05-journey-progression-2026-09-29/ui-design-before-phase-d3.md). 41 renders + 4 contact sheets in design/ from design/src/gen-d3.mjs (deterministic): every Home state incl. the N1 terminal-with-replay (D3-07), the loop-track windowing A "sliding five" (recommended) vs B "band window" (rendered alternative), the store-error screen (normal, AX5 top / end, debug), native launch iOS / Android, splash, a 1290×2796 launch asset, 1.3× / AX5, device variants; the entrance prototype + stills; window table (src/window-d3.txt) and contrast table (src/contrast-d3.txt); acceptance list §11.1; manifest §12b; NTLC §14 (windowing selection, LoopNode states, headlines, dropped pulse, one-action error). No code. Original brief: The D3 handoff in F05 `ui-design.md` (replacing the Direction A home sections): Home in every §18.2 state incl. the N1 terminal-with-replay state, the loop track and its 30-level windowing (0 / 4 / 12 / 25 / 30), the store-error screen, the native launch + splash (iOS; Android light / dark), AX5, copy proposals, a D3 acceptance list and the Visual Evidence Manifest. Contract architecture §18. Brief: Current Brief | Depends On: -
- [ ] Task ID: F05-FE-D3 | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: Implement the D3 handoff from `app/lib/design` (Home, the loop-track addition, splash, `StoreErrorScreen`, native launch assets, `MaterialApp` ground) and the §18.3 (2) CONTINUE rule; tests updated (§18.4); `frontend.md` Visual Parity Evidence with a cold-start recording and the production-shaped cold boot (architecture §18.6) | Depends On: F05-UI-D3
- [ ] Task ID: F05-QA-D3 | Assigned Role: QA | Status: Queued | Summary: Final-stage independent visual QA of D3 (rubric ≥ 93 from runtime; F05 AC7–AC10 / AC12 incl. the N1 replay rule warm and cold; error screen + Retry; cold start with no white frame; D1 / D2 regression over Home ⇄ `/play`) (architecture §18.6) | Depends On: F05-FE-D3

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Pending

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

Pending

## Visual Evidence

Selected-source records for this surface, all in features/f00-design-foundation/design/:
* Home · today `S-06b-home-today.png` — the composition to build;
* Home · design `S-06-home-design.png` — its future-scope items (settings, level-info card, chips) are **not** built;
* the component sheet `S-91-components.png`.

Their manifest is features/f00-design-foundation/ui-design.md § Visual Evidence Manifest. The Foundation's direction renders for Home (`A-06`, `B-06`, `C-06`, `C-06b`) are recorded in `design-foundation.md` §13 / §17.10.

The shipped baseline is conformance-audit.md §2, §3 and §12, captured at 615e94c: `design/audit/cur-home-new.png`, `cur-home-mid.png`, `cur-home-in-progress.png`, `cur-home-late-in-progress.png`, `cur-home-terminal.png`, `cur-a11y-ax5-home-terminal.png`, `cur-a11y-xxxl-home-terminal.png`, `cur-shell-splash.png`, `cur-shell-bootstrap-error.png`, and the pairs `pair-01-home-in-progress.jpg`, `pair-02-home-mid.jpg`.

The D1 / D2 surfaces that Home opens into and returns from (gate Passed 2026-09-28 / 2026-09-29) are recorded in the F03 orchestration and F03 `architecture.md` §19.12 / §20.11.

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
  * Provenance / Note: 2026-09-29 UI Designer, HEAD 9a36147 + working tree. ui-design.md (D3); 41 PNG renders + 4 contact sheets in features/f05-journey-progression/design/ from design/src/gen-d3.mjs + render-d3.sh (HTML/CSS → headless Chrome @2x; the launch asset @3x); `node gen-d3.mjs` regenerates every page byte for byte. Motion prototype design/src/D3-motion-prototype.html (`?t=`, `?rm=1`). Window table src/window-d3.txt; contrast src/contrast-d3.txt (locked outline raised to 3.41 : 1). Generated design artefacts, not runtime; Android rendered as a frame, not run. Windowing A recommended, Pending Selection (§14 (1)).

- Evidence ID: F05.D3-PARITY
  * Scenario: The runtime matches the D3 handoff on the canonical simulators — every Home state beside its render; a cold-start recording from the native launch to Home with no white frame and no splash jump; the store-error screen forced, with no raw exception outside debug; the OS text sweep large → AX5 on Home and the error screen; the production-shaped cold boot from an empty and from an existing store; suites and integration_test green
  * Required Class: runtime + automated functional
  * Target / Environment: iOS Simulator 18.6 — iPhone 16 (primary), 16e, 16 Pro Max; Android stated as a limit (ANDROID-CI-EVIDENCE)
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: F05.D3-HANDOFF accepted (gate Ready for Implementation)
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

Run Tech Lead — the D3 visual-gate checkpoint: reconcile F05-UI-D3 (ui-design.md, F05.D3-HANDOFF), rule on ui-design §14 (windowing A vs B, the `LoopNode` state extension, the headlines, the dropped pulse, the one-action error screen), then set the gate and open F05-FE-D3.

## Last Decision

2026-09-29 (PO revision resync) — the Tech Lead resynced **PO-REV-2026-09-29-F05-CONTINUE** and unblocked D3.

**Verified:** the revision changes only `product/product-prd.md` (§6.1 F05: the in-progress AC, the all-complete AC, one edge case, and a Revision Log entry) and the feature-board revision flags. Its text matches the user's decision F05.D3-N1-REPLAY-PRECEDENCE (A) exactly. No feature, dependency, priority, MVP scope, metric or domain object changed.

**Impact reviewed:**
* **F05 (the only affected feature):** feature PRD AC7 / AC9 and one edge case resynced; `architecture.md` §8 terminal precedence lapsed, §6 replay bullet and §15 QA focus amended in place; §18.3 (2) and §18.4 now effective.
* **F05 evidence:** the 2026-09-27 terminal-precedence behaviour and its tests stay the record of the shipped app until F05-FE-D3 replaces them. The new rule is proven in D3 (F05.D3-PARITY, F05.D3-VISUAL-QA; architecture §18.6).
* **Other features:** F10's CONTINUE AC ("current or next Journey level") is consistent — a replay in progress is the current level. F03 / F04 (Next Level on level 30 → `/`; the snapshot is cleared at `won`, so Home shows the terminal state), F08 (snapshot restore) and F09 (new-player routing) are unchanged. No Done feature is reopened.

**State:** Rework; blocker cleared; F05-UI-D3 Open, F05-FE-D3 and F05-QA-D3 Queued; Delivery Review Pending; Visual Quality Gate Pending; owner → UI Designer. Pending Product Revision cleared on the board.

The pre-resync orchestration (the D3 activation decision) is archived byte-for-byte as history/f05-journey-progression-2026-09-29/orchestration-at-po-revision.md.

## Last Update

* Updated By: UI Designer
* Timestamp: 2026-09-29
* Summary: F05-UI-D3 delivered — the D3 handoff with 41 renders, the entrance prototype and the acceptance list; F05.D3-HANDOFF PASS; Delivery Review Pending; owner → Tech Lead (visual-gate checkpoint).

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
* **After D3:** F08 local evidence (Design Adoption Route).

## History & Evidence References

* [Terminal orchestration before the D3 reopen](../../history/f05-journey-progression-2026-09-29/orchestration-before-phase-d3.md) (the 2026-09-27 closure, its full evidence and change log); [orchestration at the PO revision](../../history/f05-journey-progression-2026-09-29/orchestration-at-po-revision.md) (the D3 activation decision, Blocked).
* Earlier snapshots: [at the F05-QA-STRICT verdict](../../history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md); [at the F05-FE3 delivery](../../history/f05-journey-progression-2026-09-27/orchestration-at-fe3-delivery.md); [before closure](../../history/f05-journey-progression-2026-09-27/orchestration-before-closure.md); [original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* Reports: [QA report](qa.md), [delivery report](frontend.md), [UI design](ui-design.md) (Direction A home — superseded by D3), [contract](architecture.md) (§18 D3).
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

## Current Brief

**F05-UI-D3 — the D3 handoff: Home + app shell** (contract: architecture.md §18; authority: design-foundation §18, F00 ui-design §6–§8, §10, §13; selected source `S-06b`). **Open since 2026-09-29** (PO-REV-2026-09-29-F05-CONTINUE resynced; the N1 rule of §18.3 (2) is in force).

**Deliver in F05 `ui-design.md`** — replace the Direction A home sections with the D3 sections. Move the superseded text byte-for-byte to `history/f05-journey-progression-2026-09-29/ui-design-before-phase-d3.md` first. The micro-tutorial sections point to F03 D1 (already superseded).

**Must cover:**
1. **Home layout** per `S-06b` and F00 ui-design §6, on 393 × 852 primary plus the 390 × 844 and 440 × 956 variants. No future-scope item (§18.3 (1)).
2. **Every Home state** (§18.2):
   * new player 0 / 30; mid with no session; in progress (frontier); a replay in progress before 30 / 30;
   * terminal 30 / 30 without a session, and **terminal 30 / 30 with a replay in progress** — the user's N1 rule (§18.3 (2)): CTA "Devam et" + "Seviye N · sürüyor", the card keeps 30 / 30;
   * the first frame before the model loads; the pressed CTA; AX5.
3. **The loop track** (§18.3 (3)): nodes, line, swirl arcs, done / current / locked treatments (non-colour cues), and the **30-level windowing rule**, rendered at 0, 4, 12, 25 and 30 / 30. Specify it precisely enough for a component test.
4. **The shell** (§18.3 (7), (8)):
   * the store-error screen (glass card, headline, body, one `LimePill` Retry; where debug-only details sit);
   * the native launch: iOS, and Android light and dark;
   * the Flutter splash, and the hand-off from native → splash → Home with no white frame and no jump.
5. **Motion:** if Home animates (the node advance after a win, a halo, the CTA entrance), specify it with its reduced path and an executable prototype. If not, say "not applicable" with the reason.
6. **Copy proposals** (interim, §18.3 (4)): the terminal headline and CTA label; the error-screen copy; the CTA `Semantics` including "sürüyor". Turkish casing authored.
7. **Accessibility:** targets ≥ 44 pt; contrast of every label on its surface; C-9 (container vs free text, the scroll rule above the cap); `Semantics` for the progress and the CTA; the decorative arcs excluded.
8. **Screen / State / Viewport matrix, Visual Evidence Manifest, and a D3 acceptance list** that Frontend and QA can test item by item.

**Non-goals:** no route, read-model, unlock or persistence change; Play, the tutorial and the result (D1 / D2); F10 menu items, F07 streak, F09, F11, F12; app icon and display name; no code.

**Exit:** the handoff with renders (and prototype, if motion), F05.D3-HANDOFF recorded, Delivery Review Pending, owner → Tech Lead (visual-gate checkpoint).

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md.
