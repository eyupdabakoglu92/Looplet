/**
 * `submitDailyResultV1` behaviour tests — **EMULATOR-GATED**.
 *
 * Runs only under the Firestore emulator (`FIRESTORE_EMULATOR_HOST` set — e.g.
 * `firebase emulators:exec --only firestore "npm test"` from `infra/`, or the
 * `npm run test:emulator` script). Skipped under a plain `npm test` so CI
 * without the emulator stays green; the CI emulator job runs it for real
 * (F08-BE5).
 */

import { deleteApp, getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { handleSubmitDailyResult } from "../src/submitDailyResult";
import { dailyResultDocPath, type SubmitDailyResultRequest } from "../src/types";

const RUN = !!process.env.FIRESTORE_EMULATOR_HOST;
const d = RUN ? describe : describe.skip;

const basePayload: SubmitDailyResultRequest = {
  lang: "tr",
  dailyDate: "2026-09-06",
  dailyId: "daily-tr-2026-09-06",
  moves: 14,
  optimalMoves: 9,
  durationMs: 83210,
  stars: 2,
  completedAtUtcMs: 1757145600000,
  clientAttemptNumber: 1,
};

const call = (over: {
  auth?: { uid: string };
  app?: unknown;
  data?: Partial<SubmitDailyResultRequest>;
}) =>
  handleSubmitDailyResult({
    auth: over.auth,
    app: over.app ?? {},
    data: { ...basePayload, ...over.data },
  } as never);

d("submitDailyResultV1", () => {
  beforeAll(() => {
    if (getApps().length === 0) {
      initializeApp({ projectId: "demo-looplet" });
    }
  });
  afterAll(async () => {
    await Promise.all(getApps().map((a) => deleteApp(a)));
  });
  beforeEach(async () => {
    await getFirestore().recursiveDelete(getFirestore().collection("dailyResults"));
  });

  const uid = "alice";
  const docRef = () =>
    getFirestore().doc(
      dailyResultDocPath(basePayload.lang, basePayload.dailyDate, uid),
    );

  it("CREATED on the first authenticated call, with the doc written", async () => {
    const res = await call({ auth: { uid } });
    expect(res.status).toBe("CREATED");
    expect(typeof res.recordedAt).toBe("number");

    const snap = await docRef().get();
    expect(snap.exists).toBe(true);
    expect(snap.data()).toMatchObject({
      uid,
      lang: "tr",
      dailyDate: "2026-09-06",
      moves: 14,
      optimalMoves: 9,
      stars: 2,
      recordedAtUtcMs: res.recordedAt,
    });
  });

  it("ALREADY_SUBMITTED on a repeat — first run stays authoritative", async () => {
    const first = await call({ auth: { uid } });
    // A valid "better" replay: fewer moves (still >= optimalMoves 9), more
    // stars, a faster time — so it reaches the idempotency branch instead of
    // being rejected by validation.
    const second = await call({
      auth: { uid },
      data: { moves: 10, stars: 3, durationMs: 40000 },
    });
    expect(second.status).toBe("ALREADY_SUBMITTED");
    expect(second.recordedAt).toBe(first.recordedAt);

    const snap = await docRef().get();
    expect(snap.data()).toMatchObject({
      moves: 14,
      stars: 2,
      durationMs: 83210,
      recordedAtUtcMs: first.recordedAt,
    }); // unchanged
  });

  it("is idempotent across many repeats — one doc, one recordedAt", async () => {
    const first = await call({ auth: { uid } });
    for (let i = 0; i < 4; i++) {
      const r = await call({ auth: { uid } });
      expect(r).toEqual({ status: "ALREADY_SUBMITTED", recordedAt: first.recordedAt });
    }
    const all = await getFirestore()
      .collection(`dailyResults/tr_2026-09-06/entries`)
      .get();
    expect(all.size).toBe(1);
  });

  it("scopes the write to the caller's own uid", async () => {
    await call({ auth: { uid: "alice" } });
    await call({ auth: { uid: "bob" } });
    const alice = await getFirestore()
      .doc(dailyResultDocPath("tr", "2026-09-06", "alice"))
      .get();
    const bob = await getFirestore()
      .doc(dailyResultDocPath("tr", "2026-09-06", "bob"))
      .get();
    expect(alice.exists && bob.exists).toBe(true);
    expect(alice.data()!.uid).toBe("alice");
    expect(bob.data()!.uid).toBe("bob");
  });

  it("rejects an unauthenticated call before touching Firestore", async () => {
    await expect(call({ auth: undefined })).rejects.toMatchObject({
      code: "unauthenticated",
    });
    const all = await getFirestore().collection("dailyResults").listDocuments();
    expect(all.length).toBe(0);
  });

  it("rejects an invalid payload with invalid-argument + details.code", async () => {
    await expect(
      call({ auth: { uid }, data: { lang: "de" } }),
    ).rejects.toMatchObject({
      code: "invalid-argument",
      details: { code: "UNSUPPORTED_LANGUAGE" },
    });
    await expect(
      call({ auth: { uid }, data: { stars: 9 } }),
    ).rejects.toMatchObject({
      code: "invalid-argument",
      details: { code: "INVALID_PAYLOAD" },
    });
    expect((await docRef().get()).exists).toBe(false);
  });

  it("throws HttpsError (not a raw error) — no internal leakage", async () => {
    const err = await call({ auth: undefined }).catch((e) => e);
    expect(err).toBeInstanceOf(HttpsError);
  });
});
