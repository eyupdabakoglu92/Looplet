/**
 * Offline skeleton tests — run in plain `npm test` (no emulator needed).
 *
 * These lock the DURUM-0 skeleton behaviour: the auth guard, the soft App Check
 * posture, and the wire contract shapes. The real validation + write behaviour
 * is added and tested by F08-BE2 (see `submitDailyResult.test.ts`).
 */

import { HttpsError } from "firebase-functions/v2/https";
import { handleSubmitDailyResult } from "../src/submitDailyResult";
import {
  SUPPORTED_LANGUAGES,
  ERROR_CODES,
  dailyResultDocPath,
  type SubmitDailyResultRequest,
} from "../src/types";

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

// Minimal CallableRequest stand-in — only the fields the skeleton reads.
const req = (over: Partial<{ auth: unknown; app: unknown; data: unknown }>) =>
  ({ data: validPayload, auth: undefined, app: {}, ...over }) as never;

describe("submitDailyResultV1 skeleton", () => {
  it("rejects an unauthenticated call", async () => {
    await expect(handleSubmitDailyResult(req({ auth: undefined }))).rejects.toBeInstanceOf(HttpsError);
    await expect(handleSubmitDailyResult(req({ auth: undefined }))).rejects.toMatchObject({
      code: "unauthenticated",
    });
  });

  it("does not throw on a missing App Check token (soft-enforce)", async () => {
    // With auth present and no App Check token, it must reach the TODO body
    // (INTERNAL) rather than rejecting for App Check.
    await expect(
      handleSubmitDailyResult(req({ auth: { uid: "u1" }, app: undefined })),
    ).rejects.toMatchObject({ code: "internal" });
  });

  it("authenticated call currently reaches the not-implemented body", async () => {
    await expect(
      handleSubmitDailyResult(req({ auth: { uid: "u1" } })),
    ).rejects.toMatchObject({ code: "internal" });
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
