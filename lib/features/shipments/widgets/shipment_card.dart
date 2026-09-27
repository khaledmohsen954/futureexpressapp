import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../models/shipment.dart';
import 'shipment_details.dart';

/// Figma 11:184 — expandable card stays in sync with shipment changes.
class ShipmentCard extends StatefulWidget {
  const ShipmentCard({super.key, required this.shipment});
  final Shipment shipment;
  @override State<ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    final english = AppScope.of(context).locale.languageCode == 'en';
    final statusKey = switch (shipment.status) {
      ShipmentStatus.pending => 'pending',
      ShipmentStatus.inTransit => 'inTransit',
      ShipmentStatus.delivered => 'delivered',
      ShipmentStatus.failed => 'deliveryFailure',
    };
    return Padding(padding: const EdgeInsets.only(bottom: 11),
      child: SurfaceCard(child: Column(children: [
        Row(children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.red),
          const SizedBox(width: 8),
          Text('#${shipment.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          Flexible(child: Text(tr(context, statusKey), textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12,
              color: shipment.status == ShipmentStatus.delivered ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.w700))),
        ]),
        const Divider(height: 23),
        _Info(Icons.person_outline, english ? shipment.customerEn : shipment.customerAr),
        const SizedBox(height: 8),
        _Info(Icons.location_on_outlined, english ? shipment.addressEn : shipment.addressAr),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.payments_outlined, size: 19, color: AppColors.muted),
          const SizedBox(width: 8),
          Text(tr(context, 'amount'), style: const TextStyle(color: AppColors.muted)),
          const Spacer(), Money(shipment.amount),
        ]),
        const SizedBox(height: 10),
        InkWell(onTap: () => setState(() => expanded = !expanded),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(tr(context, expanded ? 'hideDetails' : 'showDetails'),
              style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
            Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.red),
          ])),
        if (expanded) ShipmentDetails(shipment: shipment),
      ])),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label);
  final IconData icon;
  final String label;
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 19, color: AppColors.muted),
    const SizedBox(width: 8),
    Expanded(child: Text(label)),
  ]);
}
