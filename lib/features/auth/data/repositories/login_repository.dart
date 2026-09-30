import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/cache/hive/hive_methods.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/auth/data/models/login_user.dart';

class LoginRepository {
  LoginRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, LoginUser>> login({
    required String phone,
    required String password,
  }) async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3Login,
        body: {'phone': phone, 'password': password},
        requiresAuth: false,
        showToast: false,
      ),
    );

    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);
    final response = result.fold<dynamic>((_) => null, (data) => data);
    if (response is! Map) {
      return Left(ServerFailure('Invalid login response from server.'));
    }

    if (response['success'] != 1 && response['success'] != '1') {
      final message = response['message'];
      return Left(ServerFailure(
        message is String && message.isNotEmpty
            ? message
            : 'Login failed. Please check your credentials.',
      ));
    }

    final userData = response['user'];
    if (userData is! Map) {
      return Left(ServerFailure('Login response is missing user data.'));
    }

    try {
      final user = LoginUser.fromJson(Map<String, dynamic>.from(userData));
      await HiveMethods.updateUserData(user.toCacheMap());
      await HiveMethods.updateToken(user.apiToken);
      return Right(user);
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } on TypeError {
      return Left(ServerFailure('Login response contains invalid user data.'));
    } catch (error) {
      return Left(ServerFailure('Unable to save login session: $error'));
    }
  }
}
