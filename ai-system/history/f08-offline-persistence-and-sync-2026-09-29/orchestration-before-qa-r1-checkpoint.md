# F08 — offline-persistence-and-sync: Orchestration

## Feature ID

F08

## Current Status

In QA

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
- [x] Task ID: F08-QA-FUNCTIONAL-R1 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-29 — verdict **Runtime Validation Pending** (qa.md § F08-QA-FUNCTIONAL-R1; HEAD 695f783, rules `aa4c5dc2…`, `app/` 9de12e6a…). F1 closed: QA probe P3 / P6 DENIED, emulator suite 33 / 33, N-OVERWRITE + N-DIRECT-CREATE caught, client ↔ emulator exactly-once PASS under the new rules; F08.OFFLINE-JOURNEY (AC2) PENDING. Evidence: qa/functional-r1/. Plan: Functional re-run after F08-BE7 under the plan locked in architecture A9 ruling 4 — emulator suite + N-OVERWRITE + the BE7 negative, the QA rules probe P1–P6 (P3 / P6 now denied), one client ↔ emulator exactly-once case under the new rules, AC2 if the user has run it; other functional evidence reused by fingerprint | Depends On: F08-BE7
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Resume release readiness only after explicit billing/target approval; retain runbook and remaining smoke; the existing CI emulator step (F08-BE5) must run on Java 21 and show a real green run (CI-EMULATOR-JAVA21; architecture A8 ruling 3); update the rules rollback check to "a direct client create is denied; the callable creates" (A9 ruling 6) | Depends On: F08-QA-FUNCTIONAL-R1
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

* None open for a delivery role — F08-QA-FUNCTIONAL-R1 returned Runtime Validation Pending (qa.md); only F08.OFFLINE-JOURNEY (AC2) waits for the user's no-network run.

## Handoff Plan

None

## Delivery Review

Accepted

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
  * Scenario: Rules/callable create-only, auth isolation and idempotency scenarios; every direct client write to `dailyResults/**` denied, incl. own entry, invalid payload and a non-date bucket (A9)
  * Required Class: repeatable integration
  * Target / Environment: Isolated Firebase emulator project or an identifiable existing CI emulator run
  * Owner Role: QA
  * Prerequisite / External Decision: JDK/emulator tooling — **present 2026-09-29** (OpenJDK 21 keg-only, first on `PATH`; firebase-tools 15.29; the command in setup-manifest.md, project `demo-looplet`); client ↔ emulator runs use the F08-FE13 debug wiring (delivered). No Blaze upgrade/real deploy required
  * Re-evaluation Trigger: F08-BE7 delivery (rules + rules test changed); F08-QA-FUNCTIONAL-R1
  * Blocks: F08 functional acceptance
  * Result: PASS
  * Delivery Evidence: 2026-09-29 (LE-03, LE-04): suite 30/31 — one backend test sends an invalid payload (frontend.md F08-FE13 §16.1); client ↔ emulator cases A–E. Tooling: firebase-tools 15.29 needs JDK 21 (installed, not linked).
  * Tech Lead 2026-09-29 (A6 ruling 6): the red test is a fixture defect (handler correct) → F08-BE6; the suite must be green before QA. Canonical command with Java 21: setup-manifest.md → Canonical Verification Commands.
  * Delivery Evidence (F08-BE6, 2026-09-29, HEAD b8e37ab + the fixed test): suite **31 / 31**, exit 0 (`evidence/runtime/BE6-02-fixed-suite.log.txt`); N-OVERWRITE caught (`BE6-04-neg.log.txt`). Java 21 must be on PATH, not only `JAVA_HOME` (backend.md F08-BE6 §14.1). QA review pending.
  * Tech Lead 2026-09-29 (A8): BE6 accepted; Tech Lead re-run at c70527a 31 / 31, exit 0 (not a QA claim); setup-manifest command corrected. The CI emulator step has never run (CI-EMULATOR-JAVA21) — not a source for this record.
  * QA 2026-09-29 (F08-QA-FUNCTIONAL): suite 31 / 31 exit 0 (QB-03), N-OVERWRITE caught (QB-04), client ↔ emulator cases A–E + invalid payload → parked (QE-*); create-only, auth isolation and idempotency PASS. Separate finding F1 (direct client create bypasses validation) — qa.md §3.
  * Delivery Evidence (F08-BE7, 2026-09-29, HEAD 8f26243 + the rules change): suite **33 / 33**, exit 0 (`evidence/runtime/BE7-02-fixed-suite.log.txt`); N-DIRECT-CREATE — the old client create rule fails the own-entry, invalid-payload (P3) and non-date-bucket (P6) tests (`BE7-04-neg.log.txt`). Handler / validator / callable test unchanged. QA review pending.
  * Tech Lead 2026-09-29 (A9 ruling 3): **Result reset to PENDING.** F1 is resolved by denying all client access to `dailyResults/**`; F08-BE7 changes `firestore.rules` and `rules.test.ts`, so the rules part of this PASS is at old rules. The callable / idempotency part stays valid while the handler `bcda2662…` and `validate.ts` `8f0398ea…` are unchanged. QA re-runs the suite, the negatives and its rules probe (P3 / P6 must be DENIED) at the BE7 revision in F08-QA-FUNCTIONAL-R1.
  * QA 2026-09-29 (F08-QA-FUNCTIONAL-R1, HEAD 695f783, rules `aa4c5dc2…`): suite **33 / 33** exit 0 (QB-R1-03); N-OVERWRITE and N-DIRECT-CREATE caught (QB-R1-04 / 05); QA rules probe P1–P8 8 / 8 — **P3 and P6 DENIED**, no doc written (QB-R1-06), and the same probe fails exactly P3 / P6 on the old rules (QB-R1-07); direct REST create on the running emulator → 403 (QE-R1-00); client ↔ emulator QE-A shape under the new rules → `CREATED`, 1 doc, `synced` (QE-R1-A). F1 closed.

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
  * QA 2026-09-29 (F08-QA-FUNCTIONAL-R1): still not run — no `evidence/runtime/offline/` output. The simulator currently has the emulator-define debug build; install a define-less debug build before the run.

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

