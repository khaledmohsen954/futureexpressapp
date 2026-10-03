import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

void main() {
  late _FakeApiConsumer apiConsumer;
  late ShipmentsRepository repository;

  setUp(() {
    apiConsumer = _FakeApiConsumer();
    repository = ShipmentsRepository(apiConsumer);
  });

  test('posts scanned order ID and maps the API order details', () async {
    apiConsumer.response = {
      'success': 1,
      'Order': [
        {
          'id': 12255,
          'order_id': 'ORD0000012255',
          'tracking_number': 'SHI-6abb7285e65dd',
          'store': 'Rizq',
          'store_image': 'https://example.com/store.png',
          'store_phone': null,
          'store_email': 'store@example.com',
          'store_city': 'Dhahran',
          'store_city_ar': 'ظهران',
          'client_name': 'Test customer',
          'client_phone': '9660512345678',
          'client_city': 'Dammam',
          'client_city_ar': 'الدمام',
          'client_address': null,
          'address_details': 'District 1',
          'amount': '10.00',
          'status_id': 17,
          'order_status': 'Out of Dlivery',
          'order_status_ar': 'خارج للتوصيل',
          'amount_paid': 0,
          'what_up_massage_en': 'English message',
          'what_up_massage_ar': 'رسالة عربية',
        },
      ],
    };

    final result = await repository.scanOrder(' ORD0000012255 ');

    expect(apiConsumer.path, EndPoints.v3ScanOrder);
    expect(apiConsumer.body, {'order_id': 'ORD0000012255'});
    expect(apiConsumer.isFormData, isTrue);
    expect(apiConsumer.requiresAuth, isTrue);
    expect(apiConsumer.showToast, isFalse);
    final shipment = result.fold<Shipment?>((_) => null, (value) => value);
    expect(shipment, isNotNull);
    expect(shipment!.id, '12255');
    expect(shipment.orderId, 'ORD0000012255');
    expect(shipment.trackingNumber, 'SHI-6abb7285e65dd');
    expect(shipment.store, 'Rizq');
    expect(shipment.customerAr, 'Test customer');
    expect(shipment.customerPhone, '9660512345678');
    expect(shipment.addressEn, 'Dammam');
    expect(shipment.addressDetails, 'District 1');
    expect(shipment.amountLabel, '10.00');
    expect(shipment.status, ShipmentStatus.inTransit);
    expect(shipment.whatsappMessageEn, 'English message');
  });

  test('returns a server error when scan response contains no order', () async {
    apiConsumer.response = {'success': 1, 'Order': <dynamic>[]};

    final result = await repository.scanOrder('ORD0000012255');

    expect(result.isLeft(), isTrue);
  });
}

class _FakeApiConsumer implements ApiConsumer {
  dynamic response;
  String? path;
  Map<String, dynamic>? body;
  bool? isFormData;
  bool? requiresAuth;
  bool? showToast;

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
    bool requiresAuth = true,
    bool showToast = true,
  }) async {
    this.path = path;
    this.body = body;
    this.isFormData = isFormData;
    this.requiresAuth = requiresAuth;
    this.showToast = showToast;
    return response;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      throw UnimplementedError();

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool? isFormData,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      throw UnimplementedError();
}
