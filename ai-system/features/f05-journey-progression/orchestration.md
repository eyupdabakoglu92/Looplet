# F05 — journey-progression: Orchestration

## Feature ID

F05

## Current Status

In Progress

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [ ] Task ID: F05-QA-STRICT | Assigned Role: QA | Status: Queued | Summary: Re-verify real strict Journey content and affected curve/terminal/regression scope; reconcile inherited evidence before final approval | Depends On: -

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

- Evidence ID: F05.STRICT-CONTENT
  * Scenario: Independent acceptance of the real 30-level strict pack, structural band invariants and now-reachable full-campaign/terminal behavior
  * Required Class: automated functional
  * Target / Environment: Current content/journey/tr, app bundle, CLI validator and Journey tests
  * Owner Role: QA
  * Prerequisite / External Decision: F06-CONTENT-PROMOTE delivered; QA must verify exact executable checks and relevant negative examples
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F05 final acceptance
  * Result: PENDING

- Evidence ID: F05.SHARED-RUNTIME
  * Scenario: Inherited play/navigation/lifecycle/resume evidence from F03 and local F08 persistence; offline Journey and failure preservation where applicable
  * Required Class: runtime
  * Target / Environment: F03.RUNTIME-MATRIX / VISUAL / ROTATION / BACK; F08.LOCAL-RESUME / OFFLINE-JOURNEY / STORAGE
  * Owner Role: QA
  * Prerequisite / External Decision: Review/reuse proof for the actual shared path; local simulator and isolated storage are independent of paid Firebase deployment
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F05 final acceptance
  * Result: PENDING

## Open Decision Gates

None

## Blockers

None

## Next Action

Wait for F03-QA-RUNTIME (the single active QA feature); Tech Lead then reviews its verdict and activates F05-QA-STRICT with F03's provenance reused for F05.SHARED-RUNTIME. Keep F05-QA-STRICT queued; do not activate F09 while F05 acceptance is unfinished. Use the QA brief below instead of stale command/verdict suggestions in the archived snapshot.

## Last Decision

2026-09-20 — F05 stays In Progress and queued behind F03: it depends on F03, and F05.SHARED-RUNTIME reuses F03's runtime/back/visual proof, so QA runs F03 first (one QA feature at a time). Tech Lead verified the bundled pack app/assets/journey/tr is byte-identical to content/journey/tr (`diff -rq`, 30 levels + manifest); this is orientation, not QA evidence. No product, content, application or architecture file was changed.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-20
* Summary: Routing re-pointed behind F03-QA-RUNTIME; F05-QA-STRICT unchanged and queued.

## Context & Follow-ups

F05 code and the promoted strict pack are unchanged. Previous qa.md approved the interim smoke content; it is not approval of the current strict pack. Current final approval is therefore None. Separate first-app-distribution gates remain in workflow-follow-ups.md; F08's paid deploy does not automatically block independent F05 local checks.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f05-journey-progression/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-20 — Tech Lead: QA sequencing set to F03 first; F05 routing note only.

## Consumed Signals

* analysis.md decisions D1–D8 were consumed into architecture.md; reopen only affected unresolved questions.
* F06-CONTENT-PROMOTE was Tech-Lead-reconciled on 2026-09-13; that is delivery evidence, not the outstanding QA verdict.

## Current QA Brief

1. Verify the actual strict manifest checks (contiguity, checksum, identity and positive optimal moves) and CLI content validation against the real bundle. Map each claimed hard invariant to its executable assertion and a rejecting case; do not assume a no-op test or a green CLI enforces every band rule.
2. Retain the user's recorded 2026-09-13 content acceptance (on-ramp optimalMoves = 2; accepted later-level depth). Do not silently change product criteria. Any unresolved conflict between requirement, user decision and contract goes to Tech Lead / Product Owner, not a fabricated implementation bug.
3. Re-verify newly-reachable all-30-complete, Continue/Next Level and the former interim continueTarget edge. Reuse unchanged valid evidence; scope regression to changed content/tooling and shared paths.
4. Review F03/F08 inherited runtime evidence. F05's own automated-functional scope does not erase another component's required proof. Paid deploy and store distribution are not prerequisites for local Journey testing.
5. Record actual commands, targets, results, skips and provenance. Final verdict is independent; return to Tech Lead for every outcome. Functional content success alone is not final acceptance while required inherited proof is pending.
