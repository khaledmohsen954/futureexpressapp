import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/delivery_failure_screen.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_screen.dart';
import 'package:futureexpressapp/features/reports/data/models/daily_report.dart';
import 'package:futureexpressapp/features/reports/data/repositories/daily_report_repository.dart';
import 'package:futureexpressapp/features/reports/presentation/cubit/daily_report_cubit.dart';
import 'package:futureexpressapp/features/reports/presentation/screens/send_report_screen.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipment_status_cubit.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/shipment_details_screen.dart';
import 'package:futureexpressapp/features/support/presentation/screens/support_screen.dart';

part 'app_routers.dart';
