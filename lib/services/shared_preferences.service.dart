import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

const hasSeenOnboardingKey = 'hasSeenOnboarding';
const cookiesKey = 'cookies';

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

  static Future<void> saveCookies(WebviewCookieManager wcm, String url) async {
    final cookies = await wcm.getCookies(url);
    if (cookies.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          cookiesKey, cookies.map((c) => c.toString()).toList());
    }
  }

  static Future<void> loadSavedCookies(WebviewCookieManager wcm) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cookieStrings = prefs.getStringList(cookiesKey);

    if (cookieStrings != null) {
      final cookies =
          cookieStrings.map((c) => Cookie.fromSetCookieValue(c)).toList();
      wcm.setCookies(cookies);
    }
  }

  static Future<void> clearCookies(WebviewCookieManager wcm) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(cookiesKey);
    wcm.clearCookies();
  }
}
