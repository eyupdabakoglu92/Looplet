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
- [x] Task ID: F08-QA-FUNCTIONAL-R2 | Assigned Role: QA | Status: Done | Summary: DONE 2026-09-29 — verdict **Functional Approved** (qa.md § F08-QA-FUNCTIONAL-R2; HEAD e55176f, `app/` 9de12e6a…). AC2 / J8 PASS: the user's offline run validated at store level (levels 1–2 completed and 3 opened offline, timestamps inside the offline window; offline cold relaunch → Home 2 / 30); all 30 levels open through the production path (QA probe + control), installed bundle byte-identical; define-less build confirmed. F08.OFFLINE-JOURNEY → PASS. Evidence: qa/functional-r2/. Plan: Targeted functional re-run for F08.OFFLINE-JOURNEY (AC2 / J8) only, on the user's real no-network run of 2026-09-29 14:07:49–14:09:45Z (`evidence/runtime/offline/`), under the plan of architecture A11 ruling 4 as corrected at A12 ruling 4 (core, backend-security, client-ui, stateful-flow; targeted; reuse allowed by the R1 fingerprints). Activated at the intake A12. Brief: Current Brief | Depends On: F08-QA-FUNCTIONAL-R1
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Resume release readiness only after explicit billing/target approval; retain runbook and remaining smoke; the existing CI emulator step (F08-BE5) must run on Java 21 and show a real green run (CI-EMULATOR-JAVA21; architecture A8 ruling 3); update the rules rollback check to "a direct client create is denied; the callable creates" (A9 ruling 6) | Depends On: F08-QA-FUNCTIONAL-R2
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

* None open for a delivery role — F08-QA-FUNCTIONAL-R2 returned Functional Approved (qa.md). F08-DEVOPS stays Blocked on F08.DEPLOY-AUTHORIZATION.

## Handoff Plan

None

## Delivery Review

Accepted

## QA Scope

end-to-end

## QA Modules

core, backend-security, client-ui, stateful-flow

## Regression Depth

targeted

## Evidence Reuse

allowed

## QA Stage

functional

## QA Result

