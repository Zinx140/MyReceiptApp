import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _keyIsVerified = 'is_code_verified';

  static Future<void> saveVerified() async {
    await _storage.write(key: _keyIsVerified, value: 'true');
  }

  static Future<bool> isVerified() async {
    final value = await _storage.read(key: _keyIsVerified);
    return value == 'true';
  }

  static Future<void> clearVerified() async {
    await _storage.delete(key: _keyIsVerified);
  }
}
