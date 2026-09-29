# F08 — offline-persistence-and-sync: Release Readiness

> Task: `F08-DEVOPS-PREP` · Role: DevOps/Release Engineer · Date: 2026-09-29
> Authority: project `release.md` (§2 F08 = `production-readiness`, §4 CI, §9 rollback, §10 pinning, §12 approval); `setup-manifest.md`; F08 `architecture.md` A9 ruling 6, A13 ruling 2, A14, A15, A16; `qa.md` § F08-QA-FUNCTIONAL-R1 / R2; `orchestration.md` → Current Brief.
> Previous version (2026-09-06, task F08-DEVOPS): `history/f08-offline-persistence-and-sync-2026-09-29/release-before-devops-prep.md`.

---

## 1. Feature / Release Summary

* **Release scope:** `production-readiness`. F08 is LOOPLET's first Firebase deploy — `submitDailyResultV1` (2nd-gen callable), `firestore.rules`, the Remote Config template. It is a backend-only gate.
* **Environment target:** `production` (`looplet-712e5`, the single MVP project). The emulator (`demo-looplet`) and CI are the pre-deploy validation surfaces.
* **The deploy is deferred** (F08.DEPLOY-AUTHORIZATION — B, A16). This turn ran no deploy, no billing change, no Remote Config or console change, and no push.
* **This turn:**
  1. the CI repair for run #1 (`36590316947`) — Java 21, TD-FORMAT-SCOPE, TD-CI-TOOLCHAIN, the Node 24 / Ubuntu notices;
  2. this `release.md` refreshed to the current contract;
  3. public-repository hygiene recommendations;
  4. the readiness verdict.
* **Outcome: Release Validation Pending.** Every CI job's steps pass locally on the repaired config. What is still missing: the CI run itself (the user pushes), the user's F08.DEPLOY-GO, the deploy, and the post-deploy smoke.

---

## 2. Impacted Files

| File | Change | Brief item |
| --- | --- | --- |
| `.github/workflows/ci.yml` | **`verify` + `ios-build`:** Flutter pinned to **3.32.8** through a workflow-level `FLUTTER_VERSION` (`flutter-version` input of the already-pinned `subosito/flutter-action`); a "Toolchain versions" step prints `flutter --version`. | 3 |
| | **`ios-build`:** `macos-14` → **`macos-15`**; a "Select Xcode 16.4" step selects `/Applications/Xcode_16.4.app` and prints `xcodebuild -version`. It fails with a clear error if the image no longer ships 16.4. A "Disable Swift Package Manager" step (`flutter config --no-enable-swift-package-manager`) keeps CocoaPods, as locally. | 3 |
| | **`infra`:** new step "Set up Java 21" — `actions/setup-java` (SHA-pinned, v6.0.1) with Temurin 21. It puts Java 21 first on `PATH` before the emulator step; the version step prints `node --version` and `java -version`. The stale "ubuntu ships a JDK" comments are corrected. | 1 |
| | **All jobs:** `actions/checkout` v4.2.2 (node20) → **v7.0.1** (node24), SHA-pinned. `ubuntu-latest` → **`ubuntu-24.04`**, so the 2026-10-19 switch to Ubuntu 26 cannot change the image silently. | 4 |
| `melos.yaml` | `format` → `dart format app packages tools`; `format:check` → `dart format --output=none --set-exit-if-changed app packages tools`. A comment gives the reason (TD-FORMAT-SCOPE). | 2 |
| `ai-system/project-authority/setup-manifest.md` | The canonical `format` / `format:check` lines (Step 1 and Canonical Verification Commands), and the Global constraints toolchain line: "pending" → "implemented", with the concrete CI pins. | 2, 3 |
| `infra/README.md` | Emulator section: Java 21 first on `PATH`, and CI's `setup-java`. It had said "ubuntu ships a JDK", which was wrong. Deploy prerequisites: the user's F08.DEPLOY-GO (A16) and a Node.js 20 runtime check (§10). Docs only. | 1, 5 |
| `ai-system/features/f08-offline-persistence-and-sync/release.md` | This refresh. The old version is archived byte for byte (history README entry added). | 5, 6, 8 |
| `ai-system/features/f08-offline-persistence-and-sync/evidence/devops-prep/` | **New:** the local gate logs DP-01…DP-13 and their README. | 7 |
| `ai-system/features/f08-offline-persistence-and-sync/orchestration.md` | Local fields only (ledger, owner, next role / action, Release Result, Delivery Review, Pending Evidence, Change Log). | — |

