import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/theme/app_text_style.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../domain/shipment.dart';

class ShipmentQRCad extends StatelessWidget {
  const ShipmentQRCad({
    super.key,
    required this.shipment,
  });

  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(shipment.amountLabel ?? '') ??
        shipment.amount.toDouble();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, AppLocaleKey.responsibleCarrier),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.white),
                ),
                Text(
                  "Future Express",
                  style: AppTextStyle.textR12B(context),
                ),
                Text(
                  shipment.store ??
                      shipment.orderContents ??
                      tr(context, "إسم المتجر - إسم المنتج"),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${tr(context, AppLocaleKey.assignTime)} : 10:00 AM ",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      amount > 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${tr(context, AppLocaleKey.shipmentAmount)} : ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                            color: AppColors.white, height: 2),
                                  ),
                                  Money(
                                    amount,
                                    color: AppColors.white,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              tr(context, AppLocaleKey.fullyPaidOnline),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: AppColors.white),
                            ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 55,
                        width: 50,
                        child: PrettyQrView.data(
                          data: shipment.orderId ?? shipment.id,
                          decoration: PrettyQrDecoration(
                            shape: PrettyQrSquaresSymbol(
                              color: AppColors.navy,
                              unifiedFinderPattern: false,
                            ),
                          ),
                          errorCorrectLevel: QrErrorCorrectLevel.H,
                        ),
                      ),
                      Text(
                        "#${shipment.orderId ?? shipment.id}",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
