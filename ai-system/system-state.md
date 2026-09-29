# System State — LOOPLET

Last Updated: 2026-09-29

## Platform Initialized

Yes. Existing Flutter/Dart client, pure-Dart packages, Drift persistence and Firebase authority are retained.

## Environment Status

Core workflow tooling requires Node.js 18+. Application/device/emulator environment was not freshly certified during this document/tooling migration. Old build, boot and CI results remain dated evidence in the original reports, not new PASS claims.

## Technical Authority

project-authority/platform.md and each feature's architecture.md — unchanged.

## Setup Authority

project-authority/setup-manifest.md — 2026-09-29: added the Firebase emulator-suite command with Java 21 (firebase-tools 15.29 needs Java 21+; `openjdk@21` is installed keg-only with the user's approval, and the system Java is unchanged). Corrected the same day at the BE6 checkpoint: Java 21 must also be first on `PATH`. Everything else is unchanged.

## Release Authority

project-authority/release.md — unchanged; explicit release approval remains required.

## Product Authority

product/product-prd.md — revised 2026-09-29 by PO-REV-2026-09-29-F05-CONTINUE (F05 CONTINUE precedence after 30 / 30; the user's N1 decision), resynced by the Tech Lead the same day. The user's recorded content decisions are retained; no other product criterion changed.

## Source of Truth

feature-board.md for portfolio; features/*/orchestration.md for execution; role-execution-contract.md for core workflow rules.

## Active Feature

F08

## Active Orchestration Path

features/f08-offline-persistence-and-sync/orchestration.md

## Current Phase

F08 local evidence — F08-QA-FUNCTIONAL (functional stage, plan A7 / A8)

## Current Role

QA

## Current Reason

**The F08-BE6 checkpoint** was on 2026-09-29. Full record: F08 `architecture.md` → Activation → A8.

* **Accepted:** F08-BE6 (c70527a).
  * The emulator suite's fixture is now a valid "better" replay; the suite is 31 / 31.
  * N-OVERWRITE is caught.
  * Only test code changed.
* **Delivery Review: Accepted** — F08-FE13, F08-LOCAL-EVIDENCE and F08-BE6.
* **F08-QA-FUNCTIONAL is active** under the plan locked in A7: modules core, backend-security, client-ui, stateful-flow; regression depth full; evidence reuse invalidated for the app side.
* The offline Journey (AC2) waits for the user's no-network run.
* Visual Scope `none`. The release stage stays blocked on F08.DEPLOY-AUTHORIZATION.

## Last Completed Action

Tech Lead on 2026-09-29 — **the F08-BE6 checkpoint** (after the delivery in c70527a).
* **Reviewed:**
  * `backend.md` F08-BE6;
  * the test diff against `validate.ts`;
  * `neg-be6.py` and the logs BE6-00 to BE6-04;
  * `firestore.rules`.
* **Fingerprints** match the delivery (test `cf73770d…`, handler `bcda2662…`).
* **Re-ran** the emulator suite at c70527a: 31 / 31, exit 0. This is not a QA claim.
* **Decided** (A8):
  1. F08-BE6 — accepted;
  2. the setup-manifest command — corrected (Java 21 first on `PATH`);
  3. the CI emulator step — A6 ruling 5's premise corrected. The step exists since F08-BE5 but CI has never run (0 GitHub Actions runs), and it needs Java 21 → CI-EMULATOR-JAVA21 (DevOps/Release Engineer). It does not block functional QA;
  4. the Jest teardown warning — a note;
  5. `firestore.rules` without `!exists` — equivalent, no change.
* **State:** Delivery Review Accepted; F08-QA-FUNCTIONAL Open; QA Result None; owner → QA.
* Archived: history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-be6-checkpoint.md.

## Next Expected Action

Run QA on F08-QA-FUNCTIONAL (the F08 orchestration Current Brief; plan F08 `architecture.md` → Activation A7, corrected by A8). Functional stage:
* the eight critical journeys and the misuse checks;
* re-run the named negatives, including N-OVERWRITE;
* a result per Pending Evidence record;
* the verdict in `qa.md`.

Then the Tech Lead checkpoint on the verdict. Optional and at any time: the user runs `ai-system/features/f08-offline-persistence-and-sync/evidence/offline-journey.sh <udid>` for AC2. It turns the Mac's Wi-Fi off and back on. No deployment or billing action.

## Portfolio Summary

* F01, F02, F04, F06: historical scoped Done retained.
* F03: Done (2026-09-29) — Design Adoption Phase D2 (won moment + full-screen result, `motion-critical`, architecture §20) closed: F03-QA-D2R Approved with Notes, 94 / 100, gate Passed (§20.11), after one rework (F03-QA-D2-01, the scroll band). D1 (Play) closed 2026-09-28: Approved with Notes, 93 / 100, gate Passed (§19.12).
* F00: Done again (2026-09-27) — Phase C is complete (the conformance audit was accepted). Its design-system layer closed 2026-09-26: Foundation Selected (Direction C), 90/100, Visual Quality Gate Passed via the scoped exception F00.VISUAL-93-THRESHOLD.
* F05: Done (2026-09-29) — Design Adoption Phase D3 (Home + app shell, `new-surface`, architecture §18) closed: F05-QA-D3 Approved with Notes, 94 / 100, gate Passed (§18.9). The user's N1 decision is live (PO-REV-2026-09-29-F05-CONTINUE). Previously Done 2026-09-27 (F05-QA-STRICT2 Approved with Notes).
* F04: Done — the panel is now the full-screen result (D2, F03 carrier, closed 2026-09-29; F04 §7 / §8 amended 2026-09-28; ACs unchanged and passed on the result).
* F08: **In Progress — the active feature.** F08-FE13 + F08-LOCAL-EVIDENCE accepted 2026-09-29 (A6); F08-BE6 Open with the Backend Developer, then F08-QA-FUNCTIONAL (plan A7). Independent local/emulator validation pending, release task Blocked, release/final acceptance pending. Its `StoreErrorScreen` now uses the Foundation (D3, F08 App Init step 1 amended).
* F07, F09–F13: Not Started. Pending follow-ons are in workflow-follow-ups.md.

## Release Decision

F08.DEPLOY-AUTHORIZATION is OPEN with Blocking Scope = release. The old deferral remains effective. Local/emulator proof does not require lifting the paid-deploy hold; final QA and Done still do.

## Global Risks

* F03-QA-03 / F03-QA-04 are fixed and verified on the real target (F03 final QA); not verified: physical finger, Android. (The terminal 30/30 bloom item lapses: D3 drops the bloom, F05 §18.7 ruling 4.)
* The Design Foundation is Selected and its design-system layer passed independent visual QA 2026-09-26 (90/100, every dimension >= 8, no fail condition) via a user-resolved scoped one-time exception — not a change to the >= 93 generic bar, which still applies to future visual work (new features and any rework) unless that feature's own decision gate says otherwise. **Phase D is complete (2026-09-29):** every shipped surface passed the independent gate — Play 93, the result 94, Home + shell 94. See Design Adoption Route.
* **Shipped defects found by the Phase C audit** (2026-09-27): all fixed and passed at runtime in Phase D — A-1, A-2 (board glyphs), A-5, A-6 (D1); A-2 at AX5 on Play (D1), the result (D2) and Home (D3); A-3 the store-error screen and A-4 the white launch frame (D3, F05-QA-D3). Limits kept open: the Android launch was resource-tested, not run (ANDROID-CI-EVIDENCE); the profile / release store-error capture rides FIRST-APP-DISTRIBUTION.
* **Known gesture deviation (F03-MULTITOUCH-FIRST-POINTER):** two simultaneous fingers in opposite directions produce no move instead of honouring the first touch (F03 §6). The outcome is safe and the code predates D1; it is scheduled after Phase D.
* **Hybrid period ended 2026-09-29** (C-8): with D3 closed, Home, the splash / launch, the store error, Play and the result all use Loop Glass.
* **CI format gate red (CI-FORMAT-GATE):** CI's repo-wide `melos run format:check` fails on a pre-existing F00 QA probe (`ai-system/…/qa_probe_main.dart`, since 3647cef). App, package and tool code is formatted. Owner: DevOps/Release Engineer.
* Rotation, AC9 highlight, back/exit and won-moment regular motion passed runtime QA (rev c0cba44); live lifecycle and reduced-motion runtime remain FAIL/pending until the fixes land. Info.plist still allows landscape; the portrait lock rests on runtime behaviour (rotation PASS).
* Required device/manual evidence is not established by a widget test, build or a planned CI job.
* A green suite does not prove that a rule is enforced. F05's "band-rule case" was an empty test, and it passed a Tech Lead reconciliation because the check itself was never read (2026-09-26). Every gate claim needs its check read and its negative case run.
* Startup/resume/persistence proof is shared by consuming features; reconcile the actual scope before clearing a downstream gate.
* F08 cold-boot fix evidence exists in prior delivery/Tech Lead reports; QA must review applicable provenance, not invent an approval.
* Daily content, first distribution, Android CI and other unresolved follow-ons remain OPEN in workflow-follow-ups.md.
* No billing change or deployment has been executed. The D3 closure (2026-09-29) re-measured two QA captures on the host and read the simulator settings (all `large`, Reduce Motion 0); it made no QA claim.
* **Post-D2 follow-ups (non-blocking, OPEN in workflow-follow-ups.md):**
  * RESULT-APP-SWITCHER-SNAPSHOT — the iOS app-switcher snapshot taken mid-sequence shows a mid-reveal star count;
  * RESULT-F00-COMPONENT-ALIGN — the `EN İYİ` ★ offset and the pressed-pill brightness.
  * Release-build pacing was not measured (debug video only); it belongs to FIRST-APP-DISTRIBUTION — for the result (D2) and the Home entrance (D3, F05-QA-D3 N1).
* **Post-D3 follow-ups (non-blocking, in workflow-follow-ups.md):** FIRST-APP-DISTRIBUTION (the profile / release store-error capture, moved from the F05 ledger); F08-RETRY-STORE-CONNECTION (+ the one-frame Retry feedback, N2); RESULT-F00-COMPONENT-ALIGN (+ the `LimePill` arrow at AX5, N3); OPTIONAL-QUALITY-NOTES (N4, N5); RELEASE-SCOPED-EVIDENCE (process).
* **Commits:** the D1 rework, its closure and the D2 activation are in 489606d — its tracked `app/` diff from 5798c70 hashes to QA's `88f1dca3…` and the two changed sources match QA's SHA-1s (re-verified at the D2 checkpoint); the F03-UI-D2 handoff is in 6352a75; the F03-FE-D2 delivery is in 67d9ecb (`app/` tree `f5641d2f…`, QA's evidence-reuse fingerprint); the F03-QA-D2 verdict is in f28aedb; the reconciliation in 3cd4a3b; the F03-FE-D2R rework in 77c33b9 (`app/` tree `5298c81a…`, the re-QA fingerprint); the F03-QA-D2R verdict in 5677471. The D2 closure and the D3 activation are in 171f0c1; the PO revision in 230ce0c; its resync in 9a36147; the F05-UI-D3 handoff in 981b807; the visual-gate checkpoint in 7c1a946; the F05-FE-D3 delivery in af5aec8 (`app/` `b4ad263e…`, the D3 QA fingerprint); the implementation checkpoint in 078c926; the F05-QA-D3 verdict in e46f384. The D3 closure is in b7493d6. The F08 activation is in 1d373d7; the F08-FE13 / LOCAL-EVIDENCE delivery in beb7bfe (`app/` `9de12e6a…`); the FE13 checkpoint in b8e37ab; the F08-BE6 delivery in c70527a. The BE6 checkpoint is uncommitted (documents only).
* **F08 unreadable-DB gap (found 2026-09-29):** fixed in F08-FE13 (beb7bfe) and accepted at the checkpoint; the runtime and automated evidence awaits independent QA (F08.UNREADABLE-DB). The Retry reconnect is delivered too. The one-frame Retry feedback (N2) stays a follow-up.
* **Migration partial-apply (found by F08-FE13, 2026-09-29):** Drift does not wrap `onUpgrade` in a transaction, so a failing step could leave a partial apply. It is fixed and accepted (F08 A6 ruling 1). The first real schema step must add its own real-file migration test.
* **Emulator suite (F08-BE6):** was 30 / 31 because of a contract-invalid fixture, not a handler defect; fixed in c70527a and accepted — 31 / 31 on Java 21 (first on `PATH`; setup-manifest).
* **CI never executed (CI-EMULATOR-JAVA21, found 2026-09-29):** the GitHub Actions API reports 0 runs, and `origin/main` is still the bootstrap commit. Every CI job in `ci.yml` is CI-wired only. The emulator step needs Java 21 before its first run. Owner: DevOps/Release Engineer; non-blocking for F08 functional QA.

## Contract Version

Existing product/technical contracts retained; workflow schema updated from ai-system-core working tree.

## Pending Breaking Change

None introduced by this migration.

## Active Cross-Feature Contract Migration

None. This is workflow state normalization, not a code/schema/API migration.

## History Reference

[Original complete system-state](history/core-sync-2026-09-18/system-state.md) and [migration record](history/core-sync-2026-09-18/README.md). All pre-migration chronology and environment reports are retained.
