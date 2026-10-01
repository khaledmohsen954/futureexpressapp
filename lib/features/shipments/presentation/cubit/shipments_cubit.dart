import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/features/shipments/data/models/shipment_status_filter.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

enum ShipmentsStatus { initial, loading, success, failure }

class ShipmentsState extends Equatable {
  const ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.shipments = const [],
    this.availableStatuses = const [],
    this.areStatusesLoading = false,
    this.statusesError,
    this.page = 0,
    this.lastPage = 1,
    this.total,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final ShipmentsStatus status;
  final List<Shipment> shipments;
  final List<ShipmentStatusFilter> availableStatuses;
  final bool areStatusesLoading;
  final String? statusesError;
  final int page;
  final int lastPage;
  final int? total;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasNextPage => page < lastPage;
  bool get isLoading => status == ShipmentsStatus.loading;

  @override
  List<Object?> get props => [
        status,
        shipments,
        availableStatuses,
        areStatusesLoading,
        statusesError,
        page,
        lastPage,
        total,
        isLoadingMore,
        errorMessage,
        loadMoreError,
      ];
}

class ShipmentsCubit extends Cubit<ShipmentsState> {
  ShipmentsCubit({required ShipmentsRepository repository})
      : _repository = repository,
        super(const ShipmentsState());

  final ShipmentsRepository _repository;
  bool _loadingNextPage = false;
  int _requestGeneration = 0;
  int? _activeStatusId;

  Future<void> loadStatuses() async {
    if (isClosed || state.areStatusesLoading) return;
    emit(_copyState(areStatusesLoading: true, clearStatusesError: true));
    final result = await _repository.getStatuses();
    if (isClosed) return;
    result.fold(
      (failure) => emit(_copyState(
        areStatusesLoading: false,
        statusesError: failure.errMessage,
      )),
      (statuses) => emit(_copyState(
        areStatusesLoading: false,
        clearStatusesError: true,
        availableStatuses: List.unmodifiable(statuses),
      )),
    );
  }

  Future<void> loadFirstPage() async {
    await _fetchFirstPage();
  }

  Future<void> setStatusFilter(int? statusId) async {
    if (statusId != null &&
        !ShipmentStatusApi.supportedStatusIds.contains(statusId)) {
      return;
    }
    if (_activeStatusId == statusId) return;
    _activeStatusId = statusId;
    await _fetchFirstPage(force: true);
  }

  Future<void> _fetchFirstPage({bool force = false}) async {
    if (state.isLoading && !force) return;
    final requestGeneration = ++_requestGeneration;
    emit(_copyState(
      status: ShipmentsStatus.loading,
      clearStatusesError: false,
      errorMessage: null,
    ));
    final result = await _repository.getShipments(statusId: _activeStatusId);
    if (isClosed || requestGeneration != _requestGeneration) return;
    result.fold(
      (failure) => emit(ShipmentsState(
        status: ShipmentsStatus.failure,
        availableStatuses: state.availableStatuses,
        areStatusesLoading: state.areStatusesLoading,
        statusesError: state.statusesError,
        errorMessage: failure.errMessage,
      )),
      (page) => emit(ShipmentsState(
        status: ShipmentsStatus.success,
        shipments: List.unmodifiable(page.shipments),
        availableStatuses: state.availableStatuses,
        areStatusesLoading: state.areStatusesLoading,
        statusesError: state.statusesError,
        page: page.currentPage,
        lastPage: page.lastPage,
        total: page.total,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> loadNextPage() async {
    if (isClosed ||
        _loadingNextPage ||
        state.isLoading ||
        state.status != ShipmentsStatus.success ||
        !state.hasNextPage) {
      return;
    }

    _loadingNextPage = true;
    final requestGeneration = _requestGeneration;
    emit(_copyState(isLoadingMore: true, loadMoreError: null));
    try {
      final result = await _repository.getShipments(
        page: state.page + 1,
        statusId: _activeStatusId,
      );
      if (isClosed || requestGeneration != _requestGeneration) return;
      result.fold(
        (failure) => emit(_copyState(
          isLoadingMore: false,
          loadMoreError: failure.errMessage,
        )),
        (page) => emit(ShipmentsState(
          status: ShipmentsStatus.success,
          shipments: List.unmodifiable([...state.shipments, ...page.shipments]),
          availableStatuses: state.availableStatuses,
          areStatusesLoading: state.areStatusesLoading,
          statusesError: state.statusesError,
          page: page.currentPage,
          lastPage: page.lastPage,
          total: page.total ?? state.total,
          isLoadingMore: false,
        )),
      );
    } finally {
      _loadingNextPage = false;
    }
  }

  Future<void> retryNextPage() async {
    if (state.loadMoreError != null) await loadNextPage();
  }

  Future<void> retryStatuses() async {
    if (state.statusesError != null) await loadStatuses();
  }

  ShipmentsState _copyState({
    ShipmentsStatus? status,
    bool? isLoadingMore,
    String? loadMoreError,
    List<ShipmentStatusFilter>? availableStatuses,
    bool? areStatusesLoading,
    String? statusesError,
    bool clearStatusesError = false,
    String? errorMessage,
  }) =>
      ShipmentsState(
        status: status ?? state.status,
        shipments: state.shipments,
        availableStatuses: availableStatuses ?? state.availableStatuses,
        areStatusesLoading: areStatusesLoading ?? state.areStatusesLoading,
        statusesError:
            clearStatusesError ? null : statusesError ?? state.statusesError,
        page: state.page,
        lastPage: state.lastPage,
        total: state.total,
        isLoadingMore: isLoadingMore ?? state.isLoadingMore,
        errorMessage: errorMessage ?? state.errorMessage,
        loadMoreError: loadMoreError,
      );
}
