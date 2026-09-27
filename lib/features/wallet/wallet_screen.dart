import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Wallet balances and sample transaction history are local preview data.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('المحفظة')), body: PageBody(children: [
    SurfaceCard(color: AppColors.navy, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.white), SizedBox(width: 8), Text('الرصيد الحالي', style: TextStyle(color: Colors.white70))]), const SizedBox(height: 13), const Money('1,250', color: Colors.white, size: 33), const SizedBox(height: 8), const Text('آخر تحديث اليوم', style: TextStyle(color: Colors.white70))])),
    const SizedBox(height: 18), const Row(children: [Expanded(child: _Balance('تحصيل اليوم', '450', Icons.payments_outlined)), SizedBox(width: 9), Expanded(child: _Balance('المبالغ المستحقة', '800', Icons.receipt_long_outlined))]),
    const SizedBox(height: 20), const SectionTitle('آخر العمليات'), const SizedBox(height: 8),
    const SurfaceCard(child: Column(children: [_Transaction('تحصيل شحنة #FX-2050', '150', 'اليوم، 02:40 م'), Divider(), _Transaction('تحصيل شحنة #FX-2048', '120', 'اليوم، 01:15 م'), Divider(), _Transaction('تسوية الرصيد', '300', 'أمس، 06:30 م')])),
  ]));
}
class _Balance extends StatelessWidget {
  const _Balance(this.title, this.amount, this.icon);
  final String title, amount;
  final IconData icon;
  @override Widget build(BuildContext context) => SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.red), const SizedBox(height: 10), Money(amount, size: 20), Text(title, style: const TextStyle(fontSize: 12, color: AppColors.muted))]));
}
class _Transaction extends StatelessWidget {
  const _Transaction(this.title, this.amount, this.date);
  final String title, amount, date;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [const CircleAvatar(backgroundColor: Color(0xFFFFF0F2), child: Icon(Icons.arrow_downward, color: AppColors.red)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), Text(date, style: const TextStyle(fontSize: 12, color: AppColors.muted))])), Money(amount, color: AppColors.green)]));
}
