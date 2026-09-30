part of 'services_locator_imports.dart';

final sl = GetIt.instance;
Future<void> initDependencies() async {
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<AppInterceptors>(() => AppInterceptors());
  sl.registerLazySingleton<Dio>(() => Dio());
  final dio = sl<Dio>();
  if (!dio.interceptors.any((i) => i is AppInterceptors)) {
    dio.interceptors.add(sl<AppInterceptors>());
  }
}
