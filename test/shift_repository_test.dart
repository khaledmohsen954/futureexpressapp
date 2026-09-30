import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/home/data/repositories/shift_repository.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('sends authenticated on-duty status as integer 1', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1, 'message': 'Shift updated'},
    );

    final result = await ShiftRepository(api).updateShift(true);

    expect(result.isRight(), isTrue);
    expect(api.postedPath, EndPoints.v3UpdateShift);
    expect(api.postedBody, {'shift_status': 1});
    expect(api.postedRequiresAuth, isTrue);
  });

  test('sends authenticated off-duty status as integer 0', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1},
    );

    final result = await ShiftRepository(api).updateShift(false);

    expect(result.isRight(), isTrue);
    expect(api.postedBody, {'shift_status': 0});
  });

  test('does not accept server-rejected shift updates', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 0, 'message': 'Shift update denied'},
    );

    final result = await ShiftRepository(api).updateShift(true);

    result.fold(
      (failure) => expect(failure.errMessage, 'Shift update denied'),
      (_) => fail('Expected the shift update to fail.'),
    );
  });
}
