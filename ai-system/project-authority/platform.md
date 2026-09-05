# Project Platform Authority — LOOPLET

Last Updated: 2026-09-05
Owner: Tech Lead

---

# 1. Purpose

* Locks project-wide technical standards for LOOPLET (see `/ai-system/product/product-prd.md`).
* Provides cross-feature consistency for all delivery roles.
* Serves as runtime and contract authority. Release/deployment authority is separate: `/ai-system/project-authority/release.md`.

---

# 2. Global Rules

* These decisions apply to every feature F01–F13.
* Backend Developer, Frontend/Mobile Developer, DevOps/Release Engineer, Project Setup, and QA all follow this document.
* Any change here requires an active-feature impact analysis by the Tech Lead. Downstream roles must not silently re-platform.
* PRD Section 12 left most stack choices to the Tech Lead; the choices below are made here. Where PRD input was insufficient, the decision is marked **[Assumption]**.

---

# 3. Application Stack

## Backend / Services

* Language: TypeScript (Node.js 20) for Cloud Functions.
* Runtime: Firebase (managed BaaS) — **[Assumption]** single-vendor choice for lowest ops on an MVP validation build.
* Framework: Firebase Functions (2nd gen, HTTPS callable) + Firestore + Cloud Storage + Remote Config + Firebase Anonymous Auth + App Check + Crashlytics + Firebase Analytics (GA4).
* Architecture Style: serverless functions over a managed BaaS. No long-running services. The MVP backend surface is intentionally three things only:
  1. **Daily content distribution** — pre-generated static JSON in Cloud Storage, selected by a Remote Config manifest pointer. No compute.
  2. **Analytics ingestion** — Firebase Analytics SDK direct from client. No custom endpoint.
  3. **Offline daily-result sync** — one HTTPS callable function writing create-only docs to Firestore.
* Data Layer: Firestore (leaderboard-ready relational-style collections); Cloud Storage for content artifacts.

## Frontend / Clients

* Client Type: mobile (iOS + Android), portrait only, phone-first.
* Framework: Flutter (stable channel, Dart 3.x). **[Assumption]** chosen over native ×2 / React Native / Unity for: single codebase, custom-painted deterministic grid rendering, precise sub-250ms animation control, and a pure-Dart domain layer that is unit-testable headless (required by F02). Unity was considered and rejected as disproportionate for a 5×5 slide-grid with light animation and meta UI.
* Game engine: none. Plain Flutter (`CustomPainter` / `RenderObject` + `AnimationController`) for the grid. Flame considered and rejected (smaller footprint, better meta-UI ergonomics without it).
* State Management: Riverpod v2 (plain providers; code-gen optional, off for MVP). Domain state models are immutable.
* Navigation / Routing: `go_router` with typed routes. Route list, header visibility, and back affordance per feature are defined in that feature's `architecture.md`.

## Monorepo Layout

Melos-managed monorepo. Domain packages import **no** Flutter.

```
/app                        Flutter application (screens, gestures, rendering, persistence wiring)
/packages/looplet_core      pure Dart: shared value types, Turkish-locale case utility, Result types
/packages/looplet_dictionary  pure Dart: dictionary service + curated word-list assets      (F01)
/packages/looplet_engine    pure Dart: grid model, Move, circular shift, locked/frozen, win  (F02)
/packages/looplet_solver    pure Dart: minimum-move solver (depends on looplet_engine)       (F06 lib)
/packages/looplet_content   pure Dart: puzzle definition models + JSON (de)serialization, schema/version enums
/tools/looplet_authoring    Dart CLI (+ optional Flutter desktop editor) for level authoring (F06 tooling)
/content                    versioned puzzle JSON artifacts (journey + daily), checked in
/infra                      Firebase project config, Cloud Functions (TS), Firestore rules, Remote Config templates
```

* Shared enums (`tileStatus`, `direction`, `difficultyLabel`, `puzzleType`) are defined once in `looplet_content` and reused by app, tooling, and (mirrored) Firestore docs.
* The solver and the game share `looplet_engine` so shift/win/locked/frozen semantics have a single source of truth.

---

# 4. API & Contract

## API Style

* Predominantly static content: versioned JSON over HTTPS/CDN (Cloud Storage).
* One RPC-style HTTPS callable: `submitDailyResult`.
* No REST resource API in the MVP.

## Versioning Strategy

* Content artifacts carry `schemaVersion` (breaking shape) and `contentVersion` (pack revision).
* A Remote Config key `daily_manifest_url` points at the current daily pack; rollback = repoint to the previous pack.
* The callable function is versioned by name suffix (`submitDailyResultV1`) if a breaking change is ever needed.
* App version: semantic `x.y.z+build`. Content packs version independently of the app.

