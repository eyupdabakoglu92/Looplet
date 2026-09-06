/**
 * `submitDailyResultV1` handler — SKELETON (Project Setup / F08 DURUM 0).
 *
 * Project Setup ships the auth guard + the wire contract only. The payload
 * validation, the create-only Firestore write, and the CREATED /
 * ALREADY_SUBMITTED reconciliation are implemented by **F08-BE2** against
 * `ai-system/features/f08-offline-persistence-and-sync/architecture.md`
 * → "Firebase Sync Surface" and "Reconciliation Algorithm".
 */

import { HttpsError, type CallableRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import type {
  SubmitDailyResultRequest,
  SubmitDailyResultResponse,
} from "./types";

/**
 * Handle one `submitDailyResultV1` call.
 *
 * @throws {HttpsError} `unauthenticated` when there is no Firebase Auth context.
 * @throws {HttpsError} `internal` (code `INTERNAL`) — TODO(F08-BE2): replace with
 *   real validation + a create-only write returning CREATED / ALREADY_SUBMITTED.
 */
export async function handleSubmitDailyResult(
  request: CallableRequest<SubmitDailyResultRequest>,
): Promise<SubmitDailyResultResponse> {
  // Auth guard — the only behaviour Project Setup wires. The uid used for the
  // Firestore path is request.auth.uid, never a payload field.
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign-in required.", {
      code: "INVALID_PAYLOAD",
    });
  }

  // App Check is SOFT-enforced in the MVP (platform.md §6 / §13): the callable
  // is registered with enforceAppCheck: false, so a missing/failed token does
  // not block the call. Log it for monitoring; do not reject.
  if (request.app === undefined) {
    logger.warn("submitDailyResultV1: missing App Check token (soft-enforce)", {
      uid: request.auth.uid,
    });
  }

  // TODO(F08-BE2): validate the payload (lang ∈ {tr,en}; dailyDate matches
  // ^\d{4}-\d{2}-\d{2}$; dailyId non-empty; optimalMoves >= 1;
  // optimalMoves <= moves; durationMs >= 0; stars ∈ 1..3; completedAtUtcMs > 0),
  // then do the create-only Firestore write at
  // dailyResults/{lang}_{dailyDate}/entries/{uid} and return
  // { status: "CREATED" | "ALREADY_SUBMITTED", recordedAt }.
  throw new HttpsError(
    "internal",
    "submitDailyResultV1 is not implemented yet (F08-BE2).",
    { code: "INTERNAL" },
  );
}