**Unchanged on purpose:**
* app / package / tool source; `infra/firestore.rules`; `infra/functions/**`; `remoteconfig.template.json`; `firebase.json`;
* every existing file under `ai-system/` evidence and QA — the two unformatted QA probes stay byte-identical;
* the project `release.md` (owner Tech Lead; see §3);
* dependency versions — no Flutter / Firebase / npm upgrade.

---

## 3. Release Authority Reconciliation

* **TD-FORMAT-SCOPE (A15) vs project `release.md` §4.** §4 still lists the format gate as `dart format --set-exit-if-changed .`. The Tech Lead's later decision wins: the gate now runs over `app packages tools`. Only the §4 wording is stale. The project `release.md` belongs to the Tech Lead, so it is not edited here (§10, N-1).
* **Project `release.md` §10 (SHA pinning):** met. The one new action (`actions/setup-java`) and the updated `actions/checkout` are pinned to commit SHAs. These are lightweight tags; `git ls-remote` shows the tag commit, and `action.yml` shows `runs.using: node24`.
* **Project `release.md` §4 (build gates):** `flutter build appbundle --release` and `flutter build ios --release --no-codesign` stay in CI unchanged.
  * The integration step stays best-effort (`continue-on-error`), as §4 says. A green `verify` job therefore does not prove the integration tests passed; its own step result has to be read.
* **Project `release.md` §6 / §9 and the F08 rollback — the kill-switch does not exist in release builds yet.**
  * `dailySyncEnabledProvider` (`app/lib/persistence/sync_providers.dart:42`) returns "on" in every non-debug build. The real Remote Config read is an F07 seam.
  * The old plan's "client kill-switch first" is therefore not available for the F08 deploy.
  * It is also not needed for F08. A release build has no daily-result producer: the only producer, `FakeDailyResultProducer`, is reachable only from the `kDebugMode` debug sync screen (`app_router.dart:49`). So a release build sends no traffic to the callable until F07 ships the Daily.
  * The rollback in §7 is written to this state (N-2).
* **`platform.md` §3 (Cloud Functions on Node.js 20) vs the calendar.** Node.js 20 reached upstream end-of-life on 2026-04-30, and `infra/functions/package.json` pins `engines.node: "20"`. Whether Google still accepts `nodejs20` deploys has to be checked against the Cloud Functions runtime schedule before the deploy. A runtime change is a platform decision, so it goes to the Tech Lead (§10, N-3). It does not affect CI: the tests run on the runner's Node (22 on `ubuntu-24.04`; locally 24).
* **QA:** `Functional Approved` (F08-QA-FUNCTIONAL-R2, accepted at A13). Every functional evidence record is PASS. This turn changed no code, so no functional evidence is invalidated. CI config, `melos.yaml` scripts and docs are not inputs of any functional record.

---

## 4. CI/CD Pipeline Plan

Workflow `CI` (`.github/workflows/ci.yml`). Triggers: `pull_request` to `main` and `push` to `main`. `concurrency` cancels in-progress runs of the same ref. No job deploys.

| Job | Runner | Toolchain (pinned / printed) | Steps | Gate effect | Failure behaviour |
| --- | --- | --- | --- | --- | --- |
| `verify` — format · analyze · test | `ubuntu-24.04` | Flutter 3.32.8 (`flutter --version` printed); melos ^6; JDK = runner default (17) for Gradle | bootstrap → `format:check` (`app packages tools`) → `analyze` → `test` → integration (best-effort) → content check → `build:app` (AAB) | required (project `release.md` §4) | any required step fails → job red → release blocked. The integration step cannot fail the job. |
| `infra` — functions build + test | `ubuntu-24.04` | Temurin **21** via `setup-java` (`java -version` printed); Node = runner (printed) | `npm ci` → `tsc` → offline tests → `emulators:exec` (firebase-tools@15, `demo-looplet`) running the rules + callable suites | required when `infra/` changes (§4); runs on every push | red → release blocked |
| `ios-build` — iOS release build (no codesign) | `macos-15` | **Xcode 16.4** selected + printed; Flutter 3.32.8 printed; CocoaPods; SPM disabled | select Xcode → Flutter → bootstrap → disable SPM → `flutter build ios --release --no-codesign` | required (§4 build) | red → release blocked; Xcode 16.4 missing → explicit error |

