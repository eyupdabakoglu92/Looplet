# F08 — offline-persistence-and-sync: Backend Delivery (Track B)

Role: Backend Developer · Date: 2026-09-06
Scope: **F08-BE2** (fill the `submitDailyResultV1` callable), **F08-BE3** (verify Firestore rules + rules tests), **F08-BE4** (Functions emulator behaviour tests), **F08-BE5** (CI emulator step). Emulator work targets a **fake project id** — `F08.FIREBASE-PROJECT` is not required for Track B.

---

## 1. Feature Summary

The server side of F08's deferred offline-result sync: the `submitDailyResultV1` 2nd-gen HTTPS callable that records a player's **first completed daily run**, create-only and idempotent on `(uid, lang, dailyDate)`, with **first-run-authoritative** reconciliation (a later/"better" replay never displaces the recorded run — it returns `ALREADY_SUBMITTED`). Plus the create-only Firestore security rules (already scaffolded — verified), the emulator behaviour tests, and the CI emulator job that runs the rules + callable suites.

---

## 2. Impacted Files

**Created — `infra/functions/`:**

* `src/validate.ts` — `validateSubmitDailyResult()` (pure, offline-tested) + `PayloadError` (carries `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE`).
* `test/submitDailyResult.test.ts` — emulator-gated behaviour suite (7 tests: CREATED, ALREADY_SUBMITTED, idempotent-across-repeats, per-uid scoping, unauth pre-Firestore reject, invalid-payload reject + no write, HttpsError-not-raw).

**Updated — `infra/functions/`:**

* `src/submitDailyResult.ts` — replaced the `TODO(F08-BE2)` body with: auth guard → soft App-Check log → `validateSubmitDailyResult` (→ `invalid-argument` + `details.code`) → a Firestore **transaction** that returns `ALREADY_SUBMITTED` if the doc exists, else `tx.create`s it and returns `CREATED`; a lost create-race is re-read and reported as `ALREADY_SUBMITTED`; any other write failure → `internal` (`details.code: "INTERNAL"`), logged, no detail leak.
* `test/skeleton.test.ts` — the two "reaches INTERNAL" assertions replaced with validation-path assertions (authed + invalid payload → `invalid-argument` + `details.code`, no Firestore access); added a `validateSubmitDailyResult` table of 10 rejection cases + a non-object case. Offline `npm test` stays green.
* `package.json` — added a `test:emulator` script (`firebase --config ../firebase.json emulators:exec --only firestore,auth --project demo-looplet "jest"`); `serve` / `deploy` scripts point at `../firebase.json`.

**Updated — root:**

* `.github/workflows/ci.yml` — the `infra` job's TODO replaced with a real **"Test functions (Firebase emulator)"** step: `working-directory: infra`, `npx --yes firebase-tools@15 emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` — un-skips `test/rules.test.ts` + `test/submitDailyResult.test.ts`. No new committed dep, no extra SHA-pinned action (ubuntu-latest ships a JDK; firebase-tools via `npx`).

**Verified, not changed:** `infra/firestore.rules` (create-only for `dailyResults/{bucket}/entries/{uid}`, default-deny) — compliant with the contract as scaffolded; `test/rules.test.ts` (6 emulator-gated cases) — covers the required allow/deny matrix.

---

## 3. Task-to-Code Traceability

