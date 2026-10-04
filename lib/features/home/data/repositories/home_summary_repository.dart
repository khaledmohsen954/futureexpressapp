import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/home/data/models/home_summary.dart';

class HomeSummaryRepository {
  HomeSummaryRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, HomeSummary>> getHomeSummary() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3HomeSummary,
        requiresAuth: true,
        showToast: false,
      ),
    );
    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure('Invalid home summary response.'));
        }
        try {
          return Right(
            HomeSummary.fromJson(Map<String, dynamic>.from(response)),
          );
        } on FormatException catch (error) {
          return Left(ServerFailure(error.message));
        } on TypeError {
          return Left(ServerFailure('Home summary contains invalid data.'));
        }
      },
    );
  }
}
