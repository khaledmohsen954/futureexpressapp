import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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

    // إضافة Logger في حالة Debug فقط
    if (kDebugMode && !client.interceptors.any((i) => i is PrettyDioLogger)) {
      client.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
          error: true,
          request: true,
        ),
      );
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

    debugPrint(
      'DIO -> POST about to send | path=$path | requestId=$requestId | fp=$fp | body=${body ?? {}}',
    );
    log(headers.toString());

    if (_pendingRequests.containsKey(fp)) {
      debugPrint(
        'DIO -> duplicate request detected, returning existing future for fingerprint=$fp',
      );
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
          debugPrint(
            'DIO -> POST response | path=$path | requestId=$requestId | status=${response.statusCode}',
          );
          return response.data;
        })
        .catchError((e, st) {
          debugPrint(
            'DIO -> POST error | path=$path | requestId=$requestId | error=$e',
          );
          throw e;
        })
        .whenComplete(() {
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
