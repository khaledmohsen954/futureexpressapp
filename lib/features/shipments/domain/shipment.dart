/// Courier shipment shared by all local screens and report calculations.
class Shipment {
  const Shipment(
      {required this.id,
      required this.customerAr,
      required this.customerEn,
      required this.addressAr,
      required this.addressEn,
      required this.customerPhone,
      required this.paymentMethod,
      required this.status,
      required this.amount,
      this.orderId,
      this.store,
      this.storeImage,
      this.storeCity,
      this.storeCityAr,
      this.referenceNumber,
      this.numberCount,
      this.orderContents,
      this.pickupDate,
      this.amountPaid,
      this.whatsappMessageEn,
      this.whatsappMessageAr,
      this.apiStatusId,
      this.statusLabel,
      this.statusLabelAr});

  final String id;
  final String? orderId;
  final String customerAr;
  final String customerEn;
  final String addressAr;
  final String addressEn;
  final String customerPhone;
  final String? store;
  final String? storeImage;
  final String? storeCity;
  final String? storeCityAr;
  final String? referenceNumber;
  final int? numberCount;
  final String? orderContents;
  final String? pickupDate;
  final int? amountPaid;
  final String? whatsappMessageEn;
  final String? whatsappMessageAr;
  final int? apiStatusId;
  final String? statusLabel;
  final String? statusLabelAr;
  final PaymentMethod paymentMethod;
  final ShipmentStatus status;
  final int amount;

  Shipment copyWith({ShipmentStatus? status}) => Shipment(
        id: id,
        orderId: orderId,
        customerAr: customerAr,
        customerEn: customerEn,
        addressAr: addressAr,
        addressEn: addressEn,
        customerPhone: customerPhone,
        store: store,
        storeImage: storeImage,
        storeCity: storeCity,
        storeCityAr: storeCityAr,
        referenceNumber: referenceNumber,
        numberCount: numberCount,
        orderContents: orderContents,
        pickupDate: pickupDate,
        amountPaid: amountPaid,
        whatsappMessageEn: whatsappMessageEn,
        whatsappMessageAr: whatsappMessageAr,
        apiStatusId: apiStatusId,
        statusLabel: statusLabel,
        statusLabelAr: statusLabelAr,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        amount: amount,
      );
}

enum ShipmentStatus { pending, inTransit, delivered, failed, other }

extension ShipmentStatusApi on ShipmentStatus {
  static const int statusReceived = 329;
  static const int statusInTransit = 17;
  static const int statusDelivered = 220;
  static const int statusDeliveryFailed = 10;

  int get apiId => switch (this) {
        ShipmentStatus.pending => statusReceived,
        ShipmentStatus.inTransit => statusInTransit,
        ShipmentStatus.delivered => statusDelivered,
        ShipmentStatus.failed => statusDeliveryFailed,
        ShipmentStatus.other => -1,
      };

  static ShipmentStatus? fromApiId(int? id) => switch (id) {
        statusReceived => ShipmentStatus.pending,
        statusInTransit => ShipmentStatus.inTransit,
        statusDelivered => ShipmentStatus.delivered,
        statusDeliveryFailed => ShipmentStatus.failed,
        _ => null,
      };

  static ShipmentStatus? fromLegacyStatus(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'received order':
        return ShipmentStatus.pending;
      case 'out of dlivery':
      case 'out for delivery':
        return ShipmentStatus.inTransit;
      case 'delivered':
      case 'delivery completed':
        return ShipmentStatus.delivered;
      case 'delivery failed':
      case 'no answer':
      case 'the return has been delivered to the store':
        return ShipmentStatus.failed;
      default:
        return null;
    }
  }
}

/// Demo collection channel used by the report breakdown.
enum PaymentMethod { cash, online }
