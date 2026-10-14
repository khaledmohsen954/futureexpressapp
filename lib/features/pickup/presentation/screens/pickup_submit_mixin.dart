import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/pickup/data/repositories/pickup_repository.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_customer_order_card.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_source_segment.dart';

mixin PickupSubmitMixin<T extends StatefulWidget> on State<T> {
  bool get isBusy;
  set isBusy(bool value);
  PickupSource get source;
  Map<PickupSource, List<ScannedPickupOrder>> get orders;
  Future<void> Function({bool showLoading}) get doLoadPickupOrders;

  Future<void> submitPickup() async {
    if (isBusy) return;
    final currentOrders = orders[source]!;
    if (currentOrders.isEmpty) return;
    final ordersToSubmit = List<ScannedPickupOrder>.of(currentOrders);
    if (source == PickupSource.customer &&
        (ordersToSubmit.length != 1 || ordersToSubmit.single.confirmationImage == null)) {
      if (mounted) {
        showLocalMessage(
          context,
          tr(context, AppLocaleKey.confirmationPhotoRequired),
        );
      }
      return;
    }

    setState(() => isBusy = true);
    try {
      final result = source == PickupSource.customer
          ? await sl<PickupRepository>().confirmFromCustomer(
              orderId: ordersToSubmit.single.id,
              confirmationImage: ordersToSubmit.single.confirmationImage!,
            )
          : await sl<PickupRepository>().confirmFromMerchant(
              orderIds: ordersToSubmit.map((order) => order.id).toList(),
            );
      if (!mounted) return;
      result.fold(
        (failure) {
          if (mounted) showLocalMessage(context, failure.errMessage);
        },
        (_) {
          setState(() {
            orders[source] = [];
          });
          unawaited(CommonMethods.cleanupStagingFiles(
            ordersToSubmit.map((order) => order.confirmationImage).toList(),
          ));
          if (mounted) {
            showLocalMessage(context, tr(context, AppLocaleKey.pickupConfirmed));
            Navigator.of(context).pop();
          }
        },
      );
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  Future<void> confirmCustomerOrder(String orderId, File image) async {
    // لو الـ caller (scan / retake) رافع isBusy بالفعل، منكملش عليه ومنرجّعوش
    final ownsBusy = !isBusy;
    if (ownsBusy) setState(() => isBusy = true);
    try {
      final result = await sl<PickupRepository>().confirmFromCustomer(
        orderId: orderId,
        confirmationImage: image,
      );
      if (!mounted) return;
      result.fold(
        (failure) {
          if (mounted) showLocalMessage(context, failure.errMessage);
        },
        (_) {
          setState(() {
            orders[PickupSource.customer]!.removeWhere((order) => order.id == orderId);
          });
          unawaited(CommonMethods.cleanupStagingFiles([image]));
          if (mounted) {
            showLocalMessage(context, tr(context, AppLocaleKey.pickupConfirmed));
            unawaited(doLoadPickupOrders(showLoading: false));
          }
        },
      );
    } finally {
      if (ownsBusy && mounted) setState(() => isBusy = false);
    }
  }
}
