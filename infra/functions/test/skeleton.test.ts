/**
 * Offline unit tests — run in plain `npm test` (no emulator).
 *
 * These cover the auth guard, the soft App Check posture, the wire-contract
 * shapes, and pure payload validation. The create-only Firestore write +
 * CREATED / ALREADY_SUBMITTED reconciliation are emulator-tested in
 * `submitDailyResult.test.ts`.
 */

import { HttpsError } from "firebase-functions/v2/https";
import { handleSubmitDailyResult } from "../src/submitDailyResult";
import {
  SUPPORTED_LANGUAGES,
  ERROR_CODES,
  dailyResultDocPath,
  type SubmitDailyResultRequest,
} from "../src/types";
import { PayloadError, validateSubmitDailyResult } from "../src/validate";

const validPayload: SubmitDailyResultRequest = {
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

// Minimal CallableRequest stand-in — only the fields the handler reads.
const req = (over: Partial<{ auth: unknown; app: unknown; data: unknown }>) =>
  ({ data: validPayload, auth: undefined, app: {}, ...over }) as never;

describe("submitDailyResultV1 handler — guard + validation", () => {
  it("rejects an unauthenticated call", async () => {
    await expect(handleSubmitDailyResult(req({ auth: undefined }))).rejects.toBeInstanceOf(HttpsError);
    await expect(handleSubmitDailyResult(req({ auth: undefined }))).rejects.toMatchObject({
      code: "unauthenticated",
    });
  });

  it("does not reject on a missing App Check token (soft-enforce) — reaches validation", async () => {
    // authed + no App Check token + INVALID payload → an invalid-argument, not
    // an App Check rejection.
    await expect(
      handleSubmitDailyResult(
        req({ auth: { uid: "u1" }, app: undefined, data: { ...validPayload, stars: 9 } }),
      ),
    ).rejects.toMatchObject({ code: "invalid-argument" });
  });

  it("maps a payload violation to invalid-argument + details.code", async () => {
    await expect(
      handleSubmitDailyResult(
        req({ auth: { uid: "u1" }, data: { ...validPayload, lang: "de" } }),
      ),
    ).rejects.toMatchObject({
      code: "invalid-argument",
      details: { code: "UNSUPPORTED_LANGUAGE" },
    });
    await expect(
      handleSubmitDailyResult(
        req({ auth: { uid: "u1" }, data: { ...validPayload, durationMs: -1 } }),
      ),
    ).rejects.toMatchObject({
      code: "invalid-argument",
      details: { code: "INVALID_PAYLOAD" },
    });
  });
});

describe("validateSubmitDailyResult", () => {
  it("accepts a well-formed payload and defaults clientAttemptNumber", () => {
    const { clientAttemptNumber, ...rest } = validPayload;
    void clientAttemptNumber;
    const out = validateSubmitDailyResult(rest);
    expect(out.clientAttemptNumber).toBe(1);
    expect(out.lang).toBe("tr");
  });

  it.each<[string, Partial<SubmitDailyResultRequest>, string]>([
    ["unsupported lang", { lang: "de" }, "UNSUPPORTED_LANGUAGE"],
    ["bad dailyDate", { dailyDate: "2026/09/06" }, "INVALID_PAYLOAD"],
    ["empty dailyId", { dailyId: "" }, "INVALID_PAYLOAD"],
    ["optimalMoves < 1", { optimalMoves: 0 }, "INVALID_PAYLOAD"],
    ["moves < optimalMoves", { moves: 3, optimalMoves: 9 }, "INVALID_PAYLOAD"],
    ["negative durationMs", { durationMs: -1 }, "INVALID_PAYLOAD"],
    ["stars out of range", { stars: 4 }, "INVALID_PAYLOAD"],
    ["stars below range", { stars: 0 }, "INVALID_PAYLOAD"],
    ["non-positive completedAtUtcMs", { completedAtUtcMs: 0 }, "INVALID_PAYLOAD"],
    ["non-integer moves", { moves: 1.5 }, "INVALID_PAYLOAD"],
  ])("rejects %s", (_label, patch, code) => {
    try {
      validateSubmitDailyResult({ ...validPayload, ...patch });
      throw new Error("expected PayloadError");
    } catch (e) {
      expect(e).toBeInstanceOf(PayloadError);
      expect((e as PayloadError).code).toBe(code);
    }
  });

  it("rejects a non-object payload", () => {
    expect(() => validateSubmitDailyResult(null)).toThrow(PayloadError);
    expect(() => validateSubmitDailyResult("x")).toThrow(PayloadError);
  });
});

describe("wire contract shapes", () => {
  it("supports exactly tr + en", () => {
    expect([...SUPPORTED_LANGUAGES]).toEqual(["tr", "en"]);
  });

  it("exposes the platform.md §4 error codes", () => {
    expect([...ERROR_CODES]).toEqual([
      "INVALID_PAYLOAD",
      "UNSUPPORTED_LANGUAGE",
      "APP_CHECK_FAILED",
      "INTERNAL",
    ]);
  });

  it("builds the create-only doc path", () => {
    expect(dailyResultDocPath("tr", "2026-09-06", "abc123")).toBe(
      "dailyResults/tr_2026-09-06/entries/abc123",
    );
  });
});
