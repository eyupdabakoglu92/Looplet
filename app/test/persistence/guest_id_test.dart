import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/persistence/guest_id.dart';

void main() {
  test('newGuestId produces a well-formed v4 UUID', () {
    for (var i = 0; i < 200; i++) {
      final id = newGuestId();
      expect(isGuestId(id), isTrue, reason: id);
      expect(id.length, 36);
      expect(id[14], '4'); // version nibble
      expect('89ab'.contains(id[19]), isTrue); // variant nibble
    }
  });

  test('newGuestId is effectively unique', () {
    final ids = <String>{for (var i = 0; i < 5000; i++) newGuestId()};
    expect(ids.length, 5000);
  });

  test('isGuestId rejects non-v4 strings', () {
    expect(isGuestId('not-a-uuid'), isFalse);
    expect(isGuestId('f47ac10b-58cc-1372-a567-0e02b2c3d479'), isFalse); // v1
    expect(isGuestId(''), isFalse);
  });

  test('accepts an injected Random (reproducible)', () {
    expect(newGuestId(Random(1)), newGuestId(Random(1)));
  });
}