## Contract Rules

* JSON field naming: `lowerCamelCase`.
* Timestamps: ISO-8601 UTC (`...Z`). Durations: integer milliseconds.
* `dailyDate`: local-date string `YYYY-MM-DD`, derived from device local time.
* Null semantics: optional fields are **omitted** when absent, never sent as `null`.
* Change policy: content schema changes are additive without a `schemaVersion` bump; any field removal/retype bumps `schemaVersion`.

## Error Format (callable function)

```json
{
  "code": "ERROR_CODE",
  "message": "Human readable description",
  "details": []
}
```

* `code` values: `INVALID_PAYLOAD`, `ALREADY_SUBMITTED`, `UNSUPPORTED_LANGUAGE`, `APP_CHECK_FAILED`, `INTERNAL`.

---

# 5. Data & Persistence

## On-Device (authoritative for single-player)

* Store: Drift (SQLite). **[Assumption]** chosen for durable, queryable, migratable structured storage.
* Tables (indicative): `journey_progress`, `personal_best`, `daily_entry`, `daily_attempt`, `daily_streak`, `settings`, `analytics_event_buffer`, `sync_queue`, `kv` (active-session JSON snapshot + `schemaVersion`).
* Write strategy: write-through on every domain state change. The active puzzle session is persisted as a single `kv` row updated inside a transaction, so relaunch restores grid, move count, undo history, thawed frozen tiles, elapsed time, and puzzle ID exactly.
* Time: store UTC epoch millis; measure elapsed/session durations with a monotonic `Stopwatch`, never wall clock.
* Migration: Drift schema migrations, **forward-only**. `personal_best`, `daily_streak`, and `daily_entry` first-run rows are never dropped or reset by a migration.
* Future account adoption: every player-owned row carries a `guestId` column so a future account can claim local data without a destructive migration. No account feature is built in the MVP.

## Server (sync + leaderboard-ready, not authoritative for gameplay)

* Firestore collections:
  * `dailyResults/{lang}_{date}/entries/{guestId}` — the player's **first completed run** for that daily. Create-only.
  * Structured so a future leaderboard can query by `{lang, date}` ordered by `moves` then `durationMs`.
* Idempotency: keyed by `(guestId, lang, date)`. Repeated submissions are a no-op after the first accepted write (`ALREADY_SUBMITTED`). The client `sync_queue` marks an item synced only on ack.

---

# 6. Auth / Session / Permissions

* **No user-facing login in the MVP.** The player is always a guest (PRD §39).
* Firebase Anonymous Auth provides an invisible, stable device identity (`guestId` = anonymous UID). **[Assumption]** this is not "login" in the PRD §39 sense — no credentials, no UI, no user action — and is used only for Firestore write-scoping and the analytics user id.
* Authorization (Firestore rules):
  * Content in Cloud Storage: public read.
  * `dailyResults/**`: a client may **create** only `entries/{its own uid}` and only if that document does not already exist (server-enforced first-run authority). No update, no delete, no cross-user read in the MVP.
* App Check (Play Integrity / DeviceCheck) guards the callable function and Firestore writes. Soft-enforce for the MVP; hard-enforce decision deferred to F07/F08.

---

# 7. Runtime / Realtime / Background Processing

* No realtime, no websockets, no polling loops.
* Lifecycle:
  * `AppLifecycleState.paused` → flush pending Drift writes + analytics buffer; emit `app_backgrounded`.
  * `resumed` → restore active session; re-evaluate daily rollover against current local date; attempt `sync_queue` flush if connectivity is available.
* Sync retry: `sync_queue` items retried with exponential backoff on connectivity regain; capped attempts, then parked. Local result stays authoritative regardless.
* Timeout: callable client timeout 10s; failure leaves the item queued.
* Ownership: `sync_queue` and analytics flushing are **session-level** concerns owned by an app-level service, not by any screen. Screen disposal never cancels a sync or analytics flush.

---

# 8. Observability & Security

* Crashes/ANRs: Crashlytics. Product events: Firebase Analytics (GA4), see F12. Function logs: Cloud Logging.
* Input validation (callable): payload shape + ranges — `1 ≤ optimalMoves ≤ moves`, `durationMs ≥ 0`, `dailyDate` matches `YYYY-MM-DD`, `lang` in the supported set. Reject with `INVALID_PAYLOAD` otherwise.
* Secrets: Firebase client config (`firebase_options.dart`) is not secret. Function secrets (if any) via Secret Manager; none required for the MVP beyond project defaults. No secret values in the repo — names only (see `release.md`).
* Abuse controls: Firestore create-only rule + App Check on writes and the callable. No custom rate limiter in the MVP.
* Privacy: no PII collected. **[Assumption]** iOS Firebase Analytics is configured **without** IDFA / ad-identifier collection, so no ATT prompt is required for the MVP. A `PrivacyInfo.xcprivacy` declaring **no tracking** (with required API reason codes) is shipped. Android: no ad ID permission.

