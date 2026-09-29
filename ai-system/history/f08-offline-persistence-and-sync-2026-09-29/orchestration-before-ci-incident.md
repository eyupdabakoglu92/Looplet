# F08 — offline-persistence-and-sync: Orchestration

## Feature ID

F08

## Current Status

Blocked

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
- [ ] Task ID: F08-DEVOPS-PREP | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Blocked until the release gates allow a DevOps activation (contract §5.3; architecture A13 ruling 2). Local release prep, no deploy / billing / push: (a) Java 21 on PATH for the CI `infra` emulator step, SHA-pinned (CI-EMULATOR-JAVA21), verified locally; (b) refresh the feature `release.md` to the current contract — rules rollback check + smoke S1 → "a direct client create is denied; the callable creates" (A9 ruling 6), the storage-full debt line, gate evidence → the functional QA records; (c) record the release readiness verdict (expected Release Validation Pending with the exact remaining items); (d) read CI run #1 (`36590316947`) in full and fix / route every red step — the `infra` emulator step FAILED, the format check FAILED (CI-FORMAT-GATE); (e) public-repo hygiene — recommend Firebase API key restrictions, note App Check monitor mode (console changes need the user); (f) the Node 20 → 24 / Ubuntu 26 notices (A14). Brief: Current Brief | Depends On: F08-QA-FUNCTIONAL-R2
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: After F08.DEPLOY-AUTHORIZATION: a green CI run of the `infra` job (the emulator step on Java 21), the authorized deploy per the runbook, the post-deploy smoke (F08.DEPLOY-SMOKE) incl. "a direct client create is denied; the callable creates"; the release readiness verdict | Depends On: F08-DEVOPS-PREP
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

* None open. F08-DEVOPS-PREP and F08-DEVOPS (DevOps/Release Engineer) are Blocked on the release-scoped gate F08.DEPLOY-AUTHORIZATION (F08.CI-FIRST-PUSH resolved, A14); F08-QA-FINAL Queued.

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

- Decision ID: F08.CI-FIRST-PUSH
  * Question: May the local `main` (or a branch) be pushed to `origin` (`github.com/eyupdabakoglu92/Looplet`) so that CI runs for the first time? `origin/main` is still the bootstrap commit b1a65a0, so a push publishes the whole working history, `ai-system/` included, to that repository.
  * Options / Trade-offs: (1) push `main` after F08-DEVOPS-PREP — the real CI evidence, the whole history published; (2) push only a branch — CI on that branch, `main` untouched on origin; (3) keep CI local-only for now — the CI evidence stays PENDING and F08 cannot reach Release Ready
  * Recommendation: 1 or 2, if the repository's visibility is what the user intends (A13 ruling 3)
  * Blocks: DevOps activation (F08-DEVOPS-PREP, F08-DEVOPS), final QA and Done (contract §5.3)
  * Blocking Scope: release
  * Status: RESOLVED
  * Resolution: Option (1) — the user pushed `main` (`origin/main` = 8a0522f, verified). The repository is public. CI run #1 (`36590316947`): the `infra` emulator step FAILED (exit 1; cause needs the signed-in log, consistent with CI-EMULATOR-JAVA21); the other jobs were running at the record (architecture A14)
  * Resolved At: 2026-09-29

## Blockers

* The release stage waits on the user's decision F08.DEPLOY-AUTHORIZATION (Open Decision Gates). A release-scoped gate holds every DevOps activation (contract §5.3), including the fix for CI run #1's failing emulator step (A14). F08 has no other executable work. The functional stage is closed (A13).

## Next Action

