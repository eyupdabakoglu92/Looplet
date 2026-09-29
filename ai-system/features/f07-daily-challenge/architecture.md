# F07 — daily-challenge: Architecture

> Contract authority for F07. Tech Lead, activation 2026-09-29 (F08 `architecture.md` A21 — the user's decision F08.FUNCTION-DEPLOY-GO — C).
> Authorities: `product/product-prd.md` (F07, §5.3, §11, §15, §16); `project-authority/platform.md` (§3 / §4 content distribution, §5 persistence, §6 security, §10 testing, §14 visual); `project-authority/release.md` (§2 content packs served to clients); F08 `architecture.md` (Persistence Schema, `sync_queue` contract, Reconciliation, Firebase Sync Surface, Offline Daily Cache, Ownership & Lifecycle, Streak-Integrity / Clock, Scope Boundary F08 ↔ F07); F03 `architecture.md` (play session, §19 Play, §20 result); F04 (rating); F05 `architecture.md` §18 (Home); `project-authority/design-foundation.md`.

---

## Dependency Edges [LOCKED]

* **F08 client surface** (Functional Approved; frozen for F07 — F08 A21 ruling 4):
  * the Drift tables `daily_entry`, `daily_attempt`, `daily_streak`, `daily_puzzle_cache`, `sync_queue`;
  * `DailyRepo`, `DailyStreakRepo`, `DailyPuzzleCache`;
  * `DailyResultSyncService.enqueue` / `drain`;
  * the `submitDailyResultV1` request contract.
  * F07 composes these. It does not change their signatures or the schema. A needed change goes to the Tech Lead first.
* **F08 deployed backend:** the callable in production. It is needed only for **F07's release** (F07-DEVOPS depends on F08-DEVOPS; the gate F08.DEPLOY-RESUME). Delivery and functional QA use the Firebase emulator (the F08-FE13 debug wiring).
* **F03 play session:** `PuzzleSource.daily` already exists in the active-session snapshot. The Play screen runs a daily puzzle with its own rules (AC3). Undos 3, unlimited restart and unlimited moves are already F03's session rules; `columnMovesEnabled` comes from the puzzle.
* **F04 rating:** stars for a daily completion come from the same moves-vs-`optimalMoves` rule. Daily completions never write `personal_best` (Journey only; product PRD §6.1 F04 note).
* **F06 toolchain:**
  * `Puzzle` (type `daily` + `dailyDate`) in `looplet_content`;
  * `looplet_authoring` `solve` / `playtest` / `export` / `check`. `check` already enforces a 30-day no-repeat window over a manifest's `assignments`.

---

## D1. Dependency ruling [LOCKED — F08 A21 ruling 4]

* F07 delivery starts on F08's Functional Approved client surface.
* F07's release waits on F08's deployed callable.
* F07's sync evidence runs against the Firebase emulator (debug define), as F08's did.

---

## D2. Daily content: pack format and distribution [LOCKED]

1. **Served artifact — one self-contained pack per language:** `daily_pack_{lang}.json` (UTF-8, `lowerCamelCase`, optional fields omitted):
   ```json
   {
     "schemaVersion": 1,
     "contentVersion": "2026-10-01.1",
     "lang": "tr",
     "numberingEpoch": "2026-10-01",
     "days": [
       { "dailyDate": "2026-10-01", "dailyNumber": 1, "puzzle": { "id": "daily-tr-2026-10-01", "type": "daily", "dailyDate": "2026-10-01", "...": "the full Puzzle JSON (looplet_content)" } }
     ]
   }
   ```
2. **Rules the pack must satisfy** (the authoring `check` rules, and the client's validation):
   * `days` is sorted by `dailyDate`, contiguous, and has no duplicate date;
   * for each day, `puzzle.dailyDate == dailyDate`, `puzzle.type == daily`, `puzzle.id == "daily-{lang}-{dailyDate}"`, and the puzzle parses as a `Puzzle` with `optimalMoves ≥ 1` (solved);
   * `dailyNumber` is the number of days since `numberingEpoch`, plus 1. It is stable across packs, so F13's `LOOPLET #N` is well defined;
   * the 30-day no-repeat window holds over the puzzle definitions;
   * `lang` matches every puzzle.
3. **Identity (AC2):** the puzzle for `(lang, dailyDate)` is exactly the pack's entry. Every client reads the same pack, so the same language and date give the identical puzzle.
4. **Pointer:** Remote Config `daily_manifest_url` holds the **pack URL** (`platform.md` §4 "points at the current daily pack"). Rollback = repoint to the previous pack. An empty value means no Daily is available.
5. **Hosting** is provider-neutral for the client: any HTTPS URL.
   * Production hosting (Cloud Storage per `platform.md` §3, or Firebase Hosting) and its plan / billing needs are decided at **F07's release gate** by the Tech Lead with DevOps. *[Needs verification at that gate: whether the chosen host needs the Blaze plan.]*
   * Nothing is deployed during delivery.
6. **Authoring side (repo):**
   * the daily puzzle definitions and exports live under `content/daily/{lang}/pool/`;
   * the date assignments live in `content/daily/{lang}/daily_manifest_{lang}.json` — `numberingEpoch` plus `assignments: { "YYYY-MM-DD": "<puzzle id or file>" }`, the shape `check` already reads;
   * a new `looplet_authoring pack-daily` command builds the served pack from the manifest and the pool, into a build-output path that is not the source.
7. **Development / test source:** debug builds may override the pack URL with `--dart-define=LOOPLET_DAILY_PACK_URL=<url>`, for example a local static server over the `pack-daily` output. Tests use an injected fetcher. Remote Config is not emulated, so debug builds never need the real project for Daily content.

---

## D3. Fetch, cache and eviction [LOCKED — resolves F08 "[OPEN — F07]"]

* **Interface:** `DailyContentSource.fetchPack(lang) → DailyPack` (HTTPS GET of the pack URL; 10 s timeout; one attempt per trigger, no retry loop). The implementation is swappable (tests, debug override).
* **Triggers** (each only if today's `(lang, dailyDate)` is not cached; all non-blocking for Home and Journey):
  * app start, after bootstrap;
  * `resumed`;
  * opening the Daily screen;
  * Retry on the "needs connection" state;
  * connectivity regain while the Daily screen shows "needs connection".
* **Population:** on a valid pack, `DailyPuzzleCache.put` the entries for **today through today + 7**. This is the prefetch that makes the next week playable offline.
  * An entry already cached for a date is **not** overwritten. The day's puzzle never changes under a player, even if a later pack differs.
  * **Exception:** a date with no official result yet may be replaced by a newer `contentVersion`.
* **Eviction:** `evictOlderThan(today − 14 days)` at app start. A date with an in-progress session or an unsynced official result keeps its cache row until resolved.
* **Validation:** the client rejects a pack that fails D2 (2) — wrong `lang`, a date mismatch, an unparseable puzzle. A rejected pack caches nothing and is logged (`daily_pack_invalid`). The state becomes **unavailable**, not a crash.
* **States the Daily screen derives** (exhaustive):
  * `loading` — a fetch is in flight and nothing is cached;
  * `ready` — today is cached and there is no official result yet;
  * `doneToday` — an official result exists for today;
  * `needsConnection` — offline or the fetch failed, and today is not cached;
  * `unavailable` — `daily_enabled == false`, an empty `daily_manifest_url`, no pack entry for today, or an invalid pack.

---

## D4. Dates and rollover [LOCKED]

* `dailyDate` = the device-local calendar date (`YYYY-MM-DD`) **when the run starts**.
  * The run keeps it until it completes, including across midnight and across a kill / relaunch (**product PRD §11 proposal adopted**: the puzzle in play at start).
  * The completion is recorded for that date and counts for that date's streak.
* **Restore:** the active snapshot stores `puzzleSource = daily` and `puzzleId = daily-{lang}-{date}`. The date comes from the id, and the puzzle from `daily_puzzle_cache` (kept by D3 eviction).
  * If the cache row is gone (not expected), the snapshot is discarded as F08 does for a corrupt snapshot, and the player lands on Home.
* **Rollover re-evaluation:** on opening the Daily screen and on `resumed`, recompute today.
  * A Daily screen that is **not mid-run** and shows a past date switches to today's state (AC1).
  * A run in progress is never interrupted.
* **Date arithmetic** uses calendar dates (`DateTime(y, m, d)` in local time, then `+1 day` on the date parts), never 24-hour spans. This holds on DST days, leap days and year boundaries.

---

## D5. Official result and attempts [LOCKED]

* **On a daily completion, in one Drift transaction:**
  1. `DailyRepo.recordCompletion(...)` (F08 contract, unchanged). The first completion of `(guestId, lang, dailyDate)` → `firstRun`; a later one → `replay` (an attempt row).
  2. If `firstRun`: apply the streak rule (D6) through `DailyStreakRepo.write`.
  3. If `firstRun`: `DailyResultSyncService.enqueue(...)` with the F08 request fields:
     * `lang`, `dailyDate`, `dailyId`;
     * `moves`, `optimalMoves`, `durationMs` (the monotonic elapsed);
     * `stars`, `completedAtUtcMs`;
     * `clientAttemptNumber = 1`.
     * The enqueue participates in the same transaction. If F08's `enqueue` cannot join a caller's transaction, the Frontend/Mobile Developer reports it before changing anything (Dependency Edges).
* **A replay** writes only the attempt. The official result, the streak and the queue are unchanged (AC5).
* **Score** = move count, then duration as the tie-break (both stored; no leaderboard in the MVP).
* **Stars** = F04's rule. Daily completions never write `personal_best`.

---

## D6. Streak rule [LOCKED — F07 owns the rule; F08 stores it]

* **On a first run for date `D`,** with `L = lastCompletedDate`:
  * `L == null` → `current = 1`;
  * `D == L + 1 day` → `current = current + 1`;
  * `D > L + 1 day` → `current = 1` (a missed day; AC6);
  * `D ≤ L` (the clock moved back, travel westward, or an old in-progress run finished late) → `current` unchanged, no double count;
  * then `best = max(best, current)` and `lastCompletedDate = max(L, D)`.
* **Displayed current streak** (effective, derived — never a separate write):
  * `currentStreak` if `lastCompletedDate ∈ {today, yesterday}`, else **0**;
  * best is always the stored `bestStreak`.
  * This is the product's `DAILY_STREAK_RESET`: a missed day shows 0 at once, and the stored value resets on the next completion.
* **No server-side check** (F08 locked). A clock moved forward can inflate a streak — an accepted MVP limitation, like the reinstall case.

---

## D7. Remote Config and the kill-switch [LOCKED — closes F07-KILL-SWITCH]

* **Dependency:** add `firebase_remote_config` at a version compatible with the pinned `firebase_core` line; add `http` for the pack fetch.
  * No Flutter or Firebase upgrade (a separate decision); the lockfile changes only by these additions.
* **In-app defaults** (used offline and before the first fetch): `daily_enabled = true`, `daily_sync_enabled = true`, `share_enabled = true`, `daily_manifest_url = ""`.
* **Fetch:** `fetchAndActivate` at app start, non-blocking and best-effort (a failure is logged and the defaults / last activated values stay). Minimum fetch interval: 1 h in release, 0 in debug.
* **Effects:**
  * `daily_enabled == false` → the Home Daily entry is hidden, and a restored or deep-linked Daily shows `unavailable`. **An in-progress daily run is not killed:** it can finish, and its result is recorded.
  * `daily_sync_enabled` → `dailySyncEnabledProvider` reads the activated value in release builds. The debug override (`debugSyncDisabledProvider`) stays. `drain()` stays a no-op while it is false (F08).
  * `daily_manifest_url` → D2 (4).
  * `share_enabled` → read by F13; not used by F07.
* **Debug / emulator:** Remote Config is not emulated. Debug builds use the defaults plus the D2 (7) pack override. The kill-switch paths are proven with an injected Remote Config fake.

---

## D8. Surfaces, routes and navigation [LOCKED — contract; visual design by the UI Designer]

* **Routes:** `/daily` — the Daily screen. It hosts the D3 states and starts the play session through the existing `/play` with `PuzzleSource.daily`.
  * Back / system back from `/daily` → Home.
  * From the daily result → back to `/daily` (which then shows `doneToday`), or replay in place.
  * No Next Level on a daily result. No other route changes.
* **Home (cross-feature amendment of F05 §18):**
  * a **secondary** Daily entry — not a second lime CTA; F05's one-primary-CTA rule holds;
  * it shows the day's number (`#N`), the effective current streak, and its state (available / done today / needs connection);
  * it is hidden when `daily_enabled == false`.
  * F10 later owns the main-menu layout. The Home placement is interim, and F05 stays Done (its §18 notes this amendment).
* **Play header for a daily:**
  * the day's label (`GÜNLÜK · #N`, with the date);
  * moves unlimited, 3 undos, unlimited restart, as AC3 states.
* **Daily result** (the F03 §20 full-screen result, daily variant):
  * moves, duration, stars;
  * **official** vs **replay** labelling — a replay says the official result is unchanged and shows it for comparison;
  * **Current Streak + Best Streak**;
  * Retry (replay) and back.
  * **No Share control in F07.** The layout reserves its place for F13 (prd Open Questions (1)).
* **`needsConnection`** says Journey is still playable and offers Retry. **`unavailable`** is calm and not an error.
* **Copy:** Turkish, through a strings table (interim copy; PO / localization later — F10-UI-LOCALIZATION). No raw error text is ever shown to the player.
* **Visual Scope `new-surface`** on the Selected Foundation. It needs at least two rendered directions, a recorded selection, and a handoff with a Visual Evidence Manifest before implementation (`visual-quality-gate.md`). Accessibility: C-9 text scale up to AX5 (F03 / F05 rule); never colour-only.

---

## D9. Validation responsibility [LOCKED]

* **Authoring tooling:** the pack rules D2 (2) at build time (`check`, `pack-daily`), with named negative cases.
* **Client:**
  * the pack validation D2 (2) at fetch time;
  * D4 date attribution;
  * D5 transactional completion;
  * D6 streak;
  * D7 kill-switch effects.
* **F08 (unchanged):** exactly-once delivery, queue states, server create-only, callable validation.
* **Content Designer:** the pool's editorial quality and coverage. The human sign-off is a decision gate (F07.DAILY-POOL-SIGNOFF), opened when the pool is delivered.

---

## D10. Evidence plan [LOCKED — the QA plan is locked at QA activation]

* **Automated functional:**
  * the streak table — first day, consecutive, missed day, same day replay, clock back, DST day, leap day, year boundary;
  * the rollover and midnight-crossing attribution;
  * pack validation with a negative case for each D2 (2) rule;
  * the completion transaction — first run → entry + streak + one queue item; replay → attempt only; each with a named negative run;
  * the kill-switch effects through a Remote Config fake.
* **Repeatable integration:** against the Firebase emulator, a real daily first run → exactly one server doc; a replay → no new queue item, the doc unchanged.
* **Runtime (canonical simulator):**
  * Daily open → play → first-run result with the streak;
  * a replay shows the official result unchanged;
  * kill / relaunch mid-daily → exact restore with the start date;
  * offline with a cached day → playable (F07.OFFLINE-DAILY);
  * offline with no cache → `needsConnection`, and Journey plays.
* **Real no-network run:** as F08 A4 — the user switches the network off; Claude does not change system settings.
* **Visual:** Visual Parity Evidence by the Frontend/Mobile Developer; independent QA ≥ 93, every dimension ≥ 8.
* **Content:** `check` + `pack-daily` exit 0 over the real pool, and the sign-off gate.

---

## D11. Release impact [LOCKED — scope; OPEN — the DevOps runbook at F07's release]

* **Release Scope `production-readiness`:** a content pack served to clients plus a Remote Config value (project `release.md` §2).
* **F07-DEVOPS** (Blocked until F08-DEVOPS is done and F07's functional QA passes):
  * the pack hosting;
  * publishing `daily_manifest_url`;
  * the rollback by repointing;
  * the smoke — the release build fetches the pack; a first run syncs once.
* No deploy happens during delivery. The app-build distribution is still FIRST-APP-DISTRIBUTION.

---

## Non-goals [LOCKED]

* Share (F13); leaderboard; analytics events (F12); the main-menu layout and Settings (F10); server-side anti-cheat; an English pool; any change to F08's schema or client API; a Flutter or Firebase upgrade; any deploy.

---

## Open Items

* **[OPEN — F07 release gate, Tech Lead + DevOps]** the production pack host and its plan / billing needs.
* **[OPEN — Product Owner, optional]** AC7's Share wording (prd Open Questions (1)).
* **[OPEN — decision gate, later]**
  * F07.DIRECTION-SELECT — the user picks the rendered direction; opened when F07-UI delivers;
  * F07.DAILY-POOL-SIGNOFF — the user signs off the pool; opened when F07-CONTENT delivers.
