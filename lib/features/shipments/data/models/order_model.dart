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
      storePhone: _asString(json['store_phone']),
      storeEmail: _asString(json['store_email']),
      storeCity: _asString(json['store_city']),
      storeCityAr: _asString(json['store_city_ar']),
      trackingNumber: _asString(json['tracking_number']),
      clientAddress: _asString(json['client_address']),
      addressDetails: _asString(json['address_details']),
      referenceNumber: _asString(json['reference_number']),
      numberCount: _asInt(json['number_count']),
      dailyNumber: _asInt(json['daily_number']),
      orderContents: _asString(json['order_contents']),
      pickupDate: _asString(json['pickup_date']),
      amountLabel: _asString(json['amount']),
      amountPaid: _asInt(json['amount_paid']),
      whatsappMessageEn: _asString(json['what_up_massage_en']),
      whatsappMessageAr: _asString(json['what_up_massage_ar']),
      whatsappSent: _asBool(json['whatsapp_sent']),
      apiStatusId: statusId,
      statusLabel: _asString(json['order_status']),
      statusLabelAr: _asString(json['order_status_ar']),
      latitude: _coordinate(json, const [
        'latitude',
        'lat',
        'client_latitude',
        'client_lat',
        'customer_latitude',
        'customer_lat',
        'delivery_latitude',
        'delivery_lat',
      ]),
      longitude: _coordinate(json, const [
        'longitude',
        'lng',
        'lon',
        'client_longitude',
        'client_lng',
        'client_lon',
        'customer_longitude',
        'customer_lng',
        'delivery_longitude',
        'delivery_lng',
      ]),
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

  static bool _asBool(dynamic value) =>
      value == true || value == 1 || value == '1' || value == 'true';

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static double? _coordinate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = _asDouble(json[key]);
      if (value != null) return value;
    }
    return null;
  }
}
