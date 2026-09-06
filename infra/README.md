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
| `.firebaserc` | project alias (`default` → placeholder `looplet-mvp`; set the real id with `firebase use --add`) |
| `firestore.rules` | `dailyResults/**` create-only for own uid; default-deny elsewhere |
| `firestore.indexes.json` | empty (a composite index for a future leaderboard is deferred) |
| `remoteconfig.template.json` | `daily_enabled` / `daily_sync_enabled` / `share_enabled` (true) + `daily_manifest_url` (placeholder) |
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

## Not done yet (manual, needs a real Firebase project + `firebase login`)

The DURUM 0 stops at a compiling, testable skeleton. Before F08-BE / F08-FE6 /
`F08-DEVOPS` can deploy or run the emulator suites end-to-end, someone with
Firebase Console access must:

1. Create the Firebase project; put its id in `.firebaserc` (`firebase use --add`).
2. Register the iOS + Android apps; run `flutterfire configure` from `app/` to
   generate `app/lib/firebase_options.dart` + `google-services.json` +
   `GoogleService-Info.plist` (these are **not secret** and are committed —
   `release.md` §7).
3. Enable Anonymous Auth and App Check (soft-enforce / monitor mode for the MVP).
4. Install the Firebase CLI in CI and wire `FIREBASE_CI_TOKEN` (name already in
   `release.md` §7) so the `infra` emulator + deploy jobs run for real.
