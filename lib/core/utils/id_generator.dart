import 'dart:math';

/// Génère un UUID v4 (RFC 4122) sans dépendance externe.
///
/// Indispensable à l'architecture offline-first : lorsqu'un enregistrement est
/// créé hors ligne, le client fabrique lui-même l'identifiant (le backend
/// accepte les UUID fournis par le client via `WritableIDModelSerializer`).
/// Ainsi l'`id` local reste stable et identique après la synchronisation, sans
/// risque de collision entre appareils.
final Random _rng = Random.secure();

String generateUuidV4() {
  final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));

  // Version 4 (bits 12-15 du time_hi_and_version) et variant RFC 4122.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int start, int end) {
    final sb = StringBuffer();
    for (var i = start; i < end; i++) {
      sb.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
