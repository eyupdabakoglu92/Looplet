# System State — LOOPLET

Last Updated: 2026-09-05 (F02 closed; F06 activated + contract finalized)

> Global workflow snapshot. Stack/runtime authority lives in `project-authority/platform.md`; release authority in `project-authority/release.md`. This file carries the current snapshot only.

---

# 1. SYSTEM INITIALIZATION

## Platform Initialized

* Yes — `project-authority/platform.md` produced by Tech Lead (2026-09-03). Stack: Flutter (Dart) client, pure-Dart domain packages, Firebase BaaS backend, Drift (SQLite) persistence.

## Environment Status

* Initialized — melos monorepo (`app` + 6 pure-Dart packages + CI). `melos run format:check` / `analyze` / `test` green (**145 workspace tests**: core 22, dictionary 32, engine 83, scaffold 3, app 4+1). `flutter build ios --release --no-codesign` green. Android `build:app` = CI-only locally (no Android SDK on the dev machine). Firebase `infra/` not yet provisioned (separate DURUM 0 before F07/F08/F12).

---

# 2. AUTHORITY REFERENCES

## Technical Authority

* `/ai-system/project-authority/platform.md` — Exists (Tech Lead, 2026-09-03)

## Setup Authority

* `/ai-system/project-authority/setup-manifest.md` — Exists (Tech Lead, 2026-09-03). Melos monorepo scaffold recipe (Steps 1–7, executed) + canonical Build/Test/Boot commands; containerization N/A.
* Technical Authority updated 2026-09-05: `platform.md` §11 carve-out — engine primitive enums (`MoveAxis`/`MoveDirection`/`TileStatus`/`GridCoord`) live in `looplet_core`, re-exported by `looplet_content`.

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

* F06 — puzzle-content-and-solver-tooling

## Active Orchestration Path

* `/ai-system/features/f06-puzzle-content-and-solver-tooling/orchestration.md`

---

# 5. WORKFLOW STATE

## Current Phase

* Frontend Development — F06 puzzle-content-and-solver-tooling (toolchain + smoke set)

## Current Role

* Frontend/Mobile Developer

## Current Reason

* F01 + F02 Done. F06 activated (last P0): Technical Analyst pass (`analysis.md`) → Tech Lead contract finalized (`architecture.md`). Solver = **forward BFS** over F02's `canonicalKey` + `SearchBudget` (bidirectional BFS from `platform.md` §13 dropped — amended). Scope split: F06 = `looplet_solver` + `looplet_content` `Puzzle` + `tools/looplet_authoring` CLI + a ~5-puzzle smoke set; `F06-CONTENT` (full 30 Journey + ~60 Daily authoring) = Level-Designer follow-on, still MVP, prerequisite for F05/F07 `Done`. Frontend/Mobile Developer implements F06.1-FE … F06.SMOKE-FE next.

## Last Completed Action

* Tech Lead — 2026-09-05 — Finalized the F06 contract: consumed `analysis.md` into `architecture.md` (all [PENDING ANALYSIS] → [LOCKED]); amended `platform.md` §13 (forward BFS + `SearchBudget`) + §3/§13 CLI-only notes; accepted the toolchain-vs-content scope split; opened F06.1-FE … F06.SMOKE-FE + F06.1-QA … F06.5-QA. Synced `feature-board.md` + `system-state.md`.

## Next Expected Action

* `Run Frontend/Mobile Developer` — implement F06 per `features/f06-puzzle-content-and-solver-tooling/orchestration.md → Next Action` (F06.1-FE `Puzzle` model → F06.2-FE forward-BFS solver → … → F06.SMOKE-FE ~5-puzzle smoke set).

---

# 6. CROSS-FEATURE STATUS

## Portfolio Summary

* 13 features. F01 `Done`, F02 `Done`. F06 `In Progress` (Frontend Development — toolchain + smoke set). F03, F04, F05, F07–F13 `Not Started`.
* Priority: P0 = F01✓, F02✓, F06, F08, F03, F05 · P1 = F04, F09, F10, F07, F12 · P2 = F11, F13.
* Critical path: F01✓ → F02✓ → **F06** → (F03, F08) → F04 → F05 → F09 → F10 → F07 → F13; F12 cross-cutting and release-blocking.
* **`F06-CONTENT`** (full 30 Journey + ~60 Daily authoring) — a Level-Designer follow-on split off from F06; still MVP scope; blocks F05 and F07 from reaching `Done` but not F06.

## Active Rework

* None

## Paused Features

* None

## Blocked Features

* None. Non-blocking note: production-quality curated Turkish corpus + target-word review is a Product Owner / content deliverable (F01 PRD Open Questions); F01 code proceeds on a provisional reviewed list.

---

# 7. GLOBAL CONTRACT SNAPSHOT

## Contract Version

* v1 — established 2026-09-03. Project contract rules in `platform.md` §4. F01 + F02 contracts locked and closed. **F06 contract finalized 2026-09-05** (`features/f06-.../architecture.md`): forward-BFS solver over F02's `canonicalKey` + `SearchBudget`; `SolveResult` = `Optimal` | `Unsolvable` | `BudgetExceeded`; `looplet_content` engine-free `Puzzle` model + JSON; CLI-only `tools/looplet_authoring`; `export` gate; `check` CI content gate; difficulty metric definitions locked (weights/thresholds configurable). `platform.md` §11 carries the engine-primitive-enum carve-out; **§13 amended 2026-09-05** (bidirectional BFS → forward BFS + bound).

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

* Solver optimality & performance (F06): the star rating is only fair if the stored optimal is a proven minimum. Approach **finalized** — forward BFS over F02's `canonicalKey` + a `SearchBudget` (maxDepth 16 / maxNodes 5M / 30s); minimality is BFS-by-construction; `budgetExceeded` ⇒ not shippable. Residual risk: worst-case node/time on levels 26–30 (locked+frozen) — bounded by the budget; QA validates minimality against an independent exhaustive reference; `check` re-solves every artifact in CI. A dictionary corpus change invalidates all frozen-tile `optimalMoves` (must re-`export`).
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
