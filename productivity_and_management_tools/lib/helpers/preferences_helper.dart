import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences? get _safePreferences => _preferences;

  // Username
  static Future<bool> setUsername(String username) {
    final preferences = _safePreferences;
    if (preferences == null) {
      return Future.value(false);
    }
    return preferences.setString('username', username);
  }

  static String getUsername() {
    return _safePreferences?.getString('username') ?? 'User';
  }

  // Last Opened Tab Index
  static Future<bool> setLastTabIndex(int index) {
    final preferences = _safePreferences;
    if (preferences == null) {
      return Future.value(false);
    }
    return preferences.setInt('lastTabIndex', index);
  }

  static int getLastTabIndex() {
    return _safePreferences?.getInt('lastTabIndex') ?? 0;
  }

  // Pomodoro sessions completed today
  static Future<bool> setPomodoroSessions(int sessions) {
    final preferences = _safePreferences;
    if (preferences == null) {
      return Future.value(false);
    }
    return preferences.setInt('pomodoroSessions', sessions);
  }

  static int getPomodoroSessions() {
    return _safePreferences?.getInt('pomodoroSessions') ?? 0;
  }

  // Last Pomodoro date
  static Future<bool> setLastPomodoroDate(String date) {
    final preferences = _safePreferences;
    if (preferences == null) {
      return Future.value(false);
    }
    return preferences.setString('lastPomodoroDate', date);
  }

  static String getLastPomodoroDate() {
    return _safePreferences?.getString('lastPomodoroDate') ?? '';
  }
}
