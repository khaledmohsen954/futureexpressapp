import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../shipments/models/shipment.dart';
import '../pickup/pickup_screen.dart';
import '../support/support_screen.dart';

/// Figma 11:23 — statistics derive from the live local shipment list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTab});
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recent = state.shipments.first;
    final english = state.locale.languageCode == 'en';
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'home')), actions: [IconButton(
        tooltip: tr(context, 'help'), icon: const Icon(Icons.headset_mic_outlined),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())))]),
      body: PageBody(children: [
        Text(tr(context, 'welcome'), style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 15),
        SurfaceCard(color: AppColors.navy, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.local_shipping_outlined, color: Colors.white),
            const SizedBox(width: 9), Text(tr(context, 'pickupTask'),
              style: const TextStyle(color: Colors.white70))]),
          const SizedBox(height: 7),
          Text(tr(context, 'warehousePickup'), style: const TextStyle(
            fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          ActionButton(label: tr(context, 'startPickup'), icon: Icons.qr_code_scanner,
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PickupScreen()))),
        ])),
        const SizedBox(height: 19),
        Row(children: [
          Expanded(child: _Stat(label: tr(context, 'todayShipments'),
            value: '${state.shipments.length}', icon: Icons.inventory_2_outlined, onTap: () => onTab(1))),
          const SizedBox(width: 10),
          Expanded(child: _Stat(label: tr(context, 'delivered'),
            value: '${state.count(ShipmentStatus.delivered)}', icon: Icons.check_circle_outline,
            onTap: () => onTab(1))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Stat(label: tr(context, 'inTransit'),
            value: '${state.count(ShipmentStatus.inTransit)}', icon: Icons.local_shipping_outlined,
            onTap: () => onTab(1))),
          const SizedBox(width: 10),
          Expanded(child: _Stat(label: tr(context, 'todayCollection'),
            value: '${state.totalCollected} \u20c1', icon: Icons.payments_outlined,
            onTap: () => onTab(3))),
        ]),
        const SizedBox(height: 20),
        SurfaceCard(child: Row(children: [
          const Icon(Icons.power_settings_new, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(context, 'shiftStatus'), style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(tr(context, 'shiftHint'), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          Switch(value: state.onDuty, activeTrackColor: AppColors.green, onChanged: state.setDuty),
        ])),
        const SizedBox(height: 17),
        SectionTitle(tr(context, 'recentShipments'), action: tr(context, 'seeAll'),
          onAction: () => onTab(1)),
        const SizedBox(height: 8),
        SurfaceCard(child: Row(children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${recent.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${english ? recent.customerEn : recent.customerAr} • ${english ? recent.addressEn : recent.addressAr}',
              style: const TextStyle(color: AppColors.muted)),
          ])),
          const Icon(Icons.chevron_left),
        ])),
      ]),
    );
  }
}

/// Single dashboard metric tile with its destination action.
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon, required this.onTap});
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18),
    child: SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.red), const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ])));
}