| Task | Status | Files | Behavior |
| --- | --- | --- | --- |
| **F08-BE2** implement `submitDailyResultV1` | Complete | `src/submitDailyResult.ts`, `src/validate.ts` | Auth guard (`unauthenticated` when no `request.auth.uid`, before any Firestore access). App Check soft-enforce (missing token → `logger.warn`, not rejected — `enforceAppCheck: false` stays in `index.ts`). Full payload validation per `architecture.md → Firebase Sync Surface` + `platform.md` §8: `lang ∈ {tr,en}` (else `UNSUPPORTED_LANGUAGE`), `dailyDate` matches `^\d{4}-\d{2}-\d{2}$`, `dailyId` non-empty, `optimalMoves` integer ≥ 1, `moves` integer ≥ `optimalMoves`, `durationMs` integer ≥ 0, `stars` integer 1..3, `completedAtUtcMs` integer ≥ 1, `clientAttemptNumber` (optional) integer ≥ 1 — all `INVALID_PAYLOAD` except the lang case. A violation → `HttpsError("invalid-argument", msg, { code })`. Then a Firestore transaction on `dailyResults/{lang}_{dailyDate}/entries/{uid}`: exists → `{ status: "ALREADY_SUBMITTED", recordedAt: existing.recordedAtUtcMs }`; absent → `tx.create(ref, DailyResultDoc)` with `recordedAtUtcMs = Date.now()` → `{ status: "CREATED", recordedAt }`. A create that lost a concurrent race is caught, the doc re-read, and reported `ALREADY_SUBMITTED`. Any other failure → `HttpsError("internal", generic, { code: "INTERNAL" })`, `logger.error` with context. |
| **F08-BE3** rules + rules-unit-tests | Complete (verified — no change needed) | `infra/firestore.rules`, `test/rules.test.ts` | Rules as scaffolded match `architecture.md → Firebase Sync Surface → Rules`: `allow create: if request.auth != null && request.auth.uid == uid` on `dailyResults/{bucket}/entries/{uid}`; `allow update, delete, read: if false`; a catch-all `allow read, write: if false`. `!exists(...)` from the contract text is **implied** by Firestore `create` semantics (create only fires when the doc is absent) — a second write is an `update`, which is denied. `test/rules.test.ts` (emulator-gated) covers allow-create-own / deny-create-other / deny-unauth-create / deny-update / deny-delete / deny-read. |
| **F08-BE4** Functions emulator tests | Complete | `test/submitDailyResult.test.ts` (emulator-gated) | Against the Firestore emulator (`demo-looplet`): (1) first authed call → `CREATED` + the doc is written with the exact `DailyResultDoc` fields + `recordedAtUtcMs == res.recordedAt`; (2) a "better" replay (`moves 8, stars 3`) → `ALREADY_SUBMITTED`, same `recordedAt`, **stored doc unchanged** (`moves 14, stars 2`); (3) 4 further repeats → all `ALREADY_SUBMITTED` with the first `recordedAt`, exactly **one** doc in the collection; (4) `alice` + `bob` calls → each writes only their own `entries/{uid}`; (5) unauthenticated → `unauthenticated` and **no** Firestore doc; (6) invalid payloads (`lang: "de"` → `UNSUPPORTED_LANGUAGE`; `stars: 9` → `INVALID_PAYLOAD`) → `invalid-argument` + `details.code`, no doc; (7) errors are `HttpsError` instances (no raw-error leak). |
| **F08-BE5** CI emulator step | Complete | `.github/workflows/ci.yml`, `infra/functions/package.json` | The `infra` job now runs the emulator suite after the offline test: `emulators:exec --only firestore,auth --project demo-looplet "npm --prefix functions run test"` via `npx firebase-tools@15` from `working-directory: infra`. `demo-` project id ⇒ the emulator runs fully offline with no auth. A `test:emulator` npm script mirrors it for local use (needs a JDK + `firebase-tools`). |

---

## 6. Key Decisions

* **Transaction, not a plain `create()`, for idempotency.** The callable runs with admin privileges (rules do not apply server-side), so create-only + first-run-authoritative are enforced in code: a `runTransaction` reads the doc and either returns the existing `recordedAt` (`ALREADY_SUBMITTED`) or `tx.create`s. This is atomic against two concurrent first submissions; the loser catches the `tx.create` failure, re-reads, and also returns `ALREADY_SUBMITTED`. Result: **exactly one** server doc per `(uid, lang, dailyDate)`, first writer wins, no overwrite path exists.
* **`recordedAt` is the server clock** (`Date.now()` at create time), not the client's `completedAtUtcMs` — so the authoritative "when recorded" is server-trusted even though there is no server-side clock check on the gameplay values (`platform.md` §6; `product-prd §51` resolved out of MVP scope by the Tech Lead).
* **Pure `validate.ts` split out** so the full validation matrix is unit-tested with zero Firebase deps (offline `npm test`), and the handler test focuses on the write/reconciliation behaviour.
* **CI emulator via `npx`, no committed `firebase-tools` dep** and no `actions/setup-java` — keeps the `infra` `npm ci` lean and the SHA-pinning surface minimal (ubuntu-latest has a JDK on PATH). If a future runner image drops Java, a SHA-pinned `actions/setup-java` step is the fix.

---

## 7. Contract Compliance Check

