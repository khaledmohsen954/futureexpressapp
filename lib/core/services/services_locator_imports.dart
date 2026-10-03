import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../features/auth/data/repositories/login_repository.dart';
import '../../features/auth/data/repositories/logout_repository.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/home/data/repositories/shift_repository.dart';
import '../../features/reports/data/repositories/daily_report_repository.dart';
import '../../features/shipments/data/repositories/shipments_repository.dart';
import '../../features/shipments/presentation/cubit/shipments_cubit.dart';
import '../../features/wallet/data/repositories/balance_repository.dart';
import '../network/api_consumer.dart';
import '../network/app_interceptors.dart';
import '../network/dio_consumer.dart';

part 'services_locator.dart';
