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

const _shipment = Shipment(
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

Future<void> _pumpDeliveryFailure(
  WidgetTester tester, {
  required AppState appState,
  required ShipmentStatusCubit statusCubit,
}) async {
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
              child: const DeliveryFailureScreen(shipment: _shipment),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppState appState;
  late ShipmentStatusCubit statusCubit;

  setUp(() {
    appState = AppState(repository: _MemoryRepository());
    statusCubit = ShipmentStatusCubit(
        repository: createTestShipmentsApi().createRepository());
    addTearDown(appState.dispose);
    addTearDown(statusCubit.close);
  });

  testWidgets('delivery failure reason tiles paint without visibility warnings',
      (tester) async {
    await _pumpDeliveryFailure(
      tester,
      appState: appState,
      statusCubit: statusCubit,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(RadioListTile<String>), findsNWidgets(5));
  });

  testWidgets('selecting postponed reason opens the date picker',
      (tester) async {
    await _pumpDeliveryFailure(
      tester,
      appState: appState,
      statusCubit: statusCubit,
    );

    await tester.ensureVisible(find.text('Delivery postponed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivery postponed'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirming a failure asks for camera or gallery first',
      (tester) async {
    await _pumpDeliveryFailure(
      tester,
      appState: appState,
      statusCubit: statusCubit,
    );

    await tester.ensureVisible(find.text('Incorrect address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Incorrect address'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Confirm delivery failure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm delivery failure'));
    await tester.pumpAndSettle();

    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
