# F08 — offline-persistence-and-sync: Orchestration

## Feature ID

F08

## Current Status

Rework

## Current Owner

Tech Lead

## Next Role

Tech Lead

## Active Task Ledger

- [x] Task ID: F08-FE13 | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: Close the unreadable-DB gap (Resilience row, AC8: classify, quarantine + recreate, `db_reinitialized`, loop guard), make Retry reopen the database connection (F08-RETRY-STORE-CONNECTION), add the debug-only emulator wiring and fake-producer trigger, and the storage-full fault-injection harness (architecture Activation A1–A4). Brief: Current Brief | Depends On: -
- [x] Task ID: F08-LOCAL-EVIDENCE | Assigned Role: Frontend/Mobile Developer | Status: Done | Summary: On the F08-FE13 build, capture the local evidence of architecture Activation A4 — resume fidelity incl. restart / thaw / tamper; exactly-once and lifecycle against the Firebase emulator; the emulator rules / callable suite; storage-full; the unreadable-DB runtime; the production-shaped cold boot; offline Journey only on a real no-network runtime. No deploy; no product-semantics change. Brief: Current Brief | Depends On: F08-FE13
- [x] Task ID: F08-BE6 | Assigned Role: Backend Developer | Status: Done | Summary: Fix the contract-invalid fixture in `infra/functions/test/submitDailyResult.test.ts` "ALREADY_SUBMITTED on a repeat" (`moves` 8 < `optimalMoves` 9), keep its first-run-authoritative assertions, prove them with a named negative run, and re-run the emulator suite green on Java 21 (architecture Activation A6 ruling 6). Test code only. Brief: Current Brief | Depends On: -
- [x] Task ID: F08-QA-FUNCTIONAL | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-29 — verdict **Decision Pending** (qa.md § F08-QA-FUNCTIONAL; functional, end-to-end, HEAD 84430c9, `app/` 9de12e6a…). All in-scope journeys and misuse checks PASS; F1 (rules allow a direct client create that bypasses callable validation — authority conflict in the locked Firebase Sync Surface) needs a Tech Lead decision; F08.OFFLINE-JOURNEY (AC2) PENDING. Evidence: qa/functional/ | Depends On: F08-LOCAL-EVIDENCE, F08-BE6
- [x] Task ID: F08-BE7 | Assigned Role: Backend Developer | Status: Done | Summary: DONE 2026-09-29 (backend.md § F08-BE7): rules `aa4c5dc2…`, rules test `2c7df84a…`; emulator suite 33 / 33; N-DIRECT-CREATE caught (3 / 3 expected fails). QA finding F1 (architecture A9 ruling 1): `infra/firestore.rules` denies all client access to `dailyResults/**` (only the callable writes, Admin SDK); `rules.test.ts` flips "create own entry" to denied and adds the invalid-payload and non-date-bucket direct creates; named negative N-DIRECT-CREATE; emulator suite green on Java 21; `infra/README.md` rules row. Rules + test + docs only. Brief: Current Brief | Depends On: -
- [ ] Task ID: F08-QA-FUNCTIONAL-R1 | Assigned Role: QA | Status: Queued | Summary: Functional re-run after F08-BE7 under the plan locked in architecture A9 ruling 4 — emulator suite + N-OVERWRITE + the BE7 negative, the QA rules probe P1–P6 (P3 / P6 now denied), one client ↔ emulator exactly-once case under the new rules, AC2 if the user has run it; other functional evidence reused by fingerprint | Depends On: F08-BE7
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Resume release readiness only after explicit billing/target approval; retain runbook and remaining smoke; the existing CI emulator step (F08-BE5) must run on Java 21 and show a real green run (CI-EMULATOR-JAVA21; architecture A8 ruling 3); update the rules rollback check to "a direct client create is denied; the callable creates" (A9 ruling 6) | Depends On: F08-QA-FUNCTIONAL-R1
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

* None open for a delivery role — F08-BE7 Done (backend.md); the Tech Lead reconciles it before F08-QA-FUNCTIONAL-R1.

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

allowed

## QA Stage

functional

## QA Result

