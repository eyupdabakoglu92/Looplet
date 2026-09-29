# Project Release Authority — LOOPLET

Last Updated: 2026-09-29 (F08 A17: §4 format scope = `app packages tools` (TD-FORMAT-SCOPE); §4 integration-test gate clarified (TD-CI-INTEGRATION-GATE); §2 F08 kill-switch note). 2026-09-06 (§2 — F08 fires the first Firebase-infra release gate)
Owner: Tech Lead

---

# 1. Purpose

Defines CI/CD gates, environments, store distribution, signing, privacy-manifest ownership, rollback, and release evidence for LOOPLET. Stack/runtime authority is separate: `/ai-system/project-authority/platform.md`.

---

# 2. Release Applicability

* Release gate required: **Conditional**.
* Applies to: mobile app store distribution (iOS TestFlight/App Store, Android Play Internal/Production) and Firebase Cloud Functions / Firestore rules / Remote Config deploys.
* Conditional rule:
  * **No release gate** for changes confined to pure-Dart packages or tooling with no client-distributable surface and no infra change (CI gates still run).
  * **Release gate required** when a change produces a new distributable app build, or touches Cloud Functions, Firestore rules, Remote Config, or content packs served to clients.
* F01 (`dictionary-service`), F02 (`grid-engine`), F06 (`puzzle-content-and-solver-tooling`) Release Scope: `none` — internal library / build-time tooling, no distributable surface (CI gates still run).
* **F08 (`offline-persistence-and-sync`) Release Scope: `production-readiness`.** F08 is the **first Firebase deploy** for LOOPLET — it touches Cloud Functions (`submitDailyResultV1`), Firestore rules, and Remote Config, which per the §2 conditional rule requires a release gate. This is a **backend-only** gate (functions + rules + Remote Config to the Firebase project), separate from and earlier than the first **app-build** distribution gate (still expected around F03/F05). A `DevOps/Release Engineer` task opens after F08 QA passes; it must also cover rollback-readiness: functions redeploy-previous, the `daily_sync_enabled` kill-switch, and the fact that the Drift on-device forward migration has **no downgrade** (mitigation: migration tests + staged rollout + the never-drop guard).
  * **2026-09-29 (F08 A17, N-2):** the `daily_sync_enabled` kill-switch is not read by release builds before F07 (`dailySyncEnabledProvider` is always on outside debug; the real Remote Config read is an F07 seam). The F08 deploy does not need it: release builds contain no daily-result producer (the fake producer is reachable only from the `kDebugMode` debug route), so they send the callable no traffic. The F08 rollback is function / rules redeploy or delete (feature `release.md` §7). **F07 must wire the Remote Config read before the Daily ships** — a release-blocking F07 obligation (workflow-follow-ups F07-KILL-SWITCH).

---

# 3. Environments

| Environment | Purpose | Deployment Mode | Approval Required | Notes |
| --- | --- | --- | --- | --- |
| local | developer workstation | manual | No | Flutter run, Firebase emulator suite |
| ci | PR validation (gates only, no deploy) | automated | No | GitHub Actions |
| internal-testing | TestFlight + Play Internal testing track | automated (Fastlane) | No | dogfood / QA runtime proof |
| content-staging | daily content pack validation | manual | No | separate Cloud Storage path `daily-staging/`; validated by authoring tool before promotion |
| production | App Store + Play production; production Firebase project | controlled | Yes | phased rollout |

* There is no traditional server "staging" — the backend is Firebase managed services. Function/rules changes are validated in the emulator and (optionally) a separate Firebase project before production deploy.

---

# 4. CI/CD Gate Policy

Required gates (GitHub Actions, on every PR to `main`):

