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

core, client-ui, stateful-flow

## Regression Depth

full

## Evidence Reuse

allowed

## Release Scope

none

## Release Result

None

## Pending Evidence

- Evidence ID: F06.CONTENT-PROMOTE-RECONCILE
  * Scenario: Tech Lead independent verification of the Journey content gate's delivery claims before (re-)activating QA
  * Required Class: automated functional
  * Target / Environment: workspace (melos), content/journey/tr, app/assets/journey/tr, the F05 gate and content:check sources
  * Owner Role: Tech Lead
  * Prerequisite / External Decision: F05-FE3-GATE delivered
  * Re-evaluation Trigger: F05-FE3-GATE delivery reconciliation
  * Blocks: F05 re-QA activation
  * Result: PASS
  * Provenance / Note: 2026-09-27 Tech Lead, HEAD 8c90e21 — every check read against §5.4; own real-content negatives (R2 L05, R3 L18, R5 L30, R6 L03, LABEL L10) each rejected with exactly its named violation; a one-byte bundle drift fails the suite; three content:check negatives rejected; real content check: OK. Full text in history/f05-journey-progression-2026-09-27/orchestration-before-closure.md.

- Evidence ID: F05.STRICT-CONTENT
  * Scenario: QA's own independent acceptance of the real 30-level strict pack, structural band invariants and now-reachable full-campaign/terminal behavior
  * Required Class: automated functional
  * Target / Environment: Current content/journey/tr, app bundle, CLI validator and Journey tests
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-27
  * Re-evaluation Trigger: F05-QA-STRICT2
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-27 QA, HEAD 015e50e (qa.md § F05-QA-STRICT2, Q2-04..Q2-08, Q2-11) — fresh content probe 30/30 with 0 violations; own boundary probe 21/21; real mirror negatives; 4 new content:check negatives; real-bundle campaign → terminal 7/7. Closes the 2026-09-26 FAIL.

- Evidence ID: F05.HOME-LIVE-STATE
  * Scenario: Warm-path home read-model (architecture.md §6/§10/§15) — the mounted home reflects snapshot writes, changes and clears exactly like the cold (relaunch) derivation
  * Required Class: automated functional
  * Target / Environment: app widget tests with the real repos and in-memory Drift; iPhone 16 simulator spot-check
  * Owner Role: QA
  * Prerequisite / External Decision: met 2026-09-27
  * Re-evaluation Trigger: F05-QA-STRICT2
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-27 QA, HEAD 015e50e (Q2-09..Q2-11, Q2-13) — delivered suites 27/27; own edge probe 7/7; warm == cold in the real-bundle probe and on the device (warm frontier, the win clears the in-progress state, warm replay with CONTINUE resuming it, identical after relaunch). Closes the 2026-09-26 FAIL.

- Evidence ID: F05.SHARED-RUNTIME
  * Scenario: Inherited play/navigation/lifecycle/resume evidence from F03 and local F08 persistence; offline Journey and failure preservation where applicable
  * Required Class: runtime
  * Target / Environment: F03.RUNTIME-MATRIX / VISUAL / ROTATION / BACK; F08.LOCAL-RESUME / OFFLINE-JOURNEY / STORAGE
  * Owner Role: QA
  * Prerequisite / External Decision: Review/reuse proof for the actual shared path
  * Re-evaluation Trigger: F05-QA-STRICT2 — ActiveSessionRepo changed in F05-FE3-HOME
  * Blocks: F05 final acceptance
  * Result: PASS
  * Provenance / Note: 2026-09-27 QA, HEAD 015e50e (Q2-12, Q2-13) — F03 device suite 13/13 on iPhone 16; AC7 mid-level kill/relaunch resume on a fresh install. The network-off and storage-failure device branches remain F08's (F08.OFFLINE-JOURNEY, F08.STORAGE) and are not an F05 gate (architecture §13/§15).

## Open Decision Gates

None

## Blockers

None

## Next Action

-

## Last Decision

