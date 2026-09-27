/// Courier shipment shared by all local screens and report calculations.
class Shipment {
  const Shipment({required this.id, required this.customerAr, required this.customerEn,
    required this.addressAr, required this.addressEn, required this.customerPhone,
    required this.paymentMethod, required this.status, required this.amount});

  final String id;
  final String customerAr;
  final String customerEn;
  final String addressAr;
  final String addressEn;
  final String customerPhone;
  final PaymentMethod paymentMethod;
  final ShipmentStatus status;
  final int amount;

  Shipment copyWith({ShipmentStatus? status}) => Shipment(
    id: id, customerAr: customerAr, customerEn: customerEn,
    addressAr: addressAr, addressEn: addressEn,
    customerPhone: customerPhone, paymentMethod: paymentMethod,
    status: status ?? this.status, amount: amount,
  );
}

enum ShipmentStatus { pending, inTransit, delivered, failed }

/// Demo collection channel used by the report breakdown.
enum PaymentMethod { cash, online }
