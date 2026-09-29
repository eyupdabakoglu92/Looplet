# F07 — daily-challenge: PRD

> Status: FEATURE PRODUCT AUTHORITY — derived by the Tech Lead from `product/product-prd.md` → "daily-challenge (F07)", §5.3, §11, §15 and §16 on 2026-09-29 (activation, F08 `architecture.md` A21). The product PRD wins on any conflict; the Tech Lead does not change product criteria here.

---

## Summary

* **Problem:** the Journey is finite (30 levels); nothing brings a player back each day.
* **Goal:** one shared puzzle per calendar day per language, with an official first-run result and a streak worth protecting.
* **User value:** a daily reason to return; a habit loop (streak) and an efficiency score (moves, then time).

---

## Dependencies

* **Upstream features:**
  * F03 — the play session;
  * F04 — the star rating;
  * F06 — the content toolchain;
  * F08 — storage, the daily cache, the sync queue and the callable.
* **Dependency ruling (F08 A21):** delivery builds on F08's Functional Approved client surface. **F07's release waits on the deployed callable** (F08.DEPLOY-RESUME).
* **Content dependency:** the Daily pool (workflow-follow-ups F06-CONTENT-DAILY — about 60 puzzles plus a human sign-off).
* **Platform:**
  * daily content is static JSON over HTTPS, pointed to by the Remote Config key `daily_manifest_url` (`platform.md` §3 / §4);
  * `dailyDate` is the device-local `YYYY-MM-DD`;
  * no server-side clock trust (F08 Streak-Integrity / Clock).

---

## In Scope

* The Daily puzzle: fetch, cache, offline play from cache, local-midnight rollover.
* The official first-run result, replays stored for comparison only, and the streak rule (current + best).
* Enqueueing the official result into F08's sync queue (exactly-once is F08's).
* The Remote Config reads: `daily_enabled`, `daily_manifest_url`, `daily_sync_enabled` (the kill-switch, F07-KILL-SWITCH).
* The Daily surfaces on the selected Foundation:
  * a Daily entry on Home;
  * the Daily screen and its states — loading, needs connection, unavailable, done today;
  * the Daily variant of the result: official vs replay, current + best streak.
* The Daily pack format and its authoring / validation tooling. The Turkish Daily pool is authored and signed off.
* The Daily release gate: content hosting + the Remote Config value (release-blocked until F08's deploy).

## Out of Scope

* **The Share Result action and card — F13.** F13 AC1 is the same criterion. See Open Questions (1).
* Leaderboard (the data model stays leaderboard-ready; none ships).
* Analytics events `daily_started` / `daily_completed` — F12.
* Main-menu layout and Settings — F10. The Home Daily entry is an interim placement until F10.
* Server-side clock / timezone anti-cheat (F08 locked: none in the MVP).
* An English Daily pool — the MVP content language is Turkish; `lang` stays in the model.

---

## User Stories

* As a player, I want one shared daily puzzle that resets at my local midnight, so that I have a fresh reason to return each day.
* As a player, I want the daily scored by move count with time as the tie-break, so that efficiency is what matters.
* As a player, I want a streak that grows each day I complete and resets if I miss one, so that I'm motivated to keep the habit.
* As a player, I want to replay the daily to improve, without it changing my official result.

---

## Acceptance Criteria

Numbered for traceability. The wording is the product PRD's.

* **AC1** — Given the local date rolls to a new calendar day at 00:00, When the player opens DAILY, Then the new day's puzzle for the active language is shown.
* **AC2** — Given two players on the same language and date, When each opens DAILY, Then they receive the identical puzzle.
* **AC3** — Given the daily rules, When playing, Then the grid is 5×5, the target is 5 letters, moves are unlimited, undos are 3, and restart is unlimited.
* **AC4** — Given the player completes the daily for the first time today, When it finishes, Then move count, duration, and completion timestamp are recorded as the official result and the streak increments by 1.
* **AC5** — Given the player replays the same daily, When they finish again, Then the official result and streak are unchanged and the new attempt is stored only for personal comparison.
* **AC6** — Given the player missed the previous day's daily, When they complete today's, Then the current streak becomes 1 and the best streak is preserved.
* **AC7** — Given completion, When the panel shows, Then Current Streak and Best Streak are visible, along with Share Result. *(Share Result → F13 AC1; see Open Questions (1).)*

---

## Edge Cases

* A run started before local midnight and finished after → attributed to the puzzle in play at start (Tech Lead decision, architecture D4; proposed in product PRD §11).
* Device clock or timezone change while travelling → streak integrity per architecture D6. There is no server check.
* First launch of the day, offline, with no cached daily → a "needs connection" state; Journey remains playable.
* Daily completed offline → the result is queued, the streak updated locally, and synced later; the server keeps the first completed run (F08).
* DST transition day (23- or 25-hour day).
* The player completes the daily, then reinstalls the same day (guest, local storage cleared) → treated as a new guest; an accepted MVP limitation.
* Leap day and year boundary.

---

## Success Metrics

* Daily Completion Rate > 65% (product PRD §6).
* Measurement needs F12. F07 records the data (first run, attempts, streak) so the KPI is computable once F12 lands.

---

## Open Questions

1. **Share Result on the completion panel (AC7) — Hybrid, decided as an Assumption.** The action and its card are F13's scope, and F13 AC1 states the same criterion.
   * F07 does not render a non-functional Share control. The layout reserves its place (architecture D8), and F13 adds it.
   * F07's closure records AC7's Share part as **carried by F13 AC1**.
   * The Product Owner may revise this (`Run Product Owner. Revise: ...`); nothing else in F07 depends on it.
2. **The date of a run that crosses midnight** — decided (architecture D4): the date at start. The product PRD proposal is adopted.
3. **Streak integrity under clock / timezone changes** — decided (architecture D6): calendar-date arithmetic on device-local dates; a date not after the last completed date never changes the streak; no server check.
