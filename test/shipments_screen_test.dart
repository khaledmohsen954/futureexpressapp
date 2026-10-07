import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
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
  testWidgets('pulling down refreshes shipments', (tester) async {
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
          child: ShipmentsScreen(
            repository: shipmentsApi.createRepository(),
            sequenceStore: FakeDailyShipmentSequenceStore(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      shipmentsApi.requestedPaths.where((path) => path == EndPoints.v3Orders),
      hasLength(1),
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(
      shipmentsApi.requestedPaths.where((path) => path == EndPoints.v3Orders),
      hasLength(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses API status totals for shipment tab badges', (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US');
    final shipmentsApi = FakeShipmentsApiConsumer({
      1: shipmentsResponse(
        [testOrder('FX-2048', 17)],
        page: 1,
        lastPage: 1,
        statusCounts: {220: 21, 34: 5, 17: 36},
      ),
    });
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        home: AppScope(
          state: state,
          child: ShipmentsScreen(
            repository: shipmentsApi.createRepository(),
            sequenceStore: FakeDailyShipmentSequenceStore(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('36'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<ShipmentCard>(find.byType(ShipmentCard).first)
          .sequenceNumber,
      1,
    );
  });

  testWidgets('only supported API statuses are shown and filtered',
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
          child: ShipmentsScreen(
            repository: shipmentsApi.createRepository(),
            sequenceStore: FakeDailyShipmentSequenceStore(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('All'), findsNothing);
    expect(find.text('Filter by status'), findsOneWidget);
    expect(find.text('1 shipments'), findsOneWidget);
    expect(shipmentsApi.requestedPaths, contains(EndPoints.v3Statuses));
    final statusesRequestIndex =
        shipmentsApi.requestedPaths.indexOf(EndPoints.v3Statuses);
    expect(shipmentsApi.requestedAuth[statusesRequestIndex], isTrue);
    expect(find.text('#FX-2048'), findsOneWidget);
    expect(find.text('#FX-2049'), findsNothing);
    expect(find.text('#FX-2050'), findsNothing);
    final visibleStatusIds = tester
        .widgetList<ShipmentCard>(find.byType(ShipmentCard))
        .map((card) => card.shipment.apiStatusId)
        .toList();
    expect(visibleStatusIds, [17]);

    await tester.tap(find.text('Filter by status'));
    await tester.pumpAndSettle();
    expect(find.text('Received from the branch'), findsNothing);
    expect(find.text('New Order'), findsNothing);
    expect(find.text('Out of Dlivery'), findsOneWidget);
    expect(find.text('Delivered'), findsWidgets);
    expect(find.text('Delivery Failed'), findsOneWidget);
    await tester.tap(find.text('Delivered').last);
    await tester.pumpAndSettle();

    expect(
      shipmentsApi.requestedQueries.last,
      {'status_id': 220},
    );
    expect(find.text('0 shipments'), findsOneWidget);

    expect(tester.takeException(), isNull);
    expect(find.text('0 shipments'), findsOneWidget);
    expect(find.text('#FX-2050'), findsNothing);
    expect(find.text('#FX-2048'), findsNothing);

    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.pumpAndSettle();
    expect(find.text('1 shipments'), findsOneWidget);
    expect(find.text('#FX-2050'), findsOneWidget);

    final selectedStatusChip = tester.widget<InputChip>(find.byType(InputChip));
    selectedStatusChip.onDeleted!();
    await tester.pumpAndSettle();
    expect(shipmentsApi.requestedQueries.last, isNull);
    expect(find.text('1 shipments'), findsOneWidget);
  });
}
