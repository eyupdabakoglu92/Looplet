# F05 — journey-progression: Technical Analysis

> Technical Analyst output. Resolves the `architecture.md §14 [PENDING — ANALYSIS]` items so the Tech Lead can lock `architecture.md` (DURUM 3). No code, no final architecture/scope decision — those are the Tech Lead's. Client-only feature (no backend).

---

# 1. Feature Summary (Technical View)

F05 wires the existing, isolated F03 play session into a **30-level linear campaign**:

* A **bundled Journey content pack** (30 `Puzzle` JSON artifacts + a per-language manifest) and a **resolver** that fills F03's `playSessionSetupProvider` `journeyLevel` branch (currently `throw UnsupportedError`).
* An **unlock write** on the F04 win path: `JourneyProgressRepo.markCompleted(guestId, N)` (F08, pre-built — transactional, linear `N → N+1`, idempotent).
* A **`Next Level`** handler filling F04's `CompletionPanel.onNextLevel` seam (`null` today → disabled ghost pill).
* **CONTINUE** — resolve the target level (in-progress → lowest-unlocked-incomplete → terminal) and route to `/play`; resume is F03+F08's existing restore path, keyed by `puzzleId`.
* A **minimal home surface** (LOOPLET wordmark + CONTINUE + a progress indicator + the "all 30 complete" state) replacing the debug `HomeScreen`.
* A **per-level column micro-tutorial** (action-gated overlay, first entry to the 4–6 band, re-shows until acknowledged).

**No F03/F04/F06/F08 contract changes** — F05 consumes them and fills the `[PENDING — F05]` seams. The one possible F08 touch-point (the tutorial-acknowledged flag) is avoidable via the existing `kv` table.

**System work:** a content-resolution layer + manifest + a build gate; a progression read-model derived from `journey_progress`; a navigation layer (CONTINUE / `Next Level` / terminal) over `/` and `/play`; the tutorial overlay + its persisted flag; the home screen.

---

# 2. User Stories

* As a player, I want 30 sequential levels that unlock as I finish them, So that I always have a clear next step.
* As a player, I want difficulty to ramp gently and introduce one new idea at a time, So that I'm never lost.
* As a player, I want CONTINUE to drop me straight into my current level, So that resuming takes one tap.
* As a player, I want to see how far through the Journey I am, So that I feel momentum.

---

# 3. Acceptance Criteria

Restating `prd.md §3` AC1–AC14 in testable Given/When/Then, split by layer where relevant. (The `prd.md` numbering is authoritative; this section adds test-shape detail.)

