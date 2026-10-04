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
  final List<BalanceTransaction> transactions;

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
              .map((item) => BalanceTransaction.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const [],
    );
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class BalanceTransaction {
  const BalanceTransaction({
    required this.id,
    required this.description,
    required this.debtor,
    required this.creditor,
    required this.date,
    this.order,
  });

  final int? id;
  final String description;
  final num debtor;
  final num creditor;
  final String? date;
  final BalanceOrder? order;

  num get amount => creditor - debtor;

  factory BalanceTransaction.fromJson(Map<String, dynamic> json) {
    final rawOrder = json['order'];
    return BalanceTransaction(
      id: _asInt(json['id']),
      description: json['description']?.toString() ?? '',
      debtor: _asNum(json['debtor']),
      creditor: _asNum(json['creditor']),
      date: json['date']?.toString(),
      order: rawOrder is Map
          ? BalanceOrder.fromJson(Map<String, dynamic>.from(rawOrder))
          : null,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static num _asNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class BalanceOrder {
  const BalanceOrder({required this.id, required this.orderId});

  final int? id;
  final String? orderId;

  factory BalanceOrder.fromJson(Map<String, dynamic> json) => BalanceOrder(
        id: _asInt(json['id']),
        orderId: json['order_id']?.toString(),
      );

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
