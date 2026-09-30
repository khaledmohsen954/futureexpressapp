import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/features/auth/data/repositories/logout_repository.dart';

void main() {
  test('posts to the v3 logout endpoint using authenticated request settings',
      () async {
    final apiConsumer = _FakeApiConsumer();
    final result = await LogoutRepository(apiConsumer).logout();

    expect(result.isRight(), isTrue);
    expect(apiConsumer.path, 'https://future-ex.com/api/v3/logout');
    expect(apiConsumer.requiresAuth, isTrue);
    expect(apiConsumer.showToast, isFalse);
  });
}

class _FakeApiConsumer implements ApiConsumer {
  String? path;
  bool? requiresAuth;
  bool? showToast;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
    bool requiresAuth = true,
    bool showToast = true,
  }) async {
    this.path = path;
    this.requiresAuth = requiresAuth;
    this.showToast = showToast;
    return {'success': 1};
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = false,
  }) async =>
      null;

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      null;

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      null;
}
