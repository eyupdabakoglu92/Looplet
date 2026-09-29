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
- [ ] Task ID: F08-QA-FUNCTIONAL | Assigned Role: QA | Status: Queued | Summary: Independently review local/emulator/boot evidence, preserve unresolved scenarios, then issue functional-stage verdict | Depends On: F08-LOCAL-EVIDENCE
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: Resume release readiness only after explicit billing/target approval; retain runbook and remaining smoke | Depends On: F08-QA-FUNCTIONAL
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of reviewed release proof and any affected functional scope | Depends On: F08-DEVOPS

## Open Tasks

* None open for a delivery role — F08-QA-FUNCTIONAL stays Queued until the Tech Lead checkpoint.

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

Run Tech Lead — checkpoint on the F08-FE13 / F08-LOCAL-EVIDENCE delivery (frontend.md → both sections): accept or rework the migration-transaction fix and the other reconciliation items (§4), route the backend test-data defect and the JDK 21 tooling note (§16), then the QA plan for F08-QA-FUNCTIONAL. F08.OFFLINE-JOURNEY waits for the user's run of `evidence/offline-journey.sh`. The release stage stays blocked (F08.DEPLOY-AUTHORIZATION OPEN); no deployment or billing action.

## Last Decision

2026-09-29 (F08 activation after Design Adoption Phase D) — full record: architecture → Activation 2026-09-29.

* **Gap found:** an unreadable store file is a Retry dead end (F05-QA-D3 E15 + the bootstrap code), breaking the locked Resilience row and AC8. It is closed in code by F08-FE13: classify, quarantine + recreate, `db_reinitialized`, loop guard. The earlier F08 QA had read AC8 as the `active_session` row only.
* **Scoped into F08:**
  * F08-RETRY-STORE-CONNECTION — Retry reopens the connection;
  * the debug-only emulator wiring and fake-producer trigger (the QA Focus needs client ↔ emulator runs; JDK 17 and the Firebase CLI are present).
* **Left out:** the one-frame Retry feedback (F05-QA-D3 N2) — visual, stays a follow-up; Visual Scope `none`.
* **Evidence plan A4:**
  * resume re-run in full on the FE13 build (F05-QA-D3 E09 supporting);
  * emulator exactly-once and lifecycle with the emulator stopped as "offline";
  * storage-full by `max_page_count` on a real file DB;
  * offline Journey only on a real no-network runtime (a user action or a device);
  * clock stays automated-only.
* **Assumption:** no player notice after `db_reinitialized` (AC8); tracked as DB-REINIT-NOTICE.

The pre-activation orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.

## Last Update

* Updated By: Frontend/Mobile Developer
* Timestamp: 2026-09-29
* Summary: F08-FE13 and F08-LOCAL-EVIDENCE Done (frontend.md); F08.STORAGE PASS, F08.UNREADABLE-DB delivery evidence complete (QA review pending); Delivery Review Pending; owner → Tech Lead.

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


## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**F08-FE13 → F08-LOCAL-EVIDENCE — close the unreadable-DB gap, reconnect on Retry, add the emulator tooling, then capture the local evidence** (contract: architecture → "Activation 2026-09-29" A1–A5; the locked sections "Resilience", "App Init Sequence", "Ownership & Lifecycle", "QA Focus")

**User-visible symptom** (A1, seen in F05-QA-D3 E15):
* A store file that is not a database opens the store-error screen, and "Tekrar dene" fails forever. The player is stuck until they reinstall.
* The contract instead says: recover, or as a last resort recreate, log `db_reinitialized`, never loop.
* Also: a store that becomes readable while the app runs still fails until a relaunch, because Retry keeps the dead connection (F08-RETRY-STORE-CONNECTION).

**Affected journey and entry paths:** cold start → bootstrap (`lib/bootstrap.dart` `appBootstrapProvider`) → Home or the store error (`lib/app_router.dart` `_BootstrapGate`) → Retry. Entry states:
* no store;
* a good store;
* a store that is not a database / corrupt;
* a migration failure (`MigrationDataLossError` or a throwing step);
* a transient open error;
* a Retry after the cause is gone.

**Part 1 — F08-FE13 (code):**
1. **Classification and recovery** (A1 rules 1–5):
   * in the bootstrap, map `SqliteException` NOTADB (26) / CORRUPT (11) from open or the first query to recovery;
   * close the connection; rename `looplet.sqlite` (+ `-wal` / `-shm`) to `looplet.sqlite.corrupt-<utcMs>` (keep only the newest quarantine); recreate (the normal seed); `debugPrint('store: db_reinitialized — <code>')`; continue to Home;
   * a second failure in the same launch → the error state (no second recreate);
   * migration failures keep today's error screen (data intact, AC9); every other failure → the error screen.
   * Keep the change inside the bootstrap / persistence layer (`bootstrap.dart`, `persistence/app_database.dart`, `persistence/persistence_providers.dart`). No schema, migration or repository semantics change.
