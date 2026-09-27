import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../pickup/delivery_failure_screen.dart';

/// Three shipment views: all, pending, and an expandable detail card.
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});
  @override State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  int filter = 0;
  String query = '';
  final expanded = <String>{};
  final shipments = const [
    (id: 'FX-2048', name: 'أحمد محمد', area: 'حي الياسمين، الرياض', status: 'قيد التوصيل', amount: '120'),
    (id: 'FX-2049', name: 'سارة خالد', area: 'حي النرجس، الرياض', status: 'بانتظار الاستلام', amount: '85'),
    (id: 'FX-2050', name: 'محمد علي', area: 'حي الملقا، الرياض', status: 'تم التسليم', amount: '150'),
    (id: 'FX-2051', name: 'فاطمة إبراهيم', area: 'حي العليا، الرياض', status: 'بانتظار الاستلام', amount: '95'),
  ];
  @override Widget build(BuildContext context) {
    final visible = shipments.where((s) => (filter == 0 || (filter == 1 ? s.status == 'بانتظار الاستلام' : s.status == 'تم التسليم')) && ('${s.id} ${s.name} ${s.area}').contains(query)).toList();
    return Scaffold(appBar: AppBar(title: const Text('الشحنات')), body: PageBody(children: [
      TextField(onChanged: (value) => setState(() => query = value.trim()), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث برقم الشحنة أو العميل')),
      const SizedBox(height: 14), Row(children: List.generate(3, (i) => Expanded(child: Padding(padding: const EdgeInsets.only(left: 7), child: ChoiceChip(label: SizedBox(width: double.infinity, child: Text(['الكل', 'المعلقة', 'المكتملة'][i], textAlign: TextAlign.center)), selected: filter == i, selectedColor: AppColors.navy, labelStyle: TextStyle(color: filter == i ? Colors.white : AppColors.navy), onSelected: (_) => setState(() => filter = i)))))),
      const SizedBox(height: 10), Text('${visible.length} شحنات', style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 8),
      for (final s in visible) ...[SurfaceCard(child: Column(children: [
        Row(children: [const Icon(Icons.inventory_2_outlined, color: AppColors.red), const SizedBox(width: 8), Text('#${s.id}', style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text(s.status, style: TextStyle(fontSize: 12, color: s.status == 'تم التسليم' ? AppColors.green : AppColors.red, fontWeight: FontWeight.w700))]),
        const Divider(height: 23), _Info(Icons.person_outline, s.name), const SizedBox(height: 8), _Info(Icons.location_on_outlined, s.area), const SizedBox(height: 8), Row(children: [const Icon(Icons.payments_outlined, size: 19, color: AppColors.muted), const SizedBox(width: 8), const Text('المبلغ', style: TextStyle(color: AppColors.muted)), const Spacer(), Money(s.amount)]),
        const SizedBox(height: 10), InkWell(onTap: () => setState(() => expanded.contains(s.id) ? expanded.remove(s.id) : expanded.add(s.id)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(expanded.contains(s.id) ? 'إخفاء التفاصيل' : 'عرض التفاصيل', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)), Icon(expanded.contains(s.id) ? Icons.expand_less : Icons.expand_more, color: AppColors.red)])),
        if (expanded.contains(s.id)) ...[const Divider(), _Info(Icons.phone_outlined, '0551234567'), const SizedBox(height: 8), _Info(Icons.notes_outlined, 'يرجى التواصل مع العميل قبل الوصول'), const SizedBox(height: 12), ActionButton(label: 'تعذر التسليم', icon: Icons.report_problem_outlined, outlined: true, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeliveryFailureScreen(shipmentId: s.id)))],
      ])), const SizedBox(height: 11)],
      if (visible.isEmpty) const Padding(padding: EdgeInsets.all(35), child: Center(child: Text('لا توجد شحنات مطابقة'))),
    ]));
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label);
  final IconData icon;
  final String label;
  @override Widget build(BuildContext context) => Row(children: [Icon(icon, size: 19, color: AppColors.muted), const SizedBox(width: 8), Expanded(child: Text(label))]);
}
