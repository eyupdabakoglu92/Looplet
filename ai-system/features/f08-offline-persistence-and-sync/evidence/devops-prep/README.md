# F08-DEVOPS-PREP — local gate evidence (2026-09-29)

DevOps/Release Engineer, F08-DEVOPS-PREP. Local runs of every CI job's steps
after the CI repair (TD-FORMAT-SCOPE, TD-CI-TOOLCHAIN, Java 21).

* **Revision:** HEAD `6b31195` plus the uncommitted working-tree changes of
  F08-DEVOPS-PREP (`.github/workflows/ci.yml`, `melos.yaml`,
  `ai-system/project-authority/setup-manifest.md`, `infra/README.md`). No app,
  package, rules or function source changed.
* **Host:** macOS (Darwin 24.6), Flutter 3.32.8 / Dart 3.8.1, Xcode 16.4
  (16F6), CocoaPods 1.16.2, Node v24.7.0, firebase-tools 15.29.0.
* **Time:** 2026-09-29, 15:57–16:05Z.
* **Not CI evidence.** These are local runs. The CI result is recorded in
  `release.md` → Gate Evidence only after a real run.

| File | Step (CI job) | Command | Result |
| --- | --- | --- | --- |
| DP-01 | old format scope (comparison) | `dart format --output=none --set-exit-if-changed .` | exit 1 — exactly the two `ai-system/` QA probes (= CI run #1) |
| DP-02 | Format check (`verify`) | `melos run format:check` (→ `app packages tools`) | exit 0 — 194 files, 0 changed |
| DP-03 | negative for DP-02 | an unformatted `app/lib/zz_neg_probe.dart`, then `melos run format:check`; file removed after | exit 1 — the probe caught |
| DP-04 | Bootstrap (`verify`) | `melos bootstrap` | exit 0 |
| DP-05 | Analyze (`verify`) | `melos run analyze` | exit 0 — no issues in any package or the app |
| DP-06 | Test (`verify`) | `melos run test` | exit 0 — content 17, core 22, dictionary 32, solver 23, authoring 25, engine 83, app 588; all passed (summary of the full log) |
| DP-07 | Content check (`verify`) | `melos exec --scope=looplet_authoring -- "dart run bin/looplet_authoring.dart check ../../content --repo-root ../.."` | exit 0 |
| DP-08a | Build AAB (`verify`) — local environment finding | `melos run build:app` | exit 1 — Flutter picks Android Studio's bundled JBR **25.0.3**; Gradle 8.12 cannot run on Java 25. Local tool choice, not a code or CI defect |
| DP-08b | Build AAB on the CI condition | `cd app/android && JAVA_HOME=<openjdk@17> ./gradlew --no-daemon bundleRelease` (the runner's default JDK is 17) | BUILD SUCCESSFUL — `app-release.aab` 48.2 MB |
| DP-09 | Build iOS (`ios-build`) | `melos exec --scope=looplet_app -- "flutter build ios --release --no-codesign"` (Xcode 16.4, CocoaPods, SPM not enabled) | exit 0 — `Runner.app` 56.0 MB |
| DP-10…12 | `infra` job, Java 21 first on `PATH` | `npm --prefix infra/functions ci` / `run build` / `test`; then from `infra/`: `npx --yes firebase-tools@15 emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` | all exit 0; offline 18 passed / 15 skipped; emulator **3 / 3 suites, 33 / 33 tests** |
| DP-13 | negative for DP-12 | the same emulator command with Java 17 first on `PATH` | exit 1 — "firebase-tools no longer supports Java version before 21" (= CI run #1) |

The first `npm ci` attempt of the infra sequence exited 1 while `melos bootstrap`
ran in parallel; the immediate re-run (DP-10) and every later step exited 0.
