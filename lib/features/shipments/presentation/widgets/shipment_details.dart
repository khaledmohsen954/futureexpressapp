import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../../pickup/presentation/screens/delivery_failure_screen.dart';
import '../../domain/shipment.dart';

/// Figma 11:184 — local delivery and failure actions for expanded shipments.
class ShipmentDetails extends StatelessWidget {
  const ShipmentDetails({super.key, required this.shipment});
  final Shipment shipment;

  @override Widget build(BuildContext context) => Column(children: [
    const Divider(),
    _DetailRow(Icons.phone_outlined, shipment.customerPhone),
    const SizedBox(height: 8),
    _DetailRow(Icons.notes_outlined, tr(context, 'customerNote')),
    const SizedBox(height: 8),
    _DetailRow(Icons.payments_outlined, tr(context,
      shipment.paymentMethod == PaymentMethod.cash ? 'cashCollection' : 'onlineCollection')),
    if (shipment.status == ShipmentStatus.inTransit) ...[
      const SizedBox(height: 12),
      ActionButton(label: tr(context, 'markDelivered'), icon: Icons.check_circle_outline,
        color: AppColors.green,
        onPressed: () {
          if (AppScope.of(context).deliver(shipment.id)) {
            showLocalMessage(context, tr(context, 'deliverySaved'));
          }
        }),
    ],
    if (shipment.status == ShipmentStatus.inTransit || shipment.status == ShipmentStatus.pending) ...[
      const SizedBox(height: 10),
      ActionButton(label: tr(context, 'deliveryFailure'), icon: Icons.report_problem_outlined,
        outlined: true,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DeliveryFailureScreen(shipmentId: shipment.id))),
      ),
    ],
    if (AppScope.of(context).failureReasons.containsKey(shipment.id))
      Text(tr(context, AppScope.of(context).failureReasons[shipment.id]!) + ' ' +
        (AppScope.of(context).failureNotes[shipment.id] ?? ''),
        style: const TextStyle(color: AppColors.muted)),
  ]);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 19, color: AppColors.muted),
    const SizedBox(width: 8),
    Expanded(child: Text(text)),
  ]);
}
