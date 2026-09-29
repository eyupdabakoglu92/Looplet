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

- [x] Task ID: F08-FE13 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: Close the unreadable-DB gap (Resilience row, AC8: classify, quarantine + recreate, `db_reinitialized`, loop guard), make Retry reopen the database connection (F08-RETRY-STORE-CONNECTION), add the debug-only emulator wiring and fake-producer trigger, and the storage-full fault-injection harness (architecture Activation A1–A4). Brief: Current Brief | Depends On: -
- [x] Task ID: F08-LOCAL-EVIDENCE | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: On the F08-FE13 build, capture the local evidence of architecture Activation A4 — resume fidelity incl. restart / thaw / tamper; exactly-once and lifecycle against the Firebase emulator; the emulator rules / callable suite; storage-full; the unreadable-DB runtime; the production-shaped cold boot; offline Journey only on a real no-network runtime. No deploy; no product-semantics change. Brief: Current Brief | Depends On: F08-FE13
- [x] Task ID: F08-BE6 | Assigned Role: Backend Developer | Status: Done | Summary: Fix the contract-invalid fixture in `infra/functions/test/submitDailyResult.test.ts` "ALREADY_SUBMITTED on a repeat" (`moves` 8 < `optimalMoves` 9), keep its first-run-authoritative assertions, prove them with a named negative run, and re-run the emulator suite green on Java 21 (architecture Activation A6 ruling 6). Test code only. Brief: Current Brief | Depends On: -
- [ ] Task ID: F08-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Independently review and re-run the local / emulator / boot evidence under the locked plan (architecture Activation A7), keep unresolved scenarios, then issue the functional-stage verdict | Depends On: F08-LOCAL-EVIDENCE, F08-BE6
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Resume release readiness only after explicit billing/target approval; retain runbook and remaining smoke; a CI emulator job, if added, pins Java 21 (architecture A6 ruling 5) | Depends On: F08-QA-FUNCTIONAL
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

* None open for a delivery role — F08-QA-FUNCTIONAL stays Queued until the Tech Lead checkpoint after F08-BE6.

## Handoff Plan

None

## Delivery Review

Pending

## QA Scope

end-to-end

## QA Modules

core, backend-security, client-ui, stateful-flow

## Regression Depth

full

## Evidence Reuse

invalidated

## QA Stage

functional

## QA Result

Runtime Validation Pending

## Release Scope

production-readiness

## Release Result

Release Validation Pending

## Visual Scope

none

## Design Foundation

Not Required

## Visual Quality Gate

Not Required

## Visual Evidence

None

## Pending Evidence

- Evidence ID: F08.EMULATOR
  * Scenario: Rules/callable create-only, auth isolation and idempotency scenarios
  * Required Class: repeatable integration
  * Target / Environment: Isolated Firebase emulator project or an identifiable existing CI emulator run
  * Owner Role: QA
  * Prerequisite / External Decision: JDK/emulator tooling — **present 2026-09-29** (OpenJDK 17, Firebase CLI; `npm run test:emulator`, project `demo-looplet`); client ↔ emulator runs need the F08-FE13 debug wiring. No Blaze upgrade/real deploy required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance
  * Result: PENDING
  * Delivery Evidence: 2026-09-29 (LE-03, LE-04): suite 30/31 — one backend test sends an invalid payload (frontend.md F08-FE13 §16.1); client ↔ emulator cases A–E. Tooling: firebase-tools 15.29 needs JDK 21 (installed, not linked).
  * Tech Lead 2026-09-29 (A6 ruling 6): the red test is a fixture defect (handler correct) → F08-BE6; the suite must be green before QA. Canonical command with Java 21: setup-manifest.md → Canonical Verification Commands.
  * Delivery Evidence (F08-BE6, 2026-09-29, HEAD b8e37ab + the fixed test): suite **31 / 31**, exit 0 (`evidence/runtime/BE6-02-fixed-suite.log.txt`); N-OVERWRITE caught (`BE6-04-neg.log.txt`). Java 21 must be on PATH, not only `JAVA_HOME` (backend.md F08-BE6 §14.1). QA review pending.

