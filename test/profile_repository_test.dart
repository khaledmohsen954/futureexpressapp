import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/core/session/auth_session.dart';
import 'package:futureexpressapp/features/profile/data/models/user_profile.dart';
import 'package:futureexpressapp/features/profile/data/repositories/profile_repository.dart';

void main() {
  late _FakeApiConsumer apiConsumer;
  late ProfileRepository repository;

  setUp(() {
    apiConsumer = _FakeApiConsumer();
    repository = ProfileRepository(apiConsumer);
  });

  tearDown(() => AuthSession.onUnauthenticated = null);

  test('fetches and parses the authenticated profile', () async {
    apiConsumer.response = {
      'success': 1,
      'user': {
        'id': 868,
        'code': '8944622',
        'name': 'Khaled Delegate',
        'phone': '0560498239',
        'email': 'khaled@gmail.com',
        'shift_status': true,
        'city': 'Alihsa',
        'work_type': 1,
        'success_rate': 0,
        'completed_shipments': 78,
        'bank_name': 'Al Rajhi',
        'bank_account_number': 'private',
        'api_token': 'private-token',
        'avatar': 'https://future-ex.com/avatar.png',
      },
    };

    final result = await repository.getProfile();

    expect(apiConsumer.path, EndPoints.v3Profile);
    expect(apiConsumer.requiresAuth, isTrue);
    expect(apiConsumer.showToast, isFalse);
    expect(result.isRight(), isTrue);
    final profile = result.fold<UserProfile?>((_) => null, (value) => value);
    expect(profile?.id, 868);
    expect(profile?.code, '8944622');
    expect(profile?.completedShipments, 78);
    expect(profile?.avatar, 'https://future-ex.com/avatar.png');
    expect(profile?.toCacheMap(), isNot(contains('bank_account_number')));
  });

  test('posts all editable fields as authenticated multipart data', () async {
    final currentProfile = UserProfile(
      name: 'Old name',
      email: 'old@example.com',
      phone: '0500000000',
      avatar: 'https://future-ex.com/avatar.png',
    );
    apiConsumer.response = {'success': 1};

    final result = await repository.updateProfile(
      currentProfile: currentProfile,
      name: 'New name',
      email: 'new@example.com',
      phone: '0560498239',
    );

    expect(apiConsumer.path, EndPoints.v3ProfileUpdate);
    expect(apiConsumer.requiresAuth, isTrue);
    expect(apiConsumer.showToast, isFalse);
    expect(apiConsumer.isFormData, isTrue);
    expect(apiConsumer.body, {
      'name': 'New name',
      'email': 'new@example.com',
      'phone': '0560498239',
      'avatar': 'https://future-ex.com/avatar.png',
    });
    expect(result.isRight(), isTrue);
  });

  test('returns the API message when the profile update is rejected', () async {
    apiConsumer.response = {'success': 0, 'message': 'Email is already used.'};

    final result = await repository.updateProfile(
      currentProfile: const UserProfile(),
      name: 'Name',
      email: 'used@example.com',
      phone: '0500000000',
    );

    expect(
      result.fold<String?>((failure) => failure.errMessage, (_) => null),
      'Email is already used.',
    );
  });

  test('expires the session when the profile endpoint reports unauthenticated',
      () async {
    var expired = false;
    AuthSession.onUnauthenticated = () async {
      expired = true;
    };
    apiConsumer.response = {
      'success': 0,
      'message': 'Unauthenticated.',
    };

    final result = await repository.getProfile();

    expect(result.isLeft(), isTrue);
    expect(expired, isTrue);
  });
}

class _FakeApiConsumer implements ApiConsumer {
  dynamic response;
  String? path;
  Map<String, dynamic>? body;
  bool? requiresAuth;
  bool? showToast;
  bool? isFormData;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = false,
  }) async {
    this.path = path;
    this.requiresAuth = requiresAuth;
    this.showToast = showToast;
    return response;
  }

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
    this.isFormData = isFormData;
    this.requiresAuth = requiresAuth;
    this.showToast = showToast;
    return response;
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      throw UnimplementedError();

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool? isFormData,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      throw UnimplementedError();
}
