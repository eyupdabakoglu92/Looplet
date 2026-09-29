# F08-DEVOPS-RULES — the rules-only production deploy (2026-09-29)

DevOps/Release Engineer, F08.DEPLOY-GO — B (F08 `architecture.md` A19). Claims and results: `../../release.md` → "F08-DEVOPS-RULES".

**Outcome:** steps 1–4 done (read-only and dry-run); **the deploy was not executed** — the user answered "wait" at the confirmation step. Nothing on `looplet-712e5` was changed.

| File | What |
| --- | --- |
| `DR-01-preflight.log.txt` | firebase-tools version, the CLI's signed-in state (account masked), `.firebaserc`, the `(default)` database. |
| `read-live-rules.cjs` | Read-only script: prints the project's Firestore rules releases and the live ruleset source, through the firebase-tools library and the CLI's own signed-in session. No token is printed or stored. |
| `DR-02-live-rules-before.log.txt` | Its output: 0 releases, no `cloud.firestore` release. |
| `DR-03-rulesets-before.log.txt` | 0 rulesets on the project. |
| `DR-04-probe-before.log.txt` | Unauthenticated REST GET on `dailyResults` and on an entry path → 403 `PERMISSION_DENIED` ×2. No write attempted. |
| `DR-05-suite-at-deploy-revision.log.txt` | The emulator suite at HEAD dfccce3 (Java 21): 3 / 3, 33 / 33; rules `aa4c5dc2…`, rules test `2c7df84a…` (= the CI-green c592081). |
| `DR-06-dry-run.log.txt` | `firebase deploy --only firestore:rules --project looplet-712e5 --dry-run` → compiles; nothing released. |
