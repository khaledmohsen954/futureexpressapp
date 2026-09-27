import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'widgets/report_amount_row.dart';

/// Figma screen 07: review and send the daily report locally.
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
    const SurfaceCard(child: Column(children: [ReportAmountRow('الشحنات المسلّمة', '18', isCurrency: false), Divider(), ReportAmountRow('المبلغ المحصّل', '450')])),
    const SizedBox(height: 22), const Text('ملاحظات إضافية', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), TextField(controller: notes, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب ملاحظات الوردية هنا...')),
    const SizedBox(height: 24), ActionButton(label: sent ? 'تم إرسال التقرير' : 'تأكيد وإرسال التقرير', icon: sent ? Icons.check_circle_outline : Icons.send_outlined, color: sent ? AppColors.green : AppColors.red, onPressed: sent ? null : () { setState(() => sent = true); showLocalMessage(context, 'تم إرسال التقرير محليًا في النسخة التجريبية'); }),
  ]));
}