* install / dependency restore — `melos bootstrap`
* format — `dart format --output=none --set-exit-if-changed app packages tools` (`melos run format:check`). Scope = the Dart code the workspace owns; evidence under `ai-system/` is a record and is never reformatted (F08 A15 TD-FORMAT-SCOPE; this line corrected at A17)
* lint / analyze — `flutter analyze` + `dart analyze` for each package
* unit tests — `flutter test` (app) + `dart test` (every package); `looplet_solver` optimality-vs-brute-force suite must pass
* integration tests — `integration_test` on a CI emulator (best-effort gate for the MVP; failure is investigated, not auto-blocking until F03 lands)
  * **Clarified 2026-09-29 (F08 A17, TD-CI-INTEGRATION-GATE):** F03 has landed, but CI has no emulator / simulator target — the `verify` step runs `flutter test integration_test/` headless on Ubuntu with `continue-on-error`, and it failed on its first run (`36597006854`). It is therefore **not a gate yet**: a green `verify` job never counts as an integration PASS. It becomes a **required gate at the first app-build release gate** (FIRST-APP-DISTRIBUTION), on a real emulator / simulator target. Until then the F03 play-session behaviour is gated by the required mirror `app/test/play/play_session_runtime_test.dart` (`melos run test`) and by runtime QA. Backend-only releases (F08) do not depend on it. Follow-up: CI-INTEGRATION-TARGET.
* build — `flutter build appbundle --release` and `flutter build ios --release --no-codesign`
* Firestore rules tests — `@firebase/rules-unit-testing` (when `infra/` changed)
* Cloud Functions build + test — `npm ci && npm run build && npm test` in `infra/functions` (when changed)
* dependency audit — `flutter pub outdated` + `npm audit` (advisory; note with owner, non-blocking)

Gate rule:

* Required gate fail → release blocked.
* Required gate missing → release validation pending.
* Optional/advisory gate missing → note with owner.

---

# 5. Branch / Version / Promotion Strategy

* Branch strategy: trunk-based. Short-lived feature branches, PR into `main`. `main` is always releasable.
* Versioning: app `x.y.z+build` (semantic + monotonic build number). Content packs versioned by `contentVersion` independently.
* Artifact naming: `looplet-<version>+<build>-<platform>`.
* Promotion path: `ci` → `internal-testing` → `production` (phased). Content: `content-staging` → `production` via Remote Config manifest repoint.
* Release notes source: PR titles + `feature-board.md` Done entries, curated into a CHANGELOG per release.

---

# 6. Deployment Strategy

* Provider / platform: App Store Connect (iOS), Google Play Console (Android), Firebase (functions, rules, Remote Config, Cloud Storage).
* Deployment command or pipeline: Fastlane lanes — `beta` (→ TestFlight + Play Internal), `release` (→ store review + phased release). `firebase deploy --only functions,firestore:rules,storage` for infra.
* Rollout strategy: phased — Play staged rollout (e.g., 10% → 50% → 100%), App Store phased release (7-day default). Firebase functions: all-at-once (stateless), previous version retained for redeploy.
* Feature flag strategy: Firebase Remote Config. Required kill-switches for the MVP: `daily_enabled`, `daily_sync_enabled`, `share_enabled`.
* Migration strategy: Drift on-device migrations are forward-only and ship inside the app build. Firestore schema changes are additive. Content changes ship via Remote Config manifest repoint (no app release needed).
* Backward compatibility rule: a new app build must read the previous Drift schema and the current + previous content `schemaVersion`. Never ship a migration that drops `personal_best` / `daily_streak` / first-run `daily_entry` rows.

Containerization / runtime packaging:

* Containerization required: No. (Mobile app; Firebase functions deployed via Firebase CLI.)
* Dockerfile / Compose / image build / registry / scan: N/A.

Mobile app store distribution:

* Build pipeline: GitHub Actions + Fastlane (`gym`/`build_app` for iOS, `gradle` bundle for Android).
* Xcode archive/export and code signing owner: DevOps/Release Engineer.
* Provisioning profile / certificate source: App Store Connect API key (cloud signing / `match` optional). Names only: `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY`.
* TestFlight distribution policy: every `internal-testing` build to the internal tester group automatically; external testing not used in the MVP.
* App Store Connect metadata owner: DevOps/Release Engineer (copy from Product Owner).
* IAP product catalog sync owner: N/A — no IAP in the MVP.
* Privacy Manifest (`PrivacyInfo.xcprivacy`) update owner: DevOps/Release Engineer, with Frontend/Mobile Developer input on API-reason codes. Declares **no tracking**, no IDFA.
* ATT usage description owner: N/A — ATT not used (no tracking SDK, no IDFA collection).
* dSYM / symbol upload: automated in CI to Crashlytics on every `internal-testing` and `production` build.

---

# 7. Secrets & Configuration

Rules:

* Secret values are never stored in the repo. Only names are documented.
* Environment-specific config validated before deploy.
* Firebase client config (`firebase_options.dart`, `GoogleService-Info.plist`, `google-services.json`) is not secret and is committed per environment flavor.

