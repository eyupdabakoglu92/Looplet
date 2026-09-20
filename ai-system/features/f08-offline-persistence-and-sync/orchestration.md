# F08 — offline-persistence-and-sync: Orchestration

## Feature ID

F08

## Current Status

In Progress

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [ ] Task ID: F08-LOCAL-EVIDENCE | Assigned Role: Frontend/Mobile Developer | Status: Queued | Summary: Prepare/capture missing independent local runtime and storage-failure proof; do not deploy or change product semantics | Depends On: -
- [ ] Task ID: F08-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Independently review local/emulator/boot evidence, preserve unresolved scenarios, then issue functional-stage verdict | Depends On: F08-LOCAL-EVIDENCE
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Resume release readiness only after explicit billing/target approval; retain runbook and remaining smoke | Depends On: F08-QA-FUNCTIONAL
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

None

## Handoff Plan

None

## Delivery Review

Pending

## QA Scope

end-to-end

## QA Stage

functional

## QA Result

Runtime Validation Pending

## Release Scope

production-readiness

## Release Result

Release Validation Pending

## Pending Evidence

- Evidence ID: F08.EMULATOR
  * Scenario: Rules/callable create-only, auth isolation and idempotency scenarios
  * Required Class: repeatable integration
  * Target / Environment: Isolated Firebase emulator project or an identifiable existing CI emulator run
  * Owner Role: QA
  * Prerequisite / External Decision: JDK/emulator tooling or reviewable CI evidence; no Blaze upgrade/real deploy required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance
  * Result: PENDING

- Evidence ID: F08.LOCAL-RESUME
  * Scenario: Kill/relaunch exact restore, undo/restart/thaw state and untrusted cached thaw re-derivation
  * Required Class: runtime
  * Target / Environment: Local device/simulator with real app persistence
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target; no paid backend required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance; F03/F05 shared persistence
  * Result: PENDING

- Evidence ID: F08.LIFECYCLE
  * Scenario: Session-owned sync survives screen disposal; pause/resume and connectivity regain drain correctly
  * Required Class: runtime
  * Target / Environment: Device/simulator with isolated/emulated backend where applicable
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target and isolated integration setup, not production billing
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance
  * Result: PENDING

- Evidence ID: F08.OFFLINE-JOURNEY
  * Scenario: Offline Journey through actual F03/F05 screens and persisted state
  * Required Class: runtime
  * Target / Environment: Local device/simulator
  * Owner Role: QA
  * Prerequisite / External Decision: F03/F05 screens now exist; reassess the earlier screen-availability deferral
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08/F05 functional acceptance
  * Result: PENDING

- Evidence ID: F08.STORAGE
  * Scenario: AC7 storage-full/disk-write-failure remains non-destructive and keeps last-good state
  * Required Class: repeatable integration
  * Target / Environment: Isolated persistence fault-injection harness/runtime target
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: Prepare/verify an appropriate failure-injection method; no paid deployment required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance; applicable F03/F04/F05 persistence
  * Result: PENDING

- Evidence ID: F08.DEPLOY-SMOKE
  * Scenario: Authorized real-project deploy, post-deploy create-only submission and rollback/smoke checks
  * Required Class: runtime
  * Target / Environment: Target environment named in project-authority/release.md and feature release.md
  * Owner Role: DevOps/Release Engineer
  * Prerequisite / External Decision: F08.DEPLOY-AUTHORIZATION plus explicit target approval
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 release/final acceptance
  * Result: PENDING

- Evidence ID: F08.COLD-BOOT-REVIEW
  * Scenario: QA reconciliation of F08-FE12 production-shaped cold-boot fix evidence
  * Required Class: runtime
  * Target / Environment: frontend.md F08-FE12 and archived 2026-09-13 Tech Lead runtime evidence
  * Owner Role: QA
  * Prerequisite / External Decision: Review provenance/applicable revision; re-run only missing or invalidated scope
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance and shared app startup
  * Result: PENDING

## Open Decision Gates

- Decision ID: F08.DEPLOY-AUTHORIZATION
  * Question: Is the deferred paid-backend release now authorized, for which environment and scope?
  * Options / Trade-offs: Keep deferred or explicitly approve billing and the named deployment target
  * Recommendation: Preserve the recorded deferral until the user supplies a new decision
  * Blocks: F08-DEVOPS activation, final QA and Done; not independent local/emulator validation
  * Blocking Scope: release
  * Status: OPEN

## Blockers

None

## Next Action

Queued behind the F03 rework (F03 final QA returned Rejected 2026-09-20; rework-control rule blocks other-feature client/QA activation); F08-LOCAL-EVIDENCE and F08-QA-FUNCTIONAL stay Queued and none waits for paid deployment. Tech Lead reviews F03's runtime provenance (resume/kill PASS on rev 7a907dd) before deciding whether F08.LOCAL-RESUME can reuse any of it for the identical scope after F03 re-QA. The release task remains Blocked and no deployment/billing action is authorized by this migration. After functional QA, resolve the release decision explicitly, run the scoped DevOps task, then Tech Lead review and final QA; DevOps Ready alone never closes F08.

## Last Decision

2026-09-18 — split local validation from the deferred release prerequisite. Preserve qa.md Runtime Validation Pending and release.md Release Validation Pending. Do not convert the historical direct Tech Lead cold-boot closure into QA approval. No product/code/release authority change.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-20
* Summary: Routing note only (queued behind F03 QA); ledger, evidence and release gate unchanged.

## Context & Follow-ups

F08 implementation/runbook and the F08-FE12 fix are retained. Exact old tasks and checks remain in the archive. Pending scenarios derive from qa.md Pending Validation Scenarios and the boot follow-up, not newly discovered implementation defects. F07 still depends on the required F08 proof. F07.OFFLINE-DAILY (real Daily screens/producer) is explicitly retained in workflow-follow-ups.md under F07, not in F08's required closure ledger: the existing architecture accepts F08's isolated/fake-producer surface and assigns the consumer to F07. This avoids a circular F08-final → F07 → F08 dependency without waiving F07 evidence.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.

## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
