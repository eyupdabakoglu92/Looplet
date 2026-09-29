# F08 — offline-persistence-and-sync: Release Readiness

> Task: `F08-DEVOPS` · Role: DevOps/Release Engineer · Date: 2026-09-06
> Authority: `project-authority/release.md` (§2 F08 = `production-readiness`), `architecture.md` (LOCKED — Firebase Sync Surface, App Init Sequence, Release/Deployment Impact), `qa.md` (verdict `Runtime Validation Pending` + §17 pending scenarios), `orchestration.md` (Active Task Ledger → F08-DEVOPS).

---

## 1. Feature / Release Summary

* **Release Scope:** `production-readiness` — the **first Firebase deploy** for LOOPLET. Surfaces: `submitDailyResultV1` (Cloud Function, 2nd gen), `firestore.rules` (create-only `dailyResults/**`), Remote Config (`daily_enabled` / `daily_sync_enabled` / `share_enabled` / `daily_manifest_url`). **Backend-only** gate — distinct from and earlier than the first app-build distribution gate (still ~F03/F05).
* **Environment target:** `production` (the single MVP Firebase project `looplet-712e5`; there is no separate backend "staging" — `release.md` §3). Emulator (`demo-looplet`) is the pre-deploy validation surface.
* **Purpose of this turn:** (A) release-readiness prep + dry-run evidence; (B) fold the `qa.md §17` runtime + emulator scenarios into the `release.md` §8 device smoke; (C) this verdict.
* **Outcome:** **Release Validation Pending.** Config is substantially ready and every offline/build/compile gate is green, but the actual deploy is blocked on a **billing-plan upgrade (Spark → Blaze)** and requires **explicit Tech Lead approval** (`release.md` §12). No device/JDK here → the QA runtime + emulator scenarios remain to be executed against the CI job + a build. No blocking *code* defect (QA confirmed).

---

## 2. Impacted Files

**Updated (this turn):**

| File | Change | Why |
| --- | --- | --- |
| `infra/firebase.json` | added a `"remoteconfig": { "template": "remoteconfig.template.json" }` block | without it `firebase deploy --only remoteconfig` errors `No targets in firebase.json match`; the kill-switch template (`release.md` §6) was unreachable by the CLI. Dry-run now passes. |
| `infra/README.md` | rewrote the "Not done yet" section → "Deploy runbook (F08-DEVOPS)" + recorded the Blaze-plan requirement and the live project state | the DURUM 0 note was stale (project now exists); the deploy prerequisites + commands belong in the repo next to the config. |
| `ai-system/features/f08-offline-persistence-and-sync/release.md` | **new** — this artifact | `release.md` §11 requires a per-feature release artifact. |
| `ai-system/features/f08-offline-persistence-and-sync/orchestration.md` | local fields only — `F08-DEVOPS` ledger item, `Blockers`, `Current Status`, `Current Owner`, `Next Role`, `Next Action`, `Change Log` | delivery-role local orchestration update (`prompt-delivery-footer-standard.md`). `feature-board.md` / `system-state.md` untouched (Tech Lead syncs those). |

**Not changed (deliberately):**

* `.github/workflows/ci.yml` — the `infra` job (functions build + offline test + emulator `emulators:exec --project demo-looplet`) is already correct and complete for a **gates-only** CI (`release.md` §3: "ci — PR validation, no deploy"). **No deploy job was added** — a production `firebase deploy` is approval-gated and must not run unattended, and adding a half-wired deploy workflow would be the stub-config the DevOps prompt forbids. The deploy path is documented as a runbook instead (§6).
* `infra/firestore.rules`, `infra/firestore.indexes.json`, `infra/functions/**` — verified, no change needed (rules compile; functions build + offline tests green; `enforceAppCheck: false` confirmed in `index.ts`).

---

## 3. Release Authority Reconciliation

