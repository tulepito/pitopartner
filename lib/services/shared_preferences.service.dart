import 'package:shared_preferences/shared_preferences.dart';

const hasSeenOnboardingKey = 'hasSeenOnboarding';

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
}
