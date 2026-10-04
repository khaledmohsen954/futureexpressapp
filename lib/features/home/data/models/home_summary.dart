class HomeSummary {
  const HomeSummary({
    required this.todayShipments,
    required this.deliveredShipments,
    required this.inDeliveryShipments,
    required this.todayCollected,
    required this.currency,
    required this.shiftStatus,
  });

  final int todayShipments;
  final int deliveredShipments;
  final int inDeliveryShipments;
  final num todayCollected;
  final String currency;
  final bool shiftStatus;

  static HomeSummary fromJson(Map<String, dynamic> json) {
    final success = json['success'];
    if (success != true && success != 1 && success != '1') {
      final message = json['message'];
      throw FormatException(
        message is String && message.isNotEmpty
            ? message
            : 'Unable to load home summary.',
      );
    }

    return HomeSummary(
      todayShipments: _asInt(json['today_shipments'], 'today_shipments'),
      deliveredShipments:
          _asInt(json['delivered_shipments'], 'delivered_shipments'),
      inDeliveryShipments:
          _asInt(json['in_delivery_shipments'], 'in_delivery_shipments'),
      todayCollected: _asNum(json['today_collected'], 'today_collected'),
      currency: _asString(json['currency'], 'currency'),
      shiftStatus: _asBool(json['shift_status']),
    );
  }

  static int _asInt(dynamic value, String field) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw FormatException('Home summary is missing a valid $field.');
  }

  static num _asNum(dynamic value, String field) {
    if (value is num) return value;
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw FormatException('Home summary is missing a valid $field.');
  }

  static String _asString(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Home summary is missing a valid $field.');
  }

  static bool _asBool(dynamic value) =>
      value == true || value == 1 || value == '1' || value == 'true';
}