2026-09-27 (F05 closure) — Tech Lead reconciled F05-QA-STRICT2 (Approved with Notes) and closed F05.

* **Verification:**
  * QA evaluated HEAD 015e50e; nothing in `app`, `tools`, `content` or `packages` changed after it.
  * The Tech Lead re-ran QA's own gate boundary probe (21/21) and home edge probe (7/7), and checked that the device evidence files exist.
* **Closure state:** all required evidence PASS; Delivery Review Accepted; no open decision gate or blocker.
* **N1 — Assumption, hybrid UX edge.** With 30/30 complete, an in-progress replay is not surfaced; the terminal variant wins.
  * §8 said "terminal iff `currentLevel` is null", while ui-design and the implementation said "terminal when all 30 are complete".
  * Tech Lead resolved this in favour of product AC9, ui-design and the shipped, QA-verified behaviour. §8 and §6 now state terminal precedence explicitly.
  * The UX question moves to Design Adoption Phase D, where the home is redesigned (workflow-follow-ups DESIGN-ADOPTION-CONTRACT-AMENDMENTS, F05).
* **N2–N4:** informational, carried below.

Full history: history/f05-journey-progression-2026-09-26/ and history/f05-journey-progression-2026-09-27/.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-27
* Summary: F05 closed Done — F05-QA-STRICT2 Approved with Notes reconciled; §8/§6 terminal precedence clarified (N1 → Phase D); terminal cleanup applied.

## Context & Follow-ups

* Done covers:
  * the 30-level strict Journey with an enforced build gate (R1–R6 + LABEL, bundle mirror, content:check path + shape);
  * the live home read-model (warm == cold);
  * unlock, CONTINUE, `Next Level` and terminal navigation.
* The F05 home and tutorial surfaces keep their legacy visuals until Design Adoption Phase D. Phase C is scheduled right after this closure, ahead of F08.
* **Carried notes:**
  * N1 — terminal state vs an in-progress replay (→ Phase D).
  * N2 — the label-band table is duplicated (`journeyLabelBand` and `_expectedBands`); a curve change must update both.
  * N3 — the mirror test relies on `flutter test` running in `app/`.
  * 11–15 `tdDegree = 0` — accepted content; noted for PO visibility.
  * A replayed completed level renders as in-progress on the ring — by §6 design.
* **Tracked elsewhere:**
  * Offline and storage-failure device branches: F08 and workflow-follow-ups SHARED-PERSISTENCE-PROOF.
  * First-app-distribution device smoke: workflow-follow-ups FIRST-APP-DISTRIBUTION.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* Snapshots:
  * [at the F05-QA-STRICT verdict](../../history/f05-journey-progression-2026-09-26/orchestration-at-qa-strict-verdict.md);
  * [at the F05-FE3 delivery](../../history/f05-journey-progression-2026-09-27/orchestration-at-fe3-delivery.md);
  * [before closure](../../history/f05-journey-progression-2026-09-27/orchestration-before-closure.md) — the full ledger and evidence.
* Reports: [QA report](qa.md) (§ F05-QA-STRICT, § F05-QA-STRICT2), [delivery report](frontend.md) (§ F05-FE3) and [contract](architecture.md) (amended 2026-09-26 and 2026-09-27).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20..21 — Tech Lead: QA sequencing behind F03; F03 Done released the lock.
* 2026-09-26 — Tech Lead: F06-CONTENT-PROMOTE reconciled; F05-QA-STRICT activated. QA: F05-QA-STRICT Rejected (STRICT-1/-2/-3). Tech Lead: findings re-verified, contract amended, F05-FE3-GATE + F05-FE3-HOME activated; design incident triaged.
* 2026-09-27 — Frontend/Mobile Developer: F05-FE3 delivered. Tech Lead: reconciled with its own negative runs; F05-QA-STRICT2 activated. QA: Approved with Notes.
* 2026-09-27 — Tech Lead: F05 closed Done (N1 terminal precedence recorded in §8/§6; the UX question moved to Phase D).

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md.
