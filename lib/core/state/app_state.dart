import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../features/shipments/domain/shipment.dart';
import '../../features/shipments/data/sample_shipments.dart';
import '../storage/local_preview_repository.dart';

/// Central state: shipment actions update every dependent screen and local storage.
class AppState extends ChangeNotifier {
  AppState({LocalPreviewRepository? repository}) : _repository = repository ?? LocalPreviewRepository();
  final LocalPreviewRepository _repository;
  final List<Shipment> _shipments = List.of(sampleShipments);
  Future<void> _pendingWrite = Future.value();

  List<Shipment> get shipments => List.unmodifiable(_shipments);
  bool signedIn = false;
  bool onDuty = false;
  bool reportSent = false;
  String reportNotes = '';
  String phone = '';
  Locale locale = const Locale('ar', 'SA');
  final Map<String, String> failureReasons = {};
  final Map<String, String> failureNotes = {};
  final Set<String> pickedUpIds = {};

  int count(ShipmentStatus status) => _shipments.where((s) => s.status == status).length;
  int get totalCollected => _shipments.where((s) => s.status == ShipmentStatus.delivered)
      .fold<int>(0, (total, shipment) => total + shipment.amount);
  int collectedFor(PaymentMethod method) => _shipments.where((s) =>
      s.status == ShipmentStatus.delivered && s.paymentMethod == method)
      .fold<int>(0, (total, shipment) => total + shipment.amount);
  int get pendingAmount => _shipments.where((s) =>
      s.status != ShipmentStatus.delivered && s.status != ShipmentStatus.failed)
      .fold<int>(0, (total, shipment) => total + shipment.amount);

  /// Restore the demo's language, status changes, pickup history and report.
  Future<void> restore() async {
    final saved = await _repository.read();
    if (saved['language'] == 'en') locale = const Locale('en', 'US');
    onDuty = saved['onDuty'] == true;
    reportSent = saved['reportSent'] == true;
    reportNotes = saved['reportNotes'] is String ? saved['reportNotes'] as String : '';
    if (saved['pickedUp'] is List) {
      pickedUpIds.addAll((saved['pickedUp'] as List).whereType<String>());
    }
    if (saved['failureReasons'] is Map) {
      (saved['failureReasons'] as Map).forEach((key, value) {
        if (key is String && value is String) failureReasons[key] = value;
      });
    }
    if (saved['failureNotes'] is Map) {
      (saved['failureNotes'] as Map).forEach((key, value) {
        if (key is String && value is String) failureNotes[key] = value;
      });
    }
    if (saved['statuses'] is Map) {
      final statuses = saved['statuses'] as Map;
      for (var index = 0; index < _shipments.length; index++) {
        final statusName = statuses[_shipments[index].id];
        for (final status in ShipmentStatus.values) {
          if (status.name == statusName) {
            _shipments[index] = _shipments[index].copyWith(status: status);
            break;
          }
        }
      }
    }
    notifyListeners();
  }

  /// Queue snapshots to keep consecutive edits in the order they happened.
  void _changed() {
    notifyListeners();
    final snapshot = <String, dynamic>{
      'language': locale.languageCode,
      'onDuty': onDuty,
      'reportSent': reportSent,
      'reportNotes': reportNotes,
      'pickedUp': pickedUpIds.toList(),
      'failureReasons': Map.of(failureReasons),
      'failureNotes': Map.of(failureNotes),
      'statuses': {for (final s in _shipments) s.id: s.status.name},
    };
    _pendingWrite = _pendingWrite.then((_) => _repository.write(snapshot));
  }

  void signIn(String value) { phone = value; signedIn = true; notifyListeners(); }
  void signOut() { signedIn = false; phone = ''; notifyListeners(); }
  void toggleLanguage() {
    locale = locale.languageCode == 'ar' ? const Locale('en', 'US') : const Locale('ar', 'SA');
    _changed();
  }
  void setDuty(bool value) { onDuty = value; _changed(); }

  /// A simulated scan moves the next waiting shipment to in-transit.
  Shipment? pickupNext() {
    final index = _shipments.indexWhere((s) => s.status == ShipmentStatus.pending);
    if (index < 0) return null;
    final shipment = _shipments[index];
    _shipments[index] = shipment.copyWith(status: ShipmentStatus.inTransit);
    pickedUpIds.add(shipment.id);
    reportSent = false;
    _changed();
    return _shipments[index];
  }

  /// Confirmed delivery updates the wallet and report totals immediately.
  bool deliver(String id) {
    final index = _shipments.indexWhere((s) => s.id == id && s.status == ShipmentStatus.inTransit);
    if (index < 0) return false;
    _shipments[index] = _shipments[index].copyWith(status: ShipmentStatus.delivered);
    reportSent = false;
    _changed();
    return true;
  }

  void fail(String id, String reasonKey, String notes) {
    final index = _shipments.indexWhere((s) => s.id == id);
    if (index < 0 || _shipments[index].status == ShipmentStatus.delivered) return;
    _shipments[index] = _shipments[index].copyWith(status: ShipmentStatus.failed);
    failureReasons[id] = reasonKey;
    failureNotes[id] = notes;
    reportSent = false;
    _changed();
  }

  void sendReport(String notes) { reportNotes = notes; reportSent = true; _changed(); }
}

/// Routes obtain the same AppState and rebuild after its notifications.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is required above every screen');
    return scope!.notifier!;
  }
}
