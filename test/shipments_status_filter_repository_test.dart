import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('sends the selected status ID with the orders request', () async {
    final api = createTestShipmentsApi();

    final result =
        await api.createRepository().getShipments(page: 2, statusId: 17);

    expect(result.isRight(), isTrue);
    expect(api.requestedPaths, [EndPoints.v3Orders]);
    expect(api.requestedQueries, [
      {'page': 2, 'status_id': 17},
    ]);
  });
}
