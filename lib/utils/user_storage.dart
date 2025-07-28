import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static Future<void> saveUser(Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('name', user['name']);
    await prefs.setString('email', user['email']);
    await prefs.setString('phone', user['phone'] ?? ''); // Add phone storage
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'phone': prefs.getString('phone'), // Add phone retrieval
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
