import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/wallet/data/repositories/balance_repository.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('loads and parses authenticated wallet balance data', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {
        EndPoints.v3Balance: {
          'success': 1,
          'message': 'balance retrieved successfully',
          'total_cash_cod': 0,
          'balance_under_settlement': 125.5,
          'cash_payment': 50,
          'pos_payment': '25.25',
          'balance': <dynamic>[],
        },
      },
    );

    final result = await BalanceRepository(api).getBalance();

    expect(api.requestedPaths, [EndPoints.v3Balance]);
    result.fold(
      (_) => fail('Expected wallet balance to load.'),
      (balance) {
        expect(balance.totalCashCod, 0);
        expect(balance.balanceUnderSettlement, 125.5);
        expect(balance.cashPayment, 50);
        expect(balance.posPayment, 25.25);
        expect(balance.todayCollection, 75.25);
        expect(balance.transactions, isEmpty);
      },
    );
  });

  test('returns API errors from wallet balance request', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {
        EndPoints.v3Balance: {
          'success': 0,
          'message': 'Unable to retrieve balance',
        },
      },
    );

    final result = await BalanceRepository(api).getBalance();

    result.fold(
      (failure) => expect(failure.errMessage, 'Unable to retrieve balance'),
      (_) => fail('Expected balance retrieval failure.'),
    );
  });
}
