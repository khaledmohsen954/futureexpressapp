import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Figma 11:428 — delivery failure reason and notes.
class DeliveryFailureScreen extends StatefulWidget {
  const DeliveryFailureScreen({super.key, required this.shipmentId});
  final String shipmentId;
  @override State<DeliveryFailureScreen> createState() => _DeliveryFailureScreenState();
}
class _DeliveryFailureScreenState extends State<DeliveryFailureScreen> {
  String? reason;
  final note = TextEditingController();
  final reasons = const ['العميل غير متاح', 'العنوان غير صحيح', 'رفض العميل الاستلام', 'سبب آخر'];
  @override void dispose() { note.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تعذر التسليم')), body: PageBody(children: [
    SurfaceCard(child: Row(children: [const Icon(Icons.inventory_2_outlined, color: AppColors.red), const SizedBox(width: 12), Text('الشحنة #${widget.shipmentId}', style: const TextStyle(fontWeight: FontWeight.w700))])),
    const SizedBox(height: 23), const Text('اختر سبب تعذر التسليم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 10),
    for (final item in reasons) Padding(padding: const EdgeInsets.only(bottom: 8), child: SurfaceCard(padding: EdgeInsets.zero, child: RadioListTile<String>(title: Text(item), value: item, groupValue: reason, activeColor: AppColors.red, onChanged: (value) => setState(() => reason = value)))),
    const SizedBox(height: 13), const Text('ملاحظات إضافية', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), TextField(controller: note, maxLines: 3, decoration: const InputDecoration(hintText: 'اكتب أي تفاصيل إضافية...')),
    const SizedBox(height: 24), ActionButton(label: 'تأكيد تعذر التسليم', icon: Icons.report_problem_outlined, onPressed: () { if (reason == null) { showLocalMessage(context, 'اختر سبب تعذر التسليم'); return; } showLocalMessage(context, 'تم تسجيل السبب محليًا'); Navigator.pop(context); }),
  ]));
}
