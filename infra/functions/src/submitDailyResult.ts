/**
 * `submitDailyResultV1` handler (F08-BE2).
 *
 * Records the caller's **first completed run** for a daily puzzle. Create-only
 * and idempotent on `(uid, lang, dailyDate)` — a repeat delivery of the same
 * key is a no-op that returns `ALREADY_SUBMITTED`, and the earlier server record
 * stays authoritative (F08 architecture → Firebase Sync Surface + Reconciliation
 * Algorithm; `platform.md` §4/§6/§8).
 */

import { HttpsError, type CallableRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";
import type {
  DailyResultDoc,
  SubmitDailyResultRequest,
  SubmitDailyResultResponse,
} from "./types";
import { dailyResultDocPath } from "./types";
import { PayloadError, validateSubmitDailyResult } from "./validate";

/**
 * Handle one `submitDailyResultV1` call.
 *
 * @throws {HttpsError} `unauthenticated` — no Firebase Auth context.
 * @throws {HttpsError} `invalid-argument` (details.code `INVALID_PAYLOAD` /
 *   `UNSUPPORTED_LANGUAGE`) — a payload violation.
 * @throws {HttpsError} `internal` (details.code `INTERNAL`) — an unexpected error.
 */
export async function handleSubmitDailyResult(
  request: CallableRequest<SubmitDailyResultRequest>,
): Promise<SubmitDailyResultResponse> {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }

  // App Check is SOFT-enforced in the MVP (`enforceAppCheck: false`,
  // `platform.md` §6/§13): a missing/failed token is logged, not rejected.
  if (request.app === undefined) {
    logger.warn("submitDailyResultV1: missing App Check token (soft-enforce)", {
      uid,
    });
  }

  let payload;
  try {
    payload = validateSubmitDailyResult(request.data);
  } catch (error) {
    if (error instanceof PayloadError) {
      throw new HttpsError("invalid-argument", error.message, {
        code: error.code,
      });
    }
    throw error;
  }

  const { lang, dailyDate } = payload;
  const ref = getFirestore().doc(dailyResultDocPath(lang, dailyDate, uid));

  try {
    return await getFirestore().runTransaction<SubmitDailyResultResponse>(
      async (tx) => {
        const snapshot = await tx.get(ref);

        // First-run-authoritative: never overwrite an existing entry.
        if (snapshot.exists) {
          const existing = snapshot.data() as DailyResultDoc;
          return {
            status: "ALREADY_SUBMITTED",
            recordedAt: existing.recordedAtUtcMs,
          };
        }

        const recordedAtUtcMs = Date.now();
        const doc: DailyResultDoc = {
          uid,
          lang,
          dailyDate,
          dailyId: payload.dailyId,
          moves: payload.moves,
          optimalMoves: payload.optimalMoves,
          durationMs: payload.durationMs,
          stars: payload.stars,
          completedAtUtcMs: payload.completedAtUtcMs,
          recordedAtUtcMs,
        };
        tx.create(ref, doc);
        return { status: "CREATED", recordedAt: recordedAtUtcMs };
      },
    );
  } catch (error) {
    // A concurrent create losing the race surfaces as a transaction failure on
    // `tx.create`; re-read and report the winner as ALREADY_SUBMITTED.
    const raced = await ref.get();
    if (raced.exists) {
      const existing = raced.data() as DailyResultDoc;
      return {
        status: "ALREADY_SUBMITTED",
        recordedAt: existing.recordedAtUtcMs,
      };
    }
    logger.error("submitDailyResultV1: write failed", { uid, lang, dailyDate, error });
    throw new HttpsError("internal", "Could not record the result.", {
      code: "INTERNAL",
    });
  }
}
