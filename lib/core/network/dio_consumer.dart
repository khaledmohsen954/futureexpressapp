import 'package:dio/dio.dart';

import '../services/services_locator_imports.dart';
import 'api_consumer.dart';
import 'app_interceptors.dart';
import 'contants.dart';

class DioConsumer implements ApiConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    // إضافة AppInterceptor لو مش متسجل
    if (!client.interceptors.any((i) => i is AppInterceptors)) {
      client.interceptors.add(sl<AppInterceptors>());
    }

    // إعداد الـ Dio Options
    client.options
      ..baseUrl = Constants.baseUrl
      ..followRedirects = false;
  }

  /// خريطة لتجميع الـ requests الجارية (لمنع التكرار)
  final Map<String, Future> _pendingRequests = {};

  /// عمل fingerprint للـ request عشان نعرف لو بيتكرر
  String _fingerprint(String method, String path, Map<String, dynamic>? body) {
    final bodyMap = Map.of(body ?? {})..removeWhere((k, v) => v == null);
    return '$method|$path|${bodyMap.toString()}';
  }

  @override
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = false,
  }) async {
    final response = await client.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        extra: {"requiresAuth": requiresAuth, "showToast": showToast},
      ),
    );
    return response.data;
  }

  @override
  Future post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool? isFormData,
    bool requiresAuth = true,
    bool showToast = true,
  }) async {
    final fp = _fingerprint('POST', path, body);
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();

    if (_pendingRequests.containsKey(fp)) {
      return await _pendingRequests[fp];
    }

    final options = Options(
      extra: {"requiresAuth": requiresAuth, "showToast": showToast},
      headers: {'X-Request-Id': requestId, ...?headers},
    );
    final data = (isFormData == true && body is! FormData)
        ? FormData.fromMap(body ?? {})
        : body;

    final future = client
        .post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    )
        .then((response) {
      return response.data;
    }).whenComplete(() {
      _pendingRequests.remove(fp);
    });

    _pendingRequests[fp] = future;
    return await future;
  }

  @override
  Future put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool? isFormData,
    bool requiresAuth = true,
    bool showToast = true,
  }) async {
    final response = await client.put(
      path,
      data: isFormData == true ? FormData.fromMap(body ?? {}) : body,
      queryParameters: queryParameters,
      options: Options(
        extra: {"requiresAuth": requiresAuth, "showToast": showToast},
      ),
    );
    return response.data;
  }

  @override
  Future delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool? isFormData,
    bool requiresAuth = true,
    bool showToast = true,
  }) async {
    final response = await client.delete(
      path,
      data: isFormData == true ? FormData.fromMap(body ?? {}) : body,
      queryParameters: queryParameters,
      options: Options(
        extra: {"requiresAuth": requiresAuth, "showToast": showToast},
      ),
    );
    return response.data;
  }
}
