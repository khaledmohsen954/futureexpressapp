import 'package:flutter/material.dart';
import 'models/shipment.dart';
import 'widgets/shipment_list.dart';

/// Figma 11:78 — all shipments with the shared shipment card layout.
class AllShipmentsView extends StatelessWidget {
  const AllShipmentsView({super.key, required this.shipments});
  final List<Shipment> shipments;

  @override
  Widget build(BuildContext context) => ShipmentList(shipments: shipments);
}