Run Tech Lead — reconcile F08-QA-FUNCTIONAL-R1 (Runtime Validation Pending; qa.md § F08-QA-FUNCTIONAL-R1): F1 closed, F08.EMULATOR PASS; only F08.OFFLINE-JOURNEY (AC2) is PENDING on the user's no-network run (`evidence/offline-journey.sh <udid>`). Non-blocking note N1-R1 (first backoff ≈ 60 s vs "base 30 s").

## Last Decision

2026-09-29 — Tech Lead checkpoint on F08-BE7 (commit cb96719). Full record: architecture → Activation 2026-09-29 → A10.

* **Accepted:** F08-BE7. `firestore.rules` `aa4c5dc2…` denies every client access to `dailyResults/**`; `rules.test.ts` `2c7df84a…` denies the own-entry, invalid-payload (P3) and non-date-bucket (P6) direct creates.
* **Tech Lead re-run** at cb96719 (not a QA claim): emulator suite 33 / 33, exit 0; N-DIRECT-CREATE — exactly the three new tests fail with the old rule back.
* **Unchanged:** handler `bcda2662…`, `validate.ts` `8f0398ea…`, `submitDailyResult.test.ts` `cf73770d…`, `app/` `9de12e6a…` — the A9 reuse fingerprints hold.
* **Delivery Review: Accepted** (FE13, LOCAL-EVIDENCE, BE6, BE7).
* **Activated:** F08-QA-FUNCTIONAL-R1 under A9 ruling 4; QA preflight PASS; QA Result reset to None.
* F1 stays open until QA's own probe shows P3 / P6 denied.

The pre-checkpoint orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be7-checkpoint.md.

## Last Update

* Updated By: QA
* Timestamp: 2026-09-29
* Summary: F08-QA-FUNCTIONAL-R1 Done — verdict Runtime Validation Pending; F1 closed (P3 / P6 DENIED); F08.EMULATOR PASS; F08.OFFLINE-JOURNEY PENDING; owner → Tech Lead.

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
* 2026-09-29 — Tech Lead: BE7 checkpoint (A10).
  * **Accepted:** F08-BE7; Delivery Review Accepted.
  * **Re-ran:** the suite (33 / 33) and N-DIRECT-CREATE at cb96719 — not a QA claim.
  * **Activated:** F08-QA-FUNCTIONAL-R1 (A9 ruling 4).
  * **Next:** owner → QA.
* 2026-09-29 — QA: F08-QA-FUNCTIONAL-R1 Done — **Runtime Validation Pending** (qa.md). F1 closed (rules probe P3 / P6 DENIED; suite 33 / 33; both negatives caught; client ↔ emulator exactly-once under the new rules). F08.EMULATOR → PASS; F08.OFFLINE-JOURNEY PENDING. Other functional evidence reused by fingerprint. Owner → Tech Lead.


## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**F08-QA-FUNCTIONAL-R1 — the functional re-run after F08-BE7** (plan: architecture → Activation 2026-09-29 → A9 ruling 4, activated at A10; stage functional; scope end-to-end; modules core, backend-security, client-ui, stateful-flow; regression depth full; evidence reuse allowed by fingerprint)

