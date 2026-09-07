# F05 — journey-progression: Architecture (Contract)

> Status: **INITIAL CONTRACT BRIEF — NOT LOCKED.** F05 is **COMPLEX**; a Technical Analyst pass (`analysis.md`) resolves the `[PENDING — ANALYSIS]` items below, then the Tech Lead produces the locked `architecture.md` (state-machine DURUM 3) with `Release Scope` decided. Execution state is in `orchestration.md`.

---

## 1. Purpose

Define: the **Journey progression model** (30 linearly-unlocked levels, stars-don't-gate, no re-lock); the **bundled-content resolution path** (a Journey manifest → a `Puzzle` by level number, feeding F03's `playSessionSetupProvider`); the **CONTINUE** entry semantics against the F08 active-session snapshot; the **`Next Level`** wiring into F04's completion panel + the post-completion **unlock write**; the **per-level micro-tutorial** (column intro, levels 4–6); the **"all 30 complete"** terminal state; and the **minimal home surface** (CONTINUE + progress) that replaces the debug `HomeScreen`. F05 changes no F03/F04/F06/F08 contract — it **consumes** them and fills their `[PENDING — F05]` seams.

---

## 2. Authorities & Inputs

| Authority | Role |
| --- | --- |
| `product/product-prd.md` → F05 section + §6.1 F05 row + §5.1/§5.2 + §15 `JourneyProgress` + §41 KPIs | product contract |
| `features/f05-journey-progression/prd.md` | feature scope + AC1–AC14 |
| `features/f03-puzzle-play-session/architecture.md` → §13 route/nav + `PlaySessionArgs` | **consumed contract** — `/play`, `journeyLevel`, the win moment |
| `features/f04-star-rating-and-personal-best/architecture.md` → §7 panel + §8 route (`Next Level` = `[PENDING — F05]`) | **consumed contract** — the `onNextLevel` seam + the win path |
| `features/f06-.../architecture.md` → `Puzzle` model + `export`/`check` + difficulty labels | **consumed contract** — the content format + the 30 levels (`F06-CONTENT`) |
| `app/lib/persistence/repositories/journey_progress_repo.dart` + `journey_progress` table (F08) | **consumed contract** — the unlock persistence (already built) |
| `app/lib/persistence/active_session_snapshot.dart` → `journeyLevel` key + restore path (F08) | **consumed contract** — CONTINUE resume |
| `project-authority/platform.md` | Flutter / Riverpod / go_router; asset bundling; localization pattern |
| `project-authority/release.md` | `Release Scope` decision (content pack + first app-build distribution gate — `[PENDING — TL at DURUM 3]`) |
| `design/design-doctrine.md` + `design/premium-ui-rubric.md` | the home / progress / tutorial-overlay quality bar |

---

## 3. Substrate already built (consume, do not rebuild)

* **Unlock persistence (F08):** `journey_progress` table — `highestUnlockedLevel` (int, default 1), `completedLevelsCsv` (text). `JourneyProgressRepo` — `markCompleted(guestId, levelNumber)` (transactional, linear unlock `N → N+1`, idempotent for progress), `read(guestId)`, `watch(guestId)` (a `Stream` — the progress UI can bind to it), `completedLevels(guestId)`. `journeyProgressRepoProvider` in `persistence_providers.dart`. **No schema change expected.**
* **Play entry (F03):** route `/play`, `PlaySessionScreen(args: PlaySessionArgs)`, `PlaySessionArgs {PuzzleSource source, int? journeyLevel, String? debugPuzzleId}` — `journeyLevel` is defined but unused. `app_router.dart` `Routes.play` reads `state.extra as PlaySessionArgs`.
* **Content resolution seam (F03):** `playSessionSetupProvider = FutureProvider.family<PlaySessionSetup, PlaySessionArgs>` currently handles only `debugPuzzleId` and `throw UnsupportedError` for other sources — **this is the `[PENDING — F05]` Journey branch**.
* **Completion → Next Level seam (F04):** `CompletionPanel({..., VoidCallback? onNextLevel})` — `null` in F04 scope renders the disabled ghost pill. `play_session_screen.dart` builds the panel; F05 supplies `onNextLevel` + the unlock write.
* **Engine config (F08):** `toEngineConfig(Puzzle)` in `app/lib/content/puzzle_engine_config.dart` — already consumed by `PlaySessionController`.
* **Content format (F06):** `Puzzle` / `Puzzle.fromJson` (engine-free, `looplet_content`); `optimalMoves` guaranteed by the `export`/`check` gate; `difficultyLabel` ∈ {easy, medium, hard, expert}.