2. **Retry reconnects** (A2): Retry closes and invalidates `appDatabaseProvider` (and its dependents) as well as `appBootstrapProvider`. No visual change: `StoreErrorScreen` and the splash stay exactly as in D3.
3. **Debug-only emulator wiring** (A3):
   * `--dart-define=LOOPLET_FIREBASE_EMULATOR=<host>` honoured only under `kDebugMode`, after `Firebase.initializeApp`: auth 9099, firestore 8080, functions 5001 (`infra/firebase.json`), project `demo-looplet`;
   * a `kDebugMode`-only trigger for `FakeDailyResultProducer` (e.g. a launcher in Home's debug row under the C2 rules, or a debug-only route);
   * nothing of either in profile / release — prove it with a test on the compile-time gate.
4. **Storage-full harness** (A4, F08.STORAGE): a repeatable integration test on a **real file database** that lowers `PRAGMA max_page_count` so the next write fails with `SQLITE_FULL`. Assert:
   * rollback and the last good state (the active session and a durable row);
   * the non-fatal `persist_failed` path;
   * play continuing from memory;
   * the retry at the next boundary.

**Tests (Part 1):**
* **Unit / widget:** the classification (NOTADB → recover; CORRUPT → recover; `MigrationDataLossError` → error screen, file untouched; other → error screen); the quarantine name and that only one copy is kept; the loop guard; Retry → a fresh connection (a store fixed between attempts recovers); the emulator gate off in non-debug; the storage-full harness.
* **Named negative runs**, each caught by a failing test and restored (the `design/src/neg-d3.py` pattern):
  * N-CLASS — every failure mapped to the error screen;
  * N-LOOP — the loop guard removed;
  * N-RETRY — Retry no longer invalidates the connection;
  * N-FULL — the rollback bypassed (a partial write persists);
  * N-GATE — the emulator wiring reachable outside `kDebugMode`.
* **Suites:** `melos run analyze`; `dart format --set-exit-if-changed app packages tools`; `melos run test`; `flutter test integration_test` on the iPhone 16 simulator.

**Part 2 — F08-LOCAL-EVIDENCE (runtime, on the FE13 build; debug build on the iOS Simulator 18.6, iPhone 16 primary)** — the A4 table:
1. **Unreadable DB:** `seed-d3.sh corrupt` → cold launch → Home "new"; the quarantined file listed; the log line. A migration-failure path, if it can be forced safely in debug, shows the error screen with the file intact.
2. **Resume fidelity (AC1 / AC6):** a frozen-tile level (21–30) with N moves + an undo + a restart + a thawed tile → kill → relaunch → exact restore (grid, `moveCount`, `undosRemaining`, `restartCount`, elapsed within capture resolution, thaw). Then tamper `thawedFrozenCells` → relaunch → thaw re-derived. Use the authoring CLI (`tools/looplet_authoring` `solve` / `playtest` on `drafts/journey/_defs/…`) to find a thawing move sequence.
3. **Emulator suites:** `cd infra/functions && npm ci && npm run build && npm run test:emulator` — result and counts.
4. **Exactly-once, client ↔ emulator (AC4 / AC5 / AC11):** `firebase emulators:start --only auth,firestore,functions --project demo-looplet`; the app with the dart-define. The six A4 cases. "Offline" = the emulator stopped — state it; it is not airplane mode. Evidence: queue rows (`sqlite3`), Firestore emulator documents (REST or the UI export), the emulator log.
5. **Lifecycle / ownership (F08.LIFECYCLE):**
   * trigger → leave the triggering screen at once → the doc still arrives;
   * HOME → foreground → `drain()`;
   * emulator stop → start → drain on regain (state how regain is detected under the simulator).
6. **Storage-full runtime** if a debug hook is practical; otherwise the Part 1 harness is the evidence (repeatable integration), stated as such.
7. **Production-shaped cold boot** (startup impact: yes): empty store and existing store, recorded. No light frame (the D3 method, `video-d2.swift`).
8. **Offline Journey (AC2):** only on a real no-network runtime. You may prepare a script for the user to run (network off → the capture → network on). **Do not change system settings yourself**, and do not replace this with a simulated offline mode. If the user has not provided the runtime, leave F08.OFFLINE-JOURNEY PENDING with that prerequisite and continue.

**Evidence record:** append to `frontend.md` (do not rewrite FE1–FE12):
* new sections "F08-FE13" and "F08-LOCAL-EVIDENCE" with task-to-code traceability, authority reconciliation, preserved behaviour, test evidence by task and the negative-run table;
* an evidence ledger per scenario (claim, class, command, target, result / counts, provenance with revision and time, isolation);
* evidence files under `features/f08-offline-persistence-and-sync/evidence/`.

Update your own Pending Evidence records (F08.UNREADABLE-DB, F08.STORAGE) with the result and provenance. **Do not mark QA-owned records PASS** — record the delivery evidence against them in `frontend.md` for QA's review.

**Non-goals:**
* no schema, migration or snapshot change;
* no change to the store-error screen, splash or Home look (Visual Scope `none`; the one-frame Retry feedback stays a follow-up);
* no real Firebase project, deploy, billing, Remote Config publish or App Check change;
* no F07 Daily UI; no clock change on the host; no product-semantics change (AC wording, error copy).

**Exit:**
* F08-FE13 and F08-LOCAL-EVIDENCE Done with `frontend.md`;
* F08.UNREADABLE-DB and F08.STORAGE with delivery evidence, and the other records annotated;
* Delivery Review = Pending → the Tech Lead checkpoint (delivery reconciliation, then the QA plan for F08-QA-FUNCTIONAL).

Any deviation from Activation A1–A5 → Needs Tech Lead Clarification.

## Earlier briefs

* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
