import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../pickup/pickup_screen.dart';
import '../support/support_screen.dart';

/// Dashboard summaries mirror Figma; actions open their respective local pages.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTab});
  final ValueChanged<int> onTab;
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool onDuty = false;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الرئيسية'), actions: [IconButton(tooltip: 'الدعم', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())), icon: const Icon(Icons.headset_mic_outlined))]),
    body: PageBody(children: [
      const Text('مرحبًا أحمد السعيد، ورديتك اليوم', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 15),
      SurfaceCard(color: AppColors.navy, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.local_shipping_outlined, color: Colors.white), SizedBox(width: 9), Text('مهمة الاستلام', style: TextStyle(color: Colors.white70))]),
        const SizedBox(height: 7), const Text('استلام شحنات المستودع', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12), ActionButton(label: 'بدء الاستلام', icon: Icons.qr_code_scanner, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupScreen()))),
      ])), const SizedBox(height: 19),
      Row(children: [Expanded(child: _Stat(label: 'شحنات اليوم', value: '24', icon: Icons.inventory_2_outlined, onTap: () => widget.onTab(1))), const SizedBox(width: 10), Expanded(child: _Stat(label: 'تم التسليم', value: '18', icon: Icons.check_circle_outline, onTap: () => widget.onTab(1)))]),
      const SizedBox(height: 10), Row(children: [Expanded(child: _Stat(label: 'قيد التوصيل', value: '6', icon: Icons.local_shipping_outlined, onTap: () => widget.onTab(1))), const SizedBox(width: 10), Expanded(child: _Stat(label: 'تحصيل اليوم', value: '450 \u20c1', icon: Icons.payments_outlined, onTap: () => widget.onTab(3)))]),
      const SizedBox(height: 20), SurfaceCard(child: Row(children: [const Icon(Icons.power_settings_new, color: AppColors.red), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('حالة الوردية', style: TextStyle(fontWeight: FontWeight.w700)), Text('حدّث توافرك لاستلام المهام', style: TextStyle(color: AppColors.muted, fontSize: 12))])), Switch(value: onDuty, activeTrackColor: AppColors.green, onChanged: (value) => setState(() => onDuty = value))])),
      const SizedBox(height: 17), SectionTitle('آخر الشحنات', action: 'عرض الكل', onAction: () => widget.onTab(1)),
      const SizedBox(height: 8), SurfaceCard(child: Row(children: [const Icon(Icons.inventory_2_outlined, color: AppColors.red), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('شحنة #FX-2048', style: TextStyle(fontWeight: FontWeight.w700)), Text('أحمد محمد • حي الياسمين', style: TextStyle(color: AppColors.muted))])), const Icon(Icons.chevron_left)])),
    ]));
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon, required this.onTap});
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.red), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted))])));
}
