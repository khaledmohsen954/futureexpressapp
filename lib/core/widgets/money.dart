import 'package:flutter/material.dart';
import '../theme.dart';

/// The new Saudi Riyal sign is used throughout every monetary value.
class Money extends StatelessWidget {
  const Money(this.amount, {super.key, this.color = AppColors.navy, this.size = 16});
  final Object amount;
  final Color color;
  final double size;
  @override Widget build(BuildContext context) => Text('$amount \u20c1', textDirection: TextDirection.ltr,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: color));
}

