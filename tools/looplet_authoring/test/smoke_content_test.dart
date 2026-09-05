import 'package:looplet_authoring/looplet_authoring.dart';
import 'package:test/test.dart';

/// The committed smoke set must always pass `check`. Runs from
/// tools/looplet_authoring, so content/ is two levels up.
void main() {
  test('content/smoke passes the content check', () async {
    final failures = await runContentCheck(
      root: '../../content/smoke',
      repoRoot: '../..',
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
