import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_customer_order_card.dart';

class PickupMerchantOrderCard extends StatelessWidget {
  const PickupMerchantOrderCard({
    super.key,
    required this.order,
    required this.index,
    required this.onRemove,
    required this.isBusy,
  });

  final ScannedPickupOrder order;
  final int index;
  final VoidCallback onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${index + 1} .",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(width: 8),
            const Icon(Icons.qr_code_2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ' ${order.id}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            IconButton(
              tooltip: tr(context, AppLocaleKey.removeOrder),
              onPressed: isBusy ? null : onRemove,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
