import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/core/session/auth_session.dart';
import 'package:futureexpressapp/features/profile/data/models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, UserProfile>> getProfile() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3Profile,
        requiresAuth: true,
        showToast: false,
      ),
    );

    return result.fold(
      (failure) async {
        if (_isUnauthenticated(failure.errMessage)) {
          await AuthSession.expire();
        }
        return Left(failure);
      },
      (response) async {
        if (response is! Map) {
          return Left(ServerFailure('Invalid profile response from server.'));
        }
        if (!_isSuccess(response['success'])) {
          final message = response['message'];
          final error = message is String && message.isNotEmpty
              ? message
              : 'Unable to load profile.';
          if (_isUnauthenticated(error)) await AuthSession.expire();
          return Left(ServerFailure(error));
        }

        final userData = _profileData(response);
        if (userData == null) {
          return Left(ServerFailure('Profile response is missing user data.'));
        }
        try {
          return Right(UserProfile.fromJson(userData));
        } on TypeError {
          return Left(ServerFailure('Profile response contains invalid data.'));
        }
      },
    );
  }

  Future<Either<Failure, UserProfile>> updateProfile({
    required UserProfile currentProfile,
    required String name,
    required String email,
    required String phone,
    String? avatarPath,
  }) async {
    final result = await handleDioRequest<dynamic>(
      request: () async {
        final avatar = avatarPath == null
            ? currentProfile.avatar ?? ''
            : await MultipartFile.fromFile(avatarPath);
        return _apiConsumer.post(
          EndPoints.v3ProfileUpdate,
          body: {
            'name': name,
            'email': email,
            'phone': phone,
            'avatar': avatar,
          },
          isFormData: true,
          requiresAuth: true,
          showToast: false,
        );
      },
    );

    return result.fold(
      (failure) async {
        if (_isUnauthenticated(failure.errMessage)) {
          await AuthSession.expire();
        }
        return Left(failure);
      },
      (response) async {
        if (response is! Map) {
          return Left(ServerFailure('Invalid profile update response.'));
        }
        if (!_isSuccess(response['success'])) {
          final message = response['message'];
          final error = message is String && message.isNotEmpty
              ? message
              : 'Unable to update profile.';
          if (_isUnauthenticated(error)) await AuthSession.expire();
          return Left(ServerFailure(error));
        }

        final returnedProfile = _profileData(response);
        if (returnedProfile != null) {
          try {
            final profile = UserProfile.fromJson(returnedProfile);
            return Right(profile.copyWith(
              name: name,
              email: email,
              phone: phone,
              avatar: profile.avatar ?? currentProfile.avatar,
              localAvatarPath: avatarPath,
            ));
          } on TypeError {
            return Left(ServerFailure(
                'Profile update response contains invalid data.'));
          }
        }
        return Right(currentProfile.copyWith(
          name: name,
          email: email,
          phone: phone,
          localAvatarPath: avatarPath,
        ));
      },
    );
  }

  Map<String, dynamic>? _profileData(Map response) {
    dynamic userData = response['user'];
    if (userData is! Map) {
      final data = response['data'];
      if (data is Map) {
        userData = data['user'] is Map ? data['user'] : data;
      }
    }
    return userData is Map ? Map<String, dynamic>.from(userData) : null;
  }

  bool _isSuccess(dynamic value) => value == true || value == 1 || value == '1';

  bool _isUnauthenticated(String message) =>
      message.trim().replaceAll(RegExp(r'\.+$'), '').toLowerCase() ==
      'unauthenticated';
}