---

## 5. Environment & Config

### Environments

| Environment | Deploy mode | Config / secrets | Approval | Smoke / health | Rollback |
| --- | --- | --- | --- | --- | --- |
| local | manual | emulator `demo-looplet`, no secrets; Java 21 first on `PATH` (setup-manifest) | No | the setup-manifest emulator command (33 / 33) | n/a |
| ci | automated, gates only, **no deploy** | none (`demo-looplet` needs no auth) | No | the three jobs in §4 | n/a |
| production (`looplet-712e5`) | controlled, manual `firebase deploy` from an authenticated workstation | client configs are committed and not secret; deploy auth: see below | **Yes** — the user's F08.DEPLOY-GO + Tech Lead (`release.md` §12) | §8 S2–S4 + Cloud Functions error / latency | §7 |

### Secrets (names only)

| Name | Needed for | State |
| --- | --- | --- |
| `FIREBASE_CI_TOKEN` or a service-account key (`GOOGLE_APPLICATION_CREDENTIALS`) | an automated deploy workflow only | **NOT CONFIGURED** and not needed now. The deploy is manual. CI validation needs no auth. |
| `APP_STORE_CONNECT_API_*`, `PLAY_SERVICE_ACCOUNT_JSON` | app distribution | out of F08 scope (FIRST-APP-DISTRIBUTION) |

### Live project state

The last observation is from 2026-09-06: Spark plan; a `(default)` Firestore database created as a side effect of the dry-run; no functions deployed; Anonymous Auth enabled; App Check in monitor. **It was not re-verified this turn**, because reading it needs the user's account session. It is re-read at the start of F08-DEVOPS.

### Public-repository hygiene (A14 ruling 2 (e)) — recommendations; the console changes are the user's

The repository `github.com/eyupdabakoglu92/Looplet` is public. `google-services.json`, `GoogleService-Info.plist` and `firebase_options.dart` are Firebase client identifiers, not secrets (project `release.md` §7), but they are now world-readable. Recommended actions, in the Google Cloud console for `looplet-712e5` → APIs & Services → Credentials:

1. **Restrict each API key by application.**
   * The Android key → "Android apps": package `com.looplet.looplet_app` plus the SHA-1 of every signing certificate in use (today the debug certificate; the upload and Play signing certificates at FIRST-APP-DISTRIBUTION).
   * The iOS key → "iOS apps": bundle ID `com.looplet.loopletApp`.
2. **Restrict each key by API** to the Firebase APIs the app uses today: Identity Toolkit, Token Service, Cloud Firestore, Firebase Installations, Firebase App Check. Add Remote Config (F07) and Google Analytics (F12) when those features land.
   * An API missing from the list breaks that feature at runtime. After the change, run a debug build once against the real project (not the emulator) — anonymous sign-in, App Check token — before relying on it.
3. **Check the live Firestore rules.** The repository's rules (deny all client access, A9) have **never been deployed**. The `(default)` database on the project has had the console's rules since 2026-09-06, whatever they are. If they are not deny-by-default, the public config makes that database reachable.
   * The fix is a rules-only deploy of the committed `firestore.rules`. That is a deploy, so it needs the user's decision. The Tech Lead can offer it at F08.DEPLOY-GO as a rules-only first step; it needs no Blaze plan.
4. **App Check stays in monitor mode** (`platform.md`; `enforceAppCheck: false`). With a public config, anyone can call the callable once it is deployed and create anonymous users. The callable validates every payload and writes create-only, so the harm is bounded. Enforcement is planned in F08-PLATFORM-ATTESTATION; watch the App Check metrics after the deploy.

---

## 6. Deployment Plan

**Not executed — deferred** (A16). It runs in F08-DEVOPS only after the user's F08.DEPLOY-GO. The runbook is `infra/README.md` → Deploy. It was re-checked against the current code this turn:

1. **Prerequisites:**
   * F08.DEPLOY-GO (the user) + Tech Lead approval (`release.md` §12);
   * the Blaze plan with a budget alert — for the function only; rules and Remote Config deploy on Spark;
   * the Node.js 20 runtime check (§3);
   * a green CI run at the deploy revision (S1).
