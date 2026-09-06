/**
 * LOOPLET Cloud Functions entry point.
 *
 * MVP backend surface (`platform.md` §3):
 *   1. Daily content distribution — static JSON in Cloud Storage (no compute).
 *   2. Analytics ingestion — Firebase Analytics SDK direct from client (no endpoint).
 *   3. Offline daily-result sync — this file: `submitDailyResultV1`.
 */

import { onCall } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import { initializeApp } from "firebase-admin/app";
import { handleSubmitDailyResult } from "./submitDailyResult";

initializeApp();

setGlobalOptions({ region: "us-central1", maxInstances: 10 });

/**
 * Records the caller's first completed run for a given daily puzzle.
 * Create-only, idempotent on (uid, lang, dailyDate). See
 * `ai-system/features/f08-offline-persistence-and-sync/architecture.md`.
 *
 * App Check is soft-enforced for the MVP (`enforceAppCheck: false`) — see
 * `submitDailyResult.ts`.
 */
export const submitDailyResultV1 = onCall(
  { enforceAppCheck: false },
  handleSubmitDailyResult,
);
