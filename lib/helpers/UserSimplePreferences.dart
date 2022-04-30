import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static late SharedPreferences _preferences;
  static const _keyEmail = "email";
  static const _keyUserName = "userName";
  static const _keyImage = "image";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();
  static Future setUserImage(String userImage) async =>
      await _preferences.setString(_keyImage, userImage);
  static String? getUserImage() => _preferences.getString(_keyImage);
  static Future setEmail(String email) async {
    await _preferences.setString(_keyEmail, email);
  }

  static String? getEmail() => _preferences.getString(_keyEmail);
  static Future setNom(String nom) async {
    await _preferences.setString(_keyUserName, nom);
  }

  static String? getNom() => _preferences.getString(_keyUserName);
  static void clean() => _preferences.clear();
}
