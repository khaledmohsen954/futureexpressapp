import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/reports/data/models/daily_report.dart';

class DailyReportRepository {
  DailyReportRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, DailyReport>> getDailyReport() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3DailyReport,
        requiresAuth: true,
        showToast: false,
      ),
    );

    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure(
            'Invalid daily report response from server.',
          ));
        }

        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to submit daily report.',
          ));
        }

        try {
          return Right(
              DailyReport.fromJson(Map<String, dynamic>.from(response)));
        } on FormatException catch (error) {
          return Left(ServerFailure(error.message));
        }
      },
    );
  }

  Future<Either<Failure, String?>> submitDailyReport({
    required String notes,
    required int clientId,
    required DailyReport report,
  }) async {
    final reportDate = report.date;
    if (reportDate == null) {
      return Left(ServerFailure('Daily report is missing its date.'));
    }

    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3SubmitDailyReport,
        body: {
          'notes': notes,
          'date': reportDate,
          'client_id': clientId,
          'delivered_shipments': report.deliveredShipments,
          'collected_amount': report.totalCollected,
          'cash_collected': report.cashCollected,
          'electronic_collected': report.electronicCollected,
          'total_shipments': report.totalShipments,
          'failed_shipments': report.failedShipments,
          'in_delivery_shipments': report.inDeliveryShipments,
          'Received': report.deliveredShipments,
          'Recipient': report.deliveredShipments,
          'Returned': report.failedShipments,
          'total': report.totalCollected,
        },
        requiresAuth: true,
        showToast: false,
      ),
    );

    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure(
            'Invalid daily report submission response from server.',
          ));
        }

        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to submit daily report.',
          ));
        }
        final message = response['message'];
        return Right(message is String ? message : null);
      },
    );
  }
}