* **`release.md` §2** — F08 `production-readiness`, backend-only Firebase gate, `F08-DEVOPS` opens after QA. Honored. §12 — production deploy needs **explicit Tech Lead approval + a passing smoke test**; neither exists yet → this turn does **not** deploy.
* **`release.md` §4** — CI gate list. The `infra` job covers `infra/functions` `npm ci && build && test` + the `@firebase/rules-unit-testing` + callable emulator suites (via `emulators:exec`). Present and correct. Deploy is explicitly **not** a CI gate (§3).
* **`release.md` §6** — deploy command `firebase deploy --only functions,firestore:rules` + Remote Config kill-switches `daily_enabled` / `daily_sync_enabled` / `share_enabled`. All four keys are in `remoteconfig.template.json`; the `firebase.json` wiring gap is now fixed. Forward-only Drift migration + never-drop guard already in the app build (F08-FE2).
* **`release.md` §7** — `FIREBASE_CI_TOKEN` (name only; **not configured** — deferred to this phase per the user). See §5; still `NOT CONFIGURED` — a repo-secret action the user owns, plus `firebase login:ci` tokens are now deprecated by Google (service-account auth is the forward path). Runbook in §6.
* **`platform.md` §6/§13** — App Check **soft-enforce / monitor** for the whole MVP. `submitDailyResultV1` ships `enforceAppCheck: false`; the client activates the debug provider in dev and Play Integrity / App Attest in release, wrapped so failure is a logged no-op. **Nothing to enforce or hard-gate this turn.** Not changed.
* **`qa.md` verdict `Runtime Validation Pending`** — no code rework; the six §17 pending scenarios are folded into §8 below (device/emulator smoke) as the runtime-closure checklist for this release gate. A DevOps/Release Engineer cannot override a QA verdict; this artifact carries the runtime work forward, it does not re-adjudicate it.
* **Conflict:** none between authority docs. The one blocker (**Spark plan**) is an external project-state fact, not a doc conflict — escalated to Tech Lead / user in §10.

---

## 4. CI/CD Pipeline Plan

Only the `infra` job is in scope; it was delivered by F08-BE5 and is **unchanged** this turn — re-stated here as the release gate of record.

| Job | Trigger | Commands | Gate effect | Failure behavior |
| --- | --- | --- | --- | --- |
| `infra` | PR to `main` + push to `main` | `npm --prefix infra/functions ci` → `run build` (tsc) → `test` (offline: 18 tests) → `npx --yes firebase-tools@15 emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` (un-skips `rules.test.ts` + `submitDailyResult.test.ts` — 13 tests) | **Required** for any change touching `infra/**` (`release.md` §4). The emulator step is the `repeatable integration` evidence class `architecture.md → QA Focus` mandates. | Required-gate fail → release blocked (`release.md` §4). |

* **No auth / no token needed** for this job — `--project demo-looplet` is a fully offline emulator project. `FIREBASE_CI_TOKEN` is **not** required for CI validation; it is only required by a (future, not-yet-existing) deploy workflow.
* **Not executed this turn:** the emulator step needs a JDK; the dev machine has none (`java -version` → "Unable to locate a Java Runtime"). ubuntu-latest ships a JDK, so CI runs it. This is the same CI-only posture as `build:app` (Android) and the iOS release build. Confirming it green on the F08 branch is a `Run` of the GitHub Actions workflow — it could not be triggered from this environment (no `gh`, nothing pushed).

---

## 5. Environment & Config

### Environments (`release.md` §3)

