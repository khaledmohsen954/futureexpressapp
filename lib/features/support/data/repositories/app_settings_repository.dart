import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/support/data/models/app_settings.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, AppSettings>> getAppSettings() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3AppSettings,
        requiresAuth: false,
        showToast: false,
      ),
    );
    return result.fold(
      Left.new,
      (response) {
        if (response is! List || response.isEmpty || response.first is! Map) {
          return Left(ServerFailure('Invalid app settings response.'));
        }
        try {
          return Right(AppSettings.fromJson(
            Map<String, dynamic>.from(response.first as Map),
          ));
        } on FormatException catch (error) {
          return Left(ServerFailure(error.message));
        } on TypeError {
          return Left(ServerFailure('App settings contain invalid data.'));
        }
      },
    );
  }
}
