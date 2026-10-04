import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:futureexpressapp/core/cache/hive/hive_methods.dart';
import 'package:futureexpressapp/core/session/auth_session.dart';

import '../utils/common_methods.dart';

class AppInterceptors extends Interceptor {
  AppInterceptors();
  static bool isInternet = true;

  /// Converts Arabic numerals (٠-٩) to English numerals (0-9)
  static const _arabicToEnglishDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// Converts any Arabic numerals in a string to English numerals
  String _convertArabicToEnglishNumbers(String input) {
    String result = input;
    _arabicToEnglishDigits.forEach((arabic, english) {
      result = result.replaceAll(arabic, english);
    });
    return result;
  }

  /// Recursively converts all Arabic numerals in a dynamic value to English
  dynamic _convertNumbersInValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return _convertArabicToEnglishNumbers(value);
    } else if (value is Map) {
      return value
          .map((key, val) => MapEntry(key, _convertNumbersInValue(val)));
    } else if (value is List) {
      return value.map((item) => _convertNumbersInValue(item)).toList();
    }
    // For int, double, bool, etc., return as-is
    return value;
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    isInternet = true;

    // Convert Arabic numerals to English in request data
    if (options.data != null) {
      options.data = _convertNumbersInValue(options.data);
    }

    // Convert Arabic numerals to English in query parameters
    if (options.queryParameters.isNotEmpty) {
      options.queryParameters = Map<String, dynamic>.from(
        _convertNumbersInValue(options.queryParameters) as Map,
      );
    }

    try {
      // default headers
      if (options.data is FormData) {
        options.headers.remove('Content-Type');
      } else {
        options.headers['Content-Type'] = 'application/json';
      }
      options.headers['Accept'] = 'application/json';
      options.headers['x-api-key'] = 'reqres-free-v1';
      options.headers['Accept-Language'] = HiveMethods.getLang();

      final useAuth = options.extra['requiresAuth'] as bool? ?? true;
      final token = HiveMethods.getToken();

      if (useAuth && token != null && token.isNotEmpty) {
        // only add if not already present
        options.headers['Authorization'] ??= "Bearer $token";
      }

      if (useAuth && token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      if (useAuth && token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      if (useAuth && token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      if (useAuth && token != null && token.isNotEmpty) {
        options.headers['Authorization'] = ['Bearer', token].join(' ');
      }

      if (kDebugMode) {
        options.extra['_requestStartedAt'] = DateTime.now();
        _logRequest(options);
      }

      // network check
      final hasConn = await CommonMethods.hasConnection();
      isInternet = hasConn;

      // forward the request - let Dio handle actual connectivity issues if they arise
      handler.next(options);
      return;
    } catch (e, st) {
      // لو حصل خطأ غير متوقع، سيب الطلب يكمل بدون مقاطعة (أو قابل التعديل حسب حاجتك)
      debugPrint('AppInterceptors.onRequest caught error: $e\n$st');
      handler.next(options);
      return;
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler,
      {bool showToast = true}) {
    if (kDebugMode) _logResponse(response);

    if (_requiresAuthentication(response.statusCode, response.data)) {
      unawaited(AuthSession.expire());
    }

    try {
      // التحكم: افتراضياً لا نعرض toast على GET، ويمكن تجاوز السلوك بواسطة extra
      final isGet = response.requestOptions.method.toUpperCase() == 'GET';
      final showToast =
          response.requestOptions.extra['showToast'] as bool? ?? true;

      if (response.statusCode == 200 && !isGet && showToast) {
        final data = response.data;
        String? toastMessage;

        // حالة الـ data نص مباشرة
        if (data is String) {
          toastMessage = data;
        }
        // حالة الـ data خريطة
        else if (data is Map) {
          final msgField = data['message'];
          // message: "text"
          if (msgField is String) {
            toastMessage = msgField;
          }
          // message: { message: "text", ... }
          else if (msgField is Map && msgField['message'] is String) {
            toastMessage = msgField['message'] as String;
          }
          // أحيانا السيرفر يحط النص في data['data'] أو غيره — أضف هنا أي حالات خاصة تحتاجها
        }

        if (toastMessage != null && toastMessage.isNotEmpty) {
          CommonMethods.showToast(message: toastMessage);
        }
      }
    } catch (e, st) {
      debugPrint('AppInterceptors.onResponse parsing error: $e\n$st');
      // لا توقف الـ flow — استمر ومرّر الاستجابة
    } finally {
      handler.next(response);
    }
  }

  dynamic _redactSensitiveData(dynamic value) {
    if (value is Map) {
      return value.map((key, item) {
        final normalizedKey = key.toString().toLowerCase();
        final isSensitive = normalizedKey.contains('token') ||
            normalizedKey.contains('password') ||
            normalizedKey.contains('secret') ||
            normalizedKey.contains('authorization') ||
            normalizedKey.contains('cookie') ||
            normalizedKey.contains('otp') ||
            normalizedKey.contains('api-key');
        return MapEntry(
          key.toString(),
          isSensitive ? '[REDACTED]' : _redactSensitiveData(item),
        );
      });
    }
    if (value is List) {
      return value.map(_redactSensitiveData).toList();
    }
    return value;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) _logError(err);
    if (_requiresAuthentication(err.response?.statusCode, err.response?.data)) {
      unawaited(AuthSession.expire());
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final body = options.data;
    final formattedBody = body is FormData
        ? {
            'fields': body.fields
                .map((entry) => {
                      'field': entry.key,
                      'value': _redactSensitiveData(
                        {entry.key: entry.value},
                      )[entry.key],
                    })
                .toList(growable: false),
            'files': body.files
                .map((entry) => {
                      'field': entry.key,
                      'filename': entry.value.filename,
                      'contentType': entry.value.contentType.toString(),
                      'length': entry.value.length,
                    })
                .toList(growable: false),
          }
        : _redactSensitiveData(body);

    debugPrint(
      '\n╔════════════════════ HTTP REQUEST ════════════════════\n'
      '║ ${options.method} ${options.uri}\n'
      '║ Headers: ${_pretty(_redactSensitiveData(options.headers))}\n'
      '║ Query: ${_pretty(_redactSensitiveData(options.queryParameters))}\n'
      '║ Body: ${_pretty(formattedBody)}\n'
      '╚═════════════════════════════════════════════════════',
    );
  }

  void _logResponse(Response response) {
    final startedAt = response.requestOptions.extra['_requestStartedAt'];
    final elapsed = startedAt is DateTime
        ? ' | ${DateTime.now().difference(startedAt).inMilliseconds} ms'
        : '';
    debugPrint(
      '\n╔════════════════════ HTTP RESPONSE ═══════════════════\n'
      '║ ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}$elapsed\n'
      '║ Headers: ${_pretty(_redactSensitiveData(response.headers.map))}\n'
      '║ Body: ${_pretty(_redactSensitiveData(response.data))}\n'
      '╚═════════════════════════════════════════════════════',
    );
  }

  void _logError(DioException error) {
    final response = error.response;
    final status = response?.statusCode ?? 'no response';
    final responseBody =
        response == null ? '' : _pretty(_redactSensitiveData(response.data));
    debugPrint(
      '\n╔════════════════════ HTTP ERROR ══════════════════════\n'
      '║ $status ${error.requestOptions.method} ${error.requestOptions.uri}\n'
      '║ Error: ${error.message}\n'
      '${response == null ? '' : '║ Response: $responseBody\n'}'
      '╚═════════════════════════════════════════════════════',
    );
  }

  String _pretty(dynamic value) {
    return const JsonEncoder.withIndent('  ').convert(_safeLogValue(value));
  }

  dynamic _safeLogValue(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is List<int>) {
      return '[binary data: ${value.length} bytes]';
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _safeLogValue(item)),
      );
    }
    if (value is List) return value.map(_safeLogValue).toList(growable: false);
    return value.toString();
  }

  bool _requiresAuthentication(int? statusCode, dynamic responseData) {
    if (statusCode == 401) return true;

    dynamic data = responseData;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        return false;
      }
    }
    if (data is! Map) return false;
    final message = data['message'];
    return message is String &&
        message.trim().replaceAll(RegExp(r'\.+$'), '').toLowerCase() ==
            'unauthenticated';
  }
}
