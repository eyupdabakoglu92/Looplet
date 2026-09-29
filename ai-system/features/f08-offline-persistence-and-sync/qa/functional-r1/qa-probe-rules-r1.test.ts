// F08-QA-FUNCTIONAL-R1 independent rules probe (QA-owned, not part of the suite).
// Strict version of qa/functional/qa-probe-rules.test.ts: P3 and P6 were observations
// (ALLOWED / DENIED both passed); after A9 ruling 1 they must be DENIED, so they use
// assertFails (which requires a permission-denied error, not any error).
// Copied into infra/functions/test/ only for the run and removed afterwards.
// QA_RULES=<path> points the probe at another rules file (the control run on the old rules).
import { readFileSync } from "fs";
import { resolve } from "path";
import { assertFails, initializeTestEnvironment, type RulesTestEnvironment } from "@firebase/rules-unit-testing";
import { setDoc, getDoc, doc } from "firebase/firestore";

const RULES = process.env.QA_RULES ?? resolve(__dirname, "../../firestore.rules");
const path = (uid: string) => `dailyResults/tr_2026-09-06/entries/${uid}`;
const good = (uid: string) => ({ uid, lang: "tr", dailyDate: "2026-09-06", dailyId: "daily-tr-2026-09-06",
  moves: 14, optimalMoves: 9, durationMs: 83210, stars: 2, completedAtUtcMs: 1757145600000, recordedAtUtcMs: 1757145601000 });

describe("QA probe R1 — dailyResults rules", () => {
  let env: RulesTestEnvironment;
  beforeAll(async () => {
    console.log("rules under test:", RULES);
    env = await initializeTestEnvironment({ projectId: "looplet-qa-probe-r1",
      firestore: { rules: readFileSync(RULES, "utf8") } });
  });
  afterAll(async () => env?.cleanup());
  beforeEach(async () => env.clearFirestore());

  const absent = async (p: string) => {
    let exists = true;
    await env.withSecurityRulesDisabled(async (c) => { exists = (await getDoc(doc(c.firestore(), p))).exists(); });
    expect(exists).toBe(false);
  };

  it("P1 owner cannot overwrite an existing entry with setDoc (create-only)", async () => {
    await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), path("alice")), good("alice")));
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, path("alice")), { ...good("alice"), moves: 9, stars: 3 }));
    let after: unknown;
    await env.withSecurityRulesDisabled(async (c) => { after = (await getDoc(doc(c.firestore(), path("alice")))).data(); });
    expect(after).toMatchObject({ moves: 14, stars: 2 });
  });

  it("P2 owner cannot merge-set an existing entry", async () => {
    await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), path("alice")), good("alice")));
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, path("alice")), { stars: 3 }, { merge: true }));
  });

  it("P3 a direct client create of an own invalid entry is DENIED (F1)", async () => {
    const db = env.authenticatedContext("mallory").firestore();
    // moves < optimalMoves, stars 9, an extra field — the callable rejects all three (INVALID_PAYLOAD)
    await assertFails(setDoc(doc(db, path("mallory")), { uid: "mallory", moves: 1, optimalMoves: 9, stars: 9, junk: "x" }));
    await absent(path("mallory"));
  });

  it("P6 a direct client create under a non-date bucket is DENIED (F1)", async () => {
    const db = env.authenticatedContext("mallory").firestore();
    await assertFails(setDoc(doc(db, "dailyResults/zz_not-a-date-123/entries/mallory"), { any: "thing" }));
    await absent("dailyResults/zz_not-a-date-123/entries/mallory");
  });

  it("P4 a create in a different bucket for another uid is denied", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, "dailyResults/en_2026-09-07/entries/bob"), good("bob")));
  });

  it("P5 writing outside dailyResults is denied", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, "players/alice"), { x: 1 }));
  });

  it("P7 an unauthenticated create is denied", async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, path("anon")), good("anon")));
  });

  it("P8 the owner cannot read their own entry (no client read in the MVP)", async () => {
    await env.withSecurityRulesDisabled(async (c) => setDoc(doc(c.firestore(), path("alice")), good("alice")));
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(getDoc(doc(db, path("alice"))));
  });
});