Decision Pending

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
  * Scenario: Rules/callable create-only, auth isolation and idempotency scenarios; every direct client write to `dailyResults/**` denied, incl. own entry, invalid payload and a non-date bucket (A9)
  * Required Class: repeatable integration
  * Target / Environment: Isolated Firebase emulator project or an identifiable existing CI emulator run
  * Owner Role: QA
  * Prerequisite / External Decision: JDK/emulator tooling — **present 2026-09-29** (OpenJDK 21 keg-only, first on `PATH`; firebase-tools 15.29; the command in setup-manifest.md, project `demo-looplet`); client ↔ emulator runs use the F08-FE13 debug wiring (delivered). No Blaze upgrade/real deploy required
  * Re-evaluation Trigger: F08-BE7 delivery (rules + rules test changed); F08-QA-FUNCTIONAL-R1
  * Blocks: F08 functional acceptance
  * Result: PENDING
  * Delivery Evidence: 2026-09-29 (LE-03, LE-04): suite 30/31 — one backend test sends an invalid payload (frontend.md F08-FE13 §16.1); client ↔ emulator cases A–E. Tooling: firebase-tools 15.29 needs JDK 21 (installed, not linked).
  * Tech Lead 2026-09-29 (A6 ruling 6): the red test is a fixture defect (handler correct) → F08-BE6; the suite must be green before QA. Canonical command with Java 21: setup-manifest.md → Canonical Verification Commands.
  * Delivery Evidence (F08-BE6, 2026-09-29, HEAD b8e37ab + the fixed test): suite **31 / 31**, exit 0 (`evidence/runtime/BE6-02-fixed-suite.log.txt`); N-OVERWRITE caught (`BE6-04-neg.log.txt`). Java 21 must be on PATH, not only `JAVA_HOME` (backend.md F08-BE6 §14.1). QA review pending.
  * Tech Lead 2026-09-29 (A8): BE6 accepted; Tech Lead re-run at c70527a 31 / 31, exit 0 (not a QA claim); setup-manifest command corrected. The CI emulator step has never run (CI-EMULATOR-JAVA21) — not a source for this record.
  * QA 2026-09-29 (F08-QA-FUNCTIONAL): suite 31 / 31 exit 0 (QB-03), N-OVERWRITE caught (QB-04), client ↔ emulator cases A–E + invalid payload → parked (QE-*); create-only, auth isolation and idempotency PASS. Separate finding F1 (direct client create bypasses validation) — qa.md §3.
  * Delivery Evidence (F08-BE7, 2026-09-29, HEAD 8f26243 + the rules change): suite **33 / 33**, exit 0 (`evidence/runtime/BE7-02-fixed-suite.log.txt`); N-DIRECT-CREATE — the old client create rule fails the own-entry, invalid-payload (P3) and non-date-bucket (P6) tests (`BE7-04-neg.log.txt`). Handler / validator / callable test unchanged. QA review pending.
  * Tech Lead 2026-09-29 (A9 ruling 3): **Result reset to PENDING.** F1 is resolved by denying all client access to `dailyResults/**`; F08-BE7 changes `firestore.rules` and `rules.test.ts`, so the rules part of this PASS is at old rules. The callable / idempotency part stays valid while the handler `bcda2662…` and `validate.ts` `8f0398ea…` are unchanged. QA re-runs the suite, the negatives and its rules probe (P3 / P6 must be DENIED) at the BE7 revision in F08-QA-FUNCTIONAL-R1.

- Evidence ID: F08.LOCAL-RESUME
  * Scenario: Kill/relaunch exact restore, undo/restart/thaw state and untrusted cached thaw re-derivation
  * Required Class: runtime
  * Target / Environment: Local device/simulator with real app persistence
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target; no paid backend required
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance; F03/F05 shared persistence
  * Result: PASS
  * Delivery Evidence: 2026-09-29 (LE-02): level 21 moves + restart + undo + thaw, kill / relaunch exact; tampered thaw re-derived.
  * QA 2026-09-29: level 21 restart + moves + undo + thaw → kill → relaunch, byte-identical snapshot and exact screen; tampered thaw re-derived; undo after restore (QJ4).

- Evidence ID: F08.LIFECYCLE
  * Scenario: Session-owned sync survives screen disposal; pause/resume and connectivity regain drain correctly
  * Required Class: runtime
  * Target / Environment: Device/simulator with isolated/emulated backend where applicable
  * Owner Role: QA
  * Prerequisite / External Decision: Runtime target and isolated integration setup, not production billing
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08 functional acceptance
  * Result: PASS
  * Delivery Evidence: 2026-09-29 (LE-05): screen disposed mid-sync, paused / resumed drains; connectivity regain automated only (+ N-REGAIN).
  * QA 2026-09-29: screen dispose mid-sync → doc arrives (QL1); paused and resumed each drain, same process (QL2); connectivity regain automated + N-REGAIN (the simulator cannot toggle it).

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
  * QA 2026-09-29: not run — needs the user's no-network run (`evidence/offline-journey.sh`); simulated offline does not replace it.

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
  * Result: PASS
  * Delivery Evidence: 2026-09-29 (LE-07): FE13 final build, empty + existing store, no light frame.
  * QA 2026-09-29: fresh production-shaped cold boots at `9de12e6a…`, empty (max luma 22.2) and existing store (24.6), no light frame, no init error (QJ7).

