/**
 * Pure payload validation for `submitDailyResultV1` (no Firebase deps — unit
 * tested offline). Rules from
 * `ai-system/features/f08-offline-persistence-and-sync/architecture.md`
 * → "Firebase Sync Surface" and `platform.md` §8.
 */

import { SUPPORTED_LANGUAGES, type SubmitDailyResultRequest } from "./types";

const DAILY_DATE = /^\d{4}-\d{2}-\d{2}$/;

/** A validation failure, carrying the callable `details.code` to surface. */
export class PayloadError extends Error {
  constructor(
    readonly code: "INVALID_PAYLOAD" | "UNSUPPORTED_LANGUAGE",
    message: string,
  ) {
    super(message);
    this.name = "PayloadError";
  }
}

function reqInt(
  value: unknown,
  field: string,
  { min, max }: { min?: number; max?: number } = {},
): number {
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new PayloadError("INVALID_PAYLOAD", `${field} must be an integer`);
  }
  if (min !== undefined && value < min) {
    throw new PayloadError("INVALID_PAYLOAD", `${field} must be >= ${min}`);
  }
  if (max !== undefined && value > max) {
    throw new PayloadError("INVALID_PAYLOAD", `${field} must be <= ${max}`);
  }
  return value;
}

function reqStr(value: unknown, field: string): string {
  if (typeof value !== "string" || value.length === 0) {
    throw new PayloadError("INVALID_PAYLOAD", `${field} must be a non-empty string`);
  }
  return value;
}

/**
 * Validates and normalizes an incoming payload. Throws {@link PayloadError} on
 * the first violation.
 */
export function validateSubmitDailyResult(
  data: unknown,
): Required<Omit<SubmitDailyResultRequest, "clientAttemptNumber">> & {
  clientAttemptNumber: number;
} {
  if (typeof data !== "object" || data === null) {
    throw new PayloadError("INVALID_PAYLOAD", "payload must be an object");
  }
  const d = data as Record<string, unknown>;

  const lang = reqStr(d.lang, "lang");
  if (!(SUPPORTED_LANGUAGES as readonly string[]).includes(lang)) {
    throw new PayloadError("UNSUPPORTED_LANGUAGE", `unsupported lang "${lang}"`);
  }

  const dailyDate = reqStr(d.dailyDate, "dailyDate");
  if (!DAILY_DATE.test(dailyDate)) {
    throw new PayloadError("INVALID_PAYLOAD", "dailyDate must match YYYY-MM-DD");
  }

  const dailyId = reqStr(d.dailyId, "dailyId");

  const optimalMoves = reqInt(d.optimalMoves, "optimalMoves", { min: 1 });
  const moves = reqInt(d.moves, "moves", { min: optimalMoves });
  const durationMs = reqInt(d.durationMs, "durationMs", { min: 0 });
  const stars = reqInt(d.stars, "stars", { min: 1, max: 3 });
  const completedAtUtcMs = reqInt(d.completedAtUtcMs, "completedAtUtcMs", {
    min: 1,
  });

  let clientAttemptNumber = 1;
  if (d.clientAttemptNumber !== undefined) {
    clientAttemptNumber = reqInt(d.clientAttemptNumber, "clientAttemptNumber", {
      min: 1,
    });
  }

  return {
    lang,
    dailyDate,
    dailyId,
    moves,
    optimalMoves,
    durationMs,
    stars,
    completedAtUtcMs,
    clientAttemptNumber,
  };
}
