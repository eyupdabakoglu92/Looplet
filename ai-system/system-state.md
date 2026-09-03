# System State — LOOPLET

Last Updated: 2026-09-03

> Global workflow snapshot. Stack/runtime authority lives in `project-authority/platform.md`; release authority in `project-authority/release.md`. This file carries the current snapshot only.

---

# 1. SYSTEM INITIALIZATION

## Platform Initialized

* Yes — `project-authority/platform.md` produced by Tech Lead (2026-09-03). Stack: Flutter (Dart) client, pure-Dart domain packages, Firebase BaaS backend, Drift (SQLite) persistence.

## Environment Status

* Partial — platform + release authority defined; repo not yet scaffolded. Project Setup owns the F01 scaffold task (DURUM 0).

---

# 2. AUTHORITY REFERENCES

## Technical Authority

* `/ai-system/project-authority/platform.md` — Exists (Tech Lead, 2026-09-03)

## Setup Authority

* `/ai-system/project-authority/setup-manifest.md` — not yet created (Project Setup output)

## Release Authority

* `/ai-system/project-authority/release.md` — Exists (Tech Lead, 2026-09-03). Release gate: Conditional. F01 Release Scope: none.

## Product Authority

* `/ai-system/product/product-prd.md` — Exists (Product Owner bootstrap, 2026-09-03)

---

# 3. PRODUCT STATE

## PRD

* Exists: Yes
* Path: `/ai-system/product/product-prd.md`

---

# 4. FEATURE SYSTEM STATE

## Source of Truth

* Feature Board = PRIMARY
* Orchestration = EXECUTION
* System State = GLOBAL SNAPSHOT
* Tech Lead syncs the three surfaces together on state transitions.

## Active Feature

* F01 — dictionary-service

## Active Orchestration Path

* `/ai-system/features/f01-dictionary-service/orchestration.md`

---

# 5. WORKFLOW STATE

## Current Phase

* Planning — F01 repo scaffold (DURUM 0; no dedicated "Scaffold" phase in the enum)

## Current Role

* Project Setup

## Current Reason

* Greenfield bootstrap complete. `platform.md` and `release.md` produced; F01 (dictionary-service) selected as the first feature (P0, no dependencies, blocks F02 + F06). Repo is unscaffolded, so Project Setup runs first (task F01.0-PS) before Frontend/Mobile Developer implements the package.

## Last Completed Action

* Tech Lead — 2026-09-03 — Greenfield bootstrap: produced `project-authority/platform.md`, `project-authority/release.md`, and F01 feature files (`prd.md`, `architecture.md`, `orchestration.md`). Activated F01. Complexity decision: no Technical Analyst, no UI Designer.

## Next Expected Action

* `Run Project Setup` — scaffold the melos monorepo + Flutter app skeleton + `looplet_core` / `looplet_dictionary` packages + CI gates, per `features/f01-dictionary-service/orchestration.md → Next Action`.

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* 13 features. F01 `In Progress` (scaffold). F02–F13 `Not Started`.
* Priority: P0 = F01, F02, F06, F08, F03, F05 · P1 = F04, F09, F10, F07, F12 · P2 = F11, F13.
* Critical path: F01 → F02 → F06 → (F03, F08) → F04 → F05 → F09 → F10 → F07 → F13; F12 cross-cutting and release-blocking.

## Active Rework

* None

## Paused Features

* None

## Blocked Features

* None. Non-blocking note: production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions); F01 code proceeds on a provisional reviewed list.

---

# 7. GLOBAL CONTRACT SNAPSHOT

## Contract Version

* v1 — established 2026-09-03. Project contract rules in `platform.md` §4 (JSON camelCase, ISO-8601 UTC timestamps, `YYYY-MM-DD` local dailyDate, omit-not-null, additive content schema). F01 contract locked in `features/f01-dictionary-service/architecture.md`.

## Pending Breaking Change

* None

## Active Cross-Feature Contract Migration

* None

---

# 8. SYSTEM HISTORY REFERENCE

* `/ai-system/system-history.md` — not yet created

Kural:

* `system-state.md` carries only the current snapshot.
* Append-only history is maintained in `system-history.md`.

---

# 9. GLOBAL RISKS

* Solver optimality & performance (F06): the star rating is only fair if the stored optimal is a proven minimum; locked + multiple frozen tiles blow up the state space. Approach set in `platform.md` §13 (bidirectional BFS, build-time only); final form locked in F06 `architecture.md`.
* Difficulty-curve tuning of 30 handcrafted levels (F05/F06) is manual and playtest-heavy and directly drives the Level 5 Reach and retention KPIs.
* Turkish dictionary curation quality (F01) — proper nouns / profanity / abbreviations / archaic exclusion is manual review; frozen-tile UX depends on it. Corpus sourcing is an open Product Owner item.
* Local-timezone daily reset (F07) — clock manipulation, DST, and travel across midnight create streak-integrity edge cases.
* Gesture recognition consistency across devices (F03) — one accidental counted move breaks the "every move matters" promise.
* Analytics completeness (F12) is the §52 validation gate; incomplete or inaccurate instrumentation compromises the expand/iterate decision. Release-blocking. GA4 funnel/retention sufficiency is an assumption in `platform.md` §13.
* No monetization in the MVP — no revenue signal; validation is retention-only (accepted, source §51).
* Persistence schema (F08) must be forward-compatible with future account sync — `platform.md` §5 mandates a `guestId` column on player-owned rows and forward-only migrations.
* Firebase Anonymous Auth used as invisible device identity — assumption that this does not count as "login" per PRD §39 (`platform.md` §6).
* Content pipeline (F06) is a hard dependency for F05 and F07 and must be usable early despite being Infrastructure.

---

# 10. SYSTEM NOTES

* Stack/runtime authority is not duplicated here; see `project-authority/platform.md`. Release authority: `project-authority/release.md`.
* Client stack is Flutter (not Unity) — `Frontend/Mobile Developer` is the client implementation role; `Game Developer (Unity)` is not used. Backend Developer owns the Firebase Cloud Functions / Firestore rules surface (from F07/F08/F12 onward).
* When the workflow changes, `feature-board.md`, the relevant `orchestration.md`, and this file are updated in the same pass by the Tech Lead.
