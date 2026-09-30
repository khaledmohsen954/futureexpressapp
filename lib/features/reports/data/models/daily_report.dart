class DailyReport {
  const DailyReport({
    required this.date,
    required this.dateFormatted,
    required this.dateFormattedAr,
    required this.dayName,
    required this.currency,
    required this.currencyCode,
    required this.totalShipments,
    required this.deliveredShipments,
    required this.inDeliveryShipments,
    required this.failedShipments,
    required this.cashCollected,
    required this.electronicCollected,
    required this.totalCollected,
    required this.notes,
    required this.reportId,
    this.message,
  });

  final String? message;
  final String? date;
  final String? dateFormatted;
  final String? dateFormattedAr;
  final String? dayName;
  final String? currency;
  final String? currencyCode;
  final int totalShipments;
  final int deliveredShipments;
  final int inDeliveryShipments;
  final int failedShipments;
  final num cashCollected;
  final num electronicCollected;
  final num totalCollected;
  final String? notes;
  final int? reportId;

  String get formattedTotalCollected => _formatAmount(totalCollected);
  String get formattedCashCollected => _formatAmount(cashCollected);
  String get formattedElectronicCollected => _formatAmount(electronicCollected);

  static DailyReport fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map) {
      throw const FormatException('Daily report response is missing data.');
    }

    final report = Map<String, dynamic>.from(data);
    return DailyReport(
      message: _asString(json['message']),
      date: _asString(report['date']),
      dateFormatted: _asString(report['date_formatted']),
      dateFormattedAr: _asString(report['date_formatted_ar']),
      dayName: _asString(report['day_name']),
      currency: _asString(report['currency']),
      currencyCode: _asString(report['currency_code']),
      totalShipments: _asInt(report['total_shipments']),
      deliveredShipments: _asInt(report['delivered_shipments']),
      inDeliveryShipments: _asInt(report['in_delivery_shipments']),
      failedShipments: _asInt(report['failed_shipments']),
      cashCollected: _asNum(report['cash_collected']),
      electronicCollected: _asNum(report['electronic_collected']),
      totalCollected: _asNum(report['total_collected']),
      notes: _asString(report['notes']),
      reportId: _nullableInt(report['report_id']),
    );
  }

  static String? _asString(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatAmount(num amount) =>
      amount == amount.roundToDouble() ? amount.toInt().toString() : '$amount';
}
