import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/core/custom_widgets/buttons/custom_button.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/theme/app_colors.dart';
import 'package:futureexpressapp/core/theme/app_text_style.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

class ShipmentDetailsCard extends StatelessWidget {
  const ShipmentDetailsCard({
    super.key,
    this.shipment,
  });

  final Shipment? shipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(color: AppColor.greyColor(context)),
          borderRadius: BorderRadius.circular(18),
          color: AppColor.whiteColor(context)),
      child: Column(
        children: [
          _Info(
            Icons.person_outline,
            shipment?.customerAr ?? "mohamed khaled ",
            AppLocaleKey.agentName,
          ),
          const SizedBox(height: 8),
          _Info(
            Icons.person_outline,
            "#${shipment?.orderId ?? shipment?.id ?? 'FX168768'}",
            AppLocaleKey.shipmentNumber,
          ),
          const SizedBox(height: 8),
          _Info(Icons.location_on_outlined, "123 Main Street, City, Country",
              AppLocaleKey.nationalLocation),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomButton(
                  height: 40,
                  color: AppColor.greenColor(context),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      AppImages.whatsapp,
                      color: AppColor.whiteColor(context),
                    ),
                  ),
                  text: tr(context, AppLocaleKey.contactWithWhatsapp),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: CustomButton(
                  height: 40,
                  color: AppColor.secondAppColor(context),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      AppImages.callImage,
                      color: AppColor.whiteColor(context),
                    ),
                  ),
                  text: tr(context, AppLocaleKey.call),
                  style: AppTextStyle.textW12SB(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label, this.title);
  final IconData icon;
  final String label;
  final String title;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 8),
        Text(
          tr(context, title),
          style: AppTextStyle.textD12B(context),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ]);
}
