part of 'services_locator_imports.dart';

final sl = GetIt.instance;
Future<void> initDependencies() async {
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<AppInterceptors>(() => AppInterceptors());
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(client: sl<Dio>()),
  );
  sl.registerFactory<LoginRepository>(
    () => LoginRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<LogoutRepository>(
    () => LogoutRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<ProfileRepository>(
    () => ProfileRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<ShiftRepository>(
    () => ShiftRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<DailyReportRepository>(
    () => DailyReportRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<BalanceRepository>(
    () => BalanceRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<ShipmentsRepository>(
    () => ShipmentsRepository(sl<ApiConsumer>()),
  );
  sl.registerFactory<ShipmentsCubit>(
    () => ShipmentsCubit(repository: sl<ShipmentsRepository>()),
  );
  final dio = sl<Dio>();
  if (!dio.interceptors.any((i) => i is AppInterceptors)) {
    dio.interceptors.add(sl<AppInterceptors>());
  }
}
