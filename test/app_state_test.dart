import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

/// An in-memory repository keeps state tests independent of platform storage.
class MemoryRepository implements LocalPreviewRepository {
  Map<String, dynamic> value = {};
  @override
  Future<Map<String, dynamic>> read() async => value;
  @override
  Future<void> write(Map<String, dynamic> data) async {
    value = data;
  }
}

void main() {
  test('starts without sample shipments', () {
    final state = AppState(repository: MemoryRepository());

    expect(state.shipments, isEmpty);
    expect(state.count(ShipmentStatus.inTransit), 0);
    expect(state.count(ShipmentStatus.delivered), 0);
    expect(state.totalCollected, 0);
    expect(state.collectedFor(PaymentMethod.online), 0);
    expect(state.collectedFor(PaymentMethod.cash), 0);
    state.dispose();
  });

  test('language, failure details and sent report survive restore', () async {
    final repository = MemoryRepository();
    final state = AppState(repository: repository);
    state.toggleLanguage();
    state.fail('shipment-123', 'reasonAddress', 'Apartment 2');
    state.sendReport('Done');
    await Future<void>.delayed(Duration.zero);

    final restored = AppState(repository: repository);
    await restored.restore();
    expect(restored.locale.languageCode, 'en');
    expect(restored.shipments, isEmpty);
    expect(restored.failureReasons['shipment-123'], 'reasonAddress');
    expect(restored.reportSent, isTrue);
    expect(restored.reportNotes, 'Done');
    state.dispose();
    restored.dispose();
  });
}
