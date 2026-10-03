import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
import 'package:futureexpressapp/core/utils/map_services.dart';
import 'package:futureexpressapp/core/widgets/action_button.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/shipment_details_screen.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/shipments_screen.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_card.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_qr_card.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

import 'helpers/fake_shipments_api.dart';

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}

void main() {
  testWidgets('shows fully paid online for a zero-amount shipment',
      (tester) async {
    const shipment = Shipment(
      id: 'zero-amount',
      customerAr: 'Customer',
      customerEn: 'Customer',
      addressAr: 'Riyadh',
      addressEn: 'Riyadh',
      customerPhone: '0501234567',
      paymentMethod: PaymentMethod.online,
      status: ShipmentStatus.inTransit,
      amount: 0,
      amountLabel: '0.00',
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => BlocProvider(
          create: (_) => AppThemeCubit(),
          child: const MaterialApp(
            locale: Locale('en', 'US'),
            supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
            home: Scaffold(body: ShipmentQRCad(shipment: shipment)),
          ),
        ),
      ),
    );

    expect(find.text('Fully Paid Online'), findsOneWidget);
    expect(find.text('Shipment Amount : '), findsNothing);
  });

  testWidgets('shipment card opens details with the selected shipment',
      (tester) async {
    const geolocatorChannel =
        MethodChannel('flutter.baseflow.com/geolocator_android');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, (call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true;
        case 'checkPermission':
        case 'requestPermission':
          return 0;
        default:
          return null;
      }
    });
    MapService.clearCurrentPosition();
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(geolocatorChannel, null);
      MapService.clearCurrentPosition();
    });

    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US');
    final shipmentsApi = createTestShipmentsApi();
    sl.registerFactory<ShipmentsRepository>(
      () => shipmentsApi.createRepository(),
    );
    addTearDown(sl.reset);
    addTearDown(state.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => BlocProvider(
          create: (_) => AppThemeCubit(),
          child: MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            onGenerateRoute: AppRouters.onGenerateRoute,
            builder: (context, child) => AppScope(state: state, child: child!),
            home: ShipmentsScreen(
              repository: shipmentsApi.createRepository(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstCard = find.byType(ShipmentCard).first;
    await tester.ensureVisible(firstCard);
    final selectedShipmentId =
        tester.widget<ShipmentCard>(firstCard).shipment.id;
    await tester.tap(find.descendant(
      of: firstCard,
      matching: find.text('Show details'),
    ));
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull);
    expect(find.byType(ShipmentDetailsScreen), findsOneWidget);

    expect(find.text('Shipment Details'), findsOneWidget);
    expect(find.text('#$selectedShipmentId'), findsNWidgets(2));
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Riyadh'), findsOneWidget);
    expect(find.text('Contact With Whatsapp'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Confirm delivery'), findsOneWidget);
    expect(find.text('Delivery failed'), findsOneWidget);

    await tester.ensureVisible(find.text('Confirm delivery'));
    await tester.pumpAndSettle();
    final dynamic onPressed =
        tester.widget<ActionButton>(find.byType(ActionButton).first).onPressed;
    await onPressed();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(shipmentsApi.postedPath, isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(ShipmentDetailsScreen), findsOneWidget);
    expect(shipmentsApi.postedPath, isNull);
  });
}
