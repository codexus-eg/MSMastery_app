import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static SharedPreferences? _sharedPrefrences;

  static Future<void> initSharedPref() async {
    _sharedPrefrences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) {
    if (value is String) return _sharedPrefrences!.setString(key, value);
    if (value is int) return _sharedPrefrences!.setInt(key, value);
    if (value is double) return _sharedPrefrences!.setDouble(key, value);

    return _sharedPrefrences!.setBool(key, value);
  }

  static dynamic getData(String key) => _sharedPrefrences?.get(key);

  static Future<bool>? clearData() => _sharedPrefrences?.clear();
}
