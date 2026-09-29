# F08 — offline-persistence-and-sync: Orchestration

## Feature ID

F08

## Current Status

In Release

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
- [x] Task ID: F08-DEVOPS-PREP | Assigned Role: DevOps/Release Engineer | Status: Done | Summary: DONE 2026-09-29 (release.md, verdict **Release Validation Pending**; no deploy, billing or console change). CI repair (Java 21, TD-FORMAT-SCOPE, TD-CI-TOOLCHAIN, checkout v7.0.1, `ubuntu-24.04`), `release.md` refresh, hygiene recommendations; local proof DP-01…13. **Accepted at A17:** CI run #2 `36597006854` (c592081, pushed by the user) — all three jobs green; the best-effort integration step failed inside the green `verify` job (TD-CI-INTEGRATION-GATE). N-1…N-5 ruled at A17 | Depends On: F08-QA-FUNCTIONAL-R2
- [x] Task ID: F08-BE8 | Assigned Role: Backend Developer | Status: Done | Summary: DONE 2026-09-29 (backend.md § F08-BE8): `engines.node` "22", `@types/node` 20.19.43 → 22.20.4 (lockfile: root + `@types/node` only), `infra/README.md`; on Node 22.23.3 started directly (npm scripts put the host Node 24 first on PATH — backend.md §11): `tsc` exit 0, offline 18 passed / 15 skipped, emulator suite 3 / 3, **33 / 33** (`evidence/runtime/BE8-01`, `BE8-02`). Source, tests, rules, CI unchanged; no deploy. Host note: `node@22` install broke the system node via `simdjson`; restored as node@24 24.21.0 with the user's choice (backend.md §14) — **accepted at A18** (Tech Lead re-run at 9f6b6e6: 33 / 33 on Node 22) | Depends On: -
- [ ] Task ID: F08-DEVOPS-RULES | Assigned Role: DevOps/Release Engineer | Status: Open | Summary: F08.DEPLOY-GO — B (A19): the rules-only production deploy — read the live Firestore rules, verify the source (`infra/firestore.rules` `aa4c5dc2…`, suite 33 / 33 at the deploy revision), dry-run, confirm with the user in chat, `firebase deploy --only firestore:rules --project looplet-712e5`, the rules-scope smoke (the live ruleset = the committed file; unauthenticated create / get / update / delete → 403), `release.md` updated. No function / Remote Config / index deploy, no billing. Brief: Current Brief — **2026-09-29: steps 1–4 done, the deploy HELD by the user** ("Hayır, bekle" at the confirmation step; nothing changed on the project). Found: the live project has **no rules release and no ruleset**; unauthenticated reads → 403 (implicit lock). release.md § F08-DEVOPS-RULES; `evidence/deploy-rules/` DR-01…06 | Depends On: F08-BE8
- [ ] Task ID: F08-DEVOPS | Assigned Role: DevOps/Release Engineer | Status: Blocked | Summary: The function + Remote Config deploy, deferred (A19): needs the gate F08.FUNCTION-DEPLOY-GO (Blaze + the function deploy), opened at the F08-DEVOPS-RULES checkpoint. Scope then: pin Node 22 in the CI `infra` job (SHA-pinned `setup-node`); a green CI run at the deploy revision with its logs read (S1); deploy `submitDailyResultV1` (`nodejs22`) + Remote Config per the runbook; smoke S3 / S4 and the authenticated part of S2; the release readiness verdict | Depends On: F08-DEVOPS-RULES
- [ ] Task ID: F08-QA-FINAL | Assigned Role: QA | Status: Queued | Summary: Final acceptance of the reviewed release proof and the affected functional scope; Regression Depth `full` (the Node 22 runtime change is a dependency / build-config change): the emulator suite re-run at the final revision, other functional evidence reused by fingerprint | Depends On: F08-DEVOPS

## Open Tasks

* F08-DEVOPS-RULES — Open, **held**: the user answered "wait" at the deploy confirmation; the Tech Lead decides the next step.
* F08-DEVOPS — Blocked (the function deploy is deferred); F08-QA-FINAL Queued.

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
  * Tech Lead 2026-09-29 (A17 ruling 5): stays PASS through the Node.js 22 runtime change (F08-BE8) — the suites ran on the host's Node 24, not on Node 20; F08-QA-FINAL re-runs the suite at the final revision. CI run #2 ran the emulator step green (logs not read).
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
  * Tech Lead 2026-09-29 (A17): CI run #2 `36597006854` at c592081 is green — S1 is shown at that revision only, not at the deploy revision; its logs were not read (sign-in). S1 is re-run in F08-DEVOPS with the logs read.
  * DevOps 2026-09-29 (F08-DEVOPS-PREP): not run — the deploy is deferred (A16). The smoke list is refreshed to the current rules and code in release.md §8 (S1 CI green at the deploy revision; S2 live rules deny every client path; S3 the callable creates exactly once; S4 the app smoke). The rollback is in release.md §7.