- Evidence ID: F08.LOCAL-RESUME
  * Scenario: Kill/relaunch exact restore, undo/restart/thaw state and untrusted cached thaw re-derivation
  * Required Class: runtime
  * Target / Environment: Local device/simulator with real app persistence
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target; no paid backend required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance; F03/F05 shared persistence
  * Result: PENDING
  * Delivery Evidence: 2026-09-29 (LE-02): level 21 moves + restart + undo + thaw, kill / relaunch exact; tampered thaw re-derived.

- Evidence ID: F08.LIFECYCLE
  * Scenario: Session-owned sync survives screen disposal; pause/resume and connectivity regain drain correctly
  * Required Class: runtime
  * Target / Environment: Device/simulator with isolated/emulated backend where applicable
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target and isolated integration setup, not production billing
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance
  * Result: PENDING
  * Delivery Evidence: 2026-09-29 (LE-05): screen disposed mid-sync, paused / resumed drains; connectivity regain automated only (+ N-REGAIN).

- Evidence ID: F08.OFFLINE-JOURNEY
  * Scenario: Offline Journey through actual F03/F05 screens and persisted state
  * Required Class: runtime
  * Target / Environment: Local device/simulator
  * Owner Role: QA
  * Prerequisite / External Decision: a real no-network runtime (the user turns the Mac's network off or runs a developer-provided script; or a physical device in airplane mode) — Claude may not change system settings; not replaced by simulated offline (architecture Activation A4)
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08/F05 functional acceptance
  * Result: PENDING
  * Delivery Evidence: Not run 2026-09-29: user runtime needed; `evidence/offline-journey.sh` prepared for the user.

- Evidence ID: F08.STORAGE
  * Scenario: AC7 storage-full/disk-write-failure remains non-destructive and keeps last-good state
  * Required Class: repeatable integration
  * Target / Environment: Isolated persistence fault-injection harness/runtime target
  * Owner Role: Frontend/Mobile Developer
  * Prerequisite / External Decision: Prepare/verify an appropriate failure-injection method; no paid deployment required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance; applicable F03/F04/F05 persistence
  * Result: PASS
  * Delivery Evidence: 2026-09-29, `app/test/persistence/storage_full_test.dart` (real file DB, production connection, `max_page_count` → `SQLITE_FULL`; active session + a multi-row transaction), negatives N-FULL / N-FULL-FATAL caught; no runtime hook (frontend.md → F08-FE13 §17, LE-06)

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
  * Delivery Evidence: 2026-09-29 (LE-07): FE13 final build, empty + existing store, no light frame.

- Evidence ID: F08.UNREADABLE-DB
  * Scenario: AC8 / the Resilience row — an unreadable store file (NOTADB / CORRUPT) on launch → quarantine, recreate, `db_reinitialized` log, Home "new", no error loop; a migration failure still → the store-error screen with data intact; a recreate failure → the error screen, no second recreate
  * Required Class: runtime + automated functional
  * Target / Environment: iPhone 16 simulator (debug build; `seed-d3.sh corrupt`) + unit / widget tests with named negative runs
  * Owner Role: Frontend/Mobile Developer (delivery evidence), then QA
  * Prerequisite / External Decision: F08-FE13
  * Re-evaluation Trigger: F08-FE13 delivery; F08-QA-FUNCTIONAL
  * Blocks: F08 functional acceptance
  * Result: PENDING
  * Delivery Evidence: complete 2026-09-29: runtime LE-01 / LE-01c / LE-01d + automated tests + N-CLASS / N-LOOP / N-RETRY / N-QUAR (frontend.md → F08-LOCAL-EVIDENCE)

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

Run Tech Lead — checkpoint on F08-BE6 (backend.md → "F08-BE6"): reconcile the fixture fix and the emulator suite (31 / 31, N-OVERWRITE), resolve §14.1 (the setup-manifest command needs Java 21 on PATH) and §14.2 (the existing CI emulator step and Java 21), then activate F08-QA-FUNCTIONAL under plan A7. F08.OFFLINE-JOURNEY still waits for the user's run of `evidence/offline-journey.sh`. The release stage stays blocked (F08.DEPLOY-AUTHORIZATION OPEN); no deployment or billing action.

## Last Decision

2026-09-29 — Tech Lead checkpoint on F08-FE13 + F08-LOCAL-EVIDENCE (commit beb7bfe, `app/` tree `9de12e6a…`). Full record: architecture → Activation 2026-09-29 → A6 (rulings) and A7 (QA plan).

* **Accepted:**
  * F08-FE13 and F08-LOCAL-EVIDENCE — task coverage A1–A4, contract preserved, Visual Scope `none` held;
  * the migration `transaction` fix, which restores the locked "no partial apply" row (N-TXN catches its removal);
  * quarantining `-journal`;
  * the named emulator app and skipping App Check in emulator mode (debug only);
  * the debug kill switch, as test tooling — it proves the `drain()` no-op, not the Remote Config wiring (F07);
  * the identity note: `firebaseUid` survives a recreate, which is consistent with first-run-authoritative.
* **Tech Lead re-run:** the recovery, storage-full and store-error tests — 29 / 29, exit 0. This is not a QA claim.
* **Routed:**
  * the backend fixture defect (the suite is 30 / 31; the handler is correct) → F08-BE6, before QA;
  * Java 21 → setup-manifest's canonical command, plus a note for the F08-DEVOPS CI job.
* **Locked:** the F08-QA-FUNCTIONAL plan:
  * modules core, backend-security, client-ui, stateful-flow;
  * regression depth full;
  * evidence reuse invalidated for the app side.
* **Delivery Review** stays Pending until F08-BE6 is reconciled.

The pre-checkpoint orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.

## Last Update

* Updated By: Backend Developer
* Timestamp: 2026-09-29
* Summary: F08-BE6 Done (backend.md) — the fixture is valid, the emulator suite is 31 / 31 and N-OVERWRITE is caught; Delivery Review Pending; owner → Tech Lead.

## Context & Follow-ups

F08 implementation/runbook and the F08-FE12 fix are retained. Exact old tasks and checks remain in the archive. Pending scenarios derive from qa.md Pending Validation Scenarios and the boot follow-up, not newly discovered implementation defects. F07 still depends on the required F08 proof. F07.OFFLINE-DAILY (real Daily screens/producer) is explicitly retained in workflow-follow-ups.md under F07, not in F08's required closure ledger: the existing architecture accepts F08's isolated/fake-producer surface and assigns the consumer to F07. This avoids a circular F08-final → F07 → F08 dependency without waiving F07 evidence.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.
* [Orchestration before the activation of 2026-09-29](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md).

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-26 — Tech Lead: queue reordered (incident "the app still shows the old design"): F05 → design adoption → F08 local evidence. No scope, evidence or release change.
* 2026-09-29 — Tech Lead (at the F05 D3 closure): Phase D complete; F08 active again; activation by the next Tech Lead turn (new reusable inputs listed in Next Action). No scope, evidence or release change.
* 2026-09-29 — Tech Lead: F08 activation.
  * **Found:** the unreadable-DB dead end (Resilience row / AC8 not implemented).
  * **Decided:** architecture Activation A1–A5 — recovery rules, Retry reconnect, debug emulator wiring, the evidence plan, Visual Scope `none`.
  * **Next:** F08-FE13 Open; owner → Frontend/Mobile Developer.
* 2026-09-29 — Frontend/Mobile Developer: F08-FE13 + F08-LOCAL-EVIDENCE Done (frontend.md). Found + fixed: `onUpgrade` ran without a transaction (partial apply). Needs the Tech Lead: that fix, a backend test-data defect (emulator suite 30/31), JDK 21. Owner → Tech Lead.
* 2026-09-29 — Tech Lead: FE13 checkpoint.
  * **Accepted:** FE13 + LOCAL-EVIDENCE and the migration transaction fix (A6).
  * **Opened:** F08-BE6 (a backend fixture defect).
  * **Locked:** the QA plan (A7).
  * **Recorded:** Java 21 in setup-manifest.
  * **Next:** owner → Backend Developer.
* 2026-09-29 — Backend Developer: F08-BE6 Done (backend.md). Test code only; suite 31 / 31 on Java 21; N-OVERWRITE caught. Needs the Tech Lead: the setup-manifest command (Java 21 on PATH), the existing CI emulator step (Java 21). Owner → Tech Lead.


## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**F08-BE6 — the emulator suite's contract-invalid fixture** (contract: architecture → "Firebase Sync Surface" (locked) → Server-side validation; Activation 2026-09-29 → A6 ruling 6)

**Symptom:**
* `infra/functions` `npm run test:emulator` is 30 / 31 (LE-03, `evidence/runtime/LE-03-emulator-suite.log.txt`).
* The failing test is `test/submitDailyResult.test.ts` → "ALREADY_SUBMITTED on a repeat — first run stays authoritative". Its second call sends `moves: 8` on top of the base payload's `optimalMoves: 9`.
* `src/validate.ts` requires `moves >= optimalMoves`, so the handler rightly returns `INVALID_PAYLOAD`. The test never reaches the idempotency branch it names.
* The handler is correct; the fixture is wrong.

**Scope (test code only):**
1. Make the second call a valid "better" replay. For example: `moves` between 9 and 13, `stars: 3`, a shorter `durationMs`. Keep every assertion:
   * `ALREADY_SUBMITTED`;
   * the same `recordedAt`;
   * the stored doc unchanged (`moves: 14, stars: 2`).
2. Scan the rest of `infra/functions/test/` for another fixture that passes or fails for a reason other than the one its name states. Fix it only if it is the same kind of test-data defect; report anything else as Needs Tech Lead Clarification.
3. **Named negative run (N-OVERWRITE):**
   * temporarily make the handler overwrite an existing entry (e.g. `set` instead of the create-only path);
   * show that the fixed test fails;
   * restore the handler byte for byte and record the SHA before and after.
4. **Suite:** `cd infra/functions && npm ci && npm run build && JAVA_HOME=/opt/homebrew/opt/openjdk@21 npm run test:emulator` (setup-manifest → Canonical Verification Commands; project `demo-looplet`). Record the counts, the exit code and the log under `evidence/runtime/`. Also record `npm test`, if the package runs a non-emulator suite.

**Non-goals:**
* no change to `src/` (handler, validation, rules), `firestore.rules`, `firebase.json` or the callable contract;
* no app code;
* no real Firebase project, deploy, billing or Remote Config change.

**Evidence:** append a section "F08-BE6" to `backend.md` (do not rewrite BE1–BE5). It needs:
* task-to-code traceability;
* the fixture before / after;
* the N-OVERWRITE table;
* the evidence record per `prompt-evidence-integrity-standard.md` §1: command, target, counts, exit code, revision, time, isolation.

Add the delivery evidence to the F08.EMULATOR record as a note. It is QA-owned, so do not mark it PASS.

**Exit:**
* F08-BE6 Done;
* the suite green on Java 21;
* the negative run caught;
* Delivery Review = Pending → the Tech Lead checkpoint, which activates F08-QA-FUNCTIONAL (A7).

## Earlier briefs

* The F08-FE13 → F08-LOCAL-EVIDENCE brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.
* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
