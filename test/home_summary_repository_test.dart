import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/home/data/repositories/home_summary_repository.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('fetches and parses the authenticated home summary', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {
        EndPoints.v3HomeSummary: {
          'success': 1,
          'today_shipments': 52,
          'delivered_shipments': 3,
          'in_delivery_shipments': 49,
          'today_collected': 393,
          'currency': '﷼',
          'shift_status': true,
        },
      },
    );

    final result = await HomeSummaryRepository(api).getHomeSummary();

    expect(api.requestedPaths, [EndPoints.v3HomeSummary]);
    expect(api.requestedAuth, [true]);
    result.fold(
      (_) => fail('Expected home summary to load.'),
      (summary) {
        expect(summary.todayShipments, 52);
        expect(summary.deliveredShipments, 3);
        expect(summary.inDeliveryShipments, 49);
        expect(summary.todayCollected, 393);
        expect(summary.currency, '﷼');
        expect(summary.shiftStatus, isTrue);
      },
    );
  });

  test('returns API rejection rather than parsing invalid summary values',
      () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {
        EndPoints.v3HomeSummary: {
          'success': 0,
          'message': 'Unauthenticated',
        },
      },
    );

    final result = await HomeSummaryRepository(api).getHomeSummary();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.errMessage, 'Unauthenticated'),
      (_) => fail('Expected the API rejection to be returned.'),
    );
  });
}
