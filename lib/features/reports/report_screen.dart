import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Daily figures and the separate send-report form from the Figma flow.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('التقرير اليومي')), body: PageBody(children: [
    const Text('ملخص أداء اليوم', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('الأحد، ٢٧ سبتمبر ٢٠٢٦', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 18),
    SurfaceCard(color: AppColors.navy, child: Column(children: [const Text('إجمالي التحصيل', style: TextStyle(color: Colors.white70)), const SizedBox(height: 7), const Money('450', color: Colors.white, size: 31), const SizedBox(height: 8), const Text('خلال ورديتك اليوم', style: TextStyle(color: Colors.white70))])),
    const SizedBox(height: 17), const Row(children: [Expanded(child: _ReportStat(Icons.inventory_2_outlined, 'إجمالي الشحنات', '24')), SizedBox(width: 9), Expanded(child: _ReportStat(Icons.check_circle_outline, 'تم التسليم', '18'))]),
    const SizedBox(height: 9), const Row(children: [Expanded(child: _ReportStat(Icons.pending_actions_outlined, 'قيد التوصيل', '6')), SizedBox(width: 9), Expanded(child: _ReportStat(Icons.assignment_late_outlined, 'تعذر التسليم', '0'))]),
    const SizedBox(height: 20), const SectionTitle('تفاصيل التحصيل'), const SizedBox(height: 7), SurfaceCard(child: Column(children: [const _Line('تحصيل نقدي', '300'), const Divider(), const _Line('تحصيل إلكتروني', '150'), const Divider(), const _Line('الإجمالي', '450')])),
    const SizedBox(height: 22), ActionButton(label: 'إرسال التقرير اليومي', icon: Icons.send_outlined, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendReportScreen()))),
  ]));
}

class _ReportStat extends StatelessWidget {
  const _ReportStat(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override Widget build(BuildContext context) => SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.red), const SizedBox(height: 10), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)), Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted))]));
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.amount);
  final String label, amount;
  @override Widget build(BuildContext context) => Row(children: [Text(label), const Spacer(), Money(amount)]);
}

class SendReportScreen extends StatefulWidget {
  const SendReportScreen({super.key});
  @override State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  final notes = TextEditingController();
  bool sent = false;
  @override void dispose() { notes.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('إرسال التقرير')), body: PageBody(children: [
    const Text('مراجعة تقرير الوردية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)), const SizedBox(height: 10),
    const SurfaceCard(child: Column(children: [_Line('الشحنات المسلّمة', '18'), Divider(), _Line('المبلغ المحصّل', '450')])),
    const SizedBox(height: 22), const Text('ملاحظات إضافية', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), TextField(controller: notes, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب ملاحظات الوردية هنا...')),
    const SizedBox(height: 24), ActionButton(label: sent ? 'تم إرسال التقرير' : 'تأكيد وإرسال التقرير', icon: sent ? Icons.check_circle_outline : Icons.send_outlined, color: sent ? AppColors.green : AppColors.red, onPressed: sent ? null : () { setState(() => sent = true); showLocalMessage(context, 'تم إرسال التقرير محليًا في النسخة التجريبية'); }),
  ]));
}
