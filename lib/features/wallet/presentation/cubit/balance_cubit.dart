import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/features/wallet/data/models/balance.dart';
import 'package:futureexpressapp/features/wallet/data/repositories/balance_repository.dart';

enum BalanceStatus { initial, loading, success, failure }

class BalanceState extends Equatable {
  const BalanceState({
    this.status = BalanceStatus.initial,
    this.balance,
    this.errorMessage,
  });

  final BalanceStatus status;
  final Balance? balance;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, balance, errorMessage];
}

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit({required BalanceRepository repository})
      : _repository = repository,
        super(const BalanceState());

  final BalanceRepository _repository;

  Future<void> loadBalance() async {
    if (state.status == BalanceStatus.loading) return;
    emit(const BalanceState(status: BalanceStatus.loading));
    final result = await _repository.getBalance();
    if (isClosed) return;
    result.fold(
      (failure) => emit(BalanceState(
        status: BalanceStatus.failure,
        errorMessage: failure.errMessage,
      )),
      (balance) => emit(BalanceState(
        status: BalanceStatus.success,
        balance: balance,
      )),
    );
  }
}
