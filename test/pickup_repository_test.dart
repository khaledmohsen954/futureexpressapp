import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/pickup/data/repositories/pickup_repository.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('submits one customer pickup order and confirmation image', () async {
    final directory = await Directory.systemTemp.createTemp('pickup-test-');
    addTearDown(() => directory.delete(recursive: true));
    final firstImage =
        await File('${directory.path}/first.jpg').writeAsBytes([1, 2, 3]);
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );
    final repository = PickupRepository(api);

    final result = await repository.confirmFromCustomer(
      orderId: '8300',
      confirmationImage: firstImage,
    );

    expect(result.isRight(), isTrue);
    expect(api.postedPath, EndPoints.v3ConfirmPickupFromCustomer);
    expect(api.postedAsFormData, isTrue);
    expect(api.postedRequiresAuth, isTrue);
    expect(
        api.postedBody?.keys, containsAll(['order_id', 'real_image_confirm']));
    expect(api.postedBody?['order_id'], '8300');
    expect(api.postedBody?['real_image_confirm'], isA<MultipartFile>());
    expect(api.postedBody?.containsKey('order_id[0]'), isFalse);
    expect(api.postedBody?.containsKey('real_image_confirm[0]'), isFalse);
  });

  test('submits merchant pickup order IDs as indexed fields', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );

    final result = await PickupRepository(api).confirmFromMerchant(
      orderIds: ['8300', '8301'],
    );

    expect(result.isRight(), isTrue);
    expect(api.postedPath, EndPoints.v3ConfirmPickupFromMerchant);
    expect(api.postedAsFormData, isTrue);
    expect(api.postedBody, {
      'order_id[0]': '8300',
      'order_id[1]': '8301',
    });
  });

  test('rejects an empty customer pickup order ID', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );
    final directory = await Directory.systemTemp.createTemp('pickup-test-');
    addTearDown(() => directory.delete(recursive: true));
    final image = await File('${directory.path}/confirmation.jpg')
        .writeAsBytes([1, 2, 3]);

    final result = await PickupRepository(api).confirmFromCustomer(
      orderId: ' ',
      confirmationImage: image,
    );

    expect(result.isLeft(), isTrue);
    expect(api.postedPath, isNull);
  });

  test('does not submit an empty merchant pickup list', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );

    final result =
        await PickupRepository(api).confirmFromMerchant(orderIds: const []);

    expect(result.isLeft(), isTrue);
    expect(api.postedPath, isNull);
  });

  test('returns API rejection for pickup confirmation', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 0, 'message': 'Pickup is not allowed'},
    );

    final result =
        await PickupRepository(api).confirmFromMerchant(orderIds: ['8300']);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.errMessage, 'Pickup is not allowed'),
      (_) => fail('Expected the pickup API rejection to be returned.'),
    );
  });
}