- Evidence ID: F08.UNREADABLE-DB
  * Scenario: AC8 / the Resilience row — an unreadable store file (NOTADB / CORRUPT) on launch → quarantine, recreate, `db_reinitialized` log, Home "new", no error loop; a migration failure still → the store-error screen with data intact; a recreate failure → the error screen, no second recreate
  * Required Class: runtime + automated functional
  * Target / Environment: iPhone 16 simulator (debug build; `seed-d3.sh corrupt`) + unit / widget tests with named negative runs
  * Owner Role: Frontend/Mobile Developer (delivery evidence), then QA
  * Prerequisite / External Decision: F08-FE13
  * Re-evaluation Trigger: F08-FE13 delivery; F08-QA-FUNCTIONAL
  * Blocks: F08 functional acceptance
  * Result: PASS
  * Delivery Evidence: complete 2026-09-29: runtime LE-01 / LE-01c / LE-01d + automated tests + N-CLASS / N-LOOP / N-RETRY / N-QUAR (frontend.md → F08-LOCAL-EVIDENCE)
  * QA 2026-09-29: NOTADB → quarantine + recreate + `db_reinitialized`, newest quarantine only (QJ1); CANTOPEN → error → Retry → Home without relaunch (QJ2); migration failure + loop guard automated with N-TXN / N-LOOP / N-CLASS / N-QUAR caught (QA-03).

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

Run Tech Lead — reconcile F08-BE7 (backend.md § F08-BE7; rules `aa4c5dc2…`, rules test `2c7df84a…`; suite 33 / 33; N-DIRECT-CREATE), then activate F08-QA-FUNCTIONAL-R1 under architecture A9 ruling 4 after the QA preflight.

## Last Decision

2026-09-29 — Tech Lead checkpoint on the F08-QA-FUNCTIONAL verdict (QA, commit d882211; Decision Pending). Full record: architecture → Activation 2026-09-29 → A9.

* **Reviewed:** `qa.md` § F08-QA-FUNCTIONAL and `qa/functional/`; the SHA-1s QA tested are still the working tree's.
* **Stage result:** every in-scope journey and misuse check PASS except F1; F08.OFFLINE-JOURNEY (AC2) PENDING.
* **F1 resolved — Technical Decision:** clients get **no access** to `dailyResults/**`; only the callable writes (Admin SDK, which the rules do not apply to). The locked Rules row had kept a client `allow create` that the section's own decision had rejected; the decision wins. Corrected in architecture (Rules, Reconciliation → Server, Validation Responsibility, QA Focus → Rules) and `platform.md` §6 / §8. Rejected alternative: field and bucket checks in the rules. No product criterion changes; the app is untouched.
* **Opened:** F08-BE7 (Backend Developer). **Queued:** F08-QA-FUNCTIONAL-R1 under the plan in A9 ruling 4 (full depth; evidence reuse allowed by fingerprint; the rules scope re-run).
* **Evidence:** F08.EMULATOR back to PENDING (rules part invalidated). Other PASS records kept.
* **Notes:** N1 conforms, no change; N2 → follow-up F08-EVIDENCE-PROXY-ERRORS (Frontend/Mobile Developer, non-blocking); N3 / N4 as A8.
* **Release:** unchanged scope; the F08-DEVOPS rollback check is updated when it resumes (A9 ruling 6). No deploy.

The pre-checkpoint orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-functional-checkpoint.md.

## Last Update

* Updated By: Backend Developer
* Timestamp: 2026-09-29
* Summary: F08-BE7 Done — `firestore.rules` denies every client access to `dailyResults/**`; `rules.test.ts` denies the own-entry, invalid-payload and non-date-bucket direct creates; emulator suite 33 / 33; N-DIRECT-CREATE caught. Delivery Review Pending; owner → Tech Lead.

Previous (Tech Lead): Checkpoint on F08-QA-FUNCTIONAL (Decision Pending). F1 resolved (A9): no client access to `dailyResults/**`. Status Rework; F08-BE7 Open; F08-QA-FUNCTIONAL-R1 Queued; F08.EMULATOR PENDING; Delivery Review Pending; owner → Backend Developer.

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
* 2026-09-29 — Tech Lead: BE6 checkpoint (A8).
  * **Accepted:** F08-BE6; Delivery Review Accepted.
  * **Corrected:** the Java 21 command (setup-manifest); A6 ruling 5's CI premise → CI-EMULATOR-JAVA21 (DevOps/Release Engineer, non-blocking).
  * **Activated:** F08-QA-FUNCTIONAL (A7).
  * **Next:** owner → QA.
