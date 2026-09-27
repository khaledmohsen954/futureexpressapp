import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets.dart';
import '../../pickup/delivery_failure_screen.dart';
import '../models/shipment.dart';

/// Figma 11:184 — expanded shipment details and the failed delivery route.
class ShipmentDetails extends StatelessWidget {
  const ShipmentDetails({super.key, required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) => Column(children: [
    const Divider(),
    const _DetailRow(Icons.phone_outlined, '0551234567'),
    const SizedBox(height: 8),
    const _DetailRow(Icons.notes_outlined, 'يرجى التواصل مع العميل قبل الوصول'),
    if (shipment.status != ShipmentStatus.delivered) ...[
      const SizedBox(height: 12),
      ActionButton(
        label: 'تعذر التسليم',
        icon: Icons.report_problem_outlined,
        outlined: true,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DeliveryFailureScreen(shipmentId: shipment.id))),
      ),
    ],
  ]);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 19, color: AppColors.muted),
    const SizedBox(width: 8),
    Expanded(child: Text(text)),
  ]);
}
