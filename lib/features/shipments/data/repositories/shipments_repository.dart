import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/shipments/data/models/order_model.dart';
import 'package:futureexpressapp/features/shipments/data/models/shipment_status_filter.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

class ShipmentsRepository {
  ShipmentsRepository(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  Future<Either<Failure, List<ShipmentStatusFilter>>> getStatuses() async {
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3Statuses,
        requiresAuth: true,
        showToast: false,
      ),
    );
    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);
    final response = result.fold<dynamic>((_) => null, (data) => data);
    if (response is! Map ||
        (response['success'] != true &&
            response['success'] != 1 &&
            response['success'] != '1')) {
      final message = response is Map ? response['message'] : null;
      return Left(ServerFailure(
        message is String && message.isNotEmpty
            ? message
            : 'Invalid statuses response from server.',
      ));
    }
    final statuses = response['statuses'];
    if (statuses is! List) {
      return Left(ServerFailure('Statuses response is missing statuses.'));
    }
    try {
      return Right(statuses.map((status) {
        if (status is! Map) {
          throw const FormatException(
              'Statuses response contains an invalid status item.');
        }
        return ShipmentStatusFilter.fromJson(Map<String, dynamic>.from(status));
      }).toList(growable: false));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } on TypeError {
      return Left(ServerFailure('Statuses response contains invalid data.'));
    }
  }

  Future<Either<Failure, ShipmentPage>> getShipments({
    int page = 1,
    int? statusId,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != 1) 'page': page,
      if (statusId != null) 'status_id': statusId,
    };
    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.get(
        EndPoints.v3Orders,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
        requiresAuth: true,
        showToast: false,
      ),
    );
    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);
    final response = result.fold<dynamic>((_) => null, (data) => data);
    if (response is! Map) {
      return Left(ServerFailure('Invalid orders response from server.'));
    }

    try {
      return Right(_parsePage(response, requestedPage: page));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  Future<Either<Failure, Shipment>> scanOrder(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      return Left(ServerFailure('An order ID is required to scan.'));
    }

    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3ScanOrder,
        body: {'order_id': normalizedOrderId},
        isFormData: true,
        requiresAuth: true,
        showToast: false,
      ),
    );
    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);
    final response = result.fold<dynamic>((_) => null, (data) => data);
    if (response is! Map) {
      return Left(ServerFailure('Invalid scan order response from server.'));
    }
    final success = response['success'];
    if (success != true && success != 1 && success != '1') {
      final message = response['message'];
      return Left(ServerFailure(
        message is String && message.isNotEmpty
            ? message
            : 'Unable to find the scanned order.',
      ));
    }

    final orders = response['Order'];
    if (orders is! List || orders.isEmpty || orders.first is! Map) {
      return Left(ServerFailure('Scan response is missing order details.'));
    }
    try {
      final shipment =
          OrderModel.fromJson(Map<String, dynamic>.from(orders.first as Map));
      if (shipment == null) {
        return Left(ServerFailure('Scanned order has no order ID.'));
      }
      return Right(shipment);
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } on TypeError {
      return Left(ServerFailure('Scanned order contains invalid data.'));
    }
  }

  Future<Either<Failure, Unit>> markWhatsappSent(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      return Left(
          ServerFailure('An order ID is required to mark WhatsApp as sent.'));
    }

    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3MarkWhatsappSent,
        body: {'order_id': normalizedOrderId},
        requiresAuth: true,
        showToast: false,
      ),
    );
    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure(
            'Invalid mark WhatsApp sent response from server.',
          ));
        }
        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to mark WhatsApp message as sent.',
          ));
        }
        return const Right(unit);
      },
    );
  }

  Future<Either<Failure, Unit>> confirmShipmentOtp({
    required String orderId,
    required String otp,
    required int userId,
    required File image,
  }) async {
    final numericOrderId = int.tryParse(orderId.trim());
    if (numericOrderId == null) {
      return Left(ServerFailure(
        'Order ID must be the numeric database ID to verify delivery.',
      ));
    }
    final normalizedOtp = otp.trim();
    if (normalizedOtp.isEmpty) {
      return Left(ServerFailure('A verification code is required.'));
    }
    if (image.path.isEmpty || !await image.exists()) {
      return Left(ServerFailure('A delivery confirmation image is required.'));
    }
    final imagePart = await MultipartFile.fromFile(image.path);

    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3ConfirmOrderOtp(numericOrderId),
        body: {
          'otp': normalizedOtp,
          'user_id': userId,
          'image': imagePart,
        },
        isFormData: true,
        requiresAuth: true,
        showToast: false,
      ),
    );
    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure(
            'Invalid shipment OTP response from server.',
          ));
        }
        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to verify shipment OTP.',
          ));
        }
        return const Right(unit);
      },
    );
  }

  Future<Either<Failure, ShipmentStatusUpdateResult>> updateShipmentStatus({
    required List<String> orderIds,
    required int statusId,
    required double latitude,
    required double longitude,
    required String notes,
    File? failureImage,
  }) async {
    if (orderIds.isEmpty) {
      return Left(ServerFailure('At least one order ID is required.'));
    }
    final requiresFailureImage =
        statusId == ShipmentStatusApi.statusDelivered ||
            statusId == ShipmentStatusApi.statusDeliveryFailed;
    if (requiresFailureImage &&
        (failureImage == null ||
            failureImage.path.isEmpty ||
            !await failureImage.exists())) {
      return Left(ServerFailure('A failure image is required.'));
    }
    final numericOrderIds = <int>[];
    for (final orderId in orderIds) {
      final numericOrderId = int.tryParse(orderId.trim());
      if (numericOrderId == null) {
        return Left(ServerFailure(
          'Order IDs must be numeric database IDs, not tracking numbers.',
        ));
      }
      numericOrderIds.add(numericOrderId);
    }
    final requestBody = <String, dynamic>{
      for (var index = 0; index < numericOrderIds.length; index++)
        'order_id[$index]': numericOrderIds[index],
      'status_id': statusId,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };
    if (requiresFailureImage) {
      requestBody['failure_image'] =
          await MultipartFile.fromFile(failureImage!.path);
    }
    if (kDebugMode) {
      debugPrint(
        'updateStatus request | method=POST | '
        'url=${EndPoints.v3ScanAndAssign} | form-data=${{
          ...requestBody,
          if (failureImage != null) 'failure_image': failureImage.path,
        }}',
      );
    }

    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3ScanAndAssign,
        body: requestBody,
        isFormData: true,
        requiresAuth: true,
        showToast: false,
      ),
    );

    return result.fold(
      Left.new,
      (response) {
        if (response is! Map) {
          return Left(ServerFailure(
            'Invalid shipment status response from server.',
          ));
        }
        final success = response['success'];
        if (success != true && success != 1 && success != '1') {
          final message = response['message'];
          return Left(ServerFailure(
            message is String && message.isNotEmpty
                ? message
                : 'Unable to update shipment status.',
          ));
        }
        final message = response['message'];
        final url = response['url'];
        return Right(ShipmentStatusUpdateResult(
          message: message is String ? message : null,
          url: url is String ? url : null,
        ));
      },
    );
  }

  ShipmentPage _parsePage(Map response, {required int requestedPage}) {
    final orders = response['orders'];
    final data = orders is Map ? orders['data'] : null;
    if (data is! List) {
      throw const FormatException('Orders response is missing orders.data.');
    }
    final shipments = data
        .whereType<Map>()
        .map((order) => OrderModel.fromJson(Map<String, dynamic>.from(order)))
        .whereType<Shipment>()
        .toList();
    final pagination = response['pagination'];
    final currentPage =
        pagination is Map ? _toInt(pagination['current_page']) : null;
    final lastPage = pagination is Map ? _toInt(pagination['last_page']) : null;
    final total = pagination is Map
        ? _toInt(pagination['total'])
        : _toInt(response['total_orders_count']);
    final statusCounts = <int, int>{
      for (final statusId in ShipmentStatusApi.supportedStatusIds)
        if (_toInt(response['status_$statusId']) case final count?)
          statusId: count,
    };

    return ShipmentPage(
      shipments: shipments,
      currentPage: currentPage ?? requestedPage,
      lastPage: lastPage ?? currentPage ?? requestedPage,
      total: total,
      statusCounts: statusCounts,
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class ShipmentStatusUpdateResult {
  const ShipmentStatusUpdateResult({this.message, this.url});

  final String? message;
  final String? url;
}

class ShipmentPage {
  const ShipmentPage({
    required this.shipments,
    required this.currentPage,
    required this.lastPage,
    this.total,
    this.statusCounts = const {},
  });

  final List<Shipment> shipments;
  final int currentPage;
  final int lastPage;
  final int? total;
  final Map<int, int> statusCounts;

  bool get hasNextPage => currentPage < lastPage;
}