* 2026-09-29 — QA: F08-QA-FUNCTIONAL Done — **Decision Pending** (qa.md). PASS: F08.EMULATOR, LOCAL-RESUME, LIFECYCLE, COLD-BOOT-REVIEW, UNREADABLE-DB; PENDING: OFFLINE-JOURNEY. F1: the rules allow a direct client create that bypasses validation (authority conflict). Owner → Tech Lead.
* 2026-09-29 — Tech Lead: checkpoint on the F08-QA-FUNCTIONAL verdict (A9).
  * **Decided:** F1 — no client access to `dailyResults/**`; architecture + `platform.md` corrected.
  * **Opened:** F08-BE7; **Queued:** F08-QA-FUNCTIONAL-R1 (plan A9 ruling 4).
  * **Reset:** F08.EMULATOR → PENDING; Delivery Review → Pending; Status → Rework.
  * **Next:** owner → Backend Developer.
* 2026-09-29 — Backend Developer: F08-BE7 Done (backend.md). Rules + rules test + `infra/README.md` only; suite 33 / 33 on Java 21; N-DIRECT-CREATE caught; handler / validator / callable test unchanged. Owner → Tech Lead.


## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**F08-BE7 — no client access to `dailyResults/**`** (QA finding F1; ruling: architecture → Activation 2026-09-29 → A9 ruling 1; the corrected "Firebase Sync Surface → Rules" row)

**Why:** QA's rules probe showed that any signed-in client can create its own `dailyResults/{bucket}/entries/{uid}` directly, skipping the callable's validation (P3: `moves 1 < optimalMoves 9`, `stars 9`, an extra field → allowed), and under any bucket name (P6: `zz_not-a-date-123` → allowed). The callable writes through the Admin SDK, which rules do not apply to, and the app never writes Firestore directly. So the client rule is only a bypass.

**Starting point** (check it; say so if it differs):
* `infra/firestore.rules` `b75628e6…`;
* `infra/functions/test/rules.test.ts` `9d4db0bb…`;
* the handler `bcda2662…`, `validate.ts` `8f0398ea…`, `submitDailyResult.test.ts` `cf73770d…` — these must **not** change.

**Scope:**
1. `infra/firestore.rules` — `dailyResults/{bucket}/entries/{uid}`: no client create, update, delete or read. Keep an explicit match block with a comment saying that only `submitDailyResultV1` writes, through the Admin SDK, and that create-only / first-writer-wins lives in the callable's transaction. Keep the default-deny block. Rewrite the header comment, which now says the signed-in user may create.
2. `infra/functions/test/rules.test.ts`:
   * "lets a signed-in user create their own entry" becomes a denial (`assertFails`) of that same valid document;
   * add a denied direct create of the user's own entry with an invalid payload (the P3 shape);
   * add a denied direct create in a non-date bucket (the P6 shape);
   * keep create-other, unauthenticated, update, delete and read denied;
   * update the file comment ("create-only") to match.
3. **Named negative N-DIRECT-CREATE:** put the old rule (`allow create: if request.auth != null && request.auth.uid == uid;`) back temporarily and run the rules suite. The own-entry, invalid-payload and bucket tests must fail. Restore the file byte for byte and check the SHA-1s. Keep the script and log under `evidence/` next to `neg-be6.py`.
4. The full emulator suite with the setup-manifest command (`JAVA_HOME=/opt/homebrew/opt/openjdk@21 PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm run test:emulator`) must be green. The callable tests must still pass unchanged: that shows the server path still writes under the new rules. Also run `npm run build` and `npm test`.
5. `infra/README.md` — the `firestore.rules` row now says "`dailyResults/**`: no client access; only the callable writes (Admin SDK); default-deny elsewhere".

**Non-goals:**
* no change to the handler, the validator, the callable tests, the app or CI (CI-EMULATOR-JAVA21 stays with DevOps/Release Engineer);
* no deploy, no rules dry-run against the real project, no billing or Remote Config change;
* no edit to the feature `release.md` (the rollback check is updated by DevOps/Release Engineer at F08-DEVOPS, A9 ruling 6).

**Output:** `backend.md` → "F08-BE7": what changed and why; the SHA-1s before and after; the suite counts and exit codes with the time and revision; the N-DIRECT-CREATE result; the unchanged handler / validator / callable-test SHA-1s. Evidence per `prompt-evidence-integrity-standard.md`. Set Delivery Review Pending and hand back to the Tech Lead (no Handoff Plan: the checkpoint before QA is mandatory).

## Earlier briefs

* The F08-QA-FUNCTIONAL brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-functional-checkpoint.md.
* The F08-BE6 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be6-checkpoint.md.
* The F08-FE13 → F08-LOCAL-EVIDENCE brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.
* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
