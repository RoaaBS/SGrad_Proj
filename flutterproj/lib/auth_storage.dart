import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'jwt_token';
  static const _userTypeKey = 'user_type';
  static const _storeTokenKey = 'jwt_token_store';

  static Future<void> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Store user type
  static Future<void> setUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
  }

  static Future<String?> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Set and Get functions for Store Token
  static Future<void> setStoreToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeTokenKey, token);
  }

  static Future<String?> getStoreToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeTokenKey);
  }
}
