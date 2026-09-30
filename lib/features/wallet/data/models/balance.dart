class Balance {
  const Balance({
    required this.totalCashCod,
    required this.balanceUnderSettlement,
    required this.cashPayment,
    required this.posPayment,
    required this.transactions,
  });

  final num totalCashCod;
  final num balanceUnderSettlement;
  final num cashPayment;
  final num posPayment;
  final List<Map<String, dynamic>> transactions;

  num get todayCollection => cashPayment + posPayment;

  factory Balance.fromJson(Map<String, dynamic> json) {
    final rawBalance = json['balance'];
    return Balance(
      totalCashCod: _asNum(json['total_cash_cod']),
      balanceUnderSettlement: _asNum(json['balance_under_settlement']),
      cashPayment: _asNum(json['cash_payment']),
      posPayment: _asNum(json['pos_payment']),
      transactions: rawBalance is List
          ? rawBalance
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false)
          : const [],
    );
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
