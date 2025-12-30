import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLogin = 'is_logged_in';

  static Future<bool> login(String username, String password) async {
    // login statis (simple & aman buat offline)
    if (username == 'admin' && password == '123456') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLogin, true);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogin);
  }
}
