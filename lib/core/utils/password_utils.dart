import 'package:bcrypt/bcrypt.dart';

class PasswordUtils {
  /// Hash a plaintext password using bcrypt.
  static String hashPassword(String plainPassword) {
    final salt = BCrypt.gensalt();
    final hashed = BCrypt.hashpw(plainPassword, salt);
    return hashed;
  }

  /// Verify a plaintext password against a stored hash.
  static bool verifyPassword(String plainPassword, String storedHash) {
    return BCrypt.checkpw(plainPassword, storedHash);
  }
}
