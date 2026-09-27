import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import 'shipment_details.dart';
import '../models/shipment.dart';

/// Figma screen 05: the shipment card expands to show contact and delivery actions.
class ShipmentCard extends StatefulWidget {
  const ShipmentCard({super.key, required this.shipment});
  final Shipment shipment;

  @override
  State<ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: SurfaceCard(child: Column(children: [
        Row(children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.red),
          const SizedBox(width: 8),
          Text('#${shipment.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(shipment.status.label, style: TextStyle(
            fontSize: 12,
            color: shipment.status == ShipmentStatus.delivered ? AppColors.green : AppColors.red,
            fontWeight: FontWeight.w700,
          )),
        ]),
        const Divider(height: 23),
        _Info(Icons.person_outline, shipment.customer),
        const SizedBox(height: 8),
        _Info(Icons.location_on_outlined, shipment.address),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.payments_outlined, size: 19, color: AppColors.muted),
          const SizedBox(width: 8),
          const Text('المبلغ', style: TextStyle(color: AppColors.muted)),
          const Spacer(),
          Money(shipment.amount),
        ]),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => setState(() => expanded = !expanded),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(expanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل',
              style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
            Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.red),
          ]),
        ),
        if (expanded) ShipmentDetails(shipment: shipment),
      ])),
    );
  }
}

/// Shared icon and text row inside expanded shipment details.
class _Info extends StatelessWidget {
  const _Info(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 19, color: AppColors.muted),
    const SizedBox(width: 8),
    Expanded(child: Text(label)),
  ]);
}
