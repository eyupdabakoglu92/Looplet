# F05 — journey-progression: Architecture (Contract)

> Status: **LOCKED (2026-09-07, Tech Lead — DURUM 3).** `analysis.md` decisions D1–D8 consumed. `[PENDING — UI]` **resolved** by `ui-design.md` (F05-UI, 2026-09-08). **Amended 2026-09-09 (Tech Lead — F05-QA `Rejected` reconcile, DURUM 5):** §5.4 (interim-turn `strict`-branch unit coverage required now), §12 + §15 (AC2 satisfied by construction — test-asserted, no hot-path guard; the explicit locked affordance → `[DEFERRED — F10]`), §15 (`Next Level` needs a trigger→outcome nav test, not just the routing fn), §17 (`[DEFERRED — F10]` level-select surface + affordance + guard). **Amended 2026-09-13 (Tech Lead, on the user's decision — `F06-CONTENT-PROMOTE`):** §5.4 — corrected the levels 1–3 `optimalMoves` claim (`{3,4}` was unachievable for a rows-only 5-letter 5×5 and was never actually gate-enforced; locked to `optimalMoves == 2`, matching the accepted `F06-CONTENT-DRAFT` pack). D1–D8 **unchanged**. `[PENDING — F06-CONTENT]` **resolving this turn** — the user accepted the AI-drafted 30 levels as-is; promotion to `content/journey/tr/` routed to Frontend/Mobile Developer (`F06-CONTENT-PROMOTE`). `[PENDING — F09]` still open. **Amended 2026-09-26 (Tech Lead — F05-QA-STRICT `Rejected` reconcile):**
* §5.4: band-rule enforcement ownership on the shipped bundle, with one rejecting negative case per rule; shipped bundle == `content/` mirror; `content:check` Journey-manifest recognition.
* §6 + §10: the read-model is live on both sources. The one-shot snapshot read was the root cause of F05-QA-STRICT-3. The replay-in-progress semantics are clarified and unchanged.
* §15: QA focus now covers the warm path and the negative cases.

**Amended 2026-09-27 (Tech Lead — F05 closure):** §8 + §6 now state terminal precedence explicitly. When all 30 levels are complete, the terminal variant wins over an in-progress replay; this matches AC9, ui-design and the shipped behaviour (QA note N1). To be revisited in Design Adoption Phase D.

Contract authority for F05. Execution state is in `orchestration.md`.

---

## 1. Purpose

Wire the isolated F03 play session into a **30-level linear campaign**. Define: the **level identity scheme**; the **bundled Journey content pack + manifest + resolver**; the **progression read-model** over F08's `journey_progress`; the **unlock write** on the F04 win path; the **CONTINUE / `Next Level` / terminal** navigation over `/` and `/play`; the **column micro-tutorial** (levels 4–6); the **minimal home surface** replacing the debug `HomeScreen`. F05 changes **no** F03/F04/F06/F08 contract — it consumes them and fills their `[PENDING — F05]` seams.

---

## 2. Authorities & Inputs

| Authority | Role |
| --- | --- |
| `product/product-prd.md` → F05 section + §6.1 F05 row + §5.1/§5.2 + §15 `JourneyProgress` + §41 KPIs | product contract |
| `features/f05-journey-progression/prd.md` | feature scope + AC1–AC14 |
| `features/f05-journey-progression/analysis.md` | Technical Analyst — D1–D8 consumed here |
| `features/f03-puzzle-play-session/architecture.md` → §13 (route/nav) + `PlaySessionArgs` | **consumed** — `/play`, `journeyLevel`, the win moment, the F08 restore path |
| `features/f04-star-rating-and-personal-best/architecture.md` → §7 (panel) + §8 (`Next Level` = `[PENDING — F05]`) | **consumed** — the `onNextLevel` seam + the win-path side-effect pattern |
| `features/f06-.../architecture.md` → `Puzzle` model + `export`/`check` + difficulty labels | **consumed** — the content format + the 30 levels (`F06-CONTENT`) |
| `app/lib/persistence/repositories/journey_progress_repo.dart` + `journey_progress` table (F08) | **consumed** — the unlock persistence (built) |
| `app/lib/persistence/active_session_snapshot.dart` (F08) | **consumed** — CONTINUE resume; **F05 reads only, never writes/extends** |
| `project-authority/platform.md` | Flutter / Riverpod / `go_router`; asset bundling; localization |
| `project-authority/release.md` | `Release Scope` decision (see §13) |
| `design/design-doctrine.md` + `design/premium-ui-rubric.md` | the home / progress / tutorial-overlay quality bar |

---

## 3. Substrate already built (consume, do not rebuild)

* **Unlock persistence (F08):** `journey_progress` table — `highestUnlockedLevel` (int, default 1), `completedLevelsCsv` (text). `JourneyProgressRepo` — `markCompleted(guestId, levelNumber)` (transactional; `highest = max(existing, N+1)`; `completedLevels ∪= {N}`; idempotent for progress), `read(guestId)`, `watch(guestId)` (a `watchSingle` stream), `completedLevels(guestId)`. `journeyProgressRepoProvider`. **No schema change.**
* **Play entry (F03):** route `/play`, `PlaySessionScreen(args: PlaySessionArgs)`, `PlaySessionArgs {PuzzleSource source, int? journeyLevel, String? debugPuzzleId}` — `journeyLevel` defined, currently unused. `app_router.dart` `Routes.play` reads `state.extra as PlaySessionArgs`.
* **Content-resolution seam (F03):** `playSessionSetupProvider = FutureProvider.family<PlaySessionSetup, PlaySessionArgs>` — handles `debugPuzzleId`, `throw UnsupportedError` for other sources. **F05 fills the `journeyLevel != null` branch.**
* **Completion → Next Level seam (F04):** `CompletionPanel({..., VoidCallback? onNextLevel})` — `null` in F04 scope → disabled ghost pill. `play_session_screen.dart` builds the panel. **F05 supplies `onNextLevel`.**
* **Win-path side-effect pattern (F04):** `PlaySessionController` takes optional `personalBestRepo` + `guestId`; on win, `_resolvePersonalBest` does prior-read → `recordCompletion` → read-back → build `CompletionResult`, **fire-and-forget with a caught failure**, never blocking the panel. **F05 mirrors this for the unlock write (D3).**
* **Engine config (F08):** `toEngineConfig(Puzzle)` in `app/lib/content/puzzle_engine_config.dart` — consumed by `PlaySessionController`.
* **Content format (F06):** `Puzzle` / `Puzzle.fromJson` (engine-free, `looplet_content`); `optimalMoves` guaranteed by `export`/`check`; `difficultyLabel ∈ {easy, medium, hard, expert}`; `columnMovesEnabled`, `lockedCells`, `frozenCells` are content properties.
* **`kv` table (F08):** generic `key` TEXT / `valueJson` TEXT. Already holds `active_session` + `store_meta`. **F05 adds one key (D2).**
* **Language (F08/F10):** `SettingsRepo.read(guestId).language` — default `'tr'`.

---

## 4. Level Identity [LOCKED — D1]

* **Journey level ⇄ id.** A Journey level `N ∈ 1..30` has `Puzzle.id == 'journey-<lang>-<NN>'` (zero-padded two digits, e.g. `journey-tr-07`) and `Puzzle.journeyLevelNumber == N`.
* **This is a HARD CONSTRAINT on `F06-CONTENT`** — every authored Journey artifact + the manifest MUST use exactly this scheme. `Puzzle.id` is the durable key for:
  * F04's `personal_best.levelId` (`levelId == puzzle.id`);
  * F03's restore (`PlaySessionController._tryRestore` fires only when `snapshot.puzzleId == puzzle.id`).
  Changing a shipped level's id orphans that player's best + any in-progress snapshot — permitted only pre-launch.
* **Level-number helpers** (F05 code): `journeyLevelId(int n, String lang) → 'journey-<lang>-<NN>'` and `parseJourneyLevel(String puzzleId) → int?` (returns `null` for a non-`journey-<lang>-NN` id — e.g. a debug/daily id). Single source of truth for the mapping.
* **The F08 active-session snapshot is NOT extended** — the in-progress Journey level is derived as `parseJourneyLevel(snapshot.puzzleId)` when `snapshot.puzzleSource == journey && snapshot.status == inProgress`.

---

## 5. Bundled Content + Manifest + Resolver [LOCKED — D5, D6, D7]

### 5.1 Asset home [D5]

* **Journey level artifacts + manifest are bundled app assets**, mirrored from the F06 `export` output:
  * source of truth (authored, checked-in): `content/journey/<lang>/journey-<lang>-NN.json` + `content/journey/<lang>/journey_manifest_<lang>.json`;
  * bundled into the app: `app/assets/journey/<lang>/…` (registered in `app/pubspec.yaml` `flutter: assets:`), kept in sync by a **`melos` mirror script** (`melos run content:sync` — copies `content/journey/**` → `app/assets/journey/**`) run in CI before `build`.
* **`looplet_content` stays pure Dart** — the loader lives in the `app` layer (reads `rootBundle`, calls `Puzzle.fromJson`).

### 5.2 Manifest schema

```
journey_manifest_<lang>.json
{
  "schemaVersion": 1,
  "contentVersion": "<string>",
  "lang": "tr",
  "mode": "smoke" | "strict",          // "smoke" while F06-CONTENT is incomplete
  "levels": [
    { "n": 1, "id": "journey-tr-01", "asset": "journey/tr/journey-tr-01.json",
      "difficultyLabel": "easy", "checksum": "<sha256 of the asset bytes>" },
    …  // n contiguous from 1; 30 entries required when mode == "strict"
  ]
}
```

### 5.3 Resolver

Fills `playSessionSetupProvider`'s `journeyLevel != null` branch (or a dedicated `journeyContentRepoProvider` the branch delegates to):

1. resolve the active language — `SettingsRepo.read(guestId).language`, default `'tr'`;
2. load + cache `journey_manifest_<lang>.json` (one parse per session; a `FutureProvider` or an in-memory map);
3. look up `levels` where `n == journeyLevel`; **absent → throw `JourneyContentException`** (a typed failure);
4. `rootBundle.loadString(<asset>)` → `jsonDecode` → `Puzzle.fromJson` (throws `PuzzleFormatException` on a malformed artifact);
5. assert `puzzle.id == manifest.id`, `puzzle.journeyLevelNumber == n`; verify the `checksum` (optional but recommended);
6. return `PlaySessionSetup(puzzle: puzzle, validator: <wordValidatorProvider.future>)`.

* **Corrupt / missing asset or manifest entry** → the resolver future errors → F03's **existing load-error state** (`_LoadErrorBody`, `Geri` → `/`). The rest of the Journey still resolves (per-level failure, not a campaign crash).
* **Caching:** per `(lang, n)`; 30 small artifacts; no eviction.

### 5.4 Content-manifest build gate [D6]

A new check — **`melos run content:check` extended** (F06's `check` / a `flutter test` asset test in `app`). Owner: **Frontend (F05-FE.GATE)** — analogous to F06's `content:check`, no DevOps.

* Always (both modes): the manifest parses, `schemaVersion` known, `levels[n]` contiguous from 1, each `asset` resolves + `Puzzle.fromJson` succeeds, `puzzle.id == manifest.id == 'journey-<lang>-<NN>'`, `journeyLevelNumber == n`, `optimalMoves >= 1`, `checksum` matches.
* **Band rules (structural):** `n ∈ 1..3` ⇒ `columnMovesEnabled == false`; `n ∈ 4..10` ⇒ `columnMovesEnabled == true`; `n ∈ 16..20` ⇒ `lockedCells` non-empty; `n ∈ 21..25` ⇒ `frozenCells` non-empty; `n ∈ 26..30` ⇒ both non-empty. **Gate-enforced by `tools/looplet_authoring check` / `content:check`** (`_expectedBands` in `content_check.dart`): `columnMovesEnabled == false` for 1–3, and `difficultyLabel` inside the level's expected band (1–6 → {easy, medium}; 7–15 → {easy, medium, hard}; 16–25 → {medium, hard, expert}; 26–30 → {hard, expert}). (Levels 11–15 "temporary-displacement weight" is a difficulty-score property — validated by the `difficultyLabel` + `F06-CONTENT` playtest, not a hard structural check.)
* **Levels 1–3 `optimalMoves` — corrected 2026-09-13 (Tech Lead, on the user's decision, F06-CONTENT-DRAFT investigation).** Earlier text here (and in `content-authoring-brief.md §4` / `prd.md` / `product-prd.md §20`'s sourcing AC) called for `optimalMoves ∈ {3,4}` on levels 1–3. **That is unachievable and was never actually gate-enforced.** A rows-only 5×5 with a 5-letter target has exactly one solve shape — a single-row cyclic rotation — so the provable minimum is `min(k, 5-k) ≤ 2` for any k; `optimalMoves` can only be 1 or 2, never 3 or 4. Neither `tools/looplet_authoring check` nor F05's own manifest gate (`journey_gate_support.dart` — "band rules deferred to `F06-CONTENT`") ever checked the `{3,4}` claim; it was aspirational text with no code behind it. **Locked decision: levels 1–3 ship at `optimalMoves == 2`** (the deliberate tutorial on-ramp — `min(2,3)=2`, the least-trivial value reachable). No gate change needed (nothing enforced the old claim to begin with); this is a documentation correction, not a contract behavior change. `content-authoring-brief.md §4` and `prd.md` amended to match this turn.
* **`mode == "smoke"`** (interim): the gate asserts consistency of whatever levels are present + logs the shortfall to `< 30`; **does not fail CI**.
* **`mode == "strict"`** (when `F06-CONTENT` lands): `levels.length == 30` **required**; any violation **fails CI**. Flipping the mode is a one-field manifest edit + the gate reads it.
* **Interim-turn coverage [amended 2026-09-09, F05-QA reconcile]:** even while the shipped manifest is `mode == "smoke"`, the gate's **`strict` branch itself is a Mode/Configuration variant that MUST carry executed coverage now** — a unit test feeding a synthetic `mode: "strict"` manifest with `< 30` levels (and one with an unresolvable `asset`) and asserting the gate **rejects** it. Only the *structural band rules* legitimately wait for `F06-CONTENT` (they need the real 30 authored levels); the bare `levels.length == 30` + asset-resolution checks do not.
* **Band-rule enforcement ownership [amended 2026-09-26, F05-QA-STRICT reconcile].** `F06-CONTENT` has been delivered, so the band rules are now due.
  * **Authority:** F05's own build gate (`runJourneyManifestGate`, run by `journey_manifest_gate_test.dart` inside `melos run test` / `content:journey`) is the authority for all six band rules, applied to the **shipped bundle** (`app/assets/journey/<lang>/`).
  * **The six rules:** R1–R5 are the structural rules above. R6 is `difficultyLabel` inside the level's band, using the same bands as `_expectedBands`.
  * **Label consistency:** the manifest entry's `difficultyLabel` must equal the asset's `difficultyLabel`.
  * **Modes:** in `mode:"strict"` every violation is a named gate violation and fails CI. In `mode:"smoke"` violations are logged as advisory.
  * **Evidence per rule:** each rule needs (a) an executable assertion and (b) a synthetic negative case asserting the gate rejects that specific violation (rule → check → negative example). A test body that asserts nothing is not coverage.
  * **`content:check`:** keeps its existing R1/R6 checks and solver re-verification on `content/` as defence in depth; it is not the band-rule authority.
  * **Out of scope:** levels 1–3 `optimalMoves == 2` remains a documented content decision, not a gate rule (unchanged).
* **Shipped bundle == verified source [amended 2026-09-26].** CI fails if `app/assets/journey/<lang>/` is not byte-identical to `content/journey/<lang>/` (the `content:sync` mirror). This makes `content:check`'s solver re-verification, which runs on `content/`, cover what actually ships. Placement is the implementer's choice (`content:check --repo-root` or an app test); a negative case is required.
* **Journey-manifest recognition in `content:check` [amended 2026-09-26].** A file is skipped as a Journey manifest only if **both** hold:
  * it is `content/journey/<lang>/journey_manifest_<lang>.json`;
  * it has the manifest shape (`schemaVersion`, `mode`, `lang`, and a `levels` list).

  Any other JSON carrying a `levels` key is validated as a `Puzzle` artifact and fails if it is not one. A malformed manifest also fails. Negative cases are required. (This closes F05-QA-STRICT-2: a stray `"levels": []` used to skip all puzzle validation.)

### 5.5 Interim content [D7]

Until `F06-CONTENT` delivers, F05 builds + QAs against a checked-in **`content/journey/tr/journey_manifest_tr.json` with `mode: "smoke"`** mapping the F06 smoke set to levels 1–5:

| n | id | source smoke puzzle | exercises |
| --- | --- | --- | --- |
| 1 | `journey-tr-01` | `content/smoke/tr/level01.json` (`smoke-tr-01`, opt 1, rows-only) | levels 1–3 band, unlock 1→2 |
| 2 | `journey-tr-02` | `smoke-tr-02` (opt 2, rows-only) | unlock 2→3 |
| 3 | `journey-tr-03` | `smoke-tr-04` (opt 1) | unlock 3→4 |
| 4 | `journey-tr-04` | `smoke-tr-05` (locked cell) | **4–6 band → the column micro-tutorial trigger**; locked-tile render |
| 5 | `journey-tr-05` | `smoke-tr-06` (frozen cell) | 4–6 band; frozen-tile render; `Next Level` past the last available level → terminal |

The 5 interim artifacts are **copies of the smoke JSON re-`id`'d to `journey-tr-0N`** (a `melos`/script step, or hand-authored copies committed under `content/journey/tr/`). `journeyLevelNumber` set to `n`. This lets F05 build + QA exercise: the resolver, unlock idempotency, CONTINUE resume, the 4–6 tutorial gate (levels 4–5), `Next Level` → terminal (from level 5, the last available). **F05 → `Done` requires the real 30 (`mode: "strict"`, gate green).**

---

## 6. Progression Read-Model [LOCKED]

Derived from `journey_progress` + the persisted active-session snapshot, **both observed live**. No new storage.

*Amended 2026-09-26 (F05-QA-STRICT reconcile):* this was a one-shot snapshot read. Because the home stays mounted under the pushed `/play` route, the one-shot read left the in-progress state and the CONTINUE target stale for the rest of the app session.

* `LevelState(n)` for `n ∈ 1..30`:
  * `locked` ⇔ `n > highestUnlockedLevel`;
  * `completed` ⇔ `n ∈ completedLevels`;
  * `unlockedIncomplete` ⇔ `n <= highestUnlockedLevel && n ∉ completedLevels`;
  * `inProgress` ⇔ an F08 snapshot exists with `puzzleSource == journey && status == inProgress && parseJourneyLevel(puzzleId) == n` (at most one).
    * This **includes a replay of an already-completed level**: for that level the in-progress state takes precedence over `completed`, and `progressCount` is unaffected.
    * CONTINUE therefore resumes the replay (product AC7: "Given an in-progress level … that level resumes") — except in the terminal state, where §8's terminal precedence applies.
    * These semantics are unchanged; clarified 2026-09-26.
* `currentLevel` (for CONTINUE) = the `inProgress` level if any, else `min({n : unlockedIncomplete})`, else `null` (all 30 done → terminal).
* `progressCount` = `|completedLevels ∩ {1..30}|` (clamp — ignore strays).
* Exposed as a Riverpod provider that **re-derives whenever either source changes** [amended 2026-09-26]:
  * `JourneyProgressRepo.watch(guestId)` — win commits;
  * the active-session snapshot — session start, move, completion and clear; for example a Drift watch over its stored row.
* The same persisted state must yield the same model whether the app was just relaunched (cold) or the home stayed mounted (warm).
* No new package dependency.

**Consumers must handle all four `LevelState` values** (home tiles, the `Next Level` gate, CONTINUE).

---

## 7. Unlock Write on the Win Path [LOCKED — D3]

* `PlaySessionController` gains **optional ctor params** `journeyProgressRepo` (F08's `JourneyProgressRepo`) + `journeyLevel` (`int?`) — mirroring F04's `personalBestRepo` + `guestId`. `_LoadedPlaySession._init()` (F03) passes `widget.args.journeyLevel` in (an additive line — no F03 contract change).
* On win, in the existing win side-effect path (a sibling of `_resolvePersonalBest`, e.g. `_resolveJourneyProgress`): if `source == journey && journeyProgressRepo != null && guestId != null && journeyLevel != null` → `await journeyProgressRepo.markCompleted(guestId, journeyLevel)`, **fire-and-forget with a caught failure** (`try/catch` → `debugPrint('journey: unlock_persist_failed (non-fatal) — $error')`), **ordered after** the `personal_best` write is initiated (both are independent local writes; the fixed order only aids test assertions). **Never blocks the panel.**
* **Idempotent** — `markCompleted` is a progress no-op on re-completion (Retry → re-solve). F05 adds no dedup.
* A caught failure → the unlock is retried on the next completion of that level (or lost until then) — the same posture as F03's `_persist` / F04's `_resolvePersonalBest`. This is the **shared storage-full test-debt class** (F03 QA note 3 / F08 AC7 / F04 N3) — a fault-injection test is a tracked follow-on, not an F05 gate.

---

## 8. CONTINUE / `Next Level` / Terminal Navigation [LOCKED — D4]

* **Routes:** reuse `/` (home) and `/play`. **No new route.** The terminal "all complete" state and the tutorial overlay are **in-screen states**.
* **CONTINUE** (home primary CTA): resolve `currentLevel` (§6). If `null` → render the terminal home variant in place. Else `context.push('/play', extra: PlaySessionArgs(source: journey, journeyLevel: currentLevel))`.
  * **Terminal precedence [amended 2026-09-27, F05 closure — QA note N1].** Once all 30 levels are complete (`progressCount == 30`), the home renders the terminal variant (AC9; ui-design: `TEKRAR OYNA` → level 1), even when a replay of a completed level is in progress.
    * That replay is not surfaced; starting another level supersedes its save.
    * This is an accepted edge with low impact: it only affects post-completion personal-best replays. It is the shipped and QA-verified behaviour.
    * To be revisited when the home is redesigned in Design Adoption Phase D.
* **`Next Level`** (fills F04's `CompletionPanel.onNextLevel`): let `n = <this session's journeyLevel>`. If `n != null && n < 30 && manifest has n+1` → `context.pushReplacement('/play', extra: PlaySessionArgs(source: journey, journeyLevel: n + 1))`. Else → `context.go('/')` (home → terminal variant). **`pushReplacement`** so the back stack never accumulates `/play` frames.
* **Back:** unchanged from F03 — chevron hidden in `won`; `Close` / system / gesture back → `_popToCaller` *[amended 2026-09-28, F03 §20.3 (7): no `Close`; the result's back button and system / gesture back]*, which **must resolve to `/`** (add a `context.go('/')` fallback when `!canPop`, e.g. a deep-link entry). From any Journey level, back lands on `/`.
* **Route graph:** `/` ⇄ `/play` only. Every `/play` exit → `/`. No 30-deep stack. No wrong-route, no empty stack.
* **`Next Level` on the last available interim level (5) or level 30** → terminal state (a valid action, never a dead no-op).

---

## 9. Column Micro-Tutorial (levels 4–6) [LOCKED — D2 for storage; `[PENDING — UI]` for the overlay]

* **Trigger:** on `/play` load (after content resolves), if `journeyLevel ∈ {4,5,6}` **and** the ack flag is false → show the overlay.
* **Behaviour:** an **action-gated** coach-mark over the F03 board — the player performs a column shift to dismiss. Persists `ack = true` **only** on the gated action completing (AC11). Distinct from F09 onboarding.
* **Re-show (AC11):** quitting before the gated action leaves `ack = false` → the overlay re-shows on the next entry to any level in 4–6.
* **Persisted flag [D2]:** a **`kv` row** — `key = 'journey_col_tutorial_ack'`, `valueJson = '{"ack": true, "atUtcMs": <int>}'`. **No F08 schema change.** A tiny `JourneyTutorialRepo` (or a generic `kv` accessor) reads/writes it. Single-guest today → a bare key; documented in the `kv` key registry (§14).
* **Visual design** of the overlay (layout, coach-mark, gating affordance, chrome parity with F03 Direction A) is **`[PENDING — UI]`**.
  * **[Amended 2026-09-27 — Design Adoption Phase D1]** Visual authority moves to F03 `architecture.md` §19 and the F03 D1 handoff (Loop Glass, render S-07). The overlay is re-skinned in the F03 reopen as a cross-feature item:
    * the hint pill sits above the HUD, and undo and restart stay usable;
    * the ghost hides while the player drags.
  * The behaviour above is unchanged, and F05 stays Done.
  * The home (§10) is re-composed in Phase D3, with F05 as the carrier.

---

## 10. Home Surface [LOCKED contract; `[PENDING — UI]` visual]

* Replaces `app/lib/home_screen.dart` (currently a debug `Wrap` of `smoke-tr-*` buttons). The debug buttons move behind `kDebugMode` or are removed (`[IMPL — Frontend]`).
* **Content (AC10):** LOOPLET wordmark; **CONTINUE** (primary CTA — §8); a **journey-progress indicator** ("`progressCount` / 30" + a completed/unlocked visual), bound to `JourneyProgressRepo.watch` (live-updates when a win commits, even after the player pops back to `/`) **and** to the active-session snapshot (§6). The in-progress state and the CONTINUE target update as soon as the player pops back to `/` [amended 2026-09-26].
* **Terminal variant ("all 30 complete"):** a distinct home state — a completion message; CONTINUE hidden or repurposed ("Replay a level" — **UI Designer's call**, Open item). No crash, no dead button.
* **Chrome:** `/` is the app root — **no back affordance**. Not the F10 menu (no DAILY, no Settings icon, no level-select map — F10 re-homes this surface).
* **Strings:** F05 UI strings follow F03's interim per-language table pattern (`PlayStrings`-style). `gen_l10n` stays `[DEFERRED — F10-or-earlier]` (F03's clarification).

---

## 11. F09 Seam [LOCKED — D8]

* F09 (`Not Started`) owns the pre-Level-1 onboarding. F05 ships the branch: `if (!onboardingComplete) → <[PENDING — F09] route into F09>  else → currentLevel resolution`, with `onboardingComplete` **hard-wired `true`** and a `// [PENDING — F09]` marker.
* Interim behaviour: a brand-new player's CONTINUE → Level 1 directly.
* F09 later supplies the real `onboardingComplete` signal (its own `kv` flag / `settings` column) and the route target.

---

## 12. Validation Responsibility [LOCKED]

* **F05:** the unlock rule (AC1/AC2/AC13 — stars never gate, no re-lock); the `LevelState` derivation; CONTINUE / `Next Level` / terminal resolution (AC7/AC8/AC9/AC12); the progress-indicator accuracy (AC10); the 4–6 micro-tutorial gate + re-show + ack-persist (AC4/AC11); the bundled-content resolver + corrupt/missing-asset degradation; offline load (AC14); the content-manifest build gate.
* **AC2 clarification [amended 2026-09-09, F05-QA reconcile]:** AC2's *"no navigation to a locked level"* is satisfied **by construction** — the home's CONTINUE resolves only to `currentLevel` (§6, always `≤ highestUnlockedLevel` or the in-progress level); `Next Level` advances only to an `N+1` the player just earned; there is no deep-link route; `/play` with no `extra` falls back to a debug id. F05 validation is a test asserting **no F05 navigation path emits a `locked` `LevelState`** (across new / mid / in-progress / terminal + the last-available boundary) — not a runtime guard on the hot path. AC2's *"clear locked affordance"* half needs a level-select surface that is **explicitly out of MVP** (`prd.md §5`, `ui-design.md §10` — "no level-select map") → `[DEFERRED — F10]` (see §17).
* **F08 `JourneyProgressRepo`:** the transactional idempotent unlock write.
* **F06 / `F06-CONTENT`:** the 30 levels exist, follow the id scheme (§4), land the curve bands (AC3/AC5/AC6), each carry `optimalMoves`.
* **F03:** the play session + the F08 restore path. **F04:** the completion panel + the `onNextLevel` seam + the win-path side-effect pattern.

---

## 13. Release / Deployment Impact [LOCKED — Tech Lead decision]

* **`Release Scope` = `none`.** F05 adds **no** deploy / container / environment / server change. The Journey content pack is **bundled in the app binary** (same posture as F01's dictionary assets + F06's smoke content, both `Release Scope = none`). The one CI addition — the content-manifest build gate + the `content:sync` mirror step — is **directly analogous to F06's `content:check`** and is a **Frontend/tooling task (F05-FE.GATE), not a DevOps turn.** **No `DevOps/Release Engineer` for F05.**
* **The first app-build distribution** (TestFlight / Play internal — needed for the Level 5 Reach / D1 / D7 KPIs, and where F03's 3-item manual device confirmation + F04's N4 reveal-feel device smoke land) is a **separate, deferred portfolio-level gate** ("first-app-distribution"), **parked** alongside F08's Firebase deploy: it needs an Apple Developer Program membership (the user has none — deferred) + Android Play Integrity SHA-256 (in the parked `F08-DEVOPS`). It is **NOT an F05 `Done` blocker**. F05 QA does `automated functional` (mandatory) + an optional ad-hoc device pass on the connected iPhone (no formal distribution).
* CI code gates (`format:check` / `analyze` / `test` / `content:check` (extended) / `build:app` / `build ios`) still apply. Rollback for the content pack = ship the previous binary (no server component).

---

## 14. `kv` Key Registry [LOCKED — housekeeping]

The shared F08 `kv` table now holds:

| key | writer | shape | notes |
| --- | --- | --- | --- |
| `store_meta` | F08 bootstrap | `{"guestId":…, "createdAtUtcMs":…}` | seed metadata |
| `active_session` | F03 (`ActiveSessionRepo`) | the frozen `ActiveSessionSnapshot` JSON | one row; F05 reads only |
| `journey_col_tutorial_ack` | **F05** (`JourneyTutorialRepo`) | `{"ack": true, "atUtcMs": <int>}` | absence ⇔ not acknowledged |

F05-FE adds `journey_col_tutorial_ack` here; any future `kv` key is added to this table (documented so keys don't collide).

---

## 15. QA Focus [LOCKED]

* **Progression (`automated functional`):** unlock N→N+1 at 1★ **and** 3★ (AC1/AC13 — the unlock write is star-agnostic, so an end-to-end 1★ solve is a *bonus*, not a gate; the required evidence is that `_resolveJourneyUnlock` fires irrespective of the star result and the CTA weighting enables `Next Level` at 1–2★); **AC2 — no F05 navigation path resolves to a `locked` level** (asserted across new / mid / in-progress / terminal + the last-available boundary; see §12 — the explicit locked *affordance* is `[DEFERRED — F10]`, no direct-entry guard on the hot path); replay a completed level → no re-lock / no progress change; `markCompleted` idempotency against the **real F08 `JourneyProgressRepo`** + an in-memory DB.
* **CONTINUE / resume:** in-progress → resumes at the exact saved state (kill/relaunch — via the F08 restore path; an ad-hoc device pass folds into the eventual first-app-distribution smoke) (AC7); no in-progress → lowest unlocked incomplete (AC8); all 30 → terminal, no crash (AC9).
* **Warm path (`automated functional`) [amended 2026-09-26, F05-QA-STRICT-3].** With the home mounted, `/play` may write, change or clear the active-session snapshot. Cases:
  * a frontier level is started;
  * a completed level is replayed;
  * a level is won.

  On return to `/`, the home must show the same in-progress caption, `Semantics` and CONTINUE target as the cold (relaunch) derivation. Widget-test at least the frontier and replay variants, and the win clearing the in-progress state.
* **`Next Level` (`automated functional`) [emphasised 2026-09-09, F05-QA reconcile]:** the evidence MUST be a **trigger → outcome** test — tapping the rendered `SONRAKİ` CTA on a real `/play` `CompletionPanel` and observing navigation: panel of N (N<30, `n+1` present) → level N+1's `/play` via `pushReplacement` (the back stack does **not** grow); panel of the last available level / level 30 → `context.go('/')` → the terminal home. Unit coverage of the pure `nextJourneyLevel(n, manifestLevelCount)` routing fn alone does **not** satisfy AC12 (this was the F05-QA-1 blocking gap).
* **Micro-tutorial (`automated functional`):** shows on first 4–6 entry (AC4); re-shows after a simulated force-quit (ack flag still false) until the gated action (AC11); not again after ack; not shown for 1–3 or 7+.
* **Content resolver (`automated functional`):** resolve by number → the right `Puzzle`; corrupt/missing asset or manifest entry → the F03 load-error state, the rest of the Journey playable; offline (no network) → loads from the bundle (AC14).
* **Build gate:** a manifest with `mode:"strict"` + `< 30` / a missing asset / a band-rule violation → the gate **fails CI**; `mode:"smoke"` → logs + passes.
  * *Amended 2026-09-26:* each of R1–R6 and the manifest-label check needs its own rejecting negative case (§5.4).
  * A shipped bundle that differs from `content/` fails.
  * `content:check` rejects a `Puzzle` artifact carrying a stray `levels` key instead of skipping it.
* **`ui-design.md` alignment:** the home CONTINUE/progress/terminal surface + the 4–6 micro-tutorial overlay vs `ui-design.md`; chrome parity with F03 Direction A; `premium-ui-rubric.md` fail conditions absent (≥ 90).
* **Regression:** the F03 play + F04 completion suites stay green; F04's `CompletionPanel` now-enabled `onNextLevel` path does not break its disabled-state tests; F04's per-outcome CTA-weighting tweak (§16) behaves.
* **Evidence class:** `automated functional` **mandatory**. `runtime` (device) is **not** an F05 gate — it folds into the deferred first-app-distribution smoke; an optional ad-hoc iPhone pass may be recorded.
* **Not `source-only`.** Security compliance N/A (single actor, local-only `journey_progress` + one `kv` flag, no auth, no endpoint) — justify in the QA scope line.

---

## 16. F04 `Next Level` CTA-Weighting Follow-on [LOCKED — in F05-UI + F05-FE scope]

F04's forward note (`f04 frontend.md §4`): once `Next Level` is live, revisit the Retry-vs-Next-Level primary/secondary weighting **per outcome**. This is F05's to close (it is exactly when `Next Level` goes live):

* **`ui-design.md` (F05-UI):** define the rule — proposal: `isPerfect` (3★) → **`Next Level` primary**, `Retry` secondary; sub-optimal (1–2★) → **`Retry` primary**, `Next Level` secondary. Applies to the existing `CompletionPanel`.
* **`completion_panel.dart` (F05-FE):** an **additive** tweak — the panel picks the primary CTA from `CompletionResult.isPerfect` (the panel already has it). No F04 contract change; the 7 AC7 elements + the six variants are unchanged.
* On a Journey **level 30** completion (or the last available interim level): `Next Level` still renders but routes to the terminal state (§8) — the weighting rule still applies to the button that's there.

---

## 17. Open Items

* `[PENDING — UI]` (F05-UI → `ui-design.md`): the minimal home surface (LOOPLET wordmark + CONTINUE + the "`N` / 30" progress indicator + the "all 30 complete" terminal variant — CONTINUE hidden vs "Replay a level"); the **levels 4–6 column micro-tutorial overlay** (action-gated coach-mark over the F03 board, re-shows until acknowledged); the F04 `CompletionPanel` **per-outcome CTA-weighting rule** (§16); chrome / atmosphere parity with F03's `ui-design.md` Direction A; `premium-ui-rubric.md` ≥ 90.
* `[PENDING — F06-CONTENT]` (**human / content deliverable — no canonical role; owner: Level Designer / user**): the 30 authored Journey levels + `journey_manifest_tr.json` with `mode: "strict"`, following the §4 id scheme + the §5.4 band rules, run through F06's `export`/`check`, committed under `content/journey/tr/`. **Hard prerequisite for F05 `Done`** — F05 code + QA proceed against the §5.5 interim (`mode: "smoke"`). Tracked in `features/f06-.../orchestration.md → Open Tasks → Content` and surfaced to the user this turn as an explicit decision (author now / defer F05 `Done`).
* `[PENDING — F09]` — the pre-Level-1 onboarding hand-off (§11). F05 ships the seam with `onboardingComplete` hard-`true`.
* `[DEFERRED — F10]` — the full menu re-homes F05's minimal home surface; F10 owns `settings` + multi-language + the language-switch-mid-progress story. **Also `[DEFERRED — F10]` (recorded 2026-09-09, F05-QA reconcile):** a **level-select surface** (the grid of level tiles) + AC2's **explicit locked affordance** + a **resolver guard** that rejects a direct `PlaySessionArgs(journeyLevel:)` request for an un-unlocked level. MVP has **no** navigation path that can produce a locked-level request (`prd.md §5` / `ui-design.md §10` — "no level-select map"; the home resolves only to `currentLevel`, `Next Level` only to an earned `N+1`, no deep links) → F05 satisfies AC2's "no navigation" clause by construction (test-asserted, §15). F10 (or a future deep-link feature) owns the affordance + the guard when a surface that can request an arbitrary level first exists.
* `[DEFERRED — F11/F12]` — audio/haptics on unlock; `level_started` / `level_completed` analytics (with the level number) are F12 seams.
* `[DEFERRED — first-app-distribution]` — TestFlight / Play internal + the folded-in F03/F04 device smokes; parked alongside F08's Firebase deploy pending the user's paid-account decision. **Not an F05 gate.**
