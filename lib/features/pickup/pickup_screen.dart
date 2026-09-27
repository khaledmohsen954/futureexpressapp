import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Figma 11:398 — scan preview and shipment pickup count.
class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});
  @override State<PickupScreen> createState() => _PickupScreenState();
}
class _PickupScreenState extends State<PickupScreen> {
  int scanned = 0;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('استلام الشحنات')), body: PageBody(children: [
    const Text('امسح رمز الشحنة لاستلامها', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 22),
    SurfaceCard(child: SizedBox(height: 235, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.qr_code_scanner, size: 105, color: AppColors.navy), const SizedBox(height: 14), Text(scanned == 0 ? 'وجّه الكاميرا إلى رمز QR' : 'تم تسجيل $scanned شحنة', style: const TextStyle(color: AppColors.muted))])))),
    const SizedBox(height: 19), ActionButton(label: 'محاكاة مسح شحنة', icon: Icons.qr_code_scanner, onPressed: () { setState(() => scanned++); showLocalMessage(context, 'تم استلام الشحنة بنجاح'); }),
    const SizedBox(height: 14), SurfaceCard(child: Row(children: [const Icon(Icons.inventory_2_outlined, color: AppColors.red), const SizedBox(width: 12), const Text('الشحنات المستلمة اليوم'), const Spacer(), Text('$scanned / 24', style: const TextStyle(fontWeight: FontWeight.w800))])),
  ]));
}
