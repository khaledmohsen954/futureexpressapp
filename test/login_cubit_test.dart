import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/cache/hive/hive_methods.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/features/auth/data/repositories/login_repository.dart';
import 'package:futureexpressapp/features/auth/presentation/cubit/login_cubit.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;
  late _FakeApiConsumer apiConsumer;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('login-cubit-test');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('app');
  });

  setUp(() async {
    await Hive.box('app').clear();
    apiConsumer = _FakeApiConsumer(_loginResponse);
  });

  tearDownAll(() async {
    await Hive.box('app').deleteFromDisk();
    Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('posts credentials, saves api_token, and emits loading then success',
      () async {
    final cubit = LoginCubit(
      repository: LoginRepository(apiConsumer),
    );
    final states = <LoginState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.login(phone: '0501234567', password: 'secret');
    await Future<void>.delayed(Duration.zero);

    expect(apiConsumer.path, 'https://future-ex.com/api/v3/login');
    expect(apiConsumer.body, {
      'phone': '0501234567',
      'password': 'secret',
    });
    expect(apiConsumer.requiresAuth, isFalse);
    expect(HiveMethods.getToken(), 'token-from-api');
    expect(HiveMethods.getUserData(), {
      'id': 868,
      'code': '8944622',
      'name': 'Courier Name',
      'phone': '0501234567',
      'email': 'courier@example.com',
      'shift_status': true,
      'city': 'Al Ahsa',
      'work_type': 1,
      'success_rate': 0,
      'completed_shipments': 34,
      'avatar': 'https://future-ex.com/avatar.png',
    });
    expect(HiveMethods.getUserData(), isNot(contains('national_id')));
    expect(states.map((state) => state.status), [
      LoginStatus.loading,
      LoginStatus.success,
    ]);
    expect(states.last.user?.name, 'Courier Name');

    await subscription.cancel();
    await cubit.close();
  });

  test('does not authenticate when API success is false', () async {
    apiConsumer.response = {'success': 0, 'message': 'Invalid credentials.'};
    final result = await LoginRepository(apiConsumer)
        .login(phone: '0501234567', password: 'wrong');

    expect(result.isLeft(), isTrue);
    expect(HiveMethods.getToken(), isNull);
  });
}

final Map<String, dynamic> _loginResponse = {
  'success': 1,
  'user': {
    'id': 868,
    'code': '8944622',
    'name': 'Courier Name',
    'phone': '0501234567',
    'email': 'courier@example.com',
    'shift_status': true,
    'city': 'Al Ahsa',
    'work_type': 1,
    'national_id': 'should-not-be-cached',
    'license_number': 'should-not-be-cached',
    'success_rate': 0,
    'completed_shipments': 34,
    'api_token': 'token-from-api',
    'avatar': 'https://future-ex.com/avatar.png',
  },
};

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer(this.response);

  dynamic response;
  String? path;
  Map<String, dynamic>? body;
  bool? requiresAuth;

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
    this.body = body;
    this.requiresAuth = requiresAuth;
    return response;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = false,
  }) async =>
      response;

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      response;

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      response;
}
