import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_customer_order_card.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_source_segment.dart';
import 'package:image_picker/image_picker.dart';

mixin PickupCaptureMixin<T extends StatefulWidget> on State<T> {
  ImagePicker get imagePicker;
  bool get isBusy;
  PickupSource get source;
  List<ScannedPickupOrder> get currentOrders;
  set isBusy(bool value);
  Future<void> Function(String orderId, File image)? get doConfirmCustomerOrder;

  Future<void> captureConfirmationImage(String orderId) async {
    try {
      final image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (!mounted || image == null) return;

      final compressed = await CommonMethods.compressImage(File(image.path));
      if (!mounted) {
        await CommonMethods.cleanupStagingFiles([compressed]);
        return;
      }
      final orders = currentOrders;
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index == -1) {
        await CommonMethods.cleanupStagingFiles([compressed]);
        return;
      }
      final previousImage = orders[index].confirmationImage;
      setState(() {
        orders[index] = orders[index].withImage(compressed);
      });
      if (previousImage != null) {
        await CommonMethods.cleanupStagingFiles([previousImage]);
      }
      final confirm = doConfirmCustomerOrder;
      if (source == PickupSource.customer && confirm != null) {
        await confirm(orderId, compressed);
      }
    } on PlatformException catch (error) {
      if (mounted) {
        showLocalMessage(
          context,
          error.message ?? tr(context, AppLocaleKey.confirmationPhotoRequired),
        );
      }
    } catch (error) {
      if (mounted) showLocalMessage(context, error.toString());
    }
  }

  Future<void> retakeConfirmationImage(String orderId) async {
    if (isBusy) return;
    setState(() => isBusy = true);
    try {
      await captureConfirmationImage(orderId);
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  Future<void> removeOrder(String orderId) async {
    final index = currentOrders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    final image = currentOrders[index].confirmationImage;
    setState(() => currentOrders.removeAt(index));
    if (image != null) await CommonMethods.cleanupStagingFiles([image]);
  }
}