- Evidence ID: F08.LIVE-RULES
  * Scenario: The production Firestore rules are the committed deny-all rules — the live ruleset source is byte-identical to `infra/firestore.rules` (`aa4c5dc2…`); unauthenticated REST create / get / update / delete under `dailyResults/**` → 403 `PERMISSION_DENIED`, no document written (A19 ruling 2; a subset of S2)
  * Required Class: runtime
  * Target / Environment: production `looplet-712e5` (the `(default)` database)
  * Owner Role: DevOps/Release Engineer
  * Prerequisite / External Decision: F08.DEPLOY-GO — B (RESOLVED, A19); the user's Firebase CLI session (the user signs in; Claude never types credentials)
  * Re-evaluation Trigger: F08-DEVOPS-RULES delivery
  * Blocks: F08 release / final acceptance
  * Result: PENDING
  * DevOps 2026-09-29 (F08-DEVOPS-RULES): not run — the user held the deploy. Pre-deploy state read: 0 releases, 0 rulesets; unauthenticated GET → 403 ×2 (`evidence/deploy-rules/DR-02`…`DR-04`). Source verified (33 / 33, `DR-05`); dry-run compiles (`DR-06`).

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

- Decision ID: F08.DEPLOY-GO
  * Question: May the first Firebase deploy to `looplet-712e5` run now, and how much of it?
  * Options / Trade-offs (A17 ruling 7): (A) the full deploy — the Blaze plan with a budget alert; rules + Remote Config + the function on Node 22 (after F08-BE8); F08-DEVOPS, then final QA and Done; the only route to F08 Done and F07. (B) the rules only, now — Spark, no billing; DevOps reads the live rules, deploys the committed deny-all rules, smoke S2; the function / Remote Config deploy stays deferred and the Tech Lead narrows this gate to it. (C) defer everything — after F08-BE8, F08 is Blocked with its functional acceptance intact; the Tech Lead activates the next feature (F09)
  * Recommendation: (B) while billing stays deferred — it closes the unknown-live-rules exposure of the public client config at no cost; (A) once billing is acceptable
  * Blocks: F08-DEVOPS, F08-QA-FINAL and Done; not F08-BE8
  * Blocking Scope: release
  * Status: RESOLVED
  * Resolution: Option (B) by the user — the committed deny-all rules are deployed to `looplet-712e5` now (Spark, no billing; Tech Lead approval given, project release.md §12); the function / Remote Config deploy stays deferred behind F08.FUNCTION-DEPLOY-GO, opened at the F08-DEVOPS-RULES checkpoint (architecture A19)
  * Resolved At: 2026-09-29

- Decision ID: F08.DEPLOY-AUTHORIZATION
  * Question: Is the deferred paid-backend release now authorized, for which environment and scope?
  * Options / Trade-offs (refined 2026-09-29, A15 ruling 4): (A) authorize the deploy — Blaze / billing and the named target; DevOps runs PREP, then the deploy. (B) keep deferring the deploy, but allow the non-deploy release work now (F08-DEVOPS-PREP: the CI fixes, the `release.md` refresh, a readiness verdict); the Tech Lead records the deferral, resolves this gate and opens a narrower gate F08.DEPLOY-GO for F08-DEVOPS (deploy + smoke), final QA and Done. (C) defer everything — F08 stays Blocked and `main` stays red for later features
  * Recommendation: (B) — a green CI is needed whatever the deploy date, and it costs no billing (A15)
  * Blocks: F08-DEVOPS activation, final QA and Done; not independent local/emulator validation
  * Blocking Scope: release
  * Status: RESOLVED
  * Resolution: Option (B) by the user — the deploy stays deferred (no Blaze / billing / deploy / Remote Config change); the non-deploy release work F08-DEVOPS-PREP runs now. The deploy itself needs the new gate F08.DEPLOY-GO, opened at the PREP checkpoint (architecture A16)
  * Resolved At: 2026-09-29

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

* The rules deploy (F08-DEVOPS-RULES step 5) is held: asked in chat on 2026-09-29, the user answered "Hayır, bekle" (wait). Steps 1–4 are done and nothing on `looplet-712e5` changed. It needs the Tech Lead: the live project has no rules release, and client reads are already denied by Firestore's implicit lock, so B's premise (unknown, possibly open console rules) did not hold.

## Next Action

Run Tech Lead — F08-DEVOPS-RULES is held by the user at the deploy confirmation. Review release.md § F08-DEVOPS-RULES (the live project has no rules release; reads already denied) and decide with the user: run the rules deploy later, fold it into the function deploy, or drop it.

