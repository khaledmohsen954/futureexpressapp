import 'package:flutter/material.dart';
import '../../../../core/widgets.dart';

/// Currency row shared by the daily summary and its confirmation.
class ReportAmountRow extends StatelessWidget {
  const ReportAmountRow(this.label, this.amount, {super.key, this.isCurrency = true});
  final String label;
  final String amount;
  final bool isCurrency;

  @override
  Widget build(BuildContext context) => Row(
    children: [Text(label), const Spacer(), isCurrency ? Money(amount) : Text(amount, style: const TextStyle(fontWeight: FontWeight.w700))],
  );
}
