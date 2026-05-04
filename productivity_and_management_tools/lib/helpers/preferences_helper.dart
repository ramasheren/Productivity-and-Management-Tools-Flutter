import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static late SharedPreferences _preferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Username
  static Future<bool> setUsername(String username) {
    return _preferences.setString('username', username);
  }

  static String getUsername() {
    return _preferences.getString('username') ?? 'User';
  }

  // Dark Mode
  static Future<bool> setDarkMode(bool isDarkMode) {
    return _preferences.setBool('darkMode', isDarkMode);
  }

  static bool getDarkMode() {
    return _preferences.getBool('darkMode') ?? false;
  }

  // First Launch Flag
  static Future<bool> setFirstLaunch(bool isFirstLaunch) {
    return _preferences.setBool('firstLaunch', isFirstLaunch);
  }

  static bool getFirstLaunch() {
    return _preferences.getBool('firstLaunch') ?? true;
  }

  // Last Opened Tab Index
  static Future<bool> setLastTabIndex(int index) {
    return _preferences.setInt('lastTabIndex', index);
  }

  static int getLastTabIndex() {
    return _preferences.getInt('lastTabIndex') ?? 0;
  }

  // Daily Task Count Streak
  static Future<bool> setTaskStreak(int streak) {
    return _preferences.setInt('taskStreak', streak);
  }

  static int getTaskStreak() {
    return _preferences.getInt('taskStreak') ?? 0;
  }

  // Today's date for streak tracking
  static Future<bool> setLastStreakDate(String date) {
    return _preferences.setString('lastStreakDate', date);
  }

  static String getLastStreakDate() {
    return _preferences.getString('lastStreakDate') ?? '';
  }

  // Pomodoro sessions completed today
  static Future<bool> setPomodoroSessions(int sessions) {
    return _preferences.setInt('pomodoroSessions', sessions);
  }

  static int getPomodoroSessions() {
    return _preferences.getInt('pomodoroSessions') ?? 0;
  }

  // Last Pomodoro date
  static Future<bool> setLastPomodoroDate(String date) {
    return _preferences.setString('lastPomodoroDate', date);
  }

  static String getLastPomodoroDate() {
    return _preferences.getString('lastPomodoroDate') ?? '';
  }
}
