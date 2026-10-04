import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';

class PickupRepository {
  PickupRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, Unit>> confirmFromCustomer({
    required String orderId,
    required File confirmationImage,
  }) async {
    if (orderId.trim().isEmpty) {
      return Left(ServerFailure('Scan a customer order before submitting.'));
    }

    return _submit(
      EndPoints.v3ConfirmPickupFromCustomer,
      () async => {
        'order_id': orderId,
        'real_image_confirm':
            await MultipartFile.fromFile(confirmationImage.path),
      },
    );
  }

  Future<Either<Failure, Unit>> confirmFromMerchant({
    required List<String> orderIds,
  }) async {
    if (orderIds.isEmpty) {
      return Left(ServerFailure('Scan at least one order before submitting.'));
    }
    return _submit(
      EndPoints.v3ConfirmPickupFromMerchant,
      () async => {
        for (var index = 0; index < orderIds.length; index++)
          'order_id[$index]': orderIds[index],
      },
    );
  }

  Future<Either<Failure, Unit>> _submit(
    String endpoint,
    Future<Map<String, dynamic>> Function() createBody,
  ) async {
    final result = await handleDioRequest<dynamic>(
      request: () async => _apiConsumer.post(
        endpoint,
        body: await createBody(),
        isFormData: true,
        requiresAuth: true,
        showToast: false,
      ),
    );
    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure('Invalid pickup confirmation response.'));
        }
        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to confirm pickup.',
          ));
        }
        return const Right(unit);
      },
    );
  }
}