Required secrets / env vars:

| Name | Environment | Owner | Purpose | Required |
| --- | --- | --- | --- | --- |
| APP_STORE_CONNECT_API_KEY_ID | ci / production | DevOps/Release Engineer | iOS signing + upload | Yes |
| APP_STORE_CONNECT_API_ISSUER_ID | ci / production | DevOps/Release Engineer | iOS signing + upload | Yes |
| APP_STORE_CONNECT_API_KEY | ci / production | DevOps/Release Engineer | iOS signing + upload (p8 contents) | Yes |
| PLAY_SERVICE_ACCOUNT_JSON | ci / production | DevOps/Release Engineer | Play upload + staged rollout | Yes |
| FIREBASE_CI_TOKEN | ci / production | DevOps/Release Engineer | `firebase deploy` for functions/rules/config | Yes |
| MATCH_PASSWORD | ci | DevOps/Release Engineer | only if `fastlane match` is used for iOS certs | Conditional |

---

# 8. Observability & Health

* Health: no server health endpoint (managed BaaS). Function health = Cloud Functions error rate + latency dashboards.
* Readiness check: n/a (no self-hosted service).
* Smoke test (post-deploy, every release): install the build on a device/emulator, complete the onboarding tutorial + Journey Level 1, open the Daily, background+relaunch and confirm exact resume, submit a daily result and confirm the Firestore create-only write.
* Logs: Crashlytics (client crashes/ANRs), Cloud Logging (functions).
* Metrics: Firebase Analytics (GA4) for KPIs; crash-free users %; function error rate.
* Alerts: crash-free users < 99% (rolling 24h); Cloud Functions 5xx rate > 2% (5-min window); Remote Config kill-switch toggled (informational).

---

# 9. Rollback / Recovery

* Rollback trigger: crash-free users drop below 98%, a KPI-breaking regression, or a broken Daily.
* Rollback command / action:
  * App binary: halt Play staged rollout / pause App Store phased release; ship an expedited hotfix build (no true binary rollback exists).
  * Daily / sync regression: toggle `daily_enabled` / `daily_sync_enabled` Remote Config kill-switch (no release needed).
  * Content pack regression: repoint `daily_manifest_url` Remote Config to the previous pack.
  * Cloud Functions: `firebase functions:delete` + redeploy previous, or deploy the prior commit.
* Data rollback / forward-fix policy: on-device data is never server-rolled-back; forward-fix only. Firestore `dailyResults` are create-only and low-risk; a bad batch is corrected by a one-off admin script, not a rollback.
* Recovery time objective: kill-switch effective within one Remote Config fetch cycle (< 12h default; force-fetch on resume). Hotfix build target < 48h to internal testing.
* Owner: DevOps/Release Engineer.
* Verification after rollback: re-run the post-deploy smoke test; confirm crash-free users recovering; confirm Daily loads and completes.

---

# 10. Supply Chain & Artifact Integrity

* Lockfile policy: `pubspec.lock` (app + every package) and `package-lock.json` (functions) committed and required green in CI.
* Dependency audit policy: `flutter pub outdated` + `npm audit` on every PR (advisory); a tracked upgrade pass each release.
* Artifact provenance/signing: store-managed signing (App Store Connect API, Play App Signing).
* Container/image scan: N/A.
* Third-party GitHub Action pinning: actions pinned to a commit SHA, not a floating tag.

---

# 11. Release Evidence Requirements

Every release artifact (`features/{feature}/release.md`) must include:

* CI gate results (format, analyze, unit, integration, build).
* Environment target (`internal-testing` / `production`).
* Deploy or dry-run evidence (Fastlane / `firebase deploy` output).
* Smoke/health evidence (the Section 8 smoke test run on a device/emulator).
* Rollback plan for the specific change (which kill-switch / manifest / redeploy).
* Unresolved risks.

---

# 12. Change Management

* Owner: Tech Lead.
* Approval policy: `internal-testing` needs no approval; `production` needs explicit Tech Lead approval and a passing smoke test. Production deploy is never the default and is not considered done without explicit approval.
* Incident escalation path: `Run Tech Lead. Incident: <description>` → triage → rework/reopen/cross-feature per the role execution contract.
* Active feature reassessment rule: a release policy change while a feature is `In Release` pauses that feature until its `release.md` is reconciled.