**What is under test:**
* `infra/` at cb96719 — `firestore.rules` `aa4c5dc2…`, `rules.test.ts` `2c7df84a…`; unchanged: the handler `bcda2662…`, `validate.ts` `8f0398ea…`, `submitDailyResult.test.ts` `cf73770d…`;
* the app at `app/` tree `9de12e6a…` (unchanged since beb7bfe).

Record the SHA-1s / tree you actually test. If any differs from these, say so and re-run what depends on it instead of reusing.

**Why:** your F08-QA-FUNCTIONAL verdict (Decision Pending) found F1 — a signed-in client could create its own `dailyResults` entry directly, skipping the callable's validation, and under any bucket name. The Tech Lead ruled that clients get no access to `dailyResults/**` (A9 ruling 1); F08-BE7 implemented it and was accepted (A10). Your earlier F08-QA-FUNCTIONAL results stay valid where their fingerprints are unchanged.

**Inputs:**
* `qa.md` § F08-QA-FUNCTIONAL (your previous verdict and evidence in `qa/functional/`);
* `architecture.md` — the corrected Rules / Reconciliation / Validation / QA Focus rows, A9, A10;
* `backend.md` → F08-BE7 and `evidence/README.md` → F08-BE7. Delivery evidence is input, not proof.

**Scope — run yourself:**
1. The emulator suite with the setup-manifest command (`JAVA_HOME=/opt/homebrew/opt/openjdk@21 PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm run test:emulator`).
2. The negatives N-OVERWRITE (`evidence/neg-be6.py`) and N-DIRECT-CREATE (`evidence/neg-be7.py`). Both scripts rewrite the delivery logs `runtime/BE6-04-neg.log.txt` / `runtime/BE7-04-neg.log.txt`; keep your own copy under `qa/` and restore the delivery logs from git.
3. Your own rules probe P1–P6 (`qa/functional/qa-probe-rules.test.ts`) against the new rules. **P3 and P6 must be DENIED**; P1, P2, P4, P5 stay denied. This is the check that closes F1.
4. One client ↔ emulator exactly-once case (QE-A shape: functions proxy `down` → pending, then `pass` → exactly one doc), with the new rules loaded in the emulator. It shows that the callable still writes and the app still syncs.
5. F08.OFFLINE-JOURNEY (AC2 / J8) — only if the user has run `evidence/offline-journey.sh` by then. Otherwise it stays PENDING with that prerequisite.

**Evidence reuse (allowed):** the other F08-QA-FUNCTIONAL results (QJ1, QJ2, QJ4, QJ7, QE-B…E / M, QL1, QL2, QR, QA-01…05, QB-01…02) may be reused if the app tree and the three unchanged backend SHA-1s still match. State each reuse and its fingerprint.

**Pending Evidence to record:** F08.EMULATOR (PENDING → your result) and F08.OFFLINE-JOURNEY. The PASS records F08.LOCAL-RESUME, F08.LIFECYCLE, F08.STORAGE, F08.COLD-BOOT-REVIEW and F08.UNREADABLE-DB stay PASS unless your fingerprint check invalidates them. F08.DEPLOY-SMOKE is release-stage.

**Known limits — not findings:** AC3 and the Remote Config kill-switch wiring are F07; AC10 is automated-only; the profile / release store-error capture is FIRST-APP-DISTRIBUTION; the CI emulator step has never run (CI-EMULATOR-JAVA21); the Jest teardown line (A8 ruling 4); the delivered `evidence/fn-proxy.py` error path (F08-EVIDENCE-PROXY-ERRORS) — use your corrected `qa-fn-proxy.py`.

Report any finding the evidence supports, even one that contradicts a delivery or Tech Lead claim.

**Non-goals:** no product, test or rules changes; no real Firebase write beyond the existing production-shaped anonymous sign-in; no deploy, billing or Remote Config change; no system-setting change.

**Output:** append "F08-QA-FUNCTIONAL-R1" to `qa.md` (do not rewrite earlier sections): the evidence record per `prompt-evidence-integrity-standard.md`, the reuse list with fingerprints, the F1 re-check, a result per Pending Evidence record.

**Verdict:**
* Functional Approved — only if every in-scope record is PASS (incl. AC2);
* Runtime Validation Pending — if only F08.OFFLINE-JOURNEY (AC2) is missing its no-network run;
* Rejected — with findings.

Then `Run Tech Lead`.

## Earlier briefs

* The F08-BE7 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be7-checkpoint.md.
* The F08-QA-FUNCTIONAL brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-functional-checkpoint.md.
* The F08-BE6 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be6-checkpoint.md.
* The F08-FE13 → F08-LOCAL-EVIDENCE brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.
* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
