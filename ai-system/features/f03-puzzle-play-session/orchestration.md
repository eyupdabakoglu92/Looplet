# F03 — puzzle-play-session: Orchestration

## Feature ID

F03

## Current Status

In Progress

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [ ] Task ID: F03-QA-RUNTIME | Assigned Role: QA | Status: Queued | Summary: Verify retained/runtime evidence for F03.RUNTIME-MATRIX, VISUAL, ROTATION and BACK; return an independent final verdict | Depends On: -

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

## Release Scope

none

## Release Result

None

## Pending Evidence

- Evidence ID: F03.RUNTIME-MATRIX
  * Scenario: architecture.md §16/§18 critical journeys on the required device/simulator matrix; real gesture window, no double count, lifecycle and exact resume
  * Required Class: runtime
  * Target / Environment: App device/simulator; integration_test/play_session_test.dart plus the manual scope in qa.md
  * Owner Role: QA
  * Prerequisite / External Decision: Supported device/simulator and a recorded target; prior widget/build success is not this evidence
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance; F05 shared play/navigation/persistence scope
  * Result: PENDING

- Evidence ID: F03.VISUAL
  * Scenario: Win choreography/greyscale seam readability and locked/frozen tile + thaw confirmation
  * Required Class: manual
  * Target / Environment: Device/simulator manual pass; qa.md §17 note 1 scenario 5
  * Owner Role: QA
  * Prerequisite / External Decision: Same runtime build and content; no paid deployment required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance; applicable F05 shared visuals
  * Result: PENDING

- Evidence ID: F03.ROTATION
  * Scenario: Portrait lock remains effective under OS/device rotation
  * Required Class: manual
  * Target / Environment: Device/simulator; qa.md §17 note 1 scenario 6
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance
  * Result: PENDING

- Evidence ID: F03.BACK
  * Scenario: Chevron, system back and edge-swipe/direct-entry behavior
  * Required Class: manual
  * Target / Environment: Applicable supported OS/device; qa.md §17 note 1 scenario 7
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target and reachable play route
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F03 final acceptance; F05 shared navigation
  * Result: PENDING

## Open Decision Gates

None

## Blockers

None

## Next Action

Tech Lead reviews the existing delivery and the missing required runtime evidence, then schedules one QA owner with QA Stage = final. Reuse valid existing evidence with provenance; execute only missing/affected scenarios. Do not treat build/widget success or a future distribution run as already-executed device evidence. No implementation defect or new code task is inferred.

## Last Decision

2026-09-18 — reopen acceptance validation only. qa.md §17 explicitly says required device/manual proof was not produced, while architecture.md §16/§18 requires it. The historical Approved with Notes remains in qa.md/archive but is not imported as a valid current final approval. This migration itself assigns no QA verdict.

## Last Update

* Updated By: Tech Lead (core/state migration)
* Timestamp: 2026-09-18
* Summary: Current-only snapshot; original record archived without alteration.

## Context & Follow-ups

F03 implementation is retained. The 2026-09-06 close-out and all its evidence are archived, not rewritten. Storage failure/resume evidence shared with F08 should be reconciled together; missing required proof remains visible until reviewed. No blanket repeat of already-valid automated tests is required.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f03-puzzle-play-session/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