## Last Decision

2026-09-29 — Tech Lead intake of the decision F08.DEPLOY-GO — B. Full record: architecture → Activation 2026-09-29 → A19.

* **Resolved (B):** the committed deny-all Firestore rules go to production now (Spark, no billing); the function / Remote Config deploy stays deferred.
* **Activated:** F08-DEVOPS-RULES; F08 → In Release; owner → DevOps/Release Engineer.
* **Planned:** F08.FUNCTION-DEPLOY-GO opens at the rules checkpoint (contract §5.3); the next-feature choice (F09 / F07 on the emulator / the function deploy) is put to the user then.

The pre-intake orchestration is archived as history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-deploy-go-decision.md.

## Last Update

* Updated By: DevOps/Release Engineer
* Timestamp: 2026-09-29
* Summary: F08-DEVOPS-RULES — pre-flight, live-state read, source check and dry-run done; the rules deploy held by the user ("wait"); no project change; owner → Tech Lead.

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
* [Orchestration before the CI incident](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-ci-incident.md).
* [Orchestration before the deploy decision](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-deploy-decision.md).
* [Orchestration before the PREP checkpoint](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-prep-checkpoint.md) — incl. the F08-DEVOPS-PREP brief and the full 2026-09-29 Change Log.
* [Orchestration before the BE8 checkpoint](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be8-checkpoint.md) — incl. the F08-BE8 brief.
* [Orchestration before the F08.DEPLOY-GO decision](../../history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-deploy-go-decision.md).

## Change Log

* 2026-09-18 — migrated state; see the immutable pre-migration snapshot for all earlier tasks, decisions and evidence.
* 2026-09-26 — Tech Lead: queue reordered (incident "the app still shows the old design"): F05 → design adoption → F08 local evidence.
* 2026-09-29 — the F08 local-evidence and functional stage, in order (full entries in the archived orchestration-before-prep-checkpoint.md):
  * Tech Lead activation (A1–A5) → Frontend/Mobile Developer F08-FE13 + LOCAL-EVIDENCE → Tech Lead (A6, A7) → Backend Developer F08-BE6 → Tech Lead (A8) → QA F08-QA-FUNCTIONAL (Decision Pending, F1) → Tech Lead (A9) → Backend Developer F08-BE7 → Tech Lead (A10) → QA R1 (Runtime Validation Pending) → Tech Lead (A11) → the user's offline run, intake (A12) → QA R2 (Functional Approved) → Tech Lead (A13).
  * The release stage: F08.CI-FIRST-PUSH resolved (A14) → CI run #1 incident (A15) → F08.DEPLOY-AUTHORIZATION — B (A16) → DevOps/Release Engineer F08-DEVOPS-PREP (Release Validation Pending).
* 2026-09-29 — Tech Lead: PREP checkpoint (A17).
  * **Accepted:** F08-DEVOPS-PREP; CI run #2 `36597006854` green; the integration step failed inside it (not a gate yet, TD-CI-INTEGRATION-GATE).
  * **Decided:** Node.js 22 for Cloud Functions (TD-FUNCTIONS-RUNTIME); N-1, N-2, N-4.
  * **Opened:** F08-BE8; the gate F08.DEPLOY-GO.
  * **Next:** owner → Backend Developer.
* 2026-09-29 — Backend Developer: F08-BE8 Done (backend.md). `engines.node` 22, `@types/node` 22; suite 33 / 33 on Node 22 (tools started directly — npm scripts ran the host Node 24). Host: the system node restored as 24.21.0 (node@24) after the `simdjson` break. Owner → Tech Lead.
* 2026-09-29 — Tech Lead: BE8 checkpoint (A18).
  * **Accepted:** F08-BE8 (re-run 33 / 33 on Node 22).
  * **Recorded:** setup-manifest Node 22 check + npm `PATH` caveat.
  * **Next:** Status → Blocked; the user decides F08.DEPLOY-GO.
* 2026-09-29 — Tech Lead: decision F08.DEPLOY-GO — B (A19).
  * **Resolved:** rules-only production deploy authorized; function / Remote Config deploy deferred.
  * **Activated:** F08-DEVOPS-RULES; Status → In Release.
  * **Next:** owner → DevOps/Release Engineer.
* 2026-09-29 — DevOps/Release Engineer: F08-DEVOPS-RULES held (release.md). Steps 1–4 done (read-only + dry-run); the user answered "wait" at the deploy confirmation; nothing deployed. Found: no rules release / ruleset on the project; unauthenticated reads → 403. Owner → Tech Lead.

## Release Constraints

