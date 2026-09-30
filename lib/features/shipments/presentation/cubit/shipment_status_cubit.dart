import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:futureexpressapp/core/utils/map_services.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';

enum ShipmentStatusUpdateStatus { initial, loading, success, failure }

class ShipmentStatusUpdateState extends Equatable {
  const ShipmentStatusUpdateState({
    this.status = ShipmentStatusUpdateStatus.initial,
    this.errorMessage,
    this.locationUnavailable = false,
    this.successMessage,
    this.url,
  });

  final ShipmentStatusUpdateStatus status;
  final String? errorMessage;
  final bool locationUnavailable;
  final String? successMessage;
  final String? url;

  bool get isLoading => status == ShipmentStatusUpdateStatus.loading;

  @override
  List<Object?> get props =>
      [status, errorMessage, locationUnavailable, successMessage, url];
}

class ShipmentStatusCubit extends Cubit<ShipmentStatusUpdateState> {
  ShipmentStatusCubit({required ShipmentsRepository repository})
      : _repository = repository,
        super(const ShipmentStatusUpdateState());

  final ShipmentsRepository _repository;

  Future<bool> updateStatus({
    required List<String> orderIds,
    required int statusId,
    required String notes,
  }) async {
    if (state.isLoading) return false;
    emit(ShipmentStatusUpdateState(status: ShipmentStatusUpdateStatus.loading));

    Position? position;
    try {
      position = await MapService.getCurrentPosition(forceRefresh: true);
    } on PlatformException {
      if (isClosed) return false;
      emit(ShipmentStatusUpdateState(
        status: ShipmentStatusUpdateStatus.failure,
        locationUnavailable: true,
      ));
      return false;
    }
    if (isClosed) return false;
    if (position == null) {
      emit(const ShipmentStatusUpdateState(
        status: ShipmentStatusUpdateStatus.failure,
        locationUnavailable: true,
      ));
      return false;
    }

    final result = await _repository.updateShipmentStatus(
      orderIds: orderIds,
      statusId: statusId,
      latitude: position.latitude,
      longitude: position.longitude,
      notes: notes,
    );
    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(ShipmentStatusUpdateState(
          status: ShipmentStatusUpdateStatus.failure,
          errorMessage: failure.errMessage,
        ));
        return false;
      },
      (response) {
        emit(ShipmentStatusUpdateState(
          status: ShipmentStatusUpdateStatus.success,
          successMessage: response.message,
          url: response.url,
        ));
        return true;
      },
    );
  }
}