---

## 4. Journey Progression Model `[PENDING — ANALYSIS]` → LOCK at DURUM 3

Proposed (analysis to confirm / refine):

* **Level id ↔ number.** Journey levels are `1..30`. The `Puzzle.id` for a Journey level and the `PlaySessionArgs.journeyLevel` int must map deterministically (proposal: `Puzzle.id == 'journey-<lang>-<NN>'`, `journeyLevelNumber == N`). The F04 `personal_best` key is `levelId` (`puzzle.id`) — must stay stable across content re-exports.
* **Unlock state per level** (derived, not stored beyond `journey_progress`):
  * `locked` — `N > highestUnlockedLevel`.
  * `unlocked, not completed` — `N <= highestUnlockedLevel && N ∉ completedLevels`.
  * `completed` — `N ∈ completedLevels`.
  * `in-progress` — an F08 active-session snapshot exists with `status == inProgress && journeyLevel == N` (there is at most one active session).
* **Unlock write.** On an F04 Journey completion (win): `JourneyProgressRepo.markCompleted(guestId, N)` — **before or after** the F04 `personal_best` write (order `[PENDING — ANALYSIS]`; both are independent local writes, fire-and-forget with a caught failure, same posture as F03's `_persist`). Idempotent — a replay of a completed level is a progress no-op.
* **"Next" resolution.** From the completion panel of level N: `Next Level` → level `N+1` if `N < 30` and `N+1` content exists; if `N == 30` (or `N+1` content missing) → the "all levels complete" state. CONTINUE → the in-progress level if one exists, else `min(unlocked levels not in completedLevels)`, else (all 30 done) the "all complete" state.
* **Terminal state.** All 30 in `completedLevels` → a graceful "all levels complete" surface (no crash, no dead CONTINUE). Replaying any completed level from that state is allowed.

---

## 5. Bundled Content + Manifest `[PENDING — ANALYSIS]` → LOCK at DURUM 3

* **Where do the 30 levels live?** Proposal: a bundled asset directory (`app/assets/journey/<lang>/journey-<lang>-NN.json`, each a F06 `export` artifact) + a `journey_manifest_<lang>.json` (`contentVersion`, ordered list of level ids + difficulty labels + a checksum). Registered in `app/pubspec.yaml` assets.
* **Resolver.** A `JourneyContentRepo` (or extend `playSessionSetupProvider`) — `Future<Puzzle> loadLevel(int n, String lang)` reading the bundled JSON via `rootBundle`, `Puzzle.fromJson`, cached. `playSessionSetupProvider`'s `journeyLevel != null` branch calls it. **Corrupt / missing asset → a typed failure** the screen renders as F03's load-error (AC "corrupt asset → skip + log, rest of Journey playable").
* **Build gate.** A content-manifest check (extends F06's `check` / a `melos content:check` step) — fails CI if `< 30` Journey levels for a shipping language, or a manifest/asset mismatch, or a level missing `optimalMoves`.
* **`F06-CONTENT` dependency.** The 30 authored levels are **not yet produced** — F05 is built + QA'd against the **5-puzzle smoke set** mapped into a `journey-tr-01..05` manifest (or a documented subset). **F05 cannot reach `Done` until `F06-CONTENT` delivers the full 30** (and they land the difficulty-curve bands). This is the primary F05 blocker-to-Done; the analysis confirms the interim shape.

---

## 6. CONTINUE + Resume `[PENDING — ANALYSIS]`

* **Entry:** the minimal home surface's primary CTA. Resolves the target level (§4 "Next" resolution) → `context.push('/play', extra: PlaySessionArgs(source: journey, journeyLevel: N))`.
* **Resume:** F03 + F08 already restore the active session by `puzzleId`. F05's job: ensure the `PlaySessionArgs.journeyLevel` it passes matches the snapshot's level so the restore path fires (F03 `_LoadedPlaySession._init()` reads the snapshot then constructs the controller with `restoreFrom:`). The content resolver must return the **same** `Puzzle` id the snapshot was written against.
* **F09 seam:** brand-new player (no `completedLevels`, tutorial-not-done) → `[PENDING — F09]` (route into F09, which flows into Level 1). Until F09 exists, CONTINUE → Level 1 directly.

---

## 7. Per-Level Micro-Tutorial (column intro, levels 4–6) `[PENDING — ANALYSIS + UI]`

* **Trigger:** first entry into the 4–6 band (proposal: first load of level 4). An acknowledged flag is **persisted** (a `kv` row or a `settings`/`journey_progress` column — `[PENDING — ANALYSIS]`; F08 owns the schema — if a new column is needed that is an F08 touch-point to flag).
* **Behaviour:** a short, action-gated overlay teaching the column shift; dismiss on acknowledge; **re-shows on return until acknowledged** (AC11). Distinct from F09 onboarding.
* **UI:** the overlay is a **UI Designer** deliverable (`ui-design.md`) — an action-gated coach-mark over the F03 board, consistent with F03's Direction A chrome.

---

## 8. Home / Progress Surface `[PENDING — UI]`

* Replaces the debug `HomeScreen` (`app/lib/home_screen.dart`). Content: LOOPLET wordmark, **CONTINUE** (primary CTA), a **journey progress indicator** ("N / 30" + a completed/unlocked visual, bound to `JourneyProgressRepo.watch`), the "all levels complete" state.
* **Not** the full F10 menu (no DAILY, no Settings icon, no level-select map) — a minimal surface F10 re-homes. The debug level buttons are removed or moved behind a debug flag (`[IMPL]`).
* Chrome / back behaviour: the home is the app root (`/`), no back affordance; `/play` → back returns here (F03's `_popToCaller`). `Release Scope`-permitting, this is the first screen a distributed build shows.

---

## 9. Route / Navigation Contract `[PENDING — ANALYSIS]` → LOCK at DURUM 3

* **No new route** expected — F05 reuses `/` (home) and `/play`. If the "all complete" state or the tutorial needs its own route (vs an in-screen state), the analysis decides.
* `Next Level` (F04 panel) → `context.pushReplacement('/play', extra: PlaySessionArgs(journeyLevel: N+1))` or `push` — replacement vs stacking is `[PENDING — ANALYSIS]` (stacking 30 `/play` routes is wrong; replacement or pop-then-push).
* CONTINUE / `Next Level` / "all complete" back targets all resolve to `/` — no empty stack, no wrong-route.

---

## 10. Persistence `[PENDING — ANALYSIS]`

* **Store:** F08's `journey_progress` via `JourneyProgressRepo` — **no new table**. A **possible** new column for the 4–6 tutorial-acknowledged flag (or a `kv` row) — if so, an F08 forward-only migration touch-point (flag in the analysis; Tech Lead routes a tiny F08 amendment or uses `kv`).
* **Key:** `(guestId)` — one `journey_progress` row per guest (seeded by F08).
* **Write timing:** unlock on win (fire-and-forget, caught). No cross-user data, no network.

---

## 11. Validation Responsibility `[PENDING — LOCK at DURUM 3]`

* **F05:** the unlock rule (AC1/AC2/AC13 — stars-don't-gate, no re-lock), CONTINUE resolution (AC7/AC8/AC9), `Next Level` resolution + the N==30 terminal (AC12), the progress indicator accuracy (AC10), the 4–6 micro-tutorial gate + re-show (AC4/AC11), the bundled-content resolver + corrupt-asset degradation, offline load (AC14).
* **F08 `JourneyProgressRepo`:** the transactional idempotent unlock write.
* **F06 / `F06-CONTENT`:** the 30 levels exist, land the curve bands (AC3/AC5/AC6), each carries `optimalMoves`.
* **F03:** the play session + restore path. **F04:** the completion panel + `onNextLevel` seam + the win path.

---

## 12. QA Focus `[PENDING — LOCK at DURUM 3]`

* **Progression (`automated functional`):** unlock N → N+1 at 1★ / 3★; locked N+1 not openable; replay a completed level → no re-lock, no progress change; `markCompleted` idempotency via the real F08 repo + in-memory DB.
* **CONTINUE / resume (`automated functional` + `runtime`):** in-progress level resumes at saved state (kill/relaunch — folds into F03's device smoke); no in-progress → lowest unlocked incomplete; all 30 done → "all complete" state, no crash.
* **`Next Level` (`automated functional`):** panel of N → N+1 play session; panel of 30 → terminal state.
* **Micro-tutorial (`automated functional` + `runtime`):** shows on first 4–6 entry; re-shows after force-quit until acknowledged; not shown again after acknowledge; not shown for levels 1–3 / 7+.
* **Content resolver (`automated functional`):** resolve a Journey level by number → the right `Puzzle`; corrupt/missing asset → load-error, rest of Journey playable; offline (no network) → loads from bundle.
* **`ui-design.md` alignment:** home CONTINUE/progress surface + tutorial overlay quality (doctrine + rubric); chrome parity with F03.
* **Evidence class:** `automated functional` mandatory; `runtime` (device) for CONTINUE-resume feel + the tutorial + the home visuals — **this is the likely first app-build distribution device smoke** (F03 + F04 device follow-ons fold in). **Not `source-only`.**
* Security compliance N/A (single actor, local-only progress, no endpoint) — justify in the QA scope line.

---

## 13. Release / Deployment Impact `[PENDING — TL DECISION at DURUM 3]`

* **`Release Scope` — likely NOT `none`.** F05 ships a **Journey content pack** (30 bundled level assets + manifest) and is plausibly the point where the first **playable app build is distributed** for the Level 5 Reach / D1 / D7 validation (F03 + F04 accepted their device smokes into "the first app-build distribution ~F05"). Candidate values: `container-build` N/A; more likely **`production-readiness`** for the app-distribution gate, or a narrower content-pack gate. **The Tech Lead locks this in the DURUM 3 contract after the analysis**, and — if `!= none` — opens a `DevOps/Release Engineer` task (`F05-DEVOPS`) for the app-build distribution runbook + the folded-in F03/F04 device smokes.
* CI code gates (`format:check` / `analyze` / `test` / `content:check` / `build:app` / `build ios`) still apply; a new content-manifest check is proposed (§5).

---

## 14. Open Items (for the Technical Analyst)

* `[PENDING — ANALYSIS]` §4 — the level-id ↔ number mapping; the unlock-write ordering vs F04's `personal_best` write; the exact CONTINUE / `Next Level` / terminal resolution algorithm.
* `[PENDING — ANALYSIS]` §5 — the bundled Journey manifest + asset layout + the resolver + the content-manifest build gate; the **interim shape** while `F06-CONTENT` is unfinished (map the 5-puzzle smoke set into `journey-tr-01..05` vs a documented stub).
* `[PENDING — ANALYSIS]` §7 / §10 — where the 4–6 tutorial-acknowledged flag lives (a `kv` row vs a new `journey_progress` / `settings` column → an F08 touch-point).
* `[PENDING — ANALYSIS]` §9 — `push` vs `pushReplacement` for `Next Level`; whether the terminal / tutorial states need their own routes.
* `[PENDING — ANALYSIS]` — the F09 hand-off seam for a brand-new player (CONTINUE → F09 → Level 1) — F09 is `Not Started`, so a clean seam + an interim (CONTINUE → Level 1) is fine.
* `[PENDING — UI]` (after the analysis) — the minimal home CONTINUE/progress surface + the 4–6 column micro-tutorial overlay + the "all levels complete" state, in `ui-design.md`, chrome parity with F03 Direction A.
* `[PENDING — TL at DURUM 3]` §13 — `Release Scope` + whether `F05-DEVOPS` (first app-build distribution gate) opens.
* `[PENDING — F06-CONTENT]` — the 30 authored levels landing the curve bands; **hard prerequisite for F05 `Done`**, not for F05 build/QA against the interim manifest.
* `[DEFERRED — F09]` — pre-Level-1 onboarding. `[DEFERRED — F10]` — the full menu re-homes F05's minimal surface. `[DEFERRED — F11/F12]` — audio/haptics on unlock; `level_started`/`level_completed` analytics.
