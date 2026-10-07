import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/daily_shipment_sequence_store.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

void main() {
  test('sorts new shipments locally and preserves daily numbers', () async {
    final preferences = _MemoryPreferences();
    final store = DailyShipmentSequenceStore(preferences: preferences);
    final date = DateTime(2026, 10, 7);

    final initial = await store.assignNumbers(
      [
        _shipment('database-10', 'ORDER-10'),
        _shipment('database-2', 'ORDER-2'),
        _shipment('database-1', 'ORDER-1'),
      ],
      date: date,
    );

    expect(initial, {
      'database-1': 1,
      'database-2': 2,
      'database-10': 3,
    });

    final afterDelivery = await store.assignNumbers(
      [
        _shipment('database-2', 'ORDER-2'),
        _shipment('database-10', 'ORDER-10')
      ],
      date: date,
    );
    expect(afterDelivery['database-2'], 2);
    expect(afterDelivery['database-10'], 3);

    final withNewShipment = await store.assignNumbers(
      [
        _shipment('database-2', 'ORDER-2'),
        _shipment('database-10', 'ORDER-10'),
        _shipment('database-0', 'ORDER-0'),
      ],
      date: date,
    );
    expect(withNewShipment['database-0'], 4);

    final nextDay = await store.assignNumbers(
      [_shipment('database-2', 'ORDER-2')],
      date: DateTime(2026, 10, 8),
    );
    expect(nextDay, {'database-2': 1});
  });
}

Shipment _shipment(String id, String orderId) => Shipment(
      id: id,
      orderId: orderId,
      customerAr: 'Customer',
      customerEn: 'Customer',
      addressAr: 'Riyadh',
      addressEn: 'Riyadh',
      customerPhone: '0501234567',
      paymentMethod: PaymentMethod.cash,
      status: ShipmentStatus.inTransit,
      amount: 100,
    );

class _MemoryPreferences implements DailyShipmentSequencePreferences {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