2. `cd infra && firebase deploy --only functions,firestore:rules,remoteconfig --project looplet-712e5 --dry-run`
3. `firebase deploy --only firestore:rules,remoteconfig --project looplet-712e5` — the rules deny all client access, and the app never writes Firestore directly, so there is no ordering hazard. The Remote Config template publishes the three switches `true` and `daily_manifest_url` empty (F07 fills it); it overwrites any console edits.
4. `firebase deploy --only functions --project looplet-712e5` → `submitDailyResultV1`, `us-central1`, `maxInstances: 10`, `enforceAppCheck: false`.
5. `firebase functions:list --project looplet-712e5`, then the smoke S2–S4.

* **Migration:** none server-side. The Drift forward-only migration ships in the app build, not in this deploy.
* **Rollout:** all at once. The function is stateless and release builds send it no traffic before F07 (§3).

---

## 7. Rollback Plan

| Trigger | Action | Verification |
| --- | --- | --- |
| Bad function build (5xx > 2 % over 5 min, or a smoke S3 failure) | Redeploy from the previous commit: `firebase deploy --only functions --project looplet-712e5`. If there is no previous version (this is the first deploy): `firebase functions:delete submitDailyResultV1 --project looplet-712e5`. The client treats NOT_FOUND / INTERNAL / UNAVAILABLE as retryable (`callable_sync_sender.dart`). Queue items stay local, back off, and park at the attempt cap; parked items are retried on app start. Nothing is lost. | `functions:list`; S3 against a scratch uid on the redeployed function |
| Bad rules shipped | `firebase deploy --only firestore:rules --project looplet-712e5` from the previous commit (for the first deploy: the committed deny-all rules are already the safe state). | The rules dry-run is in sync; then **smoke S2**: a direct client create is denied (own entry, invalid payload, non-date bucket, another user, unauthenticated); update / delete / read are denied; **the callable creates** (S3). *Replaces the old check "create-own allowed / create-other denied" (A9 ruling 6).* |
| Bad Remote Config value | Re-publish `remoteconfig.template.json` from the previous commit (`firebase deploy --only remoteconfig`). | `firebase remoteconfig:get --project looplet-712e5` |
| Kill the sync client-side | **Not available in release builds before F07** — the client does not read Remote Config yet (§3). Not needed for F08: release builds send no daily results. F07 must wire it before the Daily ships. | — |
| On-device data | Forward-fix only (project `release.md` §9). The never-drop guard and the forward-only migration are the safety net. Firestore `dailyResults` are create-only; a bad batch gets a one-off admin script. | migration tests green in the shipping build |

* **RTO:** function or rules redeploy < 30 min. **Owner:** DevOps/Release Engineer.

---

## 8. Observability & Smoke Validation

The smoke list, re-checked against the current rules and code. It is run in F08-DEVOPS after the deploy. **Required class:** runtime / repeatable integration as marked.

| # | Scenario | Pass criteria | Class / target |
| --- | --- | --- | --- |
| S1 | **CI green at the deploy revision** | All three jobs succeed. The `infra` log shows Java 21, and the emulator step runs the rules suite and the callable suite with 0 skipped.<br>**Rules suite (8):** a direct client create is denied for the own valid entry, an invalid payload, a non-date bucket, another user's entry and an unauthenticated caller; update, delete and read are denied.<br>**Callable suite:** CREATED; ALREADY_SUBMITTED with the doc unchanged; per-uid scoping; unauthenticated → no write; invalid → no write. | repeatable integration / GitHub Actions |
| S2 | **Live rules deny every client path** | Against `looplet-712e5`, a Firestore REST `createDocument` under `dailyResults/{lang}_{date}/entries/{uid}` returns 403 `PERMISSION_DENIED` in all five cases: with an anonymous ID token for the own uid, with an invalid payload, in a non-date bucket, for another uid, and with no token. A GET, PATCH and DELETE on the S3 document → 403. | runtime / production |
| S3 | **The callable creates, exactly once** | A **debug** build without the emulator define, pointed at the real project: the debug sync screen runs the fake producer → `CREATED`, exactly one doc at `dailyResults/{lang}_{date}/entries/{uid}`, `syncStatus = synced`. A repeat submit → `ALREADY_SUBMITTED`, the doc byte-unchanged, local `firstRun*` unchanged. | runtime / device or simulator + production |
| S4 | **App smoke on the smoke build** (project `release.md` §8, scoped to what exists before F07) | Journey level 1 completes; background + relaunch → exact resume. Daily open / submit is F07. | runtime / device or simulator |

