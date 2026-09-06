import 'dart:math';

/// Generates a random RFC-4122 version-4 UUID string, e.g.
/// `f47ac10b-58cc-4372-a567-0e02b2c3d479`.
///
/// This is LOOPLET's durable local guest key (`player.guestId`) — stamped on
/// every player-owned row so a future account can adopt the data without a
/// destructive migration (`platform.md` §6, F08 architecture → Guest Identity
/// Model). It is distinct from `firebaseUid` (the Anonymous Auth id, obtained
/// asynchronously and possibly never while offline).
///
/// `Random.secure()` gives 122 bits of entropy — practical uniqueness per
/// install; it is not a security token.
String newGuestId([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));

  // Version 4 + RFC-4122 variant bits.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int start, int end) {
    final buffer = StringBuffer();
    for (var i = start; i < end; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

/// True if [value] is a well-formed v4 UUID string.
bool isGuestId(String value) => _uuidPattern.hasMatch(value);
