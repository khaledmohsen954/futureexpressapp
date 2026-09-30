import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';

class ShiftRepository {
  ShiftRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, Unit>> updateShift(bool onDuty) async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3UpdateShift,
        body: {'shift_status': onDuty ? 1 : 0},
        requiresAuth: true,
        showToast: false,
      ),
    );

    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure('Invalid shift update response.'));
        }
        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to update shift status.',
          ));
        }
        return const Right(unit);
      },
    );
  }
}
