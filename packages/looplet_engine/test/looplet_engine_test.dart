import 'package:looplet_engine/looplet_engine.dart';
import 'package:test/test.dart';

void main() {
  test('package scaffold is wired', () {
    expect(loopletEngineReady, isTrue);
  });
}