The user decides `Run Tech Lead. Decision: F08.DEPLOY-AUTHORIZATION — …`. If approved, the Tech Lead activates F08-DEVOPS-PREP (it includes fixing CI run #1). If the deploy stays deferred, F08 stays Blocked and `Run Tech Lead` chooses the next executable feature.

## Last Decision

2026-09-29 — Tech Lead intake of the decision F08.CI-FIRST-PUSH ("Ben push işlemini yaptım"). Full record: architecture → Activation 2026-09-29 → A14.

* **Resolved:** option (1) — the user pushed `main`; verified `origin/main` = 8a0522f. The repository is **public**; no private key or token is tracked, but the Firebase client configs are now world-readable.
* **CI run #1** (`36590316947`): the `infra` emulator step **FAILED** (exit 1). Its log needs a signed-in account, so the cause is unverified; it is consistent with CI-EMULATOR-JAVA21. The suite passes locally on Java 21 (QB-R1-03). The other jobs were still running.
* **F08-DEVOPS-PREP** gains (d) the full first run, (e) public-repo hygiene, (f) the action / runner notices.
* **F08 stays Blocked:** F08.DEPLOY-AUTHORIZATION (release scope) still holds every DevOps activation, the CI fix included.

The pre-intake orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-ci-push-decision.md.

## Last Update

* Updated By: Tech Lead
* Timestamp: 2026-09-29
* Summary: decision F08.CI-FIRST-PUSH resolved (A14) — `main` pushed to the public origin; CI run #1: the `infra` emulator step failed (cause unverified); F08-DEVOPS-PREP extended; F08 stays Blocked on F08.DEPLOY-AUTHORIZATION.

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
* [Orchestration before the functional closure](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-functional-closure.md) — incl. the F08-QA-FUNCTIONAL-R2 brief.
* [Orchestration before the CI-push decision](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-ci-push-decision.md).

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
* 2026-09-29 — Tech Lead: checkpoint on the F08-QA-FUNCTIONAL-R2 verdict (A13).
  * **Accepted:** Functional Approved; the functional stage is closed.
  * **Defined:** F08-DEVOPS-PREP (split from F08-DEVOPS, Blocked); **opened** the gate F08.CI-FIRST-PUSH.
  * **Next:** Status → Blocked (release gates, contract §5.3); owner Tech Lead; the user decides.
* 2026-09-29 — Tech Lead: decision F08.CI-FIRST-PUSH (A14).
  * **Resolved:** the user pushed `main` (public origin).
  * **Recorded:** CI run #1 — the `infra` emulator step failed.
  * **Extended:** F08-DEVOPS-PREP (d)–(f).
  * **Next:** F08 stays Blocked on F08.DEPLOY-AUTHORIZATION.

## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**Waiting on the user — the deploy decision** (architecture → A13, A14). The functional stage is closed (Functional Approved; every functional evidence record PASS). F08.CI-FIRST-PUSH is resolved: `main` is on the public origin, and CI run #1's `infra` emulator step failed (A14). A release-scoped gate holds every DevOps activation (contract §5.3), so the CI fix waits too:
* **F08.DEPLOY-AUTHORIZATION** — enable Blaze / billing on `looplet-712e5` and deploy `submitDailyResultV1`, the rules and Remote Config? Or keep deferring.

Answer with `Run Tech Lead. Decision: F08.DEPLOY-AUTHORIZATION — <karar>`. If approved, the brief below is the first DevOps task.

**F08-DEVOPS-PREP — local release prep, no deploy** (architecture → A13 ruling 2; Release Scope `production-readiness`; Blocked until the gates allow it)

**Inputs:** the feature `release.md` (your 2026-09-06 readiness artifact; out of date since A9); `project-authority/release.md` (§4 CI, §6 rollback, §8 smoke, §10 action pinning); `.github/workflows/ci.yml` (`infra` job); `project-authority/setup-manifest.md` (the Java 21 emulator command); `architecture.md` A8 ruling 3, A9 ruling 6, A13, A14; `qa.md` § F08-QA-FUNCTIONAL-R1 / R2; `workflow-follow-ups.md` → CI-EMULATOR-JAVA21.

**CI run #1** (`36590316947`, head 8a0522f, A14): the `infra` emulator step FAILED ("Process completed with exit code 1"; 57 s job). The log needs a signed-in GitHub account. If you have no `gh` login or browser session from the user, ask the user for the step log. Do not guess the cause. The other jobs were still running at A14.

**Scope:**
1. **CI on Java 21 (CI-EMULATOR-JAVA21).** First confirm the actual cause of the run #1 failure from the log. Make the `infra` job's emulator step run with Java 21 first on `PATH`. firebase-tools 15 needs Java 21+; the `ubuntu-latest` default is probably older (*Needs verification* — say what you find). Pin any new action to a commit SHA (`release.md` §10).
   * Verify what can be verified locally: the workflow file parses, and the step's command passes locally on Java 21 (the setup-manifest command).
   * Do not claim "CI verified" until a pushed run is green (run #1 failed).
2. **Refresh the feature `release.md` to the current contract:**
   * Rollback table "Bad rules shipped" and smoke S1 → "a direct client create is denied (own entry, invalid payload, non-date bucket, another user, unauthenticated); update / delete / read denied; the callable creates" (A9 ruling 6).
   * The storage-full "residual test-debt" line → covered (F08.STORAGE PASS, `storage_full_test.dart`).
   * The gate evidence → the functional QA records (R1 / R2).
   * Re-check the deploy runbook and the smoke list against the current rules and code. Keep them; change only what is out of date, and say what changed.
3. **The rest of run #1 and the runner notices:** read every job. Fix, or route to its owner, each red step. The format gate (CI-FORMAT-GATE) is yours to decide. Also handle the Node 20 → 24 action notice for the pinned `actions/checkout` and the `ubuntu-latest` → Ubuntu 26 migration (2026-10-19). A CI fix is proven only by a real green run after a push. Pushing needs the user's explicit approval in chat for that push.
4. **Public-repository hygiene (A14 ruling 2 (e)):** the repository is public, so the Firebase client configs are world-readable (public by design). Check and recommend Firebase API key restrictions, and note App Check's monitor mode. Console or account changes are the user's to approve or make.
5. **Readiness verdict** in `release.md` and the orchestration `Release Result`. Expected: **Release Validation Pending**, listing exactly what remains — F08.DEPLOY-AUTHORIZATION, a green CI run of the fixed workflow, F08.DEPLOY-SMOKE. Use `Release Blocked` only for a real failed gate.

**Non-goals:** no deploy, no billing or plan change, no Remote Config change, no `git push` without the user's explicit approval for that push, no app / rules / function change. If a needed change touches product code or the rules, stop and hand back to the Tech Lead.

**Then:** close F08-DEVOPS-PREP, owner → Tech Lead, `Run Tech Lead`.

## Earlier briefs

* The F08-QA-FUNCTIONAL-R2 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-functional-closure.md.
* The user's no-network run steps (A11, 2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-offline-run-intake.md.
* The F08-QA-FUNCTIONAL-R1 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-r1-checkpoint.md.
* The F08-BE7 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be7-checkpoint.md.
* The F08-QA-FUNCTIONAL brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-functional-checkpoint.md.
* The F08-BE6 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be6-checkpoint.md.
* The F08-FE13 → F08-LOCAL-EVIDENCE brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.
* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
