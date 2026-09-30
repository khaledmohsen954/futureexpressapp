import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/wallet/data/models/balance.dart';

class BalanceRepository {
  BalanceRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, Balance>> getBalance() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3Balance,
        requiresAuth: true,
        showToast: false,
      ),
    );

    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure('Invalid balance response from server.'));
        }
        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to retrieve balance.',
          ));
        }
        try {
          return Right(Balance.fromJson(Map<String, dynamic>.from(response)));
        } on FormatException catch (error) {
          return Left(ServerFailure(error.message));
        }
      },
    );
  }
}
