# infra/

Firebase project config, security rules, Remote Config, and Cloud Functions for
LOOPLET's backend surfaces (`ai-system/project-authority/platform.md` §3):

1. **Daily content distribution** — static JSON in Cloud Storage, selected by a
   Remote Config manifest pointer. No compute. (F07)
2. **Analytics ingestion** — Firebase Analytics SDK direct from the client. No
   endpoint here. (F12)
3. **Offline daily-result sync** — `functions/` → `submitDailyResultV1`, an
   HTTPS callable that records a player's first completed daily run, create-only
   and idempotent. (F08)

Scaffolded by the **`infra/` DURUM 0** (Project Setup, 2026-09-06) per
`ai-system/project-authority/setup-manifest.md` → *"## infra/ DURUM 0 Recipe"*.
The callable body, full payload validation, and the reconciliation logic are
implemented by **F08-BE2** against
`ai-system/features/f08-offline-persistence-and-sync/architecture.md`.

## Layout

| Path | What |
| --- | --- |
| `firebase.json` | functions + firestore + emulator config |
| `.firebaserc` | project alias (`default` → `looplet-712e5`) |
| `firestore.rules` | `dailyResults/**`: no client access; only the callable writes (Admin SDK); default-deny elsewhere |
| `firestore.indexes.json` | empty (a composite index for a future leaderboard is deferred) |
| `remoteconfig.template.json` | `daily_enabled` / `daily_sync_enabled` / `share_enabled` (true) + `daily_manifest_url` (placeholder) — wired into `firebase.json` `remoteconfig.template` |
| `functions/` | TypeScript (Node 20) Cloud Functions — `submitDailyResultV1` |

## Local development

```sh
cd infra/functions
npm ci
npm run build          # tsc → lib/
npm test               # offline skeleton tests (emulator suites auto-skip)

# Full suite incl. security-rules tests — needs the Firebase CLI + emulator:
#   npm i -g firebase-tools
#   firebase emulators:exec --only firestore,auth "npm test"   (run from infra/)
```

`melos run infra:build` / `melos run infra:test` run the above from the repo root.

## Deploy (F08-DEVOPS — `production-readiness`)

Full readiness analysis + gate evidence:
`ai-system/features/f08-offline-persistence-and-sync/release.md`.

### Prerequisites (all required before the first deploy)

1. **`looplet-712e5` must be on the Blaze (pay-as-you-go) plan.** 2nd-gen Cloud
   Functions need `cloudbuild` / `artifactregistry` / `cloudfunctions` APIs,
   which Spark cannot enable. `firebase deploy --only functions` fails on Spark
   with an explicit upgrade prompt. Rules + Remote Config deploy fine on Spark.
   Recommend a low budget alert — `submitDailyResultV1` is create-only, low-QPS,
   `maxInstances: 10`.
2. **Explicit Tech Lead approval** (`release.md` §12) — production deploy is
   never the default.
3. For an **automated** deploy workflow: `FIREBASE_CI_TOKEN` **or** a Google
   Cloud service account (`roles/firebasedeploy` + `roles/cloudfunctions.developer`
   + `roles/firebaserules.admin`) JSON key as `GOOGLE_APPLICATION_CREDENTIALS`.
   `firebase login:ci` tokens are deprecated — prefer the service account.
   A **manual** first deploy from an authenticated workstation needs neither.

### Runbook (manual, authenticated operator)

```sh
cd infra

# 1. Pre-deploy validation, no changes:
firebase deploy --only functions,firestore:rules,remoteconfig \
  --project looplet-712e5 --dry-run

# 2. Rules + Remote Config first (no Blaze needed, reversible):
firebase deploy --only firestore:rules,remoteconfig --project looplet-712e5

# 3. Function (needs Blaze; first run enables the build APIs):
firebase deploy --only functions --project looplet-712e5

# 4. Verify:
firebase functions:list --project looplet-712e5     # submitDailyResultV1 present
```

Region is pinned to `us-central1` (`functions/src/index.ts`). App Check stays in
**monitor** — do not toggle enforce. Post-deploy smoke (S1–S7) is in
`release.md` §8.

### Rollback

* Daily/sync regression → Remote Config `daily_sync_enabled = false` (client
  `drain()` becomes a no-op; queued results are kept and sync later).
* Bad function/rules → redeploy the previous commit (`firebase deploy --only …`).
* On-device data → forward-fix only; never server-rolled-back. The Drift
  migration is forward-only with a never-drop guard.

### Emulator suites locally

```sh
cd infra
firebase emulators:exec --only firestore,auth --project demo-looplet \
  "npm --prefix functions run test"     # needs a JDK on PATH
```

CI runs this in the `infra` job (ubuntu ships a JDK); `demo-looplet` is a fully
offline emulator project — no auth, no token.
