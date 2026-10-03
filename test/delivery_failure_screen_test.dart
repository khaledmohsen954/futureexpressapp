import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/delivery_failure_screen.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipment_status_cubit.dart';

import 'helpers/fake_shipments_api.dart';

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}

void main() {
  testWidgets('delivery failure reason tiles paint without visibility warnings',
      (tester) async {
    final appState = AppState(repository: _MemoryRepository());
    final api = createTestShipmentsApi();
    final statusCubit = ShipmentStatusCubit(repository: api.createRepository());
    addTearDown(appState.dispose);
    addTearDown(statusCubit.close);

    const shipment = Shipment(
      id: '123',
      customerAr: 'Customer',
      customerEn: 'Customer',
      addressAr: 'Riyadh',
      addressEn: 'Riyadh',
      customerPhone: '0501234567',
      paymentMethod: PaymentMethod.cash,
      status: ShipmentStatus.inTransit,
      amount: 10,
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => BlocProvider(
          create: (_) => AppThemeCubit(),
          child: MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            home: AppScope(
              state: appState,
              child: BlocProvider.value(
                value: statusCubit,
                child: const DeliveryFailureScreen(shipment: shipment),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(RadioListTile<String>), findsNWidgets(4));
  });
}
