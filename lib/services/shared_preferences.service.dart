import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

const hasSeenOnboardingKey = 'hasSeenOnboarding';
const cookieKey = 'cookies';
const localStorageKey = 'localStorage';

class SharedPreferencesService {
  static Future<void> saveOnboardingStatus(bool hasSeenOnboarding) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(hasSeenOnboardingKey, hasSeenOnboarding);
  }

  static Future<bool> getOnboardingStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final hasSeenOnboarding = sharedPreferences.getBool(hasSeenOnboardingKey);
    return hasSeenOnboarding ?? false;
  }

  static Future<void> saveLocalStorage(
      Map<String, dynamic> localStorageData) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(localStorageKey, json.encode(localStorageData));
  }

  static getLocalStorage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? localStorageData = sharedPreferences.getString(localStorageKey);
    return localStorageData != null ? json.decode(localStorageData) : null;
  }

  static Future<void> saveCookies(List<Cookie> cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cookiesStrings =
        jsonEncode(cookies.map((cookie) => jsonEncode(cookie)).toList());
    prefs.setString(cookieKey, cookiesStrings);
  }

  static Future<List<Cookie>> getCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookieStrings = prefs.getString(cookieKey);
    if (cookieStrings != null) {
      List<String> decoded = jsonDecode(cookieStrings).cast<String>();
      if (decoded.isEmpty) {
        return [];
      }

      List<Cookie> decodedCookieList = decoded.map((e) {
        dynamic json = jsonDecode(e);
        return Cookie(name: json['name'], value: json['value']);
      }).toList();

      return decodedCookieList;
    }

    return [];
  }
}
