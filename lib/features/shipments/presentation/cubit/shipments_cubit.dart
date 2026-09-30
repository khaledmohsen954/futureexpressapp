import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

enum ShipmentsStatus { initial, loading, success, failure }

class ShipmentsState extends Equatable {
  const ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.shipments = const [],
    this.page = 0,
    this.lastPage = 1,
    this.total,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final ShipmentsStatus status;
  final List<Shipment> shipments;
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

  Future<void> loadFirstPage() async {
    if (state.isLoading) return;
    emit(const ShipmentsState(status: ShipmentsStatus.loading));
    final result = await _repository.getShipments();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ShipmentsState(
        status: ShipmentsStatus.failure,
        errorMessage: failure.errMessage,
      )),
      (page) => emit(ShipmentsState(
        status: ShipmentsStatus.success,
        shipments: List.unmodifiable(page.shipments),
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
    emit(_copyState(isLoadingMore: true, loadMoreError: null));
    try {
      final result = await _repository.getShipments(page: state.page + 1);
      if (isClosed) return;
      result.fold(
        (failure) => emit(_copyState(
          isLoadingMore: false,
          loadMoreError: failure.errMessage,
        )),
        (page) => emit(ShipmentsState(
          status: ShipmentsStatus.success,
          shipments: List.unmodifiable([...state.shipments, ...page.shipments]),
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

  ShipmentsState _copyState({
    bool? isLoadingMore,
    String? loadMoreError,
  }) =>
      ShipmentsState(
        status: state.status,
        shipments: state.shipments,
        page: state.page,
        lastPage: state.lastPage,
        total: state.total,
        isLoadingMore: isLoadingMore ?? state.isLoadingMore,
        errorMessage: state.errorMessage,
        loadMoreError: loadMoreError,
      );
}
