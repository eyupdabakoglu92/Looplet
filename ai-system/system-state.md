# System State — LOOPLET

Last Updated: 2026-09-29

## Platform Initialized

Yes. Existing Flutter/Dart client, pure-Dart packages, Drift persistence and Firebase authority are retained.

## Environment Status

Core workflow tooling requires Node.js 18+. Application/device/emulator environment was not freshly certified during this document/tooling migration. Old build, boot and CI results remain dated evidence in the original reports, not new PASS claims.

## Technical Authority

project-authority/platform.md and each feature's architecture.md. 2026-09-29 (A17): `platform.md` §3 — Cloud Functions on **Node.js 22** (TD-FUNCTIONS-RUNTIME; Node 20 is decommissioned 2026-10-30; implemented in F08-BE8, 9f6b6e6, accepted at A18). 2026-09-29: `platform.md` §6 / §8 and the F08 Rules row corrected — no client access to `dailyResults/**`; the callable is the only write path (F08 `architecture.md` A9, QA finding F1).

## Setup Authority

project-authority/setup-manifest.md — 2026-09-29: added the Firebase emulator-suite command with Java 21 (firebase-tools 15.29 needs Java 21+; `openjdk@21` is installed keg-only with the user's approval, and the system Java is unchanged). Corrected the same day at the BE6 checkpoint: Java 21 must also be first on `PATH`. At the CI incident (F08 A15, same day): CI pins the canonical toolchain (Flutter 3.32.8, Xcode ≥ 16.4, CocoaPods), and `format` / `format:check` cover `app packages tools` only. Implemented in F08-DEVOPS-PREP (c592081) and proven by CI run #2. At A17: the Cloud Functions runtime line → Node.js 22; the local Android-build JDK note (N-4). At A18: the local Node 22 check (tools started directly by Node 22 — npm scripts run the system Node). Everything else is unchanged.

## Release Authority

project-authority/release.md — amended 2026-09-29 (F08 A17): §4 format scope `app packages tools`; §4 the integration-test step is not a gate until the first app-build release gate (TD-CI-INTEGRATION-GATE); §2 the F08 kill-switch note. Explicit release approval remains required.

## Product Authority

product/product-prd.md — revised 2026-09-29 by PO-REV-2026-09-29-F05-CONTINUE (F05 CONTINUE precedence after 30 / 30; the user's N1 decision), resynced by the Tech Lead the same day. The user's recorded content decisions are retained; no other product criterion changed.

## Source of Truth

feature-board.md for portfolio; features/*/orchestration.md for execution; role-execution-contract.md for core workflow rules.

## Active Feature

F07

## Active Orchestration Path

features/f07-daily-challenge/orchestration.md

## Current Phase

F07 — F07-UI (the Daily surfaces: rendered directions + handoff). F08 paused (A21).

## Current Role

UI Designer

## Current Reason

**The user decided F08.FUNCTION-DEPLOY-GO — C** on 2026-09-29 (F08 `architecture.md` A21).

* **The first Firebase deploy stays deferred;** F08 is paused with everything kept. It resumes on `Run Tech Lead. Decision: F08.DEPLOY-RESUME — A`.
* **F07 (daily-challenge) is active** on the emulator, under a dependency ruling: it builds on F08's Functional Approved client surface, and **its release waits on F08's deploy**.
* **F07 contract** (`architecture.md` D1–D11): a daily pack behind Remote Config `daily_manifest_url`; cache for today + 7 days; the start date wins across midnight; a transactional first run with the streak and one sync item; the kill-switch; a secondary Home entry; no Share in F07 (F13).
* **Visual Scope `new-surface`,** so the UI Designer goes first: at least two rendered directions, then the user selects.

## Last Completed Action

Tech Lead on 2026-09-29 — **the decision F08.FUNCTION-DEPLOY-GO — C** (F08 A21) and **the F07 activation**.
* **F08:** gate resolved; paused (Blocked; resume point F08-DEVOPS); F08.DEPLOY-RESUME opened; fake producer kept until F08 Done.
* **F07:** `prd.md`, `architecture.md` (D1–D11), `orchestration.md`; F07-UI Open; F05 §18.10 cross-feature note; F06-CONTENT-DAILY and F07-KILL-SWITCH brought into the F07 ledger.
* Archived: history/f08-offline-persistence-and-sync-2026-09-29/orchestration-before-function-deploy-decision.md.

## Next Expected Action

Run UI Designer on F07-UI (the F07 orchestration Current Brief): at least two rendered directions for the Daily surfaces on the Foundation, then `ui-design.md` with the Visual Evidence Manifest. Then the Tech Lead visual-gate checkpoint, which opens F07.DIRECTION-SELECT for the user.

## Portfolio Summary

* F01, F02, F04, F06: historical scoped Done retained.
* F03: Done (2026-09-29) — Design Adoption Phase D2 (won moment + full-screen result, `motion-critical`, architecture §20) closed: F03-QA-D2R Approved with Notes, 94 / 100, gate Passed (§20.11), after one rework (F03-QA-D2-01, the scroll band). D1 (Play) closed 2026-09-28: Approved with Notes, 93 / 100, gate Passed (§19.12).
* F00: Done again (2026-09-27) — Phase C is complete (the conformance audit was accepted). Its design-system layer closed 2026-09-26: Foundation Selected (Direction C), 90/100, Visual Quality Gate Passed via the scoped exception F00.VISUAL-93-THRESHOLD.
* F05: Done (2026-09-29) — Design Adoption Phase D3 (Home + app shell, `new-surface`, architecture §18) closed: F05-QA-D3 Approved with Notes, 94 / 100, gate Passed (§18.9). The user's N1 decision is live (PO-REV-2026-09-29-F05-CONTINUE). Previously Done 2026-09-27 (F05-QA-STRICT2 Approved with Notes).
* F04: Done — the panel is now the full-screen result (D2, F03 carrier, closed 2026-09-29; F04 §7 / §8 amended 2026-09-28; ACs unchanged and passed on the result).
* F08: **Blocked — paused by the user's decision F08.FUNCTION-DEPLOY-GO — C (A21).** **Functional Approved** (R2, A13); PREP accepted with a green CI run #2 (A17); F08-BE8 (Node.js 22) accepted (A18); the rules-only deploy held and cancelled (A20); Release Validation Pending. Resume: F08.DEPLOY-RESUME → F08-DEVOPS → F08-QA-FINAL. Its client contract is frozen for F07. Its `StoreErrorScreen` uses the Foundation (D3).
* F07: **In Progress — the active feature** (activated 2026-09-29, A21). F07-UI Open (UI Designer); then F07-TOOL, F07-CONTENT (the Turkish pool), F07-FE, F07-QA-FUNCTIONAL; F07-DEVOPS Blocked on F08's deploy.
* F09–F13: Not Started. Pending follow-ons are in workflow-follow-ups.md.

## Release Decision

**F08.DEPLOY-RESUME is OPEN** (2026-09-29, F08 A21): authorize the first Firebase deploy (Blaze with a budget alert; rules + Remote Config + the `nodejs22` function). It resumes F08-DEVOPS, and it is also needed before F07's release (F07-DEVOPS). Until then, no Blaze, billing, deploy or console change. F08.FUNCTION-DEPLOY-GO (C, A21), F08.DEPLOY-GO (B, A19; its rules-only step held and cancelled at A20), F08.DEPLOY-AUTHORIZATION (A16) and F08.CI-FIRST-PUSH (A14) are RESOLVED. Every push needs the user's approval.

## Global Risks

* F03-QA-03 / F03-QA-04 are fixed and verified on the real target (F03 final QA); not verified: physical finger, Android. (The terminal 30/30 bloom item lapses: D3 drops the bloom, F05 §18.7 ruling 4.)
* The Design Foundation is Selected and its design-system layer passed independent visual QA 2026-09-26 (90/100, every dimension >= 8, no fail condition) via a user-resolved scoped one-time exception — not a change to the >= 93 generic bar, which still applies to future visual work (new features and any rework) unless that feature's own decision gate says otherwise. **Phase D is complete (2026-09-29):** every shipped surface passed the independent gate — Play 93, the result 94, Home + shell 94. See Design Adoption Route.
* **Shipped defects found by the Phase C audit** (2026-09-27): all fixed and passed at runtime in Phase D — A-1, A-2 (board glyphs), A-5, A-6 (D1); A-2 at AX5 on Play (D1), the result (D2) and Home (D3); A-3 the store-error screen and A-4 the white launch frame (D3, F05-QA-D3). Limits kept open: the Android launch was resource-tested, not run (ANDROID-CI-EVIDENCE); the profile / release store-error capture rides FIRST-APP-DISTRIBUTION.
* **Known gesture deviation (F03-MULTITOUCH-FIRST-POINTER):** two simultaneous fingers in opposite directions produce no move instead of honouring the first touch (F03 §6). The outcome is safe and the code predates D1; it is scheduled after Phase D.
* **Hybrid period ended 2026-09-29** (C-8): with D3 closed, Home, the splash / launch, the store error, Play and the result all use Loop Glass.
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
* **Commits:** the D1 rework, its closure and the D2 activation are in 489606d — its tracked `app/` diff from 5798c70 hashes to QA's `88f1dca3…` and the two changed sources match QA's SHA-1s (re-verified at the D2 checkpoint); the F03-UI-D2 handoff is in 6352a75; the F03-FE-D2 delivery is in 67d9ecb (`app/` tree `f5641d2f…`, QA's evidence-reuse fingerprint); the F03-QA-D2 verdict is in f28aedb; the reconciliation in 3cd4a3b; the F03-FE-D2R rework in 77c33b9 (`app/` tree `5298c81a…`, the re-QA fingerprint); the F03-QA-D2R verdict in 5677471. The D2 closure and the D3 activation are in 171f0c1; the PO revision in 230ce0c; its resync in 9a36147; the F05-UI-D3 handoff in 981b807; the visual-gate checkpoint in 7c1a946; the F05-FE-D3 delivery in af5aec8 (`app/` `b4ad263e…`, the D3 QA fingerprint); the implementation checkpoint in 078c926; the F05-QA-D3 verdict in e46f384. The D3 closure is in b7493d6. The F08 activation is in 1d373d7; the F08-FE13 / LOCAL-EVIDENCE delivery in beb7bfe (`app/` `9de12e6a…`); the FE13 checkpoint in b8e37ab; the F08-BE6 delivery in c70527a; the BE6 checkpoint in 84430c9; the F08-QA-FUNCTIONAL verdict in d882211; the QA checkpoint (A9) in 8f26243; the F08-BE7 delivery in cb96719; the BE7 checkpoint (A10) in 695f783; the F08-QA-FUNCTIONAL-R1 verdict in 4cb836a; the A11 checkpoint, the offline run and the A12 intake in e55176f; the F08-QA-FUNCTIONAL-R2 verdict in 0d65c73; the A13 checkpoint in 8a0522f — pushed to `origin/main` by the user (CI run #1); the A14–A16 records in 6b31195; the F08-DEVOPS-PREP delivery in c592081 — pushed by the user (CI run #2, green); the A17 checkpoint in ebe59ce; the F08-BE8 delivery in 9f6b6e6 (not pushed). The A18 checkpoint and the A19 intake are in dfccce3; the held F08-DEVOPS-RULES in b2873cc. The A20 checkpoint is in 79d6c2d. The A21 intake and the F07 activation are uncommitted (documents only).
* **F08 unreadable-DB gap (found 2026-09-29):** fixed in F08-FE13 (beb7bfe) and accepted at the checkpoint; the runtime and automated evidence awaits independent QA (F08.UNREADABLE-DB). The Retry reconnect is delivered too. The one-frame Retry feedback (N2) stays a follow-up.
* **Migration partial-apply (found by F08-FE13, 2026-09-29):** Drift does not wrap `onUpgrade` in a transaction, so a failing step could leave a partial apply. It is fixed and accepted (F08 A6 ruling 1). The first real schema step must add its own real-file migration test.
* **Emulator suite (F08-BE6):** was 30 / 31 because of a contract-invalid fixture, not a handler defect; fixed in c70527a and accepted — 31 / 31 on Java 21 (first on `PATH`; setup-manifest).
* **Firestore rules bypass (F1, found by F08-QA-FUNCTIONAL 2026-09-29): CLOSED.** The rules let any signed-in client write its own `dailyResults` entry directly, under any bucket name. Nothing was deployed, so there was no live exposure. Ruled at A9 (no client access), fixed in F08-BE7 (cb96719), and closed by QA's own probe in F08-QA-FUNCTIONAL-R1 (A11). The deploy precondition is met.
* **CI is green (2026-09-29, F08 A17):** run `36597006854` on c592081 — all three jobs succeeded after the F08-DEVOPS-PREP repair (Java 21, format scope, Flutter 3.32.8, Xcode 16.4). Run #1's three causes are closed. **Limit:** the best-effort integration step failed inside the green `verify` job; it has no device target on CI and is not a gate until the first app-build release (CI-INTEGRATION-TARGET). The step logs need a GitHub sign-in and were not read.
* **Cloud Functions runtime (2026-09-29, F08 A17):** Node.js 20 is decommissioned on 2026-10-30 — no create / update after that date. The runtime moved to Node.js 22 in F08-BE8 (9f6b6e6, accepted at A18). The CI `infra` job pins Node 22 in F08-DEVOPS.
* **Host toolchain (2026-09-29, F08 A18):** installing `node@22` upgraded Homebrew's `simdjson` and broke the system `node` 24.7.0; with the user's choice the system `node` is now `node@24` 24.21.0, and `node@22` is keg-only. On this host an npm script runs the system Node whatever is first on `PATH`; local Node 22 checks start the tools directly (setup-manifest).
* **Public repository (2026-09-29, F08 A14):** `github.com/eyupdabakoglu92/Looplet` is public, with its whole history including `ai-system/`. No private key or token is tracked. The Firebase client configs (`google-services.json`, `GoogleService-Info.plist`) are public by design but now world-readable: restrict the API keys and plan App Check enforcement (F08 `release.md` §5; F08-PLATFORM-ATTESTATION). The live project has no Firestore rules release; client reads are denied by Firestore's implicit lock (read on 2026-09-29, F08 A20). The committed deny-all rules ship with the function deploy.

## Contract Version

Existing product/technical contracts retained; workflow schema updated from ai-system-core working tree.

## Pending Breaking Change

None introduced by this migration.

## Active Cross-Feature Contract Migration

None. This is workflow state normalization, not a code/schema/API migration.

## History Reference

[Original complete system-state](history/core-sync-2026-09-18/system-state.md) and [migration record](history/core-sync-2026-09-18/README.md). All pre-migration chronology and environment reports are retained.
