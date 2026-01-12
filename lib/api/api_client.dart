import 'package:ar_assistant/api/api_config.dart';
import 'package:ar_assistant/services/timeout_manager.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.BASE_URL,
        connectTimeout: const Duration(seconds: 200),
        receiveTimeout: const Duration(seconds: 200),
      ),
    );

    dio.interceptors.addAll([
      PrettyDioLogger(
        responseHeader: true,
        responseBody: true,
        requestHeader: true,
        requestBody: true,
        request: true,
        compact: false,
      ),
    ]);
    TimeoutManager.applyToDio(dio);
  }
}
