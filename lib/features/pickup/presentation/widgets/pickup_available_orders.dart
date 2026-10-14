import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_card.dart';

class PickupAvailableOrders extends StatelessWidget {
  const PickupAvailableOrders({
    super.key,
    required this.shipments,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onScan,
    required this.isBusy,
  });

  final List<Shipment> shipments;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<Shipment> onScan;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SurfaceCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CustomLoading(size: 32),
          ),
        ),
      );
    }
    if (error != null) {
      return SurfaceCard(
        child: Column(
          children: [
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(tr(context, AppLocaleKey.retry)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tr(context, AppLocaleKey.pickup)} (${shipments.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (shipments.isEmpty)
          SurfaceCard(
            child: Center(
              child: Text(tr(context, AppLocaleKey.noPickupOrders)),
            ),
          )
        else
          for (final shipment in shipments)
            ShipmentCard(
              key: ValueKey('pickup-${shipment.id}'),
              shipment: shipment,
              actionLabelKey: AppLocaleKey.scanQr,
              actionIcon: Icons.qr_code_scanner,
              onActionPressed:
                  isBusy ? null : () => onScan(shipment),
            ),
      ],
    );
  }
}
