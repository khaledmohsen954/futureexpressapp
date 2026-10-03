import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/core/custom_widgets/buttons/custom_button.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/theme/app_colors.dart';
import 'package:futureexpressapp/core/theme/app_text_style.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:url_launcher/url_launcher.dart';

class ShipmentDetailsCard extends StatelessWidget {
  const ShipmentDetailsCard({
    super.key,
    this.shipment,
  });

  final Shipment? shipment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StoreCard(shipment: shipment),
        const SizedBox(height: 12),
        _CustomerCard(shipment: shipment),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Store card
/// ---------------------------------------------------------------------------
class _StoreCard extends StatelessWidget {
  const _StoreCard({this.shipment});

  final Shipment? shipment;

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        children: [
          _Info(
            Icons.store_outlined,
            shipment?.store ?? "—",
            AppLocaleKey.store,
          ),
          if (shipment?.storeCity != null) ...[
            const SizedBox(height: 8),
            _Info(
              Icons.location_city_outlined,
              shipment!.storeCity!,
              AppLocaleKey.storeCity,
            ),
          ],
          if (shipment?.storePhone != null) ...[
            const SizedBox(height: 8),
            _Info(
              Icons.phone_outlined,
              shipment!.storePhone!,
              AppLocaleKey.storePhone,
            ),
          ],
          if (shipment?.storeEmail != null) ...[
            const SizedBox(height: 8),
            _Info(
              Icons.mail_outline,
              shipment!.storeEmail!,
              AppLocaleKey.storeEmail,
            ),
          ],
          //  const SizedBox(height: 20),
          //  _ContactButtons(phone: shipment?.storePhone),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Customer card
/// ---------------------------------------------------------------------------
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({this.shipment});

  final Shipment? shipment;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return _CardContainer(
      child: Column(
        children: [
          _Info(
            Icons.person_outline,
            shipment?.customerAr ?? "—",
            AppLocaleKey.agentName,
          ),
          const SizedBox(height: 8),
          _Info(
            Icons.qr_code_2,
            "#${shipment?.orderId ?? shipment?.id ?? '—'}",
            AppLocaleKey.shipmentNumber,
          ),
          if (shipment?.trackingNumber != null) ...[
            const SizedBox(height: 8),
            _Info(
              Icons.local_shipping_outlined,
              shipment!.trackingNumber!,
              AppLocaleKey.trackingNumber,
            ),
          ],
          const SizedBox(height: 8),
          _Info(
            Icons.location_on_outlined,
            [
              shipment?.clientAddress,
              shipment?.addressDetails,
              isAr ? shipment?.addressAr : shipment?.addressEn,
            ].whereType<String>().where((value) => value.isNotEmpty).join(', '),
            AppLocaleKey.nationalLocation,
          ),
          const SizedBox(height: 8),
          _Info(
            Icons.phone_outlined,
            shipment?.customerPhone ?? '',
            AppLocaleKey.phone,
          ),
          if (shipment?.statusLabel != null) ...[
            const SizedBox(height: 8),
            _Info(
              Icons.info_outline,
              isAr ? shipment!.statusLabelAr ?? shipment!.statusLabel! : shipment!.statusLabel!,
              AppLocaleKey.shipmentStatus,
            ),
          ],
          const SizedBox(height: 20),
          _ContactButtons(phone: shipment?.customerPhone),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Shared widgets
/// ---------------------------------------------------------------------------
class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.greyColor(context)),
        borderRadius: BorderRadius.circular(18),
        color: AppColor.whiteColor(context),
      ),
      child: child,
    );
  }
}

class _ContactButtons extends StatelessWidget {
  const _ContactButtons({required this.phone});

  final String? phone;

  bool get _hasPhone => phone != null && phone!.trim().isNotEmpty;

  /// Keeps digits only and converts local Saudi format (05xxxxxxxx)
  /// to international format (9665xxxxxxxx) for WhatsApp.
  String _whatsappNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '966${digits.substring(1)}';
    return digits;
  }

  Future<void> _openWhatsapp() async {
    if (!_hasPhone) return;
    final uri = Uri.parse('https://wa.me/${_whatsappNumber(phone!)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call() async {
    if (!_hasPhone) return;
    final uri = Uri(scheme: 'tel', path: phone!.trim());
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            onPressed: _hasPhone ? _openWhatsapp : () {},
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
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: CustomButton(
            onPressed: _hasPhone ? _call : () {},
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
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label, this.title);

  final IconData icon;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 19, color: AppColors.muted),
          const SizedBox(width: 8),
          Text(
            tr(context, title),
            style: AppTextStyle.textD12B(context),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      );
}
