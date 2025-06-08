import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class AuthService{
  static final storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await storage.write(key: 'user_token', value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key:'user_token');
  }

  static Future<void> deleteToken() async {
    await storage.delete(key: 'user_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}