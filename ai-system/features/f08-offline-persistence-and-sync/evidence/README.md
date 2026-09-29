# F08 evidence — F08-FE13 / F08-LOCAL-EVIDENCE (2026-09-29)

Delivery evidence of the Frontend/Mobile Developer; the claims and results are in `../frontend.md` → "F08-FE13" and "F08-LOCAL-EVIDENCE". QA reviews and re-runs them at F08-QA-FUNCTIONAL.

Target: iPhone 16 simulator `D0011CE7-6E50-4367-93FA-B323E81270BE`, iOS 18.6, debug builds (bundle `com.looplet.loopletApp`). Base revision HEAD `1d373d7` + the uncommitted F08-FE13 working tree; delivered `app/` tree `9de12e6a82077a19178bb4e4cae2398d110c3e7d`.

| File | What |
| --- | --- |
| `neg-fe13.py` | The named negative runs (N-CLASS, N-LOOP, N-RETRY, N-FULL, N-FULL-FATAL, N-TXN, N-QUAR, N-GATE, N-REGAIN). Run from `app/` with `SP=<scratch dir>`. Output: `runtime/neg-fe13.log.txt`. |
| `ev-f08.sh` | Simulator helpers: install, log stream (`flutter:` lines), launch / kill, still, Documents listing, `sqlite3` on the live store, cold-start recording. |
| `q.sh`, `fs-docs.sh` | The app's `sync_queue` / `daily_entry` rows; the Firestore emulator documents of one `dailyDate` (admin read). |
| `fn-proxy.py` | Fault proxy on :5001 in front of the Functions emulator on :5002 — modes `pass`, `down`, `drop` (the server writes, the response is dropped), `hold`, `slow` (4 s). Mode file: `runtime/proxy-mode` (removed after the run). |
| `firebase.evidence.json` | The emulator config of the runs (Functions on :5002, UI off, `demo-looplet`). `firebase` refuses paths outside the project directory, so the run used a scratch copy with `functions` symlinked to `infra/functions` and a byte-identical `firestore.rules` (sha1 `b75628e6…`). |
| `offline-journey.sh` | **For the user to run** (it turns the Mac's Wi-Fi off and on): F08.OFFLINE-JOURNEY on a real no-network runtime. Not run. |
| `runtime/LE-01*` | Unreadable store: quarantine + recreate + `db_reinitialized`; only the newest quarantine kept; Retry reconnect after a CANTOPEN (`LE-notes.txt` = the Documents listings). |
| `runtime/LE-02*` | Resume fidelity on level 21 (moves + restart + undo + thaw), kill / relaunch, tampered thaw cache. |
| `runtime/LE-03-emulator-suite.log.txt` | `npm ci && npm run build && npm run test:emulator` (JDK 21). |
| `runtime/LE-04*` | Client ↔ emulator exactly-once cases A–E (`LE-04-cases.txt`), the emulator / proxy / app logs. `LE-04-app.log.txt`…`app3` are the runs before two wiring fixes (see frontend.md). |
| `runtime/LE-05*` | Ownership / lifecycle (screen disposed mid-sync). |
| `runtime/LE-07*`, `runtime/raw/` | Production-shaped cold boots (no emulator define), empty and existing store; videos + per-frame luma traces (`video-d2.swift trace`). `07a/07b` on the first FE13 build, `07c/07d` on the final one. |
| `runtime/LE-08*` | Release build with the emulator define: the gated strings are absent, the controls present. |
| `runtime/integration-final.log.txt` | `flutter test integration_test` on the simulator, final code. |

## F08-BE6 (Backend Developer, 2026-09-29)

Claims and results: `../backend.md` → "F08-BE6". Base HEAD `b8e37ab`; only `infra/functions/test/submitDailyResult.test.ts` changed (sha1 `cf73770d…`).

| File | What |
| --- | --- |
| `neg-be6.py` | N-OVERWRITE / N-OVERWRITE-OLDFIX: the handler overwrites an existing entry; the fixed test catches it, the old fixture cannot tell. Restores both files byte for byte. Run from the repo root; needs Java 21 on PATH. Output: `runtime/BE6-04-neg.log.txt`. |
| `runtime/BE6-00-npm-ci-build.log.txt` | `npm ci && npm run build`. |
| `runtime/BE6-01-baseline-suite.log.txt` | The suite before the fix: attempt 1 (only `JAVA_HOME`) fails on the Java version; attempt 2 (Java 21 on PATH) 30 / 31. |
| `runtime/BE6-02-fixed-suite.log.txt` | The suite after the fix: 31 / 31. |
| `runtime/BE6-03-plain-npm-test.log.txt` | `npm test` without the emulator: 18 passed, 13 skipped. |

## F08-BE7 (Backend Developer, 2026-09-29)

Claims and results: `../backend.md` → "F08-BE7". Base HEAD `8f26243`; changed `infra/firestore.rules` (sha1 `b75628e6…` → `aa4c5dc2…`), `infra/functions/test/rules.test.ts` (`9d4db0bb…` → `2c7df84a…`) and `infra/README.md`. The handler, the validator and the callable test are unchanged.

| File | What |
| --- | --- |
| `neg-be7.py` | N-DIRECT-CREATE: puts the old client `allow create` rule back; the own valid entry, the own invalid payload (QA P3) and the non-date bucket (QA P6) tests fail, the other five pass. Restores the rules byte for byte. Run from the repo root; needs Java 21 on PATH. Output: `runtime/BE7-04-neg.log.txt`. |
| `runtime/BE7-00-npm-ci-build.log.txt` | `npm ci && npm run build` at the base. |
| `runtime/BE7-01-baseline-suite.log.txt` | The suite before the change (old rules): 31 / 31. |
| `runtime/BE7-02-fixed-suite.log.txt` | The suite after the change: 33 / 33 (rules 8, callable 7, skeleton 18). Notes one invocation error before it (no test ran). |
| `runtime/BE7-03-plain-npm-test.log.txt` | `npm test` without the emulator: 18 passed, 15 skipped. |
