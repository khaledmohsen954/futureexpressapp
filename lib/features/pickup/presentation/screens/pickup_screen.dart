import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

/// Figma 11:398 — simulated scan moves one pending shipment into transit.
class PickupScreen extends StatelessWidget {
  const PickupScreen({super.key});

  @override Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(appBar: AppBar(title: Text(tr(context, 'pickup'))),
      body: PageBody(children: [
        Text(tr(context, 'scanInstruction'), textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 22),
        SurfaceCard(child: SizedBox(height: 235,
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.qr_code_scanner, size: 105, color: AppColors.navy),
            const SizedBox(height: 14),
            Text(tr(context, 'aimCamera'), style: const TextStyle(color: AppColors.muted)),
          ])))),
        const SizedBox(height: 19),
        ActionButton(label: tr(context, 'scanDemo'), icon: Icons.qr_code_scanner,
          onPressed: () {
            final shipment = state.pickupNext();
            showLocalMessage(context, tr(context,
              shipment == null ? 'noPending' : 'pickupSuccess'));
          }),
        const SizedBox(height: 14),
        SurfaceCard(child: Row(children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(tr(context, 'pickedUpToday'))),
          Text('${state.pickedUpIds.length} / ${state.shipments.length}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        ])),
      ]),
    );
  }
}