---

# 9. Release / Deployment Boundary

* Release, deployment, rollback, CI/CD gate, environment promotion, store distribution, signing, and privacy-manifest authority live in `/ai-system/project-authority/release.md`.
* This document does not duplicate provider release policy.
* Containerization is not applicable (mobile app + Firebase CLI function deploys).

---

# 10. Testing Strategy

* **Pure Dart packages** (`looplet_core`, `looplet_dictionary`, `looplet_engine`, `looplet_solver`, `looplet_content`): `package:test`, high coverage.
  * `looplet_engine`: exhaustive determinism matrix + win / locked / frozen behavior tables.
  * `looplet_solver`: asserts returned move count equals a brute-force BFS minimum on a generated test set.
  * `looplet_dictionary`: golden "must-accept / must-reject" QA word set + Turkish-locale normalization tables.
* **App** (`flutter_test`): widget + golden tests for key screens and their loading/empty/error/success/disabled/selected states; `integration_test` for critical journeys — tutorial gating, swipe→move, kill/relaunch resume, daily rollover, offline daily + deferred sync.
* **Cloud Functions**: unit tests against the Firebase emulator; Firestore rules tests via `@firebase/rules-unit-testing`.
* QA runtime expectation: device/emulator runtime proof is required for gesture, animation, resume, and daily behavior. Source-only evidence is acceptable only for pure-logic packages that already carry deterministic unit suites.

---

# 11. Cross-Cutting Rules

* **Naming:** Dart types `UpperCamelCase`, members `lowerCamelCase`, files `snake_case.dart`. JSON `lowerCamelCase`. Analytics event names and property names are written **exactly** as PRD §40 specifies (snake_case).
* **Date/time:** UTC epoch millis internally; monotonic `Stopwatch` for durations; `dailyDate` is a device-local `YYYY-MM-DD`.
* **Turkish locale (HARD RULE):** game and dictionary logic must never call Dart's default `String.toUpperCase()` / `toLowerCase()` on letters. Use the explicit Turkish case map in `looplet_core` (`İ↔i`, `I↔ı`, and `ç ğ ö ş ü` preserved). `İ` and `I` are distinct letters everywhere.
* **Localization:** Flutter `gen-l10n` with ARB files; `tr` is the default locale, `en` is scaffolded; no hardcoded user-facing strings; the dictionary is keyed by language; RTL is out of scope for the MVP.
* **Shared identifiers / enums:** *serialized* puzzle-schema enums (`difficultyLabel`, `puzzleType`) are defined once in `looplet_content`; Firestore docs mirror the same string values. *Engine primitive* value types (`MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord`) are defined in `looplet_core` — so `looplet_engine` (which must not depend on `looplet_content`, per §3) can use them — and `looplet_content` re-exports them so downstream code has one import site. (Carve-out added 2026-09-05 with F02 activation.)
* **Determinism:** no runtime RNG anywhere in gameplay or content selection on device. Any shuffling/generation happens only in `tools/looplet_authoring` at authoring time.

---

# 12. Change Management

* Owner: Tech Lead.
* Impact analysis rule: any edit to this file triggers a review of the active feature and all `Not Started` features whose assumptions it touches.
* Active feature reassessment rule: if a platform decision changes while a feature is `In Progress`, the Tech Lead pauses that feature, reconciles its `architecture.md`, then resumes.

---

# 13. Open Technical Decisions (tracked)

* **Solver algorithm (F06):** approach is set here — provable minimum via complete search of the 5×5 state space, build-time only, sharing `looplet_engine`. Default implementation: bidirectional BFS over a packed canonical grid-state hash; fall back to IDA* only if memory-bound on worst-case locked+frozen levels. Final form is locked in F06's `architecture.md`.
* **App Check enforcement level (F07/F08):** soft-enforce for the MVP; hard-enforce decision deferred.
* **Level editor surface (F06):** CLI is the MVP-critical path; a Flutter desktop editor is optional and decided in F06.
* **Product-analytics depth (F12):** GA4 built-in funnels/retention are assumed sufficient for the §52 gate; a dedicated tool (PostHog/Amplitude) is a Future Consideration only if GA4 proves insufficient.
