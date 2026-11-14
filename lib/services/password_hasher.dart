import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// SHA-256 salted hash. Good enough for the local v1 MVP (not a server).
class PasswordHasher {
  static const String seedSalt = 'ontherack-seed-salt-v1';

  static String hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  static String randomSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
