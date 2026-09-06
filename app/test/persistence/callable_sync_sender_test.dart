import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/callable_sync_sender.dart';
import 'package:looplet_app/persistence/daily_result_sync_service.dart';

void main() {
  group('mapCallableSuccess', () {
    test('CREATED → created', () {
      expect(
        mapCallableSuccess(<String, Object?>{
          'status': 'CREATED',
          'recordedAt': 1,
        }),
        SyncSendResult.created,
      );
    });

    test('ALREADY_SUBMITTED → alreadySubmitted', () {
      expect(
        mapCallableSuccess(<String, Object?>{'status': 'ALREADY_SUBMITTED'}),
        SyncSendResult.alreadySubmitted,
      );
    });

    test('unknown / missing / non-map status → retryable (never dropped)', () {
      expect(
        mapCallableSuccess(<String, Object?>{'status': 'WAT'}),
        SyncSendResult.retryable,
      );
      expect(mapCallableSuccess(<String, Object?>{}), SyncSendResult.retryable);
      expect(mapCallableSuccess(null), SyncSendResult.retryable);
      expect(mapCallableSuccess('nope'), SyncSendResult.retryable);
    });
  });

  group('mapCallableErrorCode', () {
    test(
      'invalid-argument (INVALID_PAYLOAD / UNSUPPORTED_LANGUAGE) → nonRetryable',
      () {
        expect(
          mapCallableErrorCode('invalid-argument'),
          SyncSendResult.nonRetryable,
        );
      },
    );

    test('transient codes → retryable', () {
      for (final code in const <String>[
        'internal',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'aborted',
        'unauthenticated',
        'unknown',
      ]) {
        expect(
          mapCallableErrorCode(code),
          SyncSendResult.retryable,
          reason: code,
        );
      }
    });
  });
}
