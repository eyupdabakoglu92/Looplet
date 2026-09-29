/**
 * Firestore security-rules tests for `dailyResults/**` (no client access).
 *
 * Only the `submitDailyResultV1` callable writes these entries, through the
 * Admin SDK (rules do not apply to it); `submitDailyResult.test.ts` covers that
 * path. Every direct client write or read is denied — including a valid entry
 * for the caller's own uid, which would otherwise skip the callable's payload
 * validation (f08 architecture.md A9).
 *
 * EMULATOR-GATED: this suite runs only when the Firestore emulator is up
 * (`FIRESTORE_EMULATOR_HOST` set, e.g. via `firebase emulators:exec`). Under a
 * plain `npm test` with no emulator it is skipped so CI without the emulator
 * stays green; the CI job that starts the emulator runs it for real.
 */

import { readFileSync } from "fs";
import { resolve } from "path";
import {
  assertFails,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { setDoc, updateDoc, deleteDoc, getDoc, doc } from "firebase/firestore";

const RUN = !!process.env.FIRESTORE_EMULATOR_HOST;
const d = RUN ? describe : describe.skip;

const LANG = "tr";
const DATE = "2026-09-06";
const BUCKET = `${LANG}_${DATE}`;
const entryPath = (uid: string) => `dailyResults/${BUCKET}/entries/${uid}`;

const sampleDoc = (uid: string) => ({
  uid,
  lang: LANG,
  dailyDate: DATE,
  dailyId: `daily-${LANG}-${DATE}`,
  moves: 14,
  optimalMoves: 9,
  durationMs: 83210,
  stars: 2,
  completedAtUtcMs: 1757145600000,
  recordedAtUtcMs: 1757145601000,
});

d("dailyResults rules — no client access", () => {
  let env: RulesTestEnvironment;

  beforeAll(async () => {
    env = await initializeTestEnvironment({
      projectId: "looplet-rules-test",
      firestore: {
        rules: readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8"),
      },
    });
  });

  afterAll(async () => env?.cleanup());
  beforeEach(async () => env.clearFirestore());

  it("denies a signed-in user's direct create of their own valid entry", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, entryPath("alice")), sampleDoc("alice")));
  });

  it("denies a direct create of an own entry with an invalid payload", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(
      setDoc(doc(db, entryPath("alice")), {
        ...sampleDoc("alice"),
        moves: 1, // < optimalMoves (9)
        stars: 9, // outside 1..3
        extra: "not in the contract",
      }),
    );
  });

  it("denies a direct create in a non-date bucket", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(
      setDoc(doc(db, "dailyResults/zz_not-a-date-123/entries/alice"), sampleDoc("alice")),
    );
  });

  it("denies creating another user's entry", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, entryPath("bob")), sampleDoc("bob")));
  });

  it("denies an unauthenticated create", async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, entryPath("alice")), sampleDoc("alice")));
  });

  it("denies update of an existing entry", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), entryPath("alice")), sampleDoc("alice"));
    });
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(updateDoc(doc(db, entryPath("alice")), { moves: 1 }));
  });

  it("denies delete of an existing entry", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), entryPath("alice")), sampleDoc("alice"));
    });
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(deleteDoc(doc(db, entryPath("alice"))));
  });

  it("denies reading any entry (no cross-user / no self read in the MVP)", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), entryPath("alice")), sampleDoc("alice"));
    });
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(getDoc(doc(db, entryPath("alice"))));
  });
});
