/**
 * Wire types for the `submitDailyResultV1` callable.
 *
 * Source of truth: `ai-system/features/f08-offline-persistence-and-sync/architecture.md`
 * → "Firebase Sync Surface [LOCKED — HTTPS Callable]". Project Setup ships these
 * shapes only; the validation + Firestore-write logic is F08-BE2.
 */

/** Supported content languages (`platform.md` §4 / §8). */
export const SUPPORTED_LANGUAGES = ["tr", "en"] as const;
export type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

/** Request body. `uid` is taken from `context.auth`, never the payload. */
export interface SubmitDailyResultRequest {
  lang: string;
  dailyDate: string; // YYYY-MM-DD (device-local)
  dailyId: string;
  moves: number;
  optimalMoves: number;
  durationMs: number;
  stars: number; // 1..3
  completedAtUtcMs: number;
  clientAttemptNumber?: number; // informational; server records first-run only
}

export type SubmitDailyResultStatus = "CREATED" | "ALREADY_SUBMITTED";

export interface SubmitDailyResultResponse {
  status: SubmitDailyResultStatus;
  recordedAt: number; // epoch millis of the authoritative first-run server record
}

/**
 * Callable error codes (`platform.md` §4). Surfaced to the client as the
 * `details.code` of a `functions.https.HttpsError`.
 */
export const ERROR_CODES = [
  "INVALID_PAYLOAD",
  "UNSUPPORTED_LANGUAGE",
  "APP_CHECK_FAILED", // hard-enforce only; App Check is soft-enforced in the MVP
  "INTERNAL",
] as const;
export type ErrorCode = (typeof ERROR_CODES)[number];

/** The Firestore document written at dailyResults/{lang}_{date}/entries/{uid} (create-only). */
export interface DailyResultDoc {
  uid: string;
  lang: string;
  dailyDate: string;
  dailyId: string;
  moves: number;
  optimalMoves: number;
  durationMs: number;
  stars: number;
  completedAtUtcMs: number;
  recordedAtUtcMs: number;
}

export const dailyResultDocPath = (
  lang: string,
  dailyDate: string,
  uid: string,
): string => `dailyResults/${lang}_${dailyDate}/entries/${uid}`;