The 2026-09-06 user decision to defer billing/deploy is preserved. In Progress now reflects still-available validation work, not renewed deploy permission. F08-DEVOPS remains Blocked. Environment/JDK/device availability has not been freshly probed; use current evidence, not the old environment assumptions.
## Current Brief

**Decision F08.DEPLOY-GO — B (A19):** deploy the committed Firestore rules to production now; everything else stays deferred.

**F08-DEVOPS-RULES — the rules-only production deploy** (architecture → A9, A17 ruling 7, A19; Release Scope `production-readiness`; Tech Lead approval given at A19, project `release.md` §12)

**Inputs:** `infra/firestore.rules`, `infra/firebase.json`, `infra/.firebaserc`, `infra/README.md` → Deploy / Runbook; the feature `release.md` §5 item 3, §6, §7 ("Bad rules shipped"), §8 S2; `qa.md` § F08-QA-FUNCTIONAL-R1 (rules probe P1–P8); `setup-manifest.md` (the Java 21 emulator command; the Node 22 note).

**Scope:**
1. **Pre-flight.**
   * The Firebase CLI is signed in to the user's account (`firebase login:list`). If it is not, the user runs `firebase login` — never type or handle credentials.
   * The target is `looplet-712e5` (`.firebaserc`), and its `(default)` Firestore database exists.
   * The Spark plan is fine for rules. Record the CLI version.
2. **Read the live rules before the deploy.**
   * Use the Firebase Rules API through the signed-in CLI's own session, or ask the user to paste them from the console.
   * Save the text as evidence. Classify it: deny-by-default, test-mode / open, or other. This is also the rollback reference.
3. **Verify the source.**
   * `infra/firestore.rules` sha1 = `aa4c5dc2…`.
   * The emulator suite at the deploy revision → 3 / 3, 33 / 33 (setup-manifest command, Java 21 first on `PATH`).
   * Note that CI run #2 (c592081) passed on the same rules and rules-test bytes. A push is not needed.
4. **Dry-run:** `cd infra && firebase deploy --only firestore:rules --project looplet-712e5 --dry-run` → the rules compile.
5. **Confirm with the user in chat right before the real deploy.** Show the live-vs-committed summary and the exact command. Then run `firebase deploy --only firestore:rules --project looplet-712e5`. Record the time and the ruleset / release id.
6. **Smoke — F08.LIVE-RULES:**
   * (a) the live ruleset source is byte-identical to the committed file;
   * (b) unauthenticated Firestore REST calls on `dailyResults/{lang}_{date}/entries/smoke-probe` — create, get, patch, delete — each → 403 `PERMISSION_DENIED`, and no document exists afterwards.
   * **Do not create any user in production:** no anonymous sign-up and no test account. The authenticated cases are covered by the emulator suite on the identical file (A19 ruling 2).
7. **If anything is wrong** (the smoke fails, or an unexpected dependency on the old rules shows up): roll back to the saved previous ruleset per `release.md` §7, and stop and report.
8. **`release.md`:**
   * record the deploy, the evidence and F08.LIVE-RULES;
   * Release Result stays **Release Validation Pending** — the function deploy, S3 / S4 and final QA remain.

**Non-goals:**
* no `functions`, `remoteconfig` or `firestore:indexes` deploy;
* no Blaze or billing, no other console or account setting;
* API-key restrictions and App Check stay the user's (release.md §5);
* no app, rules or CI change;
* no push without the user's approval.

If a step needs any of these, stop and hand back to the Tech Lead.

**Then:** close F08-DEVOPS-RULES, owner → Tech Lead, `Run Tech Lead`.

## Earlier briefs

* The F08.DEPLOY-GO decision wait (A18) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-deploy-go-decision.md.
* The F08-BE8 brief (A17) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be8-checkpoint.md.
* The F08-DEVOPS-PREP brief (A16) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-prep-checkpoint.md.
* The deploy-decision wait (A15) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-deploy-decision.md.
* The pre-A15 F08-DEVOPS-PREP brief — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-ci-incident.md.
* The F08-QA-FUNCTIONAL-R2 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-functional-closure.md.
* The user's no-network run steps (A11, 2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-offline-run-intake.md.
* The F08-QA-FUNCTIONAL-R1 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-r1-checkpoint.md.
* The F08-BE7 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be7-checkpoint.md.
* The F08-QA-FUNCTIONAL brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-qa-functional-checkpoint.md.
* The F08-BE6 brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be6-checkpoint.md.
* The F08-FE13 → F08-LOCAL-EVIDENCE brief (2026-09-29) — in history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-fe13-checkpoint.md.
* The 2026-09-18 migration brief and older F08 briefs — in history/core-sync-2026-09-18/features/f08-offline-persistence-and-sync/orchestration.md and history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-activation.md.