| Environment | Deploy mode | Config / secrets | Approval | Smoke / health | Rollback expectation |
| --- | --- | --- | --- | --- | --- |
| local | manual | Firebase emulator suite (`demo-looplet`), no secrets | No | `npm test` + `emulators:exec` (needs a JDK locally) | n/a |
| ci | automated, **gates only, no deploy** | none (emulator project) | No | the `infra` job | n/a |
| production (`looplet-712e5`) | **controlled** — `firebase deploy` by DevOps, **Tech Lead approval required** | `FIREBASE_CI_TOKEN` **or** a service-account key (see below); client config files (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`) — **not secret, committed** | **Yes** (`release.md` §12) | §8 device smoke + Cloud Functions error-rate / latency dashboards | functions redeploy-previous; `daily_sync_enabled` kill-switch; no Drift downgrade |

### Secrets / config (names only — no values)

| Name | Environment | Owner | Purpose | State |
| --- | --- | --- | --- | --- |
| `FIREBASE_CI_TOKEN` | ci / production | DevOps/Release Engineer | `firebase deploy` auth for functions / rules / Remote Config from a non-interactive workflow | **NOT CONFIGURED.** Deferred to this phase per the user. Action: the repo owner adds it as a GitHub Actions secret. **Note:** `firebase login:ci` tokens are deprecated by Google; the forward-compatible option is a **Google Cloud service account** with roles `roles/firebasedeploy` + `roles/cloudfunctions.developer` + `roles/firebaserules.admin`, its JSON key stored as `GOOGLE_APPLICATION_CREDENTIALS` (file) / a base64 secret, and `firebase deploy` run with `GOOGLE_APPLICATION_CREDENTIALS` set (no `--token`). Either is a value the user provisions; not creatable here. |
| Firebase client config files | all | Frontend/Mobile Developer | app ↔ Firebase wiring | **PRESENT + COMMITTED** — `app/lib/firebase_options.dart`, `app/android/app/google-services.json`, `app/ios/Runner/GoogleService-Info.plist`, `infra/.firebaserc` (`default → looplet-712e5`). Verified by the Tech Lead on the Firebase-project incident. |
| App Store / Play signing secrets (`APP_STORE_CONNECT_API_*`, `PLAY_SERVICE_ACCOUNT_JSON`, …) | ci / production | DevOps/Release Engineer | app-build distribution | **OUT OF SCOPE for F08** (backend-only gate). Belongs to the first app-distribution release (~F03/F05). Listed in `release.md` §7. |

### Live project state observed this turn (`looplet-712e5`)

* Billing plan: **Spark (free).** → **blocks Cloud Functions deploy** (see §10).
* `firestore.googleapis.com`: **enabled** and a `(default)` Firestore database exists (STANDARD / `FIRESTORE_NATIVE`). This was triggered as a prerequisite during the `firebase deploy --dry-run` (the CLI enables required APIs even in dry-run). Benign and required by F08 regardless.
* `cloudfunctions.googleapis.com` / `cloudbuild.googleapis.com` / `artifactregistry.googleapis.com`: **not enabled** — cannot be, on Spark.
* Deployed functions: **none** (`functions:list` → "No functions found").
* Anonymous Auth: enabled (Tech Lead incident verification). App Check: monitor.

### Config validation performed

* `firebase deploy --only firestore:rules --dry-run` → `rules file firestore.rules compiled successfully`. **PASS.**
* `firebase deploy --only remoteconfig --dry-run` → `Dry run complete!` (after the `firebase.json` fix). **PASS.**
* `firebase deploy --only functions --dry-run` → predeploy `tsc` **PASS**, then **STOPS** at "must be on the Blaze (pay-as-you-go) plan … Required API cloudbuild.googleapis.com can't be enabled". **BLOCKED.**
* `npm --prefix infra/functions run build` → `tsc` exit 0, `lib/` emitted. **PASS.**
* `npm --prefix infra/functions test` / `melos run infra:test` → **SUCCESS** — 18 passed, 13 emulator-skipped (no JDK).
* `remoteconfig.template.json` — well-formed; all four `release.md` §6 keys present with correct `valueType` + defaults (`daily_*`/`share_enabled` = `"true"` BOOLEAN, `daily_manifest_url` = `""` STRING placeholder for F07).

---

## 6. Deployment Plan

**Target:** `looplet-712e5` (production; single MVP project). **Approval:** Tech Lead, explicit, per `release.md` §12 — **not yet given; do not deploy without it.**

### Prerequisites (must all be true before the first deploy)

1. **Upgrade `looplet-712e5` to the Blaze plan** — required for 2nd-gen Cloud Functions (`cloudbuild` + `artifactregistry` + `cloudfunctions` APIs). Owner: user (billing). Set a budget alert; F08's function is create-only, low-QPS, `maxInstances: 10` — expected cost ≈ $0 within the free tier, but Blaze is a hard gate.
2. Tech Lead approval recorded (`release.md` §12).
3. (For an automated workflow) `FIREBASE_CI_TOKEN` or a service-account key wired — see §5. For a **manual** first deploy from an authenticated workstation, `firebase login` is sufficient.

### Deploy runbook (manual, authenticated operator)

```sh
cd infra

# 1. Final pre-deploy validation (no changes):
firebase deploy --only functions,firestore:rules,remoteconfig \
  --project looplet-712e5 --dry-run

# 2. Rules + Remote Config first (no Blaze needed, low risk, reversible):
firebase deploy --only firestore:rules,remoteconfig --project looplet-712e5

# 3. Function (needs Blaze). First deploy also enables the build APIs:
firebase deploy --only functions --project looplet-712e5
#   → creates: submitDailyResultV1 (us-central1, 2nd gen, enforceAppCheck:false)

# 4. Verify:
firebase functions:list --project looplet-712e5          # submitDailyResultV1 present
firebase deploy --only firestore:rules --project looplet-712e5 --dry-run  # in-sync
```

* **Region:** `us-central1` (pinned in `functions/src/index.ts` `setGlobalOptions`).
* **Migration handling:** none server-side (Firestore `dailyResults` are additive, create-only). On-device Drift migration ships inside the app build (forward-only, never-drop guard) — not part of this backend deploy.
* **Feature flags / rollout:** functions deploy all-at-once (stateless); previous version retained by Firebase for redeploy. Client-side kill via `daily_sync_enabled`.
* **App Check:** leave in **monitor**. Do not toggle enforce. Android release Play Integrity SHA-256 registration is deferred to the app-distribution gate (debug builds use the debug provider; no release app build exists yet).

---

## 7. Rollback Plan

| Trigger | Action | Verification |
| --- | --- | --- |
| `submitDailyResultV1` error rate > 2% (5-min) / broken Daily submit / KPI regression | **Client kill-switch first:** set Remote Config `daily_sync_enabled = false` → `DailyResultSyncService.drain()` becomes a no-op; queued results stay `pending` locally and sync later (nothing lost). Effective within one Remote Config fetch (< 12h; force-fetch on resume). | Function error rate returns to baseline; local queues untouched; re-enable after fix. |
| Bad function build shipped | `firebase deploy --only functions --project looplet-712e5` from the **previous commit**, or `firebase functions:delete submitDailyResultV1` + redeploy prior. Function is stateless → safe. | `functions:list` + a `CREATED` smoke call (§8) against a scratch uid. |
| Bad rules shipped | `firebase deploy --only firestore:rules` from the previous commit. `dailyResults` is create-only + already low-risk. | rules dry-run in-sync; a `create-own` allowed / `create-other` denied check. |
| Bad Remote Config value | Re-publish `remoteconfig.template.json` from the previous commit (`firebase deploy --only remoteconfig`), or edit in console. | `firebase remoteconfig:get`. |
| On-device data corruption suspicion | **Forward-fix only** — on-device Drift data is never server-rolled-back (`release.md` §9). The never-drop `MigrationGuard` + forward-only migrations are the safety net; a bad on-device migration is fixed by a new app build, not a downgrade. A bad Firestore batch is corrected by a one-off admin script, never a rollback. | migration tests green in the shipping build; `personal_best` / `daily_streak` / `daily_entry` row counts preserved. |

* **RTO:** kill-switch < 12h (force-fetch on resume makes it near-immediate for active users); function/rules redeploy < 30 min.
* **Owner:** DevOps/Release Engineer.

---

## 8. Observability & Smoke Validation

### Post-deploy smoke — MANDATORY before this gate can pass (`release.md` §8 + `qa.md §17` folded in)

Run on a real device/simulator against `looplet-712e5` after the deploy, **and** confirm the CI `infra` emulator job is green on the F08 branch:

| # | Scenario | Pass criteria | Source |
| --- | --- | --- | --- |
| S1 | **CI emulator suites green on the F08 branch** | `infra` job: `rules.test.ts` (create-own allow / create-other deny / unauth deny / update·delete·read deny) + `submitDailyResult.test.ts` (CREATED; ALREADY_SUBMITTED with the doc unchanged; one doc across repeats; per-uid scoping; unauth → no write; invalid → no write) all pass | `qa.md §17.1` |
| S2 | **Kill / relaunch resume fidelity** | Start a puzzle → N moves + ≥1 undo + a restart + a thawed frozen tile → OS-kill the process → relaunch → grid, `moveCount`, `undosRemaining`, `restartCount`, elapsed, thawed state exactly restored. Tamper `kv['active_session'].thawedFrozenCells` → confirm it is **re-derived** by engine replay, not trusted. | `qa.md §17.2` (AC1/AC6) |
| S3 | **Lifecycle + connectivity drain** | `paused` → `resumed` → `drain()` fires; connectivity regain → `drain()` fires; dispose the screen that triggered a completion mid-sync → the session-level `DailyResultSyncService` still completes the sync. | `qa.md §17.3` |
| S4 | **Offline daily → exactly one create-only write** | Airplane mode → complete the daily (fake producer / F07 producer) → `daily_entry` first-run written, `syncStatus = queued`, 1 `sync_queue` row → reconnect → **exactly one** doc at `dailyResults/{lang}_{date}/entries/{uid}`, `syncStatus = synced`. Force a mid-request drop → retried → still one doc. Kill during `inFlight` → relaunch → reclaimed → still one doc. | `qa.md §17` + `release.md` §8 |
| S5 | **Repeat submit → ALREADY_SUBMITTED, unchanged** | Submit again (same or "better" result) → `ALREADY_SUBMITTED`, server doc byte-unchanged, local `firstRun*` unchanged, a `daily_attempt` row added, no new `sync_queue` row. | `qa.md §17` |
| S6 | **Kill-switch** | Remote Config `daily_sync_enabled = false` → `drain()` no-op, nothing sent; set back to `true` → queued item syncs. | `release.md` §6/§9 |
| S7 | **Storage-full fault injection** (residual test-debt, non-blocking) | Simulated disk-write failure → transaction rolls back, last-good state kept, non-fatal `persist_failed`, no crash. May be closed by an automated fault-injection test in a follow-up instead of the device smoke. | `qa.md §17.5` (AC7) |

* **S-Journey/Daily end-user offline play (AC2/AC3)** — needs F03/F05 screens; **explicitly out of F08 scope**, tracked for F05/F07 QA. Not a gate item here.

### Signals

* Cloud Functions: error rate + p95 latency (Firebase console dashboards). Alert: 5xx > 2% over 5 min.
* Remote Config: kill-switch toggle is an informational alert.
* Crashlytics / Cloud Logging / GA4 KPI wiring: **F12 + the app-distribution gate**, not F08.

---

## 9. Gate Evidence

| Gate | Result | Evidence / Notes |
| --- | --- | --- |
| Functions build (`tsc`) | **PASS** | `npm --prefix infra/functions run build` → exit 0, `lib/{index,submitDailyResult,types,validate}.js` emitted. |
| Functions unit tests (offline) | **PASS** | `melos run infra:test` → SUCCESS; 18 passed, 13 emulator-skipped. |
| Firestore rules compile | **PASS** | `firebase deploy --only firestore:rules --project looplet-712e5 --dry-run` → "rules file firestore.rules compiled successfully". |
| Remote Config template | **PASS** | `firebase deploy --only remoteconfig --project looplet-712e5 --dry-run` → "Dry run complete!" (after adding the `remoteconfig` block to `firebase.json`). All 4 `release.md` §6 keys present. |
| Rules + callable emulator suites (`repeatable integration`) | **PENDING (CI)** | `rules.test.ts` + `submitDailyResult.test.ts` wired into the `infra` job via `emulators:exec --project demo-looplet`. Not run this turn — no JDK locally; not triggered on CI from here. Must be confirmed green on the F08 branch (S1). |
| Cloud Functions deploy (dry-run) | **BLOCKED** | `firebase deploy --only functions --dry-run` stops: "Your project looplet-712e5 must be on the Blaze (pay-as-you-go) plan … Required API cloudbuild.googleapis.com can't be enabled". Predeploy `tsc` passed; the block is billing-plan, not code. |
| Production deploy (functions + rules + Remote Config) | **NOT EXECUTED** | Requires Blaze + explicit Tech Lead approval (`release.md` §12). Runbook in §6. |
| Device / emulator post-deploy smoke (S2–S7) | **PENDING** | No device/simulator/JDK in this environment. Checklist authored in §8; belongs to the smoke run once a build + deploy exist. |
| Rollback plan | **PASS (documented)** | §7 — kill-switch + function/rules redeploy-previous + forward-fix-only for on-device data. |
| iOS release App Attest / DeviceCheck | **DEFERRED — non-blocking** | `[OPEN — post-MVP, after Apple Developer Program enrollment]`. App Check is monitor-only; a failed attestation is a logged no-op. |
| Android release Play Integrity SHA-256 | **DEFERRED — non-blocking for F08** | No Android release keystore / Play App Signing yet (first app-distribution gate, ~F03/F05). Debug builds use the App Check debug provider. |
| `FIREBASE_CI_TOKEN` / deploy auth | **NOT CONFIGURED** | User-owned repo secret. Runbook + the service-account alternative in §5/§6. Not required for CI validation (emulator project needs no auth); required only for an automated deploy workflow. |
| Container build / scan | **N/A** | `release.md` §6 — no containerization (mobile + Firebase CLI). |
| App-build distribution gates (Xcode archive / signing / TestFlight / Play) | **N/A for F08** | Backend-only gate; app distribution is a later release. |

---

## 10. Release Risks

### Blocking (must clear before `F08-DEVOPS` can pass)

1. **`looplet-712e5` is on the Spark (free) plan.** 2nd-gen Cloud Functions cannot deploy without Blaze. **Owner: user** (billing decision + upgrade; recommend a low budget alert). Until then `submitDailyResultV1` does not exist server-side and the offline→online daily-result sync path cannot be exercised end-to-end against the real project. *The app itself is unaffected — every Firebase call is best-effort and the sync queue simply waits.*
2. **Production deploy approval not given.** `release.md` §12 requires explicit Tech Lead approval + a passing smoke. **Owner: Tech Lead.**
3. **Runtime + emulator evidence not yet produced** (`qa.md` verdict carried forward). S1 (CI emulator job green on the branch) + S2–S6 (device smoke) must be run. **Owner: DevOps/Release Engineer + Tech Lead/user for the device pass.**

### Non-blocking (record, do not hold F08)

* `FIREBASE_CI_TOKEN` / service-account deploy auth not wired — only needed for an automated deploy workflow; a manual authenticated first deploy does not need it. **Owner: user/DevOps.**
* iOS production App Attest / DeviceCheck — `[OPEN — post-MVP]`, App Check monitor-only.
* Android release Play Integrity SHA-256 — deferred to the first app-distribution gate.
* Storage-full fault-injection test (S7 / AC7) — residual test-debt; mechanism (Drift transaction rollback + non-fatal event) is source-sound; add an automated test in a follow-up.
* End-user offline Journey/Daily play (AC2/AC3) — needs F03/F05 screens; tracked for F05/F07 QA.
* `dailySyncEnabledProvider` (client) + `FakeDailyResultProducer` — F07 seams; F07 wires the real Remote Config read + real Daily producer.
* `firestore.googleapis.com` was enabled + a `(default)` DB created as a dry-run side effect — benign, required by F08 anyway.

---

## 11. Release Readiness Verdict

### **Release Validation Pending**

* **Config is substantially ready.** Functions build + offline tests green; `firestore.rules` compiles; Remote Config template validates (after the `firebase.json` fix); the CI `infra` job wires the mandated rules + callable emulator suites; rollback plan documented; App Check correctly left in monitor.
* **Not `Release Ready`** because: (1) the project must move to **Blaze** before the Cloud Function can deploy — a hard external gate; (2) production deploy requires **explicit Tech Lead approval** (`release.md` §12), not yet given; (3) the contract-mandated **`runtime` + `repeatable integration` evidence** (`qa.md §17` S1–S6) has not been produced — no device/JDK here and nothing pushed to trigger CI.
* **Not `Release Blocked`** — QA found **no code defect**, there is no failed *code/build* gate, and the rollback plan exists. The gating items are billing, approval, and running the smoke — none require F08 rework.
* **Deploy was not executed** (correct — approval + Blaze first).

### What closes this gate

1. User upgrades `looplet-712e5` → Blaze (+ budget alert).
2. Tech Lead records deploy approval.
3. DevOps runs the §6 runbook (rules + Remote Config, then the function); confirms the CI `infra` emulator job green on the F08 branch (**S1**).
4. Device/simulator smoke **S2–S6** (S7 may be swapped for an automated fault-injection test); attach evidence here.
5. Re-run this artifact to **Release Ready (with Notes)** — the Notes being the deferred non-blockers in §10.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** `F08-DEVOPS` part (A) release-readiness prep + dry-run evidence (functions build, rules compile, Remote Config validate, `firebase.json` fix, live-project state audit); part (B) the `qa.md §17` scenarios authored into the §8 smoke checklist; part (C) this artifact.
* **Remaining Tasks:** Blaze upgrade (user) → Tech Lead deploy approval → execute the §6 runbook → S1–S6 smoke evidence → re-verdict.
* **Blockers:** Spark→Blaze plan (user); production-deploy approval (Tech Lead); runtime/emulator smoke not yet run.
* **Status Suggestion:** Needs Tech Lead Review — F08 stays `In Release`; it is **not `Done`** until this artifact reaches `Release Ready` with the S1–S6 evidence attached.

---

## 12. Sonraki Komut

```
Run Tech Lead
```
