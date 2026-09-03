import 'package:looplet_content/looplet_content.dart';
import 'package:test/test.dart';

void main() {
  test('package scaffold is wired', () {
    expect(loopletContentReady, isTrue);
  });
}
