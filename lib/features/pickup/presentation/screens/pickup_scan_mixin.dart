import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_qr_scan_screen.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_utils.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_customer_order_card.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_source_segment.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

mixin PickupScanMixin<T extends StatefulWidget> on State<T> {
  bool get isBusy;
  set isBusy(bool value);
  PickupSource get source;
  Map<PickupSource, List<ScannedPickupOrder>> get orders;
  Future<void> Function(String orderId) get doCaptureConfirmationImage;
  void Function(String orderId, bool isDuplicate)? onDuplicateScanned;
  void Function()? onCustomerPickupScanComplete;

  Future<void> scanShipment(Shipment shipment) async {
    if (isBusy) return;
    final scanSource = source;
    setState(() => isBusy = true);
    try {
      if (shipment.apiStatusId != scanSource.statusId) return;
      final scannedCode = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const PickupQrScanScreen()),
      );
      if (!mounted || scannedCode == null) return;
      final normalizedScannedCode = scannedCode.trim();
      final localMatch = pickupOrderCodes(shipment)
          .any((code) => code.trim().toUpperCase() == normalizedScannedCode.toUpperCase());
      if (!localMatch) {
        final expectedCodes = pickupOrderCodes(shipment).join(', ');
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(' shipment QR mismatch'),
              content: SelectableText(
                'scanned=$normalizedScannedCode\nexpected=[$expectedCodes]',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final currentOrders = orders[scanSource]!;
      final orderId = pickupOrderId(shipment);
      final isDuplicate = currentOrders.any((order) => order.id == orderId);
      if (isDuplicate) {
        if (onDuplicateScanned != null) {
          onDuplicateScanned!(orderId, isDuplicate);
        } else if (mounted) {
          showLocalMessage(
            context,
            tr(context, AppLocaleKey.orderAlreadyScanned),
          );
        }
      } else if (scanSource == PickupSource.customer && currentOrders.isNotEmpty) {
        if (onCustomerPickupScanComplete != null) {
          onCustomerPickupScanComplete!();
        } else if (mounted) {
          showLocalMessage(
            context,
            tr(context, AppLocaleKey.customerPickupScanComplete),
          );
        }
      } else {
        setState(() {
          currentOrders.add(ScannedPickupOrder(id: orderId));
        });
        if (scanSource == PickupSource.customer) {
          await WidgetsBinding.instance.endOfFrame;
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          await doCaptureConfirmationImage(orderId);
        }
      }
    } finally {
      if (mounted) {
        setState(() => isBusy = false);
      }
    }
  }
}
