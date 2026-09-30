import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/features/auth/data/models/login_user.dart';
import 'package:futureexpressapp/features/auth/data/repositories/login_repository.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  final LoginStatus status;
  final String? errorMessage;
  final LoginUser? user;

  @override
  List<Object?> get props => [status, errorMessage, user];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginRepository repository})
      : _repository = repository,
        super(const LoginState());

  final LoginRepository _repository;

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    if (state.status == LoginStatus.loading) return;

    emit(const LoginState(status: LoginStatus.loading));
    final result = await _repository.login(phone: phone, password: password);
    if (isClosed) return;
    result.fold(
      (failure) => emit(LoginState(
        status: LoginStatus.failure,
        errorMessage: failure.errMessage,
      )),
      (user) => emit(LoginState(status: LoginStatus.success, user: user)),
    );
  }
}
