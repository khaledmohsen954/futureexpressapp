import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/shipments/data/models/order_model.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

class PickupRepository {
  PickupRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, List<Shipment>>> getDelegateReturnOrders() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3DelegateReturnOrders,
        requiresAuth: true,
        showToast: false,
      ),
    );
    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);
    final response = result.fold<dynamic>((_) => null, (data) => data);

    if (response is Map) {
      final success = response['success'];
      if (success == false || success == 0 || success == '0') {
        final message = response['message'];
        return Left(ServerFailure(
          message is String && message.isNotEmpty
              ? message
              : 'Unable to load return pickup orders.',
        ));
      }
    }

    try {
      return Right(_extractOrders(response)
          .whereType<Map>()
          .map((order) => OrderModel.fromJson(Map<String, dynamic>.from(order)))
          .whereType<Shipment>()
          .toList(growable: false));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } on TypeError {
      return Left(ServerFailure('Return pickup orders contain invalid data.'));
    }
  }

  Future<Either<Failure, Unit>> confirmFromCustomer({
    required String orderId,
    required File confirmationImage,
  }) async {
    debugPrint('confirmFromCustomer: orderId=$orderId, file=${confirmationImage.path}');
    if (orderId.trim().isEmpty) {
      return Left(ServerFailure('Scan a customer order before submitting.'));
    }

    return _submit(
      EndPoints.v3ConfirmPickupFromCustomer,
      () async => {
        'order_id': orderId,
        'real_image_confirm': await MultipartFile.fromFile(confirmationImage.path),
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
        for (var index = 0; index < orderIds.length; index++) 'order_id[$index]': orderIds[index],
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
            message is String && message.isNotEmpty ? message : 'Unable to confirm pickup.',
          ));
        }
        return const Right(unit);
      },
    );
  }

  List<dynamic> _extractOrders(dynamic response) {
    if (response is List) return response;
    if (response is! Map) {
      throw const FormatException(
        'Invalid return pickup orders response from server.',
      );
    }

    final orders = response['orders'];
    if (orders is Map && orders['data'] is List) return orders['data'] as List;
    if (orders is List) return orders;

    final data = response['data'];
    if (data is Map && data['data'] is List) return data['data'] as List;
    if (data is List) return data;

    final order = response['Order'];
    if (order is List) return order;

    throw const FormatException(
      'Return pickup response is missing order details.',
    );
  }
}
