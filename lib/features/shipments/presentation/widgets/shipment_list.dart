import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../data/repositories/daily_shipment_sequence_store.dart';
import '../../domain/shipment.dart';
import 'shipment_card.dart';

/// One list component powers the all, pending, and completed Figma states.
class ShipmentList extends StatelessWidget {
  const ShipmentList({
    super.key,
    required this.shipments,
    this.numberInTransitShipments = false,
  });

  final List<Shipment> shipments;
  final bool numberInTransitShipments;

  @override
  Widget build(BuildContext context) {
    final sorted = [...shipments];
    if (numberInTransitShipments) {
      sorted.sort((left, right) {
        final leftNumber = left.dailyNumber;
        final rightNumber = right.dailyNumber;
        if (leftNumber != null && rightNumber != null) {
          return leftNumber.compareTo(rightNumber);
        }
        if (leftNumber != null) return -1;
        if (rightNumber != null) return 1;
        return DailyShipmentSequenceStore.compareByShipmentNumber(left, right);
      });
    }

    return Column(children: [
      for (final shipment in sorted)
        ShipmentCard(
          key: ValueKey(shipment.id),
          shipment: shipment,
          sequenceNumber:
              numberInTransitShipments ? shipment.dailyNumber : null,
        ),
      if (sorted.isEmpty)
        Padding(
          padding: const EdgeInsets.all(35),
          child: Center(child: Text(tr(context, AppLocaleKey.noShipments))),
        ),
    ]);
  }
}
