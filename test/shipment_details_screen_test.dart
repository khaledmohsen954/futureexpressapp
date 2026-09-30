import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/shipment_details_screen.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/shipments_screen.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_card.dart';

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}

void main() {
  testWidgets('shipment card opens details with the selected shipment',
      (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US');
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
            home: const ShipmentsScreen(),
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
    expect(find.text('#$selectedShipmentId'), findsOneWidget);
    final selectedShipment = state.shipments
        .firstWhere((shipment) => shipment.id == selectedShipmentId);
    expect(find.text(selectedShipment.addressEn), findsOneWidget);
  });
}