Functional Approved

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
  * Prerequisite / External Decision: a real no-network runtime (the user turns the Mac's network off or runs a developer-provided script; or a physical device in airplane mode) — Claude may not change system settings; not replaced by simulated offline (architecture Activation A4). The simulator needs a debug build without the emulator define first (Current Brief, step 1)
  * Re-evaluation Trigger: Evidence captured or existing evidence reviewed against the current scope
  * Blocks: F08/F05 functional acceptance
  * Result: PASS
  * Delivery Evidence: Not run 2026-09-29: user runtime needed; `evidence/offline-journey.sh` prepared for the user.
  * QA 2026-09-29: not run — needs the user's no-network run (`evidence/offline-journey.sh`); simulated offline does not replace it.
  * QA 2026-09-29 (F08-QA-FUNCTIONAL-R1): still not run — no `evidence/runtime/offline/` output. The simulator currently has the emulator-define debug build; install a define-less debug build before the run.
  * Tech Lead 2026-09-29 (A11 ruling 4): the only open functional scenario; F08 Blocked on it. Re-evaluated by F08-QA-FUNCTIONAL-R2 once the user's run output exists.
  * User run 2026-09-29 14:07:49–14:09:45Z (`evidence/runtime/offline/01…06`): Wi-Fi off and the host offline at the start and at the offline relaunch. Before: level 1 unlocked, none completed. Played offline: `journey-tr-01` (best 3 moves, 2★) and `journey-tr-02` (2 moves, 3★); after: highest unlocked 3, completed 1,2. Offline relaunch → Home "YOLCULUK · 2 / 30", Seviye 3. Input for QA, not a PASS.
  * Tech Lead 2026-09-29 (intake A12): the output is complete and is a valid offline run. Build check: the installed app = the build of 14:05:34Z, its `DART_DEFINES` carry no emulator define, and the store's `firebase_uid` is set (the emulators were down). F08-QA-FUNCTIONAL-R2 activated.
  * QA 2026-09-29 (F08-QA-FUNCTIONAL-R2): PASS. The user's run validated independently — offline at 14:07:49Z / 14:09:45Z; a define-less build (QO-06); the live store shows levels 1–2 first-completed at 14:08:24Z / 14:08:56Z and level 3's session started at 14:09:09Z, after the offline cold relaunch (QO-01); Home 2 / 30 after that relaunch (`05`). "All levels load": all 30 open through the production level-open path, which uses no network (QO-03, control QO-04, QO-07); the installed bundle is byte-identical (QO-02). Levels 4–30 were not opened at the offline runtime (qa.md N1-R2).

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

Run Tech Lead — reconcile F08-QA-FUNCTIONAL-R2 (Functional Approved; qa.md § F08-QA-FUNCTIONAL-R2): every functional record PASS; the release stage waits on F08.DEPLOY-AUTHORIZATION.

## Last Decision

2026-09-29 — Tech Lead intake of the user's no-network run (`Incident:` — a status report, not a defect). Full record: architecture → Activation 2026-09-29 → A12.

* **Classified:** Insufficient Evidence (no defect; the report completes A11's prerequisite). **Workflow Impact:** Continue Current Flow.
* **Checked:** all six outputs present; offline confirmed at the start and at the relaunch; a define-less build installed; fingerprints of A11 hold (`app/` `9de12e6a…`, rules / handler / validator / callable test unchanged).
* **Deviations noted for QA:** the Wi-Fi was also switched off by hand before the script; two levels were played, not one.
* **Activated:** F08-QA-FUNCTIONAL-R2 under A11 ruling 4, corrected: `backend-security` added (the scope is end-to-end; the QA preflight requires it), its evidence reused from R1 by fingerprint. QA Result None; Blockers None.

The pre-intake orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-offline-run-intake.md.

## Last Update

* Updated By: QA
* Timestamp: 2026-09-29
* Summary: F08-QA-FUNCTIONAL-R2 Done — verdict Functional Approved; F08.OFFLINE-JOURNEY PASS (user's offline run validated at store level; all 30 levels open through the production path); owner → Tech Lead.

## Context & Follow-ups

F08 implementation/runbook and the F08-FE12 fix are retained. Exact old tasks and checks remain in the archive. Pending scenarios derive from qa.md Pending Validation Scenarios and the boot follow-up, not newly discovered implementation defects. F07 still depends on the required F08 proof. F07.OFFLINE-DAILY (real Daily screens/producer) is explicitly retained in workflow-follow-ups.md under F07, not in F08's required closure ledger: the existing architecture accepts F08's isolated/fake-producer surface and assigns the consumer to F07. This avoids a circular F08-final → F07 → F08 dependency without waiving F07 evidence.

## History & Evidence References

* [Original orchestration](../../history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md) — historical only, not a run queue.
* [QA report](qa.md) and [contract](architecture.md) — retained unchanged.
* [Portfolio follow-ups](../../workflow-follow-ups.md) and [migration record](../../history/core-sync-2026-09-18/README.md).
* Canonical execution: role-execution-contract.md; historical next-command text does not authorize execution.
* [Orchestration before the activation of 2026-09-29](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md).
* [Orchestration before the QA R1 checkpoint](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-r1-checkpoint.md) — incl. the F08-QA-FUNCTIONAL-R1 brief.
* [Orchestration before the offline-run intake](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-offline-run-intake.md) — incl. the user's run steps (A11).

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
* 2026-09-29 — Tech Lead: checkpoint on the F08-QA-FUNCTIONAL-R1 verdict (A11).
  * **Closed:** F1; F08.EMULATOR PASS.
  * **Clarified:** the Backoff line (N1-R1; no code change).
  * **Added:** F08-QA-FUNCTIONAL-R2 (Blocked on the user's no-network run); F08-DEVOPS now depends on it.
  * **Next:** Status → Blocked; owner Tech Lead; the user runs AC2.
* 2026-09-29 — Tech Lead: intake of the user's no-network run (A12).
  * **Checked:** a valid offline run (outputs 01–06; define-less build).
  * **Activated:** F08-QA-FUNCTIONAL-R2; Status → In QA.
  * **Next:** owner → QA.
* 2026-09-29 — QA: F08-QA-FUNCTIONAL-R2 Done — **Functional Approved** (qa.md). AC2 / J8 PASS: the user's offline run validated at store level; all 30 levels open through the production path (probe + control). F08.OFFLINE-JOURNEY → PASS; every functional record PASS. Owner → Tech Lead.

## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**F08-QA-FUNCTIONAL-R2 — AC2 / J8 on the user's no-network run** (plan: architecture → A11 ruling 4, corrected and activated at A12; stage functional; scope end-to-end; modules core, backend-security, client-ui, stateful-flow; regression depth targeted; evidence reuse allowed by the R1 fingerprints)

**`backend-security`** is selected because the scope is end-to-end (A12 ruling 4). The backend is unchanged since R1. Reuse R1's backend evidence — QB-R1-01…07, QE-R1-00 and QE-R1-A — by fingerprint for the module's build/test prerequisite and its compliance tables. Re-run it only if a backend fingerprint differs.

**What is under test:** F08.OFFLINE-JOURNEY — the Journey plays and persists with no network, and a cold relaunch while still offline shows the progress. Nothing else changed since R1: `app/` tree `9de12e6a…`; rules `aa4c5dc2…`, handler `bcda2662…`, `validate.ts` `8f0398ea…`, callable test `cf73770d…`. Record what you actually test. If any differs, say so and re-run what depends on it.

**Input — the user's run, 2026-09-29 14:07:49–14:09:45Z** (`evidence/runtime/offline/`; the user's evidence, not a QA PASS):
* `01-offline-check.txt` — Wi-Fi `en0` off; `curl` failed ("offline confirmed");
* `02-store-before.txt` — highest unlocked 1, nothing completed;
* `03-result.png` — the result of `journey-tr-02` (2 moves, 3★);
* `04-store-after.txt` — highest unlocked 3, completed 1,2; bests `journey-tr-01` 3 / 2★, `journey-tr-02` 2 / 3★;
* `05-relaunch-offline-home.png` — after an offline kill + cold relaunch: Home "YOLCULUK · 2 / 30", Seviye 3;
* `06-still-offline.txt` — still offline at the relaunch.
* The simulator's live store is still there (read-only access is fine): `sync_queue` empty, the guest created just before the run.

**Deviations from the steps (the user's report):** the Wi-Fi was switched off by hand before the script (the script then confirmed offline itself); two levels were played instead of one; the app was not quit by hand (the script terminates it before its offline launch). Judge whether any of this affects validity.

**Judge against:** PRD AC2 and architecture "QA Focus → Offline Journey" (airplane mode → all 30 levels load, a level completes, progress + best persist, relaunch still offline → intact).
* "All 30 levels load": only two were played. Decide from the evidence whether the bundled-content path covers it — for example the Journey content source, the existing tests, or a read of the level assets. A decision the evidence cannot support is a pending item, not a PASS.
* Claude cannot turn the network off. If you need another no-network run, name exactly what it must capture. That makes the verdict Runtime Validation Pending.

**Non-goals:** no product, test or rules changes; no network or system-setting change; no deploy.

**Output:** append "F08-QA-FUNCTIONAL-R2" to `qa.md`; update the F08.OFFLINE-JOURNEY record.

**Verdict:**
* Functional Approved — only if AC2 passes and every in-scope record is PASS;
* Runtime Validation Pending — if the run does not suffice and another user run is needed;
* Rejected — with findings.

Then `Run Tech Lead`.

## Earlier briefs

* The user's no-network run steps (A11, 2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-offline-run-intake.md.
* The F08-QA-FUNCTIONAL-R1 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-r1-checkpoint.md.
* The F08-BE7 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be7-checkpoint.md.
* The F08-QA-FUNCTIONAL brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-functional-checkpoint.md.
* The F08-BE6 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be6-checkpoint.md.
* The F08-FE13 → F08-LOCAL-EVIDENCE brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.
* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
