import 'package:looplet_core/looplet_core.dart';
import 'package:test/test.dart';

void main() {
  test('package scaffold is wired', () {
    expect(loopletCoreReady, isTrue);
  });
}
