import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/shipments/data/models/order_model.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipments_cubit.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('fetches and parses authenticated API shipment statuses', () async {
    final api = createTestShipmentsApi();

    final result = await api.createRepository().getStatuses();

    expect(api.requestedPaths, [EndPoints.v3Statuses]);
    expect(api.requestedAuth, [true]);
    result.fold(
      (_) => fail('Expected statuses to load.'),
      (statuses) {
        expect(statuses, hasLength(7));
        expect(statuses.first.id, 35);
        expect(statuses.first.title, 'New Order');
        expect(statuses.first.localizedTitle('ar'), 'طلب جديد');
        expect(statuses[1].localizedTitle('en'), 'Received from the branch');
      },
    );
  });

  test('requests orders with status_id and page query parameters', () async {
    final api = createTestShipmentsApi();

    final result =
        await api.createRepository().getShipments(page: 2, statusId: 17);

    expect(result.isRight(), isTrue);
    expect(api.requestedPaths, [EndPoints.v3Orders]);
    expect(api.requestedQueries, [
      {'page': 2, 'status_id': 17},
    ]);
  });

  test('sends numeric database order IDs to scan-and-assign', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {
        'success': 1,
        'message': 'تم تغير الحالة بنجاح',
        'url': 'https://future-ex.com/public/storage/pdf/order/test.pdf',
      },
    );
    final repository = api.createRepository();

    final result = await repository.updateShipmentStatus(
      orderIds: ['8300'],
      statusId: 220,
      latitude: 24.7136,
      longitude: 46.6753,
      notes: '',
    );

    expect(result.isRight(), isTrue);
    expect(api.postedPath, EndPoints.v3ScanAndAssign);
    expect(api.postedAsFormData, isTrue);
    result.fold(
      (_) => fail('Expected the status update to succeed.'),
      (response) {
        expect(response.message, 'تم تغير الحالة بنجاح');
        expect(
          response.url,
          'https://future-ex.com/public/storage/pdf/order/test.pdf',
        );
      },
    );
    expect(api.postedBody, {
      'order_id[0]': 8300,
      'status_id': 220,
      'latitude': 24.7136,
      'longitude': 46.6753,
      'notes': '',
    });
  });

  test('serializes multiple order IDs as indexed form fields', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );

    final result = await api.createRepository().updateShipmentStatus(
      orderIds: ['8300', '8301'],
      statusId: 220,
      latitude: 24.7136,
      longitude: 46.6753,
      notes: '',
    );

    expect(result.isRight(), isTrue);
    expect(api.postedBody, {
      'order_id[0]': 8300,
      'order_id[1]': 8301,
      'status_id': 220,
      'latitude': 24.7136,
      'longitude': 46.6753,
      'notes': '',
    });
  });

  test('returns an API rejection instead of treating it as a successful update',
      () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 0, 'message': 'Invalid order status'},
    );

    final result = await api.createRepository().updateShipmentStatus(
      orderIds: ['8300'],
      statusId: 220,
      latitude: 24.7136,
      longitude: 46.6753,
      notes: '',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.errMessage, 'Invalid order status'),
      (_) => fail('Expected the API rejection to be returned as a failure.'),
    );
  });

  test('rejects tracking numbers instead of sending a nonnumeric order ID',
      () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );

    final result = await api.createRepository().updateShipmentStatus(
      orderIds: ['OR0008300'],
      statusId: 220,
      latitude: 24.7136,
      longitude: 46.6753,
      notes: '',
    );

    expect(result.isLeft(), isTrue);
    expect(api.postedPath, isNull);
  });

  test('maps all fields from the current orders API response', () {
    final shipment = OrderModel.fromJson({
      'id': 8300,
      'order_id': 'OR0008300',
      'store': 'متجر مرجانى',
      'store_image': null,
      'store_city': 'Riyadh',
      'store_city_ar': 'الرياض',
      'client_name': 'منى الشهري',
      'client_phone': '535550476',
      'client_city': 'Jeddah',
      'client_city_ar': 'جدة',
      'reference_number': '100966',
      'number_count': 1,
      'order_contents': 'ماكينة صنع الكيك',
      'amount': '155.00',
      'status_id': 307,
      'order_status': 'The return has been delivered to the store',
      'order_status_ar': 'تم توصيل المرتجع للمتجر',
      'pickup_date': '2024-05-22',
      'amount_paid': 0,
      'what_up_massage_en': 'English message',
      'what_up_massage_ar': 'رسالة عربية',
    });

    expect(shipment, isNotNull);
    expect(shipment!.id, '8300');
    expect(shipment.orderId, 'OR0008300');
    expect(shipment.store, 'متجر مرجانى');
    expect(shipment.storeImage, isNull);
    expect(shipment.storeCity, 'Riyadh');
    expect(shipment.storeCityAr, 'الرياض');
    expect(shipment.customerAr, 'منى الشهري');
    expect(shipment.customerPhone, '535550476');
    expect(shipment.addressEn, 'Jeddah');
    expect(shipment.addressAr, 'جدة');
    expect(shipment.referenceNumber, '100966');
    expect(shipment.numberCount, 1);
    expect(shipment.orderContents, 'ماكينة صنع الكيك');
    expect(shipment.amount, 155);
    expect(shipment.apiStatusId, 307);
    expect(shipment.status, ShipmentStatus.other);
    expect(shipment.statusLabel, 'The return has been delivered to the store');
    expect(shipment.statusLabelAr, 'تم توصيل المرتجع للمتجر');
    expect(shipment.pickupDate, '2024-05-22');
    expect(shipment.amountPaid, 0);
    expect(shipment.whatsappMessageEn, 'English message');
    expect(shipment.whatsappMessageAr, 'رسالة عربية');
  });

  test('maps order status IDs and fetches additional pages from the Cubit',
      () async {
    final api = FakeShipmentsApiConsumer({
      1: shipmentsResponse([
        testOrder('in-transit-first', 17),
        testOrder('in-transit', 17),
        testOrder('delivered', 220),
        testOrder('failed', 34),
        {
          ...testOrder('legacy', 17),
          'status_id': null,
        },
      ], page: 1, lastPage: 2, total: 6),
      2: shipmentsResponse([
        testOrder('later-in-transit', 17),
      ], page: 2, lastPage: 2, total: 6),
    });
    final cubit = ShipmentsCubit(repository: api.createRepository());
    addTearDown(cubit.close);

    await cubit.loadFirstPage();
    expect(cubit.state.status, ShipmentsStatus.success);
    expect(cubit.state.page, 1);
    expect(cubit.state.hasNextPage, isTrue);
    expect(cubit.state.shipments.map((shipment) => shipment.status), [
      ShipmentStatus.inTransit,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
      ShipmentStatus.failed,
      ShipmentStatus.other,
    ]);

    await cubit.loadNextPage();

    expect(api.requestedPages, [1, 2]);
    expect(cubit.state.page, 2);
    expect(cubit.state.hasNextPage, isFalse);
    expect(cubit.state.shipments, hasLength(6));
    expect(cubit.state.shipments.last.status, ShipmentStatus.inTransit);
  });

  test('keeps the selected status filter on first and later page requests',
      () async {
    final api = FakeShipmentsApiConsumer({
      1: shipmentsResponse([
        testOrder('in-transit', 17),
        testOrder('delivered', 220),
      ], page: 1, lastPage: 2, total: 3),
      2: shipmentsResponse([
        testOrder('later-in-transit', 17),
      ], page: 2, lastPage: 2, total: 3),
    });
    final cubit = ShipmentsCubit(repository: api.createRepository());
    addTearDown(cubit.close);

    await cubit.setStatusFilter(17);
    expect(
        cubit.state.shipments.map((shipment) => shipment.id), ['in-transit']);

    await cubit.loadNextPage();

    expect(api.requestedQueries, [
      {'status_id': 17},
      {'page': 2, 'status_id': 17},
    ]);
    expect(
      cubit.state.shipments.map((shipment) => shipment.id),
      ['in-transit', 'later-in-transit'],
    );
  });

  test('keeps every order and sorts unknown status IDs in All shipments',
      () async {
    final orders = List.generate(
      34,
      (index) => {
        'id': 1000 + index,
        'order_id': 'ORD-$index',
        'status_id': index % 4 == 0 ? 17 : 900 + index,
        'order_status': 'Status $index',
        'client_name': 'Customer $index',
        'amount': '10.00',
      },
    );
    final api = FakeShipmentsApiConsumer({
      1: shipmentsResponse(orders, page: 1, lastPage: 1, total: 34),
    });
    final cubit = ShipmentsCubit(repository: api.createRepository());
    addTearDown(cubit.close);

    await cubit.loadFirstPage();

    expect(cubit.state.shipments, hasLength(34));
    expect(cubit.state.shipments.first.id, '1000');
    expect(cubit.state.shipments.first.apiStatusId, 17);
    expect(cubit.state.shipments.last.apiStatusId, 933);
    expect(
      cubit.state.shipments.where(
        (shipment) => shipment.status == ShipmentStatus.other,
      ),
      hasLength(25),
    );
  });
}
