import 'package:flutter/material.dart';
import 'models/shipment.dart';
import 'widgets/shipment_list.dart';

/// Figma 11:131 — pending shipments shown when the second filter is selected.
class PendingShipmentsView extends StatelessWidget {
  const PendingShipmentsView({super.key, required this.shipments});
  final List<Shipment> shipments;

  @override
  Widget build(BuildContext context) => ShipmentList(shipments: shipments);
}
