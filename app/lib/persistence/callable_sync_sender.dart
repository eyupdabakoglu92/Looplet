import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'daily_result_sync_service.dart';

/// Builds the real [SyncSender] for `DailyResultSyncService` — a thin binding to
/// the `submitDailyResultV1` HTTPS callable. The response/error → [SyncSendResult]
/// mapping (below) mirrors `architecture.md → Firebase Sync Surface → client
/// mapping`; the queue state transitions it drives are already covered by
/// `sync_test.dart`.
///
/// `functions` is a **getter**, not a resolved `FirebaseFunctions` — it is only
/// called from inside the returned closure, at actual send-time, never at
/// construction time. This matters: `FirebaseFunctions.instance` throws
/// `[core/no-app]` if `Firebase.initializeApp()` hasn't completed yet, and this
/// sender is built (via `syncSenderProvider`) before that init kicks off
/// (`bootstrap.dart`'s `appBootstrapProvider` — see `sync_providers.dart` for
/// the full story, F08-FE12). Deferring the call here means the catch-all below
/// is what actually handles that case, exactly as its comment always intended.
SyncSender callableSyncSender(FirebaseFunctions Function() functions) {
  return (Map<String, Object?> payload) async {
    try {
      final callable = functions().httpsCallable('submitDailyResultV1');
      final result = await callable.call<Object?>(payload);
      return mapCallableSuccess(result.data);
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        'sync: submitDailyResultV1 failed — ${error.code}: ${error.message}',
      );
      return mapCallableErrorCode(error.code);
    } catch (error) {
      // Transport / plugin / no-Firebase-app — transient, keep the item.
      debugPrint('sync: submitDailyResultV1 failed (transient) — $error');
      return SyncSendResult.retryable;
    }
  };
}

/// Maps a successful callable payload (`{ "status": "CREATED" | "ALREADY_SUBMITTED", … }`).
/// An unrecognised/absent status is treated as retryable so the queue item is
/// never silently dropped.
SyncSendResult mapCallableSuccess(Object? data) {
  final status = data is Map ? data['status'] : null;
  return switch (status) {
    'CREATED' => SyncSendResult.created,
    'ALREADY_SUBMITTED' => SyncSendResult.alreadySubmitted,
    _ => SyncSendResult.retryable,
  };
}

/// Maps a `FirebaseFunctionsException.code`. `invalid-argument` (the server's
/// `INVALID_PAYLOAD` / `UNSUPPORTED_LANGUAGE`) is permanent → `parked`;
/// everything else — `internal`, `unavailable`, `deadline-exceeded`,
/// `resource-exhausted`, `aborted`, `unauthenticated` (auth not ready yet),
/// unknown — is transient → retry with backoff.
SyncSendResult mapCallableErrorCode(String code) {
  return switch (code) {
    'invalid-argument' => SyncSendResult.nonRetryable,
    _ => SyncSendResult.retryable,
  };
}
