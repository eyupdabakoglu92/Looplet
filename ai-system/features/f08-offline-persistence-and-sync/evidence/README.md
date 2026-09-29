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
