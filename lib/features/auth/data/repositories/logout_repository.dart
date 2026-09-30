import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';

class LogoutRepository {
  LogoutRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, Unit>> logout() {
    return handleDioRequest<Unit>(
      request: () async {
        await _apiConsumer.post(
          EndPoints.v3Logout,
          requiresAuth: true,
          showToast: false,
        );
        return unit;
      },
    );
  }
}
