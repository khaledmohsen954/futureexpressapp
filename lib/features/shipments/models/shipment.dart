/// Data shown by shipment cards. Replace these immutable fields with an API model later.
class Shipment {
  const Shipment({required this.id, required this.customer, required this.address,
    required this.status, required this.amount});

  final String id;
  final String customer;
  final String address;
  final ShipmentStatus status;
  final String amount;
}

enum ShipmentStatus { pending, inTransit, delivered }

/// Centralized Arabic status labels used by filters and cards.
extension ShipmentStatusLabel on ShipmentStatus {
  String get label => switch (this) {
    ShipmentStatus.pending => 'بانتظار الاستلام',
    ShipmentStatus.inTransit => 'قيد التوصيل',
    ShipmentStatus.delivered => 'تم التسليم',
  };
}
