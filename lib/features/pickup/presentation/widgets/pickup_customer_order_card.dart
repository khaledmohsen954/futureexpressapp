import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/widgets.dart';

class ScannedPickupOrder {
  const ScannedPickupOrder({required this.id, this.confirmationImage});

  final String id;
  final File? confirmationImage;

  ScannedPickupOrder withImage(File image) =>
      ScannedPickupOrder(id: id, confirmationImage: image);
}

class PickupCustomerOrderCard extends StatelessWidget {
  const PickupCustomerOrderCard({
    super.key,
    required this.order,
    required this.onRetake,
    required this.onRemove,
    required this.isBusy,
  });

  final ScannedPickupOrder order;
  final VoidCallback onRetake;
  final VoidCallback onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (order.confirmationImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                order.confirmationImage!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          else
            const Icon(Icons.qr_code_2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              order.id,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          IconButton(
            tooltip: tr(
              context,
              order.confirmationImage == null
                  ? AppLocaleKey.captureConfirmationPhoto
                  : AppLocaleKey.retakeConfirmationPhoto,
            ),
            onPressed: isBusy ? null : onRetake,
            icon: Icon(
              order.confirmationImage == null
                  ? Icons.camera_alt_outlined
                  : Icons.refresh,
            ),
          ),
          IconButton(
            tooltip: tr(context, AppLocaleKey.removeOrder),
            onPressed: isBusy ? null : onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