* **AC1 — unlock on completion (any stars).** Given the player wins Journey level N (`engine.isSolved`, `source == journey`, `journeyLevel == N`), When the win path runs, Then `JourneyProgressRepo.markCompleted(guestId, N)` is called → `highestUnlockedLevel >= N+1` and `N ∈ completedLevels`; independent of the star count (1★, 2★, 3★).
* **AC2 — locked level not openable.** Given `N+1 > highestUnlockedLevel`, When the UI offers no path to N+1 (the home surface + `Next Level` both gate on unlock), Then N+1 cannot be entered; a direct `context.push('/play', extra: journeyLevel: N+1)` (deep link / debug) resolves to a **locked** state, not a playable board.
* **AC3 — levels 1–3 rows-only.** Given a level with `journeyLevel ∈ {1,2,3}`, When loaded, Then its `Puzzle.columnMovesEnabled == false` (a content property, guaranteed by the manifest build gate) and `optimalMoves ∈ {3,4}`; F03's engine already disables column moves from `EngineConfig`.
* **AC4 — 4–6 column micro-tutorial on first entry.** Given `journeyLevel ∈ {4,5,6}` and the tutorial-acknowledged flag is false, When the play screen loads, Then the column micro-tutorial overlay is shown before / over the board; column moves are available (`columnMovesEnabled == true` in that band's content).
* **AC5 — levels 7–10 rows+cols.** Given `journeyLevel ∈ {7..10}`, When loaded, Then `columnMovesEnabled == true` and `optimalMoves ∈ {4,5,6}`.
* **AC6 — bands 11–30 mechanics.** Given `journeyLevel` in 11–15 / 16–20 / 21–25 / 26–30, When loaded, Then the content carries respectively: temporary-displacement-heavy grids / `lockedCells` / `frozenCells` / both — verified by the manifest build gate against band rules, not at runtime.
* **AC7 — CONTINUE resumes in-progress.** Given an F08 active-session snapshot with `status == inProgress && puzzleSource == journey && puzzleId == <the Journey id for level N>`, When CONTINUE is tapped, Then `/play` opens for level N and F03's restore path rebuilds the exact saved state (grid, moves, undo history, thawed tiles, elapsed time).
* **AC8 — CONTINUE with no in-progress.** Given no in-progress Journey snapshot, When CONTINUE is tapped, Then the player lands on `min({1..30} \ completedLevels ∩ unlocked)` — Level 1 for a brand-new player (subject to the F09 seam, §11).
* **AC9 — all 30 complete terminal.** Given `completedLevels ⊇ {1..30}`, When CONTINUE is tapped, Then a graceful "all levels complete" state is shown (no crash, no dead button); replaying a completed level from there is allowed.
* **AC10 — progress indicator.** Given the home surface, When shown, Then it displays an accurate progress read ("`|completedLevels|` / 30" or equivalent), bound to `JourneyProgressRepo.watch` (live-updates on completion).
* **AC11 — tutorial re-shows until acknowledged.** Given the player force-quits during the 4–6 micro-tutorial (flag still false), When they next enter any level in 4–6, Then the tutorial re-shows; Given they complete the gated action, Then the flag persists true and it never re-shows.
* **AC12 — `Next Level` resolution.** Given the F04 completion panel for level N, When `Next Level` is tapped: if `N < 30` and level `N+1` content exists → navigate to level N+1's `/play` (via `pushReplacement`, §11); if `N == 30` or `N+1` content missing → route to the "all levels complete" state (`context.go('/')` → the terminal home variant).
* **AC13 — 1★ still shows `Next Level`.** Given a Journey level completed at 1★, When the completion panel renders, Then `onNextLevel` is non-null and the CTA is enabled. (Resolves product PRD open question — **yes, stars never gate**.)
* **AC14 — offline.** Given no network, When the player plays any Journey level, Then the `Puzzle` loads from the bundled asset (`rootBundle`, no network) and `markCompleted` persists locally.

---

# 4. Functional Breakdown

## 4.1 Level identity & the number↔id mapping `[DECISION — TL]`

* F03's restore fires only when `snapshot.puzzleId == puzzle.id` (`PlaySessionController._tryRestore`). F04's `personal_best.levelId == puzzle.id`. So the Journey level's `Puzzle.id` is a **stable durable key** — it must not change across F06 content re-exports, and F05 must be able to map `journeyLevel N ⇄ Puzzle.id` deterministically.
* **Recommendation:** `Puzzle.id == 'journey-<lang>-<NN>'` (zero-padded, e.g. `journey-tr-07`), `Puzzle.journeyLevelNumber == N`. F05 derives N from an id by parsing; derives the id from N + the active language. The F08 active-session snapshot needs **no new field** — the in-progress Journey level is read back by parsing `snapshot.puzzleId`.
* **Constraint for `F06-CONTENT`:** the manifest + the exported artifacts MUST use exactly this id scheme. Changing a shipped level's id later orphans that player's `personal_best` + any in-progress snapshot (acceptable only pre-launch).

## 4.2 Bundled Journey content + manifest `[DECISION — TL]`

* **Manifest schema** (`journey_manifest_<lang>.json`):
  ```
  {
    "schemaVersion": 1,
    "contentVersion": "<string>",
    "lang": "tr",
    "levels": [
      { "n": 1, "id": "journey-tr-01", "asset": "journey/tr/journey-tr-01.json",
        "difficultyLabel": "easy", "checksum": "<sha256 of the asset>" },
      ...  // 30 entries, n = 1..30 contiguous
    ]
  }
  ```
* **Where the assets live** — two viable options; Tech Lead picks:
  * **(A, recommended)** `packages/looplet_content/assets/journey/<lang>/*.json` + the manifest, exposed by a `looplet_content` loader API (`Future<Puzzle> loadJourneyLevel(int n, String lang)`), registered in `looplet_content/pubspec.yaml` `flutter: assets:`. Content lives with the content package; `F06-CONTENT` writes there; F06's `check` validates there. Trade-off: `looplet_content` gains a Flutter-asset dependency (it is currently pure Dart — `AssetBundle` would make it Flutter-coupled). **Mitigation:** put the loader in the `app` layer (or a thin `looplet_content_flutter` shim) and keep `looplet_content` pure — the app reads `rootBundle` and calls `Puzzle.fromJson`.
  * **(B)** `app/assets/journey/<lang>/*.json` + manifest, a build/copy step from `content/journey/<lang>/` (the F06 `export` output), registered in `app/pubspec.yaml`. Content authored in `content/`, mirrored into `app/assets/` by a `melos` script. Trade-off: a copy step to keep in sync (the manifest checksum + a CI check catch drift).
* **Resolver** (fills `playSessionSetupProvider`'s `journeyLevel != null` branch):
  1. read the active language (`SettingsRepo.read(guestId).language`, default `tr`);
  2. load + cache `journey_manifest_<lang>.json`;
  3. look up `levels[n-1]`; if absent → typed `JourneyContentException` (→ F03's load-error state, "rest of Journey playable");
  4. `rootBundle.loadString(asset)` → `jsonDecode` → `Puzzle.fromJson`; validate `puzzle.id == manifest id` + optional checksum;
  5. return `PlaySessionSetup(puzzle, validator)` (validator from `wordValidatorProvider`, as today).
* **Caching:** a `Provider`/`FutureProvider.family` keyed by `(lang, n)` or an in-memory map — a level is small; 30 is trivial; no eviction needed.

## 4.3 Content-manifest build gate `[DECISION — TL]`

A new check (extend F06's `tools/looplet_authoring check`, or a `melos content:check` step, or a `flutter test` asset test):

* for each shipping language: the manifest exists, `schemaVersion` known, `levels` has **exactly 30** contiguous `n = 1..30`;
* every `asset` resolves + parses as a `Puzzle`, `puzzle.id == manifest id == 'journey-<lang>-<NN>'`, `puzzle.journeyLevelNumber == n`, `optimalMoves >= 1`, `checksum` matches;
* **band rules:** `n ∈ 1..3` ⇒ `columnMovesEnabled == false` and `optimalMoves ∈ {3,4}`; `n ∈ 4..10` ⇒ `columnMovesEnabled == true`; `n ∈ 16..20` ⇒ `lockedCells` non-empty; `n ∈ 21..25` ⇒ `frozenCells` non-empty; `n ∈ 26..30` ⇒ both non-empty. (Temporary-displacement weight for 11–15 is a difficulty-score property, not a hard structural check — leave to `F06-CONTENT` playtest + the difficulty label.)
* **Interim mode:** while `< 30` levels exist, the gate runs in a "smoke" mode (asserts consistency of whatever is present + logs the shortfall) and does **not** fail CI; it flips to strict (`== 30` required) when `F06-CONTENT` lands. The mode switch is a one-line flag / manifest field.

## 4.4 Progression read-model

Derived from `journey_progress` (no new storage):

* `LevelState` per `n ∈ 1..30`:
  * `locked` ⇔ `n > highestUnlockedLevel`;
  * `completed` ⇔ `n ∈ completedLevels`;
  * `unlockedIncomplete` ⇔ `n <= highestUnlockedLevel && n ∉ completedLevels`;
  * `inProgress` ⇔ an F08 snapshot exists with `status == inProgress && puzzleSource == journey && parseLevel(puzzleId) == n` (at most one).
* `currentLevel` (for CONTINUE): `inProgress` level if any, else `min({n : unlockedIncomplete})`, else (all done) `null` → terminal.
* `progressCount` = `|completedLevels ∩ {1..30}|` (clamp — ignore any stray ids).
* Exposed as a Riverpod provider bound to `JourneyProgressRepo.watch(guestId)` (live) + a one-shot read of the active-session snapshot.

## 4.5 Unlock write on the win path `[DECISION — TL]`

* **Hook point — two options:**
  * **(A, recommended — consistent with F04)** inject `journeyProgressRepo` + `journeyLevel` into `PlaySessionController` (optional ctor params, exactly like F04's `personalBestRepo` + `guestId`); in the existing win side-effect path (`_resolvePersonalBest`, or a sibling `_resolveJourneyProgress`), if `source == journey && journeyLevel != null`, call `markCompleted(guestId, journeyLevel)` — **fire-and-forget with a caught failure** (same posture as `_persist` / `_resolvePersonalBest`), ordered **after** the `personal_best` write is initiated (both independent local writes; a deterministic order only aids test assertions). Never blocks the panel.
  * **(B)** a screen-level reaction (`play_session_screen.dart` listens for `phase == won` + `source == journey` once, calls `markCompleted`) or a dedicated listener provider. Keeps `PlaySessionController` from accreting every feature's win side-effect. Trade-off: a second place that reacts to "won"; ordering vs the F04 write less explicit.
* **Idempotency:** `JourneyProgressRepo.markCompleted` is already idempotent for progress (re-completing N is a no-op). A Retry-then-re-solve of the same level → a second `markCompleted(N)` → no-op. No dedup needed in F05.
* **`journeyLevel` plumbing:** F05 passes `PlaySessionArgs.journeyLevel` from CONTINUE / `Next Level` / the home surface; `_LoadedPlaySession._init()` (F03) passes it into the controller (a new line — additive, no F03 contract change).

## 4.6 CONTINUE / `Next Level` / terminal navigation `[DECISION — TL]`

* **Routes:** reuse `/` (home) and `/play`. **No new route.** The terminal "all complete" state and the tutorial overlay are **in-screen states**, not routes.
* **CONTINUE** (home primary CTA): resolve `currentLevel` (§4.4); if `null` → render the terminal home variant in place; else `context.push('/play', extra: PlaySessionArgs(source: journey, journeyLevel: currentLevel))`.
* **`Next Level`** (F04 panel `onNextLevel`): `final n = currentJourneyLevel; if (n != null && n < 30 && manifestHas(n+1)) context.pushReplacement('/play', extra: PlaySessionArgs(source: journey, journeyLevel: n+1)); else context.go('/')` (home → terminal variant). **`pushReplacement`** so the back stack never accumulates `/play` frames — from any Journey level, system/gesture back and F03's chevron/`_popToCaller` land on `/`.
* **Back behaviour:** unchanged from F03 — chevron hidden in `won`; `Close` / system back → `_popToCaller` → `/`. Direct-entry / deep-link into `/play?journeyLevel=N` with an empty stack → F03's `_popToCaller` fallback already handles it (`maybePop`); F05 should ensure it resolves to `/` (a `context.go('/')` fallback if `!canPop`).
* **Route-graph summary:** `/` ⇄ `/play` only. `/play` always returns to `/`. No 30-deep stack. No wrong-route.

## 4.7 Column micro-tutorial (levels 4–6) `[DECISION — TL]`

* **Trigger:** on `/play` load, if `journeyLevel ∈ {4,5,6}` and `tutorialAck == false` → show the overlay.
* **Behaviour:** an **action-gated** coach-mark over the F03 board (the player must perform a column shift to dismiss) — a **UI Designer** deliverable, chrome-consistent with F03 Direction A. Distinct from F09 onboarding (which is the pre-Level-1 row/column/form-target sequence).
* **Persisted flag location — two options:**
  * **(A, recommended)** a `kv` row: `key = 'journey_col_tutorial_ack'`, `valueJson = '{"ack":true,"atUtcMs":...}'`. **No schema change** — the `kv` table already exists and F08 uses it (`active_session`, `store_meta`). A tiny `JourneyTutorialRepo` (or a generic `KvRepo`) reads/writes it. Per-guest scoping: prefix the key with the guest id or store `{guestId: true}` (single-guest today, so a bare key is fine; document it).
  * **(B)** a `BoolColumn colTutorialAck` on `journey_progress` (typed, per-guest by the row PK). Trade-off: an **F08 forward-only migration** (`schemaVersion` bump + a guarded `onUpgrade` step) — an F08 `architecture.md` amendment the Tech Lead must route. Cleaner typing; more ceremony.
* **AC11:** dismiss + persist `ack=true` **only** on the gated action completing. Quitting before that leaves `ack=false` → re-shows on the next 4–6 entry.

## 4.8 Home surface `[PENDING — UI]`

Replaces `app/lib/home_screen.dart` (currently a debug `Wrap` of `smoke-tr-*` buttons). Content: LOOPLET wordmark; **CONTINUE** (primary CTA); a progress indicator ("N / 30" + a completed/unlocked visual, bound to `JourneyProgressRepo.watch`); the "all 30 complete" state (a distinct home variant). **Not** the F10 menu (no DAILY, no Settings icon, no level-select map). The debug buttons move behind a `kDebugMode` flag or are removed (`[IMPL — Frontend]`). Chrome: the home is the app root (`/`), no back affordance.

## 4.9 F09 seam (brand-new player) `[DECISION — TL]`

F09 (`Not Started`) owns the pre-Level-1 tutorial. CONTINUE for a player with `completedLevels == ∅ && highestUnlockedLevel == 1 && no in-progress snapshot`:

* **Interim (F09 not built):** CONTINUE → Level 1 directly.
* **Seam:** a `bool onboardingComplete` signal (F09-owned — likely a `kv` flag or a `settings` column F09 adds). F05's CONTINUE: `if (!onboardingComplete) → <route to F09>  else → level resolution`. F05 ships the branch with `onboardingComplete` hard-wired `true` and a `// [PENDING — F09]` marker; F09 flips it.

---

# 5. API Requirements (CONTRACT BASE)

**None — F05 is client-only.** No new endpoint, no backend call. All persistence is local (F08's `journey_progress` + the `kv` flag). F08's parked Firebase deploy is irrelevant (journey progress is on-device only, no sync surface).

---

# 6. Data Model (Conceptual)

| Entity | Storage | Owner | F05 use |
| --- | --- | --- | --- |
| `journey_progress` (`guestId` PK, `highestUnlockedLevel` int, `completedLevelsCsv` text) | Drift table (F08) | F08 | read (`read`/`watch`/`completedLevels`) + write (`markCompleted`) — **no schema change** |
| Active-session snapshot (`kv['active_session']` — `puzzleId`, `puzzleSource`, `status`, …) | Drift `kv` (F08) | F08 | read to detect the in-progress Journey level (parse `puzzleId`) — **no contract change**; no new field |
| `journey_col_tutorial_ack` | Drift `kv` (new row, **recommended**) OR a new `journey_progress` column (option B) | F05 (or F08 if a column) | read on 4–6 `/play` load; write on gated-action completion |
| Journey manifest `journey_manifest_<lang>.json` | bundled asset | F06 / `F06-CONTENT` | resolver input |
| Journey level `Puzzle` artifacts `journey-<lang>-<NN>.json` | bundled assets | F06 / `F06-CONTENT` | `Puzzle.fromJson` → `PlaySessionSetup` |
| `personal_best` (`levelId == puzzle.id`) | Drift table (F08) | F04 | **read-through consequence** — the id-scheme decision must keep this key stable |
| `settings.language` | Drift table (F08) | F10 | read for the active language in the resolver (default `tr`) |

Relationships: `journey_progress (1) — (1) guest`; `manifest (1) — (30) level artifacts`; a level's `Puzzle.id` is the join key to `personal_best` and to the active-session snapshot.

---

# 7. Validation Rules

## Input Validation

* `journeyLevel` (from `PlaySessionArgs`): integer `1..30`. Out of range / null on a `source == journey` entry → the load-error state (not a crash). `< 1` or `> manifest length` → "locked" (if `> highestUnlockedLevel`) or load-error (if `> 30` / missing content).
* Manifest JSON: `schemaVersion` known; `levels` contiguous `n = 1..N`; each entry has `n`, `id`, `asset`. Malformed → the resolver throws `JourneyContentException` → load-error, rest of Journey playable.
* Level artifact JSON: delegated to `Puzzle.fromJson` (F06 — throws `PuzzleFormatException`); F05 additionally checks `puzzle.id == manifest id` + `journeyLevelNumber == n` + optional checksum.

## Business Validation

* **Unlock is monotone** — `markCompleted` never lowers `highestUnlockedLevel` (F08 repo already guarantees `highest = max(existing, N+1)`), never removes from `completedLevels`. Replaying a completed level → no progress change.
* **Stars never gate** — the unlock write is unconditional on the star count (AC1/AC13).
* **`Next Level` gating** — enabled ⇔ `N < 30 && manifestHas(N+1)`; else it routes to the terminal state (still a valid action, never a no-op dead button).
* **CONTINUE never dead** — always resolves to a level or the terminal state.
* **Tutorial** — shows ⇔ `journeyLevel ∈ 4..6 && !ack`; persists `ack` only on gated completion.
* **At most one in-progress session** — F08's `kv['active_session']` is a single row; F05 reads it, doesn't manage its lifecycle.

---

# 8. Edge Cases

* **Direct/deep-link entry to `/play?journeyLevel=N` for a locked N** → resolve to a "locked" state, not a playable board (AC2). The debug-friendly path (`kDebugMode`) may bypass; production must not.
* **`journeyLevel` for a level whose asset is missing/corrupt** → load-error state; the rest of the Journey still resolves (no global campaign crash).
* **Fewer than 30 levels in the build** (`F06-CONTENT` incomplete) → the manifest gate runs in "smoke" mode; runtime shows accurate progress against what's present; `Next Level` past the last available level → terminal state (documented interim behaviour).
* **CONTINUE with a stale in-progress snapshot for level N that the player has since `Restart`ed or completed elsewhere** → F08's restore re-derives from `appliedMoves`; if the snapshot is `completed` it's already cleared by F03's `_persistCompletedThenClear`; a `completed` snapshot that failed to clear → F03 lands in `won` directly (already handled by F04's controller path).
* **Force-quit mid-tutorial** (AC11) → `ack` false → re-shows on next 4–6 entry.
* **Force-quit mid-level** → F08 snapshot restores exactly (AC7) — this is F03+F08 behaviour, F05 only ensures the passed `journeyLevel`/id matches.
* **All 30 complete, player taps a completed level's Retry then wins again** → `markCompleted(N)` no-op; still terminal; no regression.
* **Language switch** (F10, later) while an in-progress `journey-tr-NN` snapshot exists → the resolver would look for `journey-en-NN`; the id mismatch means F03 won't restore (fresh board). Acceptable for the MVP (single language `tr` at launch); flag for F10.
* **`completedLevels` CSV contains stray/out-of-range ids** (data corruption / a future Daily reuse) → `progressCount` clamps to `{1..30}`; unlock derivation ignores strays.
* **`highestUnlockedLevel` ahead of `completedLevels`** (e.g. unlocked 5 but only completed 1–3, 5 in progress) → `currentLevel` = the in-progress 5, or `min(unlockedIncomplete)` = 4. Deterministic.

---

# 9. Error Scenarios

| Scenario | Behaviour | Surface |
| --- | --- | --- |
| Manifest missing / malformed | resolver throws `JourneyContentException`; `playSessionSetupProvider` future errors | F03's existing load-error state (`_LoadErrorBody`, `Geri` → `/`) |
| Level asset missing / corrupt | same as above (per-level, not global) | load-error for that level; home + other levels unaffected |
| `markCompleted` write fails (storage full) | caught + `debugPrint('journey: unlock_persist_failed …')`; the panel is unaffected; the unlock is retried on the next completion of that level (or lost until then — acceptable, matches F03's `_persist` posture) | none (silent, logged) — shared debt class with F03 note 3 / F08 AC7 / F04 N3 |
| Tutorial-ack write fails | caught + logged; the tutorial may re-show next time (no data loss, mild annoyance) | none |
| `journeyLevel` out of range | resolve to locked / load-error per §7 | locked state or load-error |
| CONTINUE with corrupt `journey_progress` row | F08 bootstrap already self-heals / the row is seeded on first launch; a `getSingle` throw → treat as "brand new" (Level 1) + log | home renders Level-1 CONTINUE |

No error *codes* (client-only, no API). All failures are local, caught, non-fatal.

---

# 10. Client / UI Expectations

## Home surface (`/`, replaces the debug `HomeScreen`)

* **idle:** LOOPLET wordmark + CONTINUE (primary) + progress indicator ("N / 30").
* **loading:** the `journey_progress` read is instant (local, seeded); a brief splash is already the `_BootstrapGate` job. F05 adds no new loading state on `/` beyond binding to `watch`.
* **terminal ("all 30 complete"):** a distinct variant — a celebratory/complete message; CONTINUE either hidden or repurposed ("Replay" / opens a completed level). No crash, no dead button.
* **error:** if `journey_progress` can't be read (bootstrap-level) → the existing `StoreErrorScreen` (F08) already covers it upstream.
* **header/back:** none — `/` is the app root.

## Play screen (`/play`, F03 + F05 additions)

* **content resolution:** `journeyLevel` branch resolves the bundled `Puzzle`; F03's existing `setup.when(loading/error/data)` handles the states — F05 adds no new play-screen chrome except the tutorial overlay.
* **tutorial overlay (4–6, first entry):** action-gated coach-mark over the board; blocks/points at the column gesture; dismisses + persists on the gated action; re-shows until acknowledged. `[PENDING — UI]`.
* **back:** F03's chevron (`_popToCaller`) — now always resolves to `/`. Hidden in `won` (F03 rule). System/gesture back identical.

## Completion panel (`/play` overlay, F04 + F05 addition)

* F05 supplies `onNextLevel` (non-null for Journey `N < 30` with `N+1` content; else routes to terminal). F04's disabled ghost pill becomes an enabled primary/secondary CTA — **the F04 forward-note applies:** once `Next Level` is live, the Retry-vs-Next-Level weighting should be revisited per outcome (Perfect → `Next Level` primary; sub-optimal → `Retry` primary). This is a **UI decision for F05-UI**, not a contract change.

---

# 11. Integration Rules

* **`playSessionSetupProvider`** — the single content-resolution seam. F05 fills the `journeyLevel != null` branch; the `debugPuzzleId` branch stays (debug). The `throw UnsupportedError` for other sources stays until F07 (Daily).
* **`PlaySessionArgs.journeyLevel`** — plumbed from CONTINUE / `Next Level` / home into `/play` `state.extra`; `_LoadedPlaySession._init()` passes it into `PlaySessionController` (additive line).
* **`JourneyProgressRepo`** — `markCompleted` on win (fire-and-forget caught); `watch` for the home progress indicator; `read`/`completedLevels` for `currentLevel` resolution.
* **F08 active-session snapshot** — read-only in F05 (detect in-progress Journey level via `parseLevel(puzzleId)`). **F05 does not write or extend the snapshot.**
* **`personal_best` (F04)** — the id-scheme decision (§4.1) is load-bearing for this key's stability. No F05 code touches `personal_best`.
* **Field naming:** `journeyLevel` (int, `PlaySessionArgs`) ⇄ `journeyLevelNumber` (int, `Puzzle`) ⇄ the `NN` in `journey-<lang>-<NN>` — one concept, three surfaces; the mapping helper is the single source.
* **Enum/union exhaustiveness:** `LevelState ∈ {locked, unlockedIncomplete, completed, inProgress}` — every consumer (home tiles, `Next Level` gate, CONTINUE) must handle all four.
* **Route graph:** `/` ⇄ `/play`. `Next Level` = `pushReplacement` (no stack growth). All back paths → `/`. Terminal + tutorial are in-screen states, not routes. System back alone is sufficient from `/play`; from `/` there is nowhere to go back to (app root).
* **Live updates:** the home progress indicator binds to `JourneyProgressRepo.watch(guestId)` (a Drift `watchSingle` stream) — updates the instant `markCompleted` commits, even if the win happened on `/play` and the player then pops to `/`.

---

# 12. Non-Functional Considerations

* **Performance:** 30 small JSON assets; lazy-load per level + cache; no perceptible cost. The solver never runs on device (F06 gate) — every level ships `optimalMoves`. The manifest parse is one-time per session.
* **Offline:** fully offline by construction — bundled assets + local `journey_progress`. AC14.
* **Security:** N/A — single actor, local-only progress, no auth, no endpoint, no cross-user data. (QA to justify the N/A.)
* **Release / deployment:** **F05 ships a Journey content pack** (30 bundled assets + manifest) and is the **plausible first playable-app-build distribution point** — the Level 5 Reach / D1 / D7 validation KPIs need a distributed build, and F03 + F04 both folded their device smokes into "the first app-build distribution ~F05". → `Release Scope` is **likely `!= none`** (candidate: `production-readiness` for the app-distribution gate, or a narrower content-pack gate). **Tech Lead decision at DURUM 3.** If gated, `F05-DEVOPS` opens after QA for: the app-build distribution runbook (TestFlight / internal), the folded-in F03 (3-item manual device confirmation) + F04 (N4 reveal feel) device smokes, the content-pack versioning + a rollback story, Android release Play Integrity SHA-256 (also flagged in the parked `F08-DEVOPS`). **Rollback:** content-pack is bundled in the binary → rollback = ship the previous binary; no server component.
* **Scalability:** 30 levels is fixed for the MVP; the manifest schema is versioned for a future expansion.

---

# 13. Dependencies

* **F03** (`Done`) — `/play`, `PlaySessionScreen`, `PlaySessionArgs` (`journeyLevel` field exists), `PlaySessionController` win path, the F08 restore path.
* **F04** (`Done`) — `CompletionPanel.onNextLevel` seam; the win-path side-effect pattern (`personalBestRepo` injection) to mirror for `journeyProgressRepo`.
* **F06** (`Done`, toolchain) — `looplet_content` `Puzzle` / `Puzzle.fromJson`; `tools/looplet_authoring` `export`/`check`; the difficulty label. **`F06-CONTENT`** (the 30 authored Journey levels + a manifest) — an **open Level-Designer follow-on**; **hard prerequisite for F05 `Done`**, not for F05 build/QA (interim manifest).
* **F08** (`In Release` / parked; on-device persistence complete) — `journey_progress` + `JourneyProgressRepo`, the `kv` table, `currentGuestIdProvider`, the active-session snapshot + restore path, `SettingsRepo.language`.
* **F09** (`Not Started`) — the pre-Level-1 onboarding hand-off (a clean seam; interim = CONTINUE → Level 1).
* **F10** (`Not Started`) — will re-home F05's minimal home surface; owns `settings`.
* **External:** none (no services; `rootBundle` only).

---

# 14. Assumptions

* **A1** — Journey level ids follow `journey-<lang>-<NN>` and this is the durable key for `personal_best` + snapshot resume. (Recommendation → Tech Lead to lock.)
* **A2** — The 4–6 tutorial-ack flag lives in the existing `kv` table (no F08 schema change). (Recommendation → Tech Lead to lock; option B is a column + an F08 migration.)
* **A3** — `Next Level` uses `pushReplacement`; the terminal + tutorial states are in-screen, no new routes.
* **A4** — Launch language is `tr` only; multi-language Journey content + a language-switch-mid-progress story is F10's problem. `SettingsRepo.language` defaults `tr`.
* **A5** — F05 builds + QAs against an interim manifest mapping the F06 smoke set (`smoke-tr-01/02/04/05/06` → levels 1–5, or a 6-slot map) to exercise the resolver + unlock + the 4–6 tutorial trigger (`smoke-tr-05` locked, `smoke-tr-06` frozen sit in the 4–6 slots). `Done` needs the real 30 from `F06-CONTENT`.
* **A6** — The unlock write mirrors F04's pattern (repo injected into `PlaySessionController`, fire-and-forget caught, ordered after the `personal_best` write). (Recommendation → Tech Lead to lock vs a screen-level reaction.)
* **A7** — F05 UI strings follow F03's interim per-language table pattern (`PlayStrings`-style); `gen_l10n` stays `[DEFERRED — F10-or-earlier]` (F03's clarification) unless the Tech Lead makes F05 the point to introduce it.
* **A8** — No analytics in F05 (`level_started` / `level_completed` with the level number are F12 seams); no audio/haptic on unlock (F11).

---

# 15. Open Questions

1. **Content asset home** — `packages/looplet_content/assets/` (couples `looplet_content` to Flutter assets) vs `app/assets/journey/` + a copy step from `content/`. → Tech Lead.
2. **Tutorial-ack storage** — `kv` row (no migration, recommended) vs a `journey_progress` column (an F08 forward-only migration + an `architecture.md` amendment). → Tech Lead.
3. **Unlock-write hook** — inject into `PlaySessionController` (F04-consistent) vs a screen-level / listener reaction. → Tech Lead.
4. **`Release Scope`** — is F05 the first app-build distribution gate (`production-readiness` + `F05-DEVOPS`), a narrower content-pack gate, or `none` with the distribution deferred further? → Tech Lead at DURUM 3.
5. **`F06-CONTENT` scheduling** — F05 cannot reach `Done` without it. Does the Tech Lead open `F06-CONTENT` now (parallel to F05 build) or gate F05's QA on it? → Tech Lead.
6. **Terminal-state UX** — CONTINUE at 30/30: hide CONTINUE, or repurpose it ("Replay a level")? → UI Designer, informed by the Tech Lead.
7. **F04 `Next Level` weighting** — now that `Next Level` is live, is the per-outcome Retry-vs-Next-Level primary/secondary swap (F04's forward note) in F05-UI's scope? → Tech Lead → UI Designer.
8. **Debug home buttons** — remove, or keep behind `kDebugMode`? → Frontend (`[IMPL]`), low stakes.

---

# 16. Task Breakdown

## Backend Tasks

* **None** — F05 is client-only. (Possible exception: **if** the Tech Lead chooses the `journey_progress` column for the tutorial flag → one F08 forward-only migration step + an F08 `architecture.md` amendment. The `kv` recommendation avoids this.)

## Client Tasks (Frontend)

* **F05-FE.CONTENT** — the Journey manifest schema + the interim `tr` manifest (smoke-set map) + a `JourneyContentRepo` / resolver + wire `playSessionSetupProvider`'s `journeyLevel` branch + typed `JourneyContentException` → F03 load-error; the level-number↔id mapping helper.
* **F05-FE.GATE** — the content-manifest build gate (extend F06 `check` or a `melos content:check` / asset test); "smoke" vs "strict" mode.
* **F05-FE.PROGRESS** — the progression read-model provider (`LevelState` per level + `currentLevel` + `progressCount`) over `JourneyProgressRepo.watch` + the active-session snapshot read.
* **F05-FE.UNLOCK** — the unlock write on the win path (`journeyProgressRepo` + `journeyLevel` into `PlaySessionController`, or the chosen alternative), fire-and-forget caught, ordered after the `personal_best` write; plumb `PlaySessionArgs.journeyLevel` through `_LoadedPlaySession._init()`.
* **F05-FE.NAV** — the `Next Level` handler (fills F04's `onNextLevel`, `pushReplacement` / terminal); CONTINUE resolution; the deep-link/back fallback to `/`.
* **F05-FE.HOME** — replace `home_screen.dart` with the minimal CONTINUE + progress surface + the terminal variant (per `ui-design.md`); debug buttons behind `kDebugMode`.
* **F05-FE.TUTORIAL** — the 4–6 column micro-tutorial overlay (per `ui-design.md`) + the `kv` ack flag repo + the trigger on `/play` load.
* **F05-FE.STRINGS** — F05 UI strings in the F03 interim per-language pattern.
* **F05-FE.TESTS** — unit (mapping helper, progression read-model, resolver incl. corrupt-asset), widget (home CONTINUE/progress/terminal, the tutorial gate + re-show, `Next Level` → N+1 / terminal), integration against the real `JourneyProgressRepo` + in-memory DB (unlock idempotency, CONTINUE resume).

## QA Tasks

* **Progression:** unlock N→N+1 at 1★ and 3★; locked N+1 not openable (incl. direct entry); replay a completed level → no re-lock / no progress change; `markCompleted` idempotency (real repo + in-memory DB).
* **CONTINUE / resume:** in-progress → resumes at saved state (kill/relaunch — folds into the device smoke); no in-progress → lowest unlocked incomplete; all 30 → terminal, no crash.
* **`Next Level`:** panel of N (N<30, content present) → N+1; panel of the last available level / level 30 → terminal.
* **Micro-tutorial:** shows on first 4–6 entry; re-shows after force-quit until acknowledged; not again after acknowledge; not shown for 1–3 or 7+.
* **Content resolver:** resolve by number → right `Puzzle`; corrupt/missing asset → load-error, rest of Journey playable; offline → loads from bundle.
* **Build gate:** manifest with <30 / missing asset / band-rule violation → gate fails (strict mode) / logs (smoke mode).
* **UI-handoff alignment:** home CONTINUE/progress/terminal + the tutorial overlay vs `ui-design.md`; chrome parity with F03; `premium-ui-rubric.md` ≥ 90.
* **Regression:** F03 play + F04 completion suites still green; the F04 `CompletionPanel.onNextLevel` now-enabled path doesn't break the disabled-state tests.
* **Device (runtime):** CONTINUE-resume feel + the tutorial + the home visuals — **the first app-build distribution device smoke** (F03's 3-item manual confirmation + F04's N4 reveal feel fold in).
* Security compliance N/A (single actor, local-only progress, no endpoint) — justify.

---

# 17. Delivery Note for Tech Lead

## Decisions to carry into `architecture.md` (recommendations)

| # | Decision | Recommendation | Alternatives / trade-offs |
| --- | --- | --- | --- |
| D1 | **Level id ↔ number scheme** | `Puzzle.id = 'journey-<lang>-<NN>'`, `journeyLevelNumber = N`; F05 parses N from the id; the F08 active-session snapshot gets **no new field** (in-progress level derived from `puzzleId`). | Add `journeyLevel` to the F08 snapshot JSON → an F08 "frozen contract" amendment; more explicit but a contract touch. |
| D2 | **Tutorial-ack flag storage** | A `kv` row (`journey_col_tutorial_ack`) — **no schema change**, F08-precedented. | A `BoolColumn` on `journey_progress` → an F08 forward-only migration + `architecture.md` amendment; cleaner typing, more ceremony. |
| D3 | **Unlock-write hook** | Inject `journeyProgressRepo` + `journeyLevel` into `PlaySessionController` (mirrors F04's `personalBestRepo` + `guestId`); fire-and-forget caught; ordered after the `personal_best` write. | A screen-level / listener reaction — keeps the controller lean but adds a second "won" reactor and less explicit ordering. |
| D4 | **`Next Level` navigation** | `pushReplacement` for N→N+1; terminal + tutorial as **in-screen states**, no new routes; all back paths → `/`. | `push` (30-deep stack — rejected); a dedicated `/journey-complete` route (unnecessary). |
| D5 | **Journey content asset home** | App-layer loader reading `rootBundle` + `Puzzle.fromJson`, assets in `app/assets/journey/<lang>/` mirrored from `content/journey/<lang>/` by a `melos` step (keeps `looplet_content` pure Dart). | Bundle in `packages/looplet_content/assets/` + a loader there — couples `looplet_content` to Flutter's `AssetBundle`. |
| D6 | **Content-manifest build gate** | A new check (extend F06 `check` or a `melos content:check` step) with "smoke" (interim, non-failing) and "strict" (`== 30`, CI-failing) modes; flips when `F06-CONTENT` lands. | No gate — risks shipping `< 30` / a broken level silently (rejected). |
| D7 | **Interim content** | A documented `journey_manifest_tr.json` mapping the F06 smoke set (`smoke-tr-01/02/04/05/06`) to levels 1–5 (or a 6-slot map) so F05 build + QA exercise the resolver + unlock + the 4–6 tutorial. | A pure stub with fake puzzles — less realistic; the real smoke puzzles are better. |
| D8 | **F09 seam** | Ship the `if (!onboardingComplete) → [PENDING — F09]` branch with `onboardingComplete` hard-`true`; F09 flips it. | Wait for F09 — blocks F05 unnecessarily (rejected). |

## Tech Lead decisions that should stay **unresolved** until DURUM 3 (not for `architecture.md` yet)

* **`Release Scope`** (Open Question 4) — is F05 the first app-build distribution gate? → `production-readiness` + `F05-DEVOPS`, a narrower content-pack gate, or deferred. This drives whether `F05-DEVOPS` is in the routing.
* **`F06-CONTENT` scheduling** (Open Question 5) — open it now (parallel), or gate F05 QA on it. F05 **cannot reach `Done`** without the 30 real levels.
* **F04 `Next Level` weighting swap** (Open Question 7) — in F05-UI's scope or deferred.

## Contract risks

* **The id scheme (D1) is load-bearing** for `personal_best` (F04) and snapshot resume (F03/F08). Locking it wrong, or letting `F06-CONTENT` diverge from it, silently orphans player data. → `architecture.md` must state the id scheme as a **hard constraint on `F06-CONTENT`**.
* **The F08 `kv` table is shared** (`active_session`, `store_meta`, now the tutorial flag) — key collisions must be avoided; recommend a documented key registry in `f08 architecture.md` or a `kv` key constant file.
* **No upstream business-rule conflict found.** The product PRD open question "Does a 1★ Journey level still show Next Level?" is **resolved in the PRD's own AC** ("completed with **any** star count … N+1 is unlocked") and in `prd.md` AC13 → **yes**. No PO escalation needed.

## Analyst recommendation summary

* **Recommendation:** proceed to DURUM 3 with D1–D8 as above; keep `Release Scope`, `F06-CONTENT` scheduling, and the F04-weighting swap as explicit Tech Lead decisions at the contract turn.
* **Alternatives considered:** captured per-decision in the table above.
* **Trade-offs:** the main axis is *contract-touch vs cleanliness* — the recommendations consistently favour **no contract change** (`kv` flag, id-parsing over a new snapshot field, app-layer loader) at a small cost in typing/ceremony, keeping F05 a pure consumer of F03/F04/F06/F08.

---

# 18. Sonraki Komut

```
Run Tech Lead
```

Context for the Tech Lead:

* Review this analysis; lock `architecture.md` (DURUM 3) with D1–D8.
* Decide `Release Scope` + whether `F05-DEVOPS` opens; decide `F06-CONTENT` scheduling; decide the F04 `Next Level` weighting-swap scope.
* Set the UI Designer brief (home CONTINUE/progress/terminal + the 4–6 column micro-tutorial overlay).
* Confirm the id scheme (D1) as a hard constraint written into `architecture.md` for `F06-CONTENT`.

---

# 19. Orchestration Signals for Tech Lead

* Analysis ready: **yes.**
* Blocker: **none to start F05.** `F06-CONTENT` is a hard prerequisite for F05 `Done` (not for build/QA against the interim manifest) — a scheduling decision, not a blocker.
* Product clarification needed: **no** — the one open PRD question (1★ → Next Level) is resolved by the PRD's own AC.
* Tech Lead decision needed: **yes** — D1–D8 to lock in `architecture.md`; `Release Scope` + `F05-DEVOPS`; `F06-CONTENT` scheduling; F04-weighting-swap scope (see §17).
* Ready for contract planning: **yes.**
