# Feature Board — LOOPLET

Last Updated: 2026-09-03
Active Phase: Planning — F01 repo scaffold (DURUM 0), unblocked
Active Owner: Project Setup

> Bootstrap snapshot produced by Product Owner (2026-09-03), then activated by Tech Lead greenfield bootstrap (2026-09-03): `platform.md` + `release.md` produced, F01 activated. Project Setup blocked on a missing `setup-manifest.md`; Tech Lead authored it (2026-09-03) and F01 is unblocked. Feature IDs and names match `product-prd.md` Section 6 exactly. Global owner / active phase sync is Tech Lead's responsibility.

---

## Status Table

| ID | Feature | Status | Owner | QA | Priority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | dictionary-service | In Progress | Project Setup | — | P0 | Curated Turkish dictionary + Turkish-locale case (İ/I distinct) + validation behind a language key. Foundation for F02 (frozen break) and F06 (solver/content). ACTIVE — DURUM 0 repo scaffold per `setup-manifest.md` (F01.0-PS), then Frontend/Mobile Developer (F01.1–F01.7-FE) → QA (client-only). Release Scope: none. No Analyst, no UI Designer. |
| F02 | grid-engine | Not Started | — | — | P0 | Deterministic 5×5 shift engine: circular row/col shift, move count, L→R win detection, locked tile, frozen tile, undo/restart primitives. Depends on F01. Headless/testable. |
| F03 | puzzle-play-session | Not Started | — | — | P0 | In-game screen: swipe→move (dominant axis, threshold, accidental-touch reject), 150–250ms anim + input lock (no queue), MOVES HUD, 3 Undo, separated Restart, completion sequence. Depends on F02. |
| F04 | star-rating-and-personal-best | Not Started | — | — | P1 | 1–3 star rating (never 0), completion panel, per-level best (improves only), "Perfect" flag. Depends on F03, F06. |
| F05 | journey-progression | Not Started | — | — | P0 | 30 handcrafted sequential levels, linear unlock by completion, source §20 difficulty curve, per-level micro-tutorials (columns at L4–6), CONTINUE resume. Depends on F03, F06. |
| F06 | puzzle-content-and-solver-tooling | Not Started | — | — | P0 | Internal level editor + build-time solver (provable minimum moves, honors locked/frozen), solvability + difficulty scoring, playtest, export with required metadata. Produces Journey levels + Daily pool. Depends on F01, F02. Not player-visible but P0. |
| F07 | daily-challenge | Not Started | — | — | P1 | One shared puzzle/day/language, local-midnight reset, move-count score (time tie-break), first run official, streak (current + best). Leaderboard-ready data model, no leaderboard. Depends on F03, F04, F06, F08. |
| F08 | offline-persistence-and-sync | Not Started | — | — | P0 | Persist active puzzle + progress + bests + streak + settings; full offline Journey; offline Daily if pre-fetched; deferred exactly-once sync with first-run-authoritative reconciliation; guest-only, account-adoptable schema. |
| F09 | onboarding-tutorial | Not Started | — | — | P1 | Interactive 3-step tutorial (row / column / form target), action-gated, < 60s, flows into Level 1, shown once. Depends on F03. KPI gate: > 85% completion. |
| F10 | main-menu-and-settings | Not Started | — | — | P1 | LOOPLET logo, CONTINUE (primary), DAILY (secondary), Journey Progress, Daily Streak, Settings (Sound / Haptics toggles). No Shop/Battle Pass/Clan/Events. Accessibility baseline. Depends on F05, F07. |
| F11 | audio-and-haptics | Not Started | — | — | P2 | Fixed SFX set + light/medium/success haptics, independent on/off toggles, no BGM, game completable with both off. Depends on F03, F10. |
| F12 | analytics-instrumentation | Not Started | — | — | P1 | All source §40 events with exact properties, offline buffering + exactly-once flush, anonymous guest id, KPI set computable. Cross-cutting; release-blocking for the §52 validation gate. Depends on F03, F05, F07, F09, F13. |
| F13 | daily-share | Not Started | — | — | P2 | Spoiler-free share card (LOOPLET #N, stars, moves, streak, optional arrow sequence), no grid/no target word, OS share sheet, reflects official first run. Depends on F07. |

Status set: Not Started · In Progress · In QA · In Release · Rework · Done · Blocked

---

## Priority Ordering & Rationale

1. `F01` — dictionary-service — no dependencies; required by both F02 (frozen-tile thaw) and F06 (solver/content validation). Nothing that touches words can be verified without it.
2. `F02` — grid-engine — depends only on F01; it is the deterministic core every playable feature and the solver build on. Ship headless and fully tested first.
3. `F06` — puzzle-content-and-solver-tooling — depends on F01 + F02; produces the optimal-move values and the actual puzzle content. F05 and F07 cannot exist without its output, so it must be usable early even though it is Infrastructure and not player-visible.
4. `F08` — offline-persistence-and-sync — depends only on the F02 state shape; foundational for any real retention testing (resume, offline Journey). Best landed before the play screen so persistence is designed in, not bolted on.
5. `F03` — puzzle-play-session — depends on F02; the first player-visible loop. Gesture handling, animation/input-lock, MOVES, Undo, Restart.
6. `F04` — star-rating-and-personal-best — depends on F03 + F06; turns "completed" into "rated vs optimal", which is the replay hook and the North Star trigger.
7. `F05` — journey-progression — depends on F03 + F06 + F04; the main progression and the home of the Level 5 Reach / D1 / D7 KPIs. Needs the 30 authored levels from F06.
8. `F09` — onboarding-tutorial — depends on F03; gates the Tutorial Completion KPI. Sequenced after the play screen exists so the tutorial teaches the real mechanic.
9. `F10` — main-menu-and-settings — depends on F05 + F07; the navigation hub and the accessibility/settings baseline. Surfaces state the earlier features own.
10. `F07` — daily-challenge — depends on F03 + F04 + F06 + F08; the day-2 return driver. Needs play, rating, content, and persistence/sync all in place.
11. `F13` — daily-share — depends on F07; the virality loop. Small, independently shippable, sequenced right after Daily.
12. `F11` — audio-and-haptics — depends on F03 + F10; feedback polish that ships with the MVP but is not on the critical path.
13. `F12` — analytics-instrumentation — depends on F03/F05/F07/F09/F13; cross-cutting. Instrumented incrementally as each feature lands, with a final schema-conformance pass. Listed last because it closes over the others, but it is release-blocking: the §52 validation gate cannot be evaluated without it.

Dependency chain (must-precede):

* F01 → F02 → {F03, F06}
* F02 → F06 ; F01 → F06
* F02 → F08
* F03 → {F04, F05, F09, F11}
* F06 → {F04, F05, F07}
* F03 + F04 + F06 + F08 → F07
* F07 → F13
* F05 + F07 → F10 ; F03 + F10 → F11
* {F03, F05, F07, F09, F13} → F12

---

## Rules

* `feature-board.md` is the portfolio / state / priority view; detailed task breakdown lives in each `features/{feature-name}/orchestration.md`.
* Feature IDs and names are 1:1 with `product-prd.md` Section 6.
* Global owner and active phase are synced by the Tech Lead on state transitions.
