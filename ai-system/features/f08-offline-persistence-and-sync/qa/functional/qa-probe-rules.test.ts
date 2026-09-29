// F08-QA-FUNCTIONAL independent rules probe (QA-owned, not part of the suite).
// Copied into infra/functions/test/ only for the run and removed afterwards.
import { readFileSync } from "fs";
import { resolve } from "path";
import { assertFails, initializeTestEnvironment, type RulesTestEnvironment } from "@firebase/rules-unit-testing";
import { setDoc, getDoc, doc } from "firebase/firestore";

const path = (uid: string) => `dailyResults/tr_2026-09-06/entries/${uid}`;
const good = (uid: string) => ({ uid, lang: "tr", dailyDate: "2026-09-06", dailyId: "daily-tr-2026-09-06",
  moves: 14, optimalMoves: 9, durationMs: 83210, stars: 2, completedAtUtcMs: 1757145600000, recordedAtUtcMs: 1757145601000 });

describe("QA probe — dailyResults rules", () => {
  let env: RulesTestEnvironment;
  beforeAll(async () => {
    env = await initializeTestEnvironment({ projectId: "looplet-qa-probe",
      firestore: { rules: readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8") } });
  });
  afterAll(async () => env?.cleanup());
  beforeEach(async () => env.clearFirestore());

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

  it("P3 (observation) a direct client create bypasses callable validation", async () => {
    const db = env.authenticatedContext("mallory").firestore();
    // moves < optimalMoves and stars 9 — the callable would reject both (INVALID_PAYLOAD)
    const r = await setDoc(doc(db, path("mallory")), { uid: "mallory", moves: 1, optimalMoves: 9, stars: 9, junk: "x" })
      .then(() => "ALLOWED", () => "DENIED");
    console.log("P3 direct invalid create:", r);
    expect(["ALLOWED", "DENIED"]).toContain(r);
  });

  it("P6 (observation) a direct client create in an arbitrary bucket name", async () => {
    const db = env.authenticatedContext("mallory").firestore();
    const r = await setDoc(doc(db, "dailyResults/zz_not-a-date-123/entries/mallory"), { any: "thing" })
      .then(() => "ALLOWED", () => "DENIED");
    console.log("P6 arbitrary bucket create:", r);
    expect(["ALLOWED", "DENIED"]).toContain(r);
  });

  it("P4 a create in a different bucket for another uid is denied", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, "dailyResults/en_2026-09-07/entries/bob"), good("bob")));
  });

  it("P5 writing outside dailyResults is denied", async () => {
    const db = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(db, "players/alice"), { x: 1 }));
  });
});
