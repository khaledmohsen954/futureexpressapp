import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

enum PickupSource { customer, merchant }

extension PickupSourceInfo on PickupSource {
  int get statusId => switch (this) {
        PickupSource.customer => ShipmentStatusApi.statusReturnPickupFromCustomer,
        PickupSource.merchant => ShipmentStatusApi.statusReturnPickupFromMerchant,
      };
}

class PickupSourceSegment extends StatelessWidget {
  const PickupSourceSegment({
    super.key,
    required this.selected,
    required this.onSelectionChanged,
    required this.enabled,
  });

  final PickupSource selected;
  final ValueChanged<PickupSource> onSelectionChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PickupSource>(
      segments: [
        ButtonSegment(
          value: PickupSource.customer,
          label: Text(tr(context, AppLocaleKey.pickupFromCustomer)),
          icon: const Icon(Icons.person_outline),
        ),
        ButtonSegment(
          value: PickupSource.merchant,
          label: Text(tr(context, AppLocaleKey.pickupFromMerchant)),
          icon: const Icon(Icons.store_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged:
          enabled ? (selection) => onSelectionChanged(selection.first) : null,
    );
  }
}
