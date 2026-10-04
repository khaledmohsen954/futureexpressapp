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
          'balance_under_settlement': 0,
          'cash_payment': 0,
          'pos_payment': 0,
          'balance': [
            {
              'id': 11459,
              'description': ' تحصيل مبلغ مالي للطلب رقم : OR0008896',
              'debtor': '0.00',
              'creditor': '219.00',
              'order': {'id': 8896, 'order_id': 'OR0008896'},
              'date': '2026-10-01',
            },
          ],
        },
      },
    );

    final result = await BalanceRepository(api).getBalance();

    expect(api.requestedPaths, [EndPoints.v3Balance]);
    expect(api.requestedAuth, [true]);
    result.fold(
      (_) => fail('Expected wallet balance to load.'),
      (balance) {
        expect(balance.totalCashCod, 0);
        expect(balance.balanceUnderSettlement, 0);
        expect(balance.cashPayment, 0);
        expect(balance.posPayment, 0);
        expect(balance.todayCollection, 0);
        expect(balance.transactions, hasLength(1));
        final transaction = balance.transactions.single;
        expect(transaction.id, 11459);
        expect(
          transaction.description,
          ' تحصيل مبلغ مالي للطلب رقم : OR0008896',
        );
        expect(transaction.debtor, 0);
        expect(transaction.creditor, 219);
        expect(transaction.amount, 219);
        expect(transaction.order?.id, 8896);
        expect(transaction.order?.orderId, 'OR0008896');
        expect(transaction.date, '2026-10-01');
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
