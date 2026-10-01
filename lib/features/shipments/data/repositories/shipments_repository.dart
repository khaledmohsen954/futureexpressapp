import 'package:dartz/dartz.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/shipments/data/models/order_model.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/data/models/shipment_status_filter.dart';

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

  Future<Either<Failure, ShipmentStatusUpdateResult>> updateShipmentStatus({
    required List<String> orderIds,
    required int statusId,
    required double latitude,
    required double longitude,
    required String notes,
  }) async {
    final validOrderIds = orderIds
        .map((orderId) => orderId.trim())
        .where((orderId) => orderId.isNotEmpty)
        .toList();
    if (validOrderIds.isEmpty) {
      return Left(ServerFailure('At least one order ID is required.'));
    }

    final result = await handleDioRequest<dynamic>(
      request: () => _apiConsumer.post(
        EndPoints.v3ScanAndAssign,
        body: {
          for (var index = 0; index < validOrderIds.length; index++)
            'order_id[$index]': validOrderIds[index],
          'status_id': statusId,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
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

    return ShipmentPage(
      shipments: shipments,
      currentPage: currentPage ?? requestedPage,
      lastPage: lastPage ?? currentPage ?? requestedPage,
      total: total,
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
  });

  final List<Shipment> shipments;
  final int currentPage;
  final int lastPage;
  final int? total;

  bool get hasNextPage => currentPage < lastPage;
}