* **Now covered elsewhere — no longer smoke items:**
  * storage-full → F08.STORAGE PASS (automated fault injection, `app/test/persistence/storage_full_test.dart`);
  * offline Journey (AC2) → F08.OFFLINE-JOURNEY PASS (R2);
  * resume fidelity and lifecycle → F08.LOCAL-RESUME / F08.LIFECYCLE PASS;
  * exactly-once and the kill-switch against the emulator → F08.EMULATOR PASS (R1).
* **Signals:**
  * Cloud Functions error rate and p95 latency (console); alert on 5xx > 2 % over 5 min (`release.md` §8);
  * App Check metrics in monitor mode (§5 item 4).
  * Crashlytics / GA4 belong to F12 and app distribution.

---

## 9. Gate Evidence

Local evidence: `evidence/devops-prep/` (README gives the revision and the host). Revision: HEAD `6b31195` plus this turn's working-tree changes. Time: 2026-09-29 15:57–16:05Z.

| Gate / Claim | Evidence Class | Command / Job | Target / Environment | Result / Exit / Counts | Provenance | Isolation / Skips |
| --- | --- | --- | --- | --- | --- | --- |
| Format (TD-FORMAT-SCOPE) | static inspection | `melos run format:check` | local, Dart 3.8.1 | exit 0; 194 files, 0 changed | DP-02 | — |
| Format — negative | static inspection | an unformatted `app/lib` probe + `format:check` | local | exit 1, probe caught; probe removed | DP-03 | — |
| Format — old scope reproduces run #1 | static inspection | `dart format … .` | local | exit 1; exactly the two `ai-system/` probes | DP-01 | output=none; nothing rewritten |
| Analyze | static inspection | `melos run analyze` | local | exit 0; no issues | DP-05 | — |
| Unit / widget tests | unit | `melos run test` | local, Flutter 3.32.8 | exit 0; content 17, core 22, dictionary 32, solver 23, authoring 25, engine 83, app 588 | DP-06 | no skips reported |
| Content check | static inspection | authoring `check ../../content` | local | exit 0 | DP-07 | — |
| Build — Android AAB | build | `./gradlew bundleRelease`, Java 17 (the runner default) | local | BUILD SUCCESSFUL; `app-release.aab` 48.2 MB | DP-08b | `melos run build:app` itself fails locally: Flutter picks Android Studio's JBR 25, and Gradle 8.12 cannot run on it (DP-08a; §10 N-4) |
| Build — iOS no-codesign | build | `flutter build ios --release --no-codesign` | local, Xcode 16.4, CocoaPods, SPM off | exit 0; `Runner.app` 56.0 MB | DP-09 | build ≠ boot |
| Functions build + offline tests | build / unit | `npm ci`, `run build`, `test` | local, Node 24 | exit 0; 18 passed, 15 emulator-skipped | DP-10, DP-11 | the skips are the emulator suites, run next |
| Rules + callable suites | repeatable integration | the CI `emulators:exec` command, Java 21 first on `PATH` | local emulator `demo-looplet` | exit 0; 3 / 3 suites, **33 / 33** tests | DP-12 | offline emulator |
| Java 21 requirement — negative | repeatable integration | the same command, Java 17 first on `PATH` | local | exit 1; "no longer supports Java version before 21" (= run #1) | DP-13 | — |
| Workflow file | static inspection | Ruby YAML parse of `ci.yml` | local | 3 jobs (`verify` 11 steps, `infra` 7, `ios-build` 8); `env.FLUTTER_VERSION = 3.32.8` | this turn | parse only, not a run |
| **CI run after the repair** | CI | workflow `CI` on push to `main` | GitHub Actions | **PENDING / NOT RUN** — the user pushes (asked in chat; answer: "Ben push'layacağım") | — | the fix counts only after a green run (A16 ruling 4) |
| Functional acceptance | runtime + integration (QA) | F08-QA-FUNCTIONAL-R1 / R2 | emulator + simulator | Functional Approved; every functional record PASS | `qa.md` § R1 / R2; `qa/functional-r1/`, `qa/functional-r2/` | QA's limits: N1-R2 (levels 4–30 not opened offline) |
| Deploy | — | runbook §6 | production | **NOT EXECUTED** — deferred (A16) | — | — |
| Post-deploy smoke S2–S4 (F08.DEPLOY-SMOKE) | runtime | §8 | production | **PENDING** | — | — |
| Rollback plan | documented | §7 | — | written to the current rules and code | this file | not exercised |

---

## 10. Release Risks

### Blocking — `Release Ready` is impossible until these clear

1. **The CI run after the repair.** It has not run yet; the user pushes. Record the run id, every job's conclusion, the integration step's own result, and the printed Flutter / Xcode / Java versions. Owner: DevOps/Release Engineer (or the Tech Lead at the checkpoint — the run is readable on the public repository without signing in).
   * If a job is red: the `verify` job has never run past its format step on CI (run #1 stopped there). So analyze, test, the integration step, the content check and the AAB build meet CI for the first time now.
2. **F08.DEPLOY-GO** — the user's deploy decision (the Tech Lead opens it at the PREP checkpoint), then the deploy and smoke S2–S4 (F08.DEPLOY-SMOKE). Owner: user → DevOps/Release Engineer.

### Needs a Tech Lead decision (non-blocking for this prep)

* **N-1 — the project `release.md` §4 format line** still reads `dart format --set-exit-if-changed .`. It should read `app packages tools` (TD-FORMAT-SCOPE). The Tech Lead owns that file.
* **N-2 — no kill-switch in release builds before F07.** The F08 deploy is safe without it: no release-build producer exists (§3). F07 must wire the Remote Config read before the Daily ships. That belongs in the F07 contract / follow-ups.
* **N-3 — the Node.js 20 Cloud Functions runtime** (`platform.md` §3; `engines.node: "20"`) is past upstream end-of-life (2026-04-30). Check deployability before F08.DEPLOY-GO. A runtime bump is a dependency / platform change that needs its own regression run (the emulator suite).
* **N-4 — the local Android build JDK.** On this machine `melos run build:app` fails: Flutter uses Android Studio's bundled JBR 25, and Gradle 8.12 supports Java ≤ 23. CI is not affected (JDK 17).
  * Options for the setup-manifest: record `flutter config --jdk-dir <JDK 17 or 21>` as a local prerequisite — a global Flutter setting, so the user's call — or plan a Gradle / AGP upgrade.
  * Not done here: it changes the user's environment.
* **N-5 — the live Firestore rules are unknown** (§5 item 3). A rules-only deploy of the deny-all rules needs no Blaze plan. It could be offered as a separate, earlier step of F08.DEPLOY-GO.

### Non-blocking notes

* **CocoaPods:** the `macos-15` image has CocoaPods 1.17.0; `Podfile.lock` was written by 1.16.2. The dependency manager is the same; the lock header may differ. CI does not commit.
* **Ubuntu:** the Ubuntu jobs are pinned to `ubuntu-24.04`. Revisit when GitHub announces that image's retirement.
* **npm audit:** `npm ci` reports 14 moderate advisories (advisory gate, `release.md` §10); the upgrade pass belongs to a release.
* **Public repository:** the §5 hygiene items are recommendations; the console changes are the user's.
* **App Check:** iOS App Attest and the Android Play Integrity release SHA-256 stay deferred to app distribution; App Check is monitor-only.

---

## 11. Release Readiness Verdict

### **Release Validation Pending**

* **Ready now:**
  * the CI repair is in place and every CI step passes locally on the repaired config, with named negatives for the format scope and Java 21;
  * the runbook, rollback and smoke are aligned to the deny-all rules (A9) and to the real kill-switch state;
  * functional QA is approved.
* **Not Release Ready:** no CI run has proved the repair yet, the deploy is deferred, and the post-deploy smoke (F08.DEPLOY-SMOKE) cannot run without a deploy (A16 ruling 5).
* **Not Release Blocked:** no required gate has failed on the repaired config, and a rollback plan exists.
* **What remains, exactly:**
  1. a green CI run after the user's push (S1 at that revision);
  2. F08.DEPLOY-GO (the user, opened by the Tech Lead);
  3. the deploy per §6 in F08-DEVOPS;
  4. smoke S2–S4 → F08.DEPLOY-SMOKE;
  5. F08-QA-FINAL.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-DEVOPS-PREP — brief items 1–6 and 8; item 7 locally (DP-01…13), with the CI run pending the user's push.
* **Remaining Tasks:** the CI run after the push; F08.DEPLOY-GO; F08-DEVOPS (deploy + smoke); F08-QA-FINAL.
* **Blockers:** none for the checkpoint. N-1…N-5 need Tech Lead rulings.
* **Status Suggestion:** Ready for Tech Lead Review.

---

## 12. Sonraki Komut

```
Run Tech Lead
```
