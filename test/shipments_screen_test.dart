import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/shipments_screen.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_card.dart';

import 'helpers/fake_shipments_api.dart';

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}

void main() {
  testWidgets('shipment status filters render and filter the list',
      (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US');
    final shipmentsApi = createTestShipmentsApi();
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        home: AppScope(
          state: state,
          child: ShipmentsScreen(repository: shipmentsApi.createRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('4 shipments'), findsOneWidget);
    expect(find.text('#FX-2048'), findsOneWidget);
    expect(find.text('#FX-2050'), findsOneWidget);
    final allStatusIds = tester
        .widgetList<ShipmentCard>(find.byType(ShipmentCard))
        .map((card) => card.shipment.apiStatusId)
        .toList();
    expect(allStatusIds, [17, 220, 329, 329]);

    await tester.tap(find.text('Received'));
    await tester.pumpAndSettle();

    expect(find.text('2 shipments'), findsOneWidget);

    expect(tester.takeException(), isNull);
    expect(find.text('2 shipments'), findsOneWidget);
    expect(find.text('#FX-2049'), findsOneWidget);
    expect(find.text('#FX-2050'), findsNothing);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivery failed'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('0 shipments'), findsOneWidget);
  });
}
