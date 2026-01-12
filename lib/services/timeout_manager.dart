import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeoutManager {
  static const String _keyTimeoutSeconds = 'dio_timeout_seconds';
  static const int defaultTimeoutSeconds = 60;

  static Future<int> getTimeoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTimeoutSeconds) ?? defaultTimeoutSeconds;
  }

  static Future<void> setTimeoutSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTimeoutSeconds, seconds);
  }

  static Future<void> applyToDio(Dio dio) async {
    final seconds = await getTimeoutSeconds();
    final duration = Duration(seconds: seconds);

    dio.options = dio.options.copyWith(
      connectTimeout: duration,
      receiveTimeout: duration,
    );

    print('Dio timeout updated to ${seconds}s');
  }
}
