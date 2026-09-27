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
  test('pickup and delivery update shipment counts and wallet total', () {
    final state = AppState(repository: MemoryRepository());
    expect(state.count(ShipmentStatus.pending), 2);
    expect(state.totalCollected, 150);
    expect(state.pickupNext()?.id, 'FX-2049');
    expect(state.count(ShipmentStatus.pending), 1);
    expect(state.count(ShipmentStatus.inTransit), 2);
    expect(state.deliver('FX-2049'), isTrue);
    expect(state.count(ShipmentStatus.delivered), 2);
    expect(state.totalCollected, 235);
    expect(state.collectedFor(PaymentMethod.online), 235);
    expect(state.collectedFor(PaymentMethod.cash), 0);
    state.dispose();
  });

  test('language, failed delivery and sent report survive restore', () async {
    final repository = MemoryRepository();
    final state = AppState(repository: repository);
    state.toggleLanguage();
    state.fail('FX-2051', 'reasonAddress', 'Apartment 2');
    state.sendReport('Done');
    await Future<void>.delayed(Duration.zero);

    final restored = AppState(repository: repository);
    await restored.restore();
    expect(restored.locale.languageCode, 'en');
    expect(restored.count(ShipmentStatus.failed), 1);
    expect(restored.failureReasons['FX-2051'], 'reasonAddress');
    expect(restored.reportSent, isTrue);
    expect(restored.reportNotes, 'Done');
    state.dispose();
    restored.dispose();
  });
}
