import '../../domain/shipment.dart';

class OrderModel {
  const OrderModel._();

  static Shipment? fromJson(Map<String, dynamic> json) {
    final statusId =
        _asInt(json['status_id']) ?? _asInt(json['order_status_id']);
    final status = statusId == null
        ? ShipmentStatusApi.fromLegacyStatus(_asString(json['order_status'])) ??
            ShipmentStatus.other
        : ShipmentStatusApi.fromApiId(statusId) ?? ShipmentStatus.other;

    final id = _asString(json['id']) ?? _asInt(json['id'])?.toString();
    final orderId = _asString(json['order_id']);
    if (id == null && orderId == null) return null;

    final customerName = _asString(json['client_name']) ?? '';
    final clientCity = _asString(json['client_city']) ?? '';
    final clientCityAr = _asString(json['client_city_ar']) ?? clientCity;
    final amount = _asDouble(json['amount'])?.round() ?? 0;

    return Shipment(
      id: id ?? orderId!,
      orderId: orderId,
      customerAr: customerName,
      customerEn: customerName,
      addressAr: clientCityAr,
      addressEn: clientCity,
      customerPhone: _asString(json['client_phone']) ?? '',
      store: _asString(json['store']),
      storeImage: _asString(json['store_image']),
      storeCity: _asString(json['store_city']),
      storeCityAr: _asString(json['store_city_ar']),
      referenceNumber: _asString(json['reference_number']),
      numberCount: _asInt(json['number_count']),
      orderContents: _asString(json['order_contents']),
      pickupDate: _asString(json['pickup_date']),
      amountPaid: _asInt(json['amount_paid']),
      whatsappMessageEn: _asString(json['what_up_massage_en']),
      whatsappMessageAr: _asString(json['what_up_massage_ar']),
      apiStatusId: statusId,
      statusLabel: _asString(json['order_status']),
      statusLabelAr: _asString(json['order_status_ar']),
      paymentMethod: _asInt(json['amount_paid']) == 1
          ? PaymentMethod.online
          : PaymentMethod.cash,
      status: status,
      amount: amount,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