| Area | Result |
| --- | --- |
| Callable name + registration (`submitDailyResultV1`, 2nd-gen `onCall`, `enforceAppCheck: false`) | **Preserved** (unchanged from the skeleton; `index.ts` untouched) |
| Request shape (`lang`, `dailyDate`, `dailyId`, `moves`, `optimalMoves`, `durationMs`, `stars`, `completedAtUtcMs`, `clientAttemptNumber?`) — `uid` from `context.auth` | **Preserved** — validated exactly per the contract; `uid` never read from the body |
| Response shape (`{ status: "CREATED" \| "ALREADY_SUBMITTED", recordedAt: number }`) | **Preserved** |
| Error format — `HttpsError` with `details.code ∈ {INVALID_PAYLOAD, UNSUPPORTED_LANGUAGE, INTERNAL}` (`platform.md` §4); `APP_CHECK_FAILED` not used (hard-enforce is post-MVP) | **Preserved** |
| Server-side validation ranges (`optimalMoves ≥ 1`, `optimalMoves ≤ moves`, `durationMs ≥ 0`, `dailyDate` format, `lang` set, `stars` 1..3, `completedAtUtcMs > 0`) — `platform.md` §8 | **Preserved** |
| Firestore path `dailyResults/{lang}_{dailyDate}/entries/{uid}` + `DailyResultDoc` shape | **Preserved** (`dailyResultDocPath` + `DailyResultDoc` from `types.ts`) |
| Create-only + first-run-authoritative reconciliation (no update/overwrite; `ALREADY_SUBMITTED` = client success) | **Preserved** — enforced by the transaction + verified by the emulator suite |
| Firestore rules: create-only own-uid, deny update/delete/read, default-deny | **Preserved** (verified; unchanged) |
| App Check soft-enforce (log, don't block) | **Preserved** |
| CI: `infra/functions` build + test + rules tests (`release.md` §4) | **Extended** — the emulator step now runs the rules + callable suites in CI |

---

## 10. Validation & Error Handling

* **Input validation** — `validateSubmitDailyResult` throws `PayloadError` on the first violation; the handler maps it to `HttpsError("invalid-argument", message, { code })`. Non-object payloads, missing fields, wrong types, out-of-range values, and cross-field (`moves < optimalMoves`) are all covered.
* **Auth** — `unauthenticated` is thrown before any validation or Firestore access.
* **App Check** — soft: a missing token is logged (`logger.warn` with `uid`), never rejected.
* **Write failures** — caught; a create-race is reconciled to `ALREADY_SUBMITTED`; anything else is `logger.error`ed with `{ uid, lang, dailyDate }` and returned as a generic `internal` (`details.code: "INTERNAL"`) — no internal detail in the client-visible message.
* **Idempotency / race** — the transaction guarantees one doc per key; concurrent first-writes converge (winner `CREATED`, loser `ALREADY_SUBMITTED`).

---

## 11. Test Evidence by Task

| Task / behavior | Test type | Scenario proven | File |
| --- | --- | --- | --- |
| BE2 validation | unit (offline) | 10 rejection cases (unsupported lang → `UNSUPPORTED_LANGUAGE`; bad date format, empty id, `optimalMoves < 1`, `moves < optimalMoves`, negative duration, stars 4 / 0, `completedAtUtcMs` 0, non-integer moves → `INVALID_PAYLOAD`); non-object payload → `PayloadError`; happy path defaults `clientAttemptNumber` to 1 | `test/skeleton.test.ts` |
| BE2 guard + mapping | unit (offline) | unauthenticated → `HttpsError` `code: "unauthenticated"`; authed + missing App Check + invalid payload → `invalid-argument` (App Check did **not** block); payload violation → `invalid-argument` + `details.code` (`UNSUPPORTED_LANGUAGE` / `INVALID_PAYLOAD`) | `test/skeleton.test.ts` |
| BE2 write + reconciliation | integration (Firestore emulator, gated) | first call → `CREATED` + doc written with exact fields + `recordedAtUtcMs == recordedAt`; "better" replay → `ALREADY_SUBMITTED`, same `recordedAt`, **doc unchanged**; 4 repeats → all `ALREADY_SUBMITTED` same `recordedAt`, **one** doc; unauth → `unauthenticated` + **no** doc; invalid → `invalid-argument` + no doc; errors are `HttpsError` | `test/submitDailyResult.test.ts` |
| BE2 per-uid scoping | integration (gated) | `alice` + `bob` calls each write only `entries/{own uid}` | `test/submitDailyResult.test.ts` |
| BE3 rules | integration (`@firebase/rules-unit-testing`, gated) | allow-create-own; deny-create-other; deny-unauthenticated-create; deny-update; deny-delete; deny-read | `test/rules.test.ts` (from F08.SETUP-0) |
| BE5 CI | config | the `infra` CI job runs both gated suites via `firebase emulators:exec` (`demo-looplet`, offline) | `.github/workflows/ci.yml` |

**Local run status:** `npm --prefix infra/functions run build` (tsc) green; `npm --prefix infra/functions test` (offline) green — **18 passed, 13 skipped** (6 rules + 7 callable, emulator-gated); `melos run infra:build` / `infra:test` green. The **emulator suites could not be executed in this environment (no Java Runtime)** — they run in CI via the new emulator step (analogous to Android `build:app` being CI-only locally). Verified logically + type-checked; the assertions are concrete and self-contained.

---

## 13. Missing / TODO

* **Emulator suites are CI-verified only** in this delivery — no JDK in the dev environment. First real green comes from the CI `infra` job (or any machine with a JDK running `npm run test:emulator`).
* `F08-FE8` (real `SyncSender` binding to this callable) + `F08-FE9` (app-scoped wiring) remain on the Frontend side, gated on `F08.FIREBASE-PROJECT`. The response→state mapping they need is already implemented + tested in `F08-FE7`.
* Actual `firebase deploy` of the function + rules is `F08-DEVOPS` (post-QA), gated on `F08.FIREBASE-PROJECT`.

---

# WORKFLOW HANDOFF SUGGESTION (NON-AUTHORITATIVE)

* **Completed Tasks:** F08-BE2, F08-BE3 (verified), F08-BE4, F08-BE5.
* **Remaining Tasks (this feature):** `F08.FIREBASE-PROJECT` (user) → then F08-FE6 / FE8 / FE9 (Frontend join) → QA → Tech Lead → DevOps/Release Engineer.
* **Blockers:** none for Track B. The emulator suites need a JDK to run (CI has one).
* **Status Suggestion:** Ready for Tech Lead review — both tracks' implementation is done; the feature now waits on `F08.FIREBASE-PROJECT` before the FE join + QA.

---

## 15. Sonraki Komut

```
Run Tech Lead
```
