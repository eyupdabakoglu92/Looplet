# Project Platform Authority — LOOPLET

Last Updated: 2026-09-29 (§3: Cloud Functions runtime Node.js 20 → **22** — Node 20 is decommissioned on Cloud Functions 2026-10-30, F08 A17 TD-FUNCTIONS-RUNTIME; §6 + §8: no client access to `dailyResults/**` — the callable is the only write path, F08 A9; §14 visual capture / asset / motion baseline added for the Visual Quality Gate; §3 + §11 shared-enum carve-out extended at F06 close-out; §6 guest-identity decouple + §13 Drift-schema/App-Check notes at F08 contract finalization; §13 App Check provider selection + iOS-App-Attest-deferred at F08 Firebase-project incident)
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

* Language: TypeScript (**Node.js 22**) for Cloud Functions. Changed from Node.js 20 on 2026-09-29 (F08 `architecture.md` A17, TD-FUNCTIONS-RUNTIME): Google decommissions the Node.js 20 runtime on 2026-10-30, after which no function can be created or updated on it; Node.js 22 is supported until its decommission on 2027-10-31. A later runtime bump is a platform change with an emulator-suite regression run.
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
/tools/looplet_authoring    Dart CLI for level authoring — solve/playtest/export/check/fill  (F06 tooling; CLI-only for MVP)
/content                    versioned puzzle JSON artifacts (journey + daily), checked in
/infra                      Firebase project config, Cloud Functions (TS), Firestore rules, Remote Config templates
```

* Shared value enums (`MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord`, `PuzzleType`, `DifficultyLabel`) are defined once in `looplet_core` and **re-exported** by `looplet_content`, so `looplet_engine` / `looplet_solver` (which must not depend on `looplet_content`, per §3) can use them and downstream code still has one import site. Firestore docs mirror the same string values. (See §11 — carve-out extended 2026-09-06 with F06.)
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
* Firebase Anonymous Auth provides an invisible device identity used for Firestore write-scoping and the analytics user id. **[Assumption]** this is not "login" in the PRD §39 sense — no credentials, no UI, no user action.
* **Identity model (amended 2026-09-06, F08 contract):** the anonymous UID and the durable guest key are **decoupled** — `firebaseUid` = the Firebase Anonymous UID (server identity: Firestore path segment + sync idempotency-key component; `null` until Auth completes); `guestId` = a **locally generated UUID v4**, persisted on first launch, stamped on every player-owned row, available offline before any network. Rationale: offline-first (PRD §5.4/§51) forbids gating local play/persistence on Anonymous Auth, which cannot complete offline on a first launch; the local UUID is also the cleaner anchor for future account adoption (`accountId` added alongside a retained `guestId`). Where earlier text here read "`guestId` = anonymous UID", read this decouple. See `features/f08-offline-persistence-and-sync/architecture.md` → Guest Identity Model.
* Authorization (Firestore rules):
  * Content in Cloud Storage: public read.
  * `dailyResults/**`: **no client access** — no create, update, delete or read in the MVP. Only the `submitDailyResultV1` callable writes, through the Admin SDK; it creates `entries/{the caller's uid}` only if that document does not already exist (server-enforced first-run authority). *[Amended 2026-09-29, F08 `architecture.md` A9: this line used to let a client create its own entry directly, which skipped the callable's validation — QA finding F1.]*
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
* Abuse controls: the callable is the only write path (create-only transaction + payload validation); Firestore rules deny all client access to `dailyResults/**`; App Check on the callable. No custom rate limiter in the MVP. *[Amended 2026-09-29, F08 A9.]*
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
* **Shared identifiers / enums:** all shared value enums — *engine primitives* (`MoveAxis`, `MoveDirection`, `TileStatus`, `GridCoord`) **and** *serialized puzzle-schema* enums (`PuzzleType`, `DifficultyLabel`) — are defined once in `looplet_core` and **re-exported** by `looplet_content`. Rationale: `looplet_engine` and `looplet_solver` must not depend on `looplet_content` (§3), yet `looplet_engine` needs the primitives and `looplet_solver` needs `DifficultyLabel` for its `DifficultyScorer`; defining them in `looplet_core` keeps every dependency edge legal, and the `looplet_content` re-export gives downstream code (app, tooling, Firestore mirrors) one import site. Firestore docs mirror the same string values. (Engine-primitive carve-out added 2026-09-05 with F02; extended 2026-09-06 to the puzzle-schema enums with F06 — this supersedes the earlier "defined once in `looplet_content`" wording.)
* **Determinism:** no runtime RNG anywhere in gameplay or content selection on device. Any shuffling/generation happens only in `tools/looplet_authoring` at authoring time.

---

# 12. Change Management

* Owner: Tech Lead.
* Impact analysis rule: any edit to this file triggers a review of the active feature and all `Not Started` features whose assumptions it touches.
* Active feature reassessment rule: if a platform decision changes while a feature is `In Progress`, the Tech Lead pauses that feature, reconciles its `architecture.md`, then resumes.

---

# 13. Open Technical Decisions (tracked)

* **Solver algorithm (F06):** approach is set here — provable minimum via complete search of the 5×5 state space, build-time only, sharing `looplet_engine`. **Implementation: forward BFS** over `GridState.canonicalKey` with a visited set + parent map + a `SearchBudget` (maxDepth / maxNodes / timeBudget); the first `isSolved` state dequeued is the proven minimum (the goal is a *set* — any full target row). Amended 2026-09-05 (F06 analysis): bidirectional BFS is **not** used — the goal-is-a-set plus the irreversibility of frozen-tile thaw break meet-in-the-middle. IDA* remains a documented per-puzzle fallback only. Final form is locked in F06's `architecture.md`.
* **App Check enforcement level:** **soft-enforce (monitor) for the MVP** — locked at F08 contract finalization (2026-09-06). Attestation failure on `submitDailyResultV1` / Firestore writes is logged, not blocked. Hard-enforce is a **post-MVP launch-hardening** item, not part of F07/F08. **Provider selection (2026-09-06):** debug/profile/simulator/test → debug provider; release → Play Integrity (Android) / App Attest (iOS). **iOS production App Attest / DeviceCheck cannot be configured yet** (LOOPLET Apple account is not enrolled in the Apple Developer Program — no Team ID / `.p8`); because enforcement is OFF, a failed iOS attestation is a logged no-op and does not block anything. Completing it is a post-MVP follow-on after enrollment. Android release Play Integrity needs the release-signing SHA-256 registered — an `F08-DEVOPS` / launch-hardening step.
* **On-device persistence schema (F08):** Drift/SQLite; the concrete table set + migration policy + the `kv` active-session snapshot contract are **locked** in `features/f08-offline-persistence-and-sync/architecture.md` (Persistence Schema / Active-Session Snapshot Contract). Forward-only; store downgrade unsupported; `personal_best` / `daily_streak` / `daily_entry` first-run rows never dropped. Drift codegen (`build_runner`) IS run for this schema (the "codegen off for MVP" note in §3 is Riverpod-only).
* **Daily offline-result sync surface (F08):** HTTPS Callable `submitDailyResultV1` (the "one RPC-style callable" from §4), not a direct client Firestore write. Contract locked in F08's `architecture.md`.
* **Level editor surface (F06):** CLI-only for the MVP (`solve`/`playtest`/`export`/`check`/`fill`); a Flutter desktop editor is a Future Consideration. Locked 2026-09-05 in F06's `architecture.md`.
* **Product-analytics depth (F12):** GA4 built-in funnels/retention are assumed sufficient for the §52 gate; a dedicated tool (PostHog/Amplitude) is a Future Consideration only if GA4 proves insufficient.

---

# 14. Visual Capture, Asset and Motion Baseline (added 2026-09-21 — `design/visual-quality-gate.md`)

Facts as verified on the running app (F03 QA runs, 2026-09-20). Where this section says **Pending**, a visual claim on that surface cannot PASS.

## Canonical visual capture target

* **Primary:** iOS Simulator, portrait, iOS 18.6 — iPhone 16 (393×852 pt, primary reference), iPhone 16e (390×844, smallest), iPhone 16 Pro Max (440×956, largest). Debug build of the exact revision under review: `flutter build ios --debug --simulator`, installed with `xcrun simctl install`.
* **Android:** no emulator/device capture exists or is planned yet. Any Android visual claim is **Pending**; iOS evidence does not stand in for it.
* Physical-device capture: not available in the current environment; simulator pointer input is synthetic (gesture accuracy claims need a physical-finger pass — see F03 QA notes).

## Screenshot / recording / state-forcing methods (proven)

| Need | Method |
| --- | --- |
| Still capture | `xcrun simctl io <UDID> screenshot <file>.png` (native 1179×2556 on iPhone 16) |
| Motion capture | `xcrun simctl io <UDID> recordVideo --codec h264 --force <file>.mov`, stop with SIGINT; frame sequences extracted with an AVFoundation (Swift) contact-sheet tool at 40–60 ms steps |
| Dynamic Type | `xcrun simctl ui <UDID> content_size <category>` (verified through accessibility-medium) |
| Reduce Motion | the real Settings toggle (Settings → Accessibility → Motion). `defaults write` does **not** reach the app |
| Rotation | Simulator menu `Device > Rotate Left/Right` via System Events (requires macOS Accessibility for the host); use a landscape-capable app (Safari) as the control |
| App switch / lifecycle | `xcrun simctl launch <other bundle id>` (the Simulator `Home` menu item is not reliable) |
| Greyscale | the OS Grayscale colour filter is **not available** in this iOS 18.6 simulator's Settings; luminance conversion of a real frame is an *approximation* and must be declared as such |
| Persisted-state forcing | `sqlite3` against the app container's `Documents/looplet.sqlite` |

## Fonts, icons, assets, motion runtime

* **Fonts:** **decided 2026-09-21** (Design Foundation Selected, Direction C): **Space Grotesk** (variable 300–700, headings / tile glyphs / numerals) and **Manrope** (variable 200–800, body / labels / CTAs), both SIL OFL 1.1, bundled as app assets with their licence texts; no network loading. Turkish glyph coverage (`İ ı Ş ş Ğ ğ Ç ç Ö ö Ü ü`) and tabular figures were verified in the design renders (`design/C-90-specimen.png`) — **runtime verification on the simulator is part of F00-FE-DESIGN-SYSTEM**. Until that task is delivered the shipped app still uses the system font (**Pending** for any surface claim).
* **Icons:** **decided 2026-09-21**: a drawn thin-outline set (back, sliders, flame, sparkle, star, undo, restart, arrow-up-right, arrow-right, lock, snowflake, up/down chevrons) replaces the Material Icons placeholders (`chevron_left_rounded`, `refresh_rounded`, `undo_rounded`, `push_pin`, `unfold_more_rounded`, `error_outline_rounded`); delivery mechanism (CustomPainter / Path) is a Frontend decision without a new dependency unless the Tech Lead approves. Shipped surfaces still use the Material icons until each is reworked (**Pending**).
* **Motion runtime:** Flutter `AnimationController` / `Interval` timelines (F03 won sequence, F04 star reveal, F05 ring). iOS "Reduce Motion" is exposed by Flutter as `AccessibilityFeatures.reduceMotion` (iOS-only), **not** `disableAnimations`; current code reads only `disableAnimations` (F03-QA-04). Motion evidence must be video or a frame sequence, never a static screenshot.
* **Audio / haptic:** none exists (F11 not started). Any audio/haptic claim is **Pending** until F11.
* **Localization/visual:** Turkish is the launch language; layouts must tolerate longer strings and Dynamic Type up to at least accessibility-medium (verified for the F03 win panel).

## Ownership

Project-specific brand, references, colour, font and art-direction decisions live in `project-authority/design-foundation.md` (not in `ai-system/design/`); this section only fixes *how* visual evidence is produced on this stack.

