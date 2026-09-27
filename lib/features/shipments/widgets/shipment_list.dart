import 'package:flutter/material.dart';
import '../models/shipment.dart';
import 'shipment_card.dart';

/// One list component powers the all, pending, and completed Figma states.
class ShipmentList extends StatelessWidget {
  const ShipmentList({super.key, required this.shipments});
  final List<Shipment> shipments;

  @override
  Widget build(BuildContext context) => Column(children: [
    for (final shipment in shipments)
      ShipmentCard(key: ValueKey(shipment.id), shipment: shipment),
    if (shipments.isEmpty)
      const Padding(padding: EdgeInsets.all(35), child: Center(child: Text('لا توجد شحنات مطابقة'))),
  ]);
}
