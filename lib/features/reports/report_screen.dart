import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'send_report_screen.dart';
import 'widgets/report_amount_row.dart';

/// Figma 11:250 — daily totals and route to report submission.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('التقرير اليومي')), body: PageBody(children: [
    const Text('ملخص أداء اليوم', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('الأحد، ٢٧ سبتمبر ٢٠٢٦', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 18),
    SurfaceCard(color: AppColors.navy, child: Column(children: [const Text('إجمالي التحصيل', style: TextStyle(color: Colors.white70)), const SizedBox(height: 7), const Money('450', color: Colors.white, size: 31), const SizedBox(height: 8), const Text('خلال ورديتك اليوم', style: TextStyle(color: Colors.white70))])),
    const SizedBox(height: 17), const Row(children: [Expanded(child: _ReportStat(Icons.inventory_2_outlined, 'إجمالي الشحنات', '24')), SizedBox(width: 9), Expanded(child: _ReportStat(Icons.check_circle_outline, 'تم التسليم', '18'))]),
    const SizedBox(height: 9), const Row(children: [Expanded(child: _ReportStat(Icons.pending_actions_outlined, 'قيد التوصيل', '6')), SizedBox(width: 9), Expanded(child: _ReportStat(Icons.assignment_late_outlined, 'تعذر التسليم', '0'))]),
    const SizedBox(height: 20), const SectionTitle('تفاصيل التحصيل'), const SizedBox(height: 7), SurfaceCard(child: Column(children: [const ReportAmountRow('تحصيل نقدي', '300'), const Divider(), const ReportAmountRow('تحصيل إلكتروني', '150'), const Divider(), const ReportAmountRow('الإجمالي', '450')])),
    const SizedBox(height: 22), ActionButton(label: 'إرسال التقرير اليومي', icon: Icons.send_outlined, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendReportScreen()))),
  ]));
}

class _ReportStat extends StatelessWidget {
  const _ReportStat(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override Widget build(BuildContext context) => SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.red), const SizedBox(height: 10), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)), Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted))]));
}

