import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/theme/app_text_style.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ShipmentQRCad extends StatelessWidget {
  const ShipmentQRCad({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.white),
                ),
                Text(
                  "Future Express",
                  style: AppTextStyle.textR12B(context),
                ),
                Text(
                  tr(context, "إسم المتجر - إسم المنتج"),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${tr(context, AppLocaleKey.assignTime)} : 10:00 AM ",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.white),
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
                  child: Text(
                    tr(context, AppLocaleKey.fullyPaidOnline),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                          data: "165135",
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
                        "#165135",
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.navy),
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
