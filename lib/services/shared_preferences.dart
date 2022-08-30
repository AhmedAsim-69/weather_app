import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static late SharedPreferences _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const _keyLatitude = 'keyLat';
  static const _keyLongitude = 'keyLon';
  static const _keyCity = 'keyCity';

  static Future storeLatitude(String lat) async {
    await _preferences.setString(_keyLatitude, lat);
  }

  static Future storeLongitude(String lon) async {
    await _preferences.setString(_keyLongitude, lon);
  }

  static Future storeCity(String city) async {
    await _preferences.setString(_keyCity, city);
  }

  static String? getLatitude() {
    return _preferences.getString(_keyLatitude);
  }

  static String? getLongitude() {
    return _preferences.getString(_keyLongitude);
  }

  static String? getCity() {
    return _preferences.getString(_keyCity);
  }
}
