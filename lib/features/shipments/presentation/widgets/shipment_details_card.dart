import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/core/custom_widgets/buttons/custom_button.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/theme/app_colors.dart';
import 'package:futureexpressapp/core/theme/app_text_style.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ShipmentDetailsCard extends StatelessWidget {
  const ShipmentDetailsCard({
    super.key,
    this.shipment,
    required this.onMarkWhatsappSent,
  });

  final Shipment? shipment;
  final Future<bool> Function() onMarkWhatsappSent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StoreCard(shipment: shipment),
        const SizedBox(height: 12),
        _CustomerCard(
          shipment: shipment,
          onMarkWhatsappSent: onMarkWhatsappSent,
        ),
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
  const _CustomerCard({
    this.shipment,
    required this.onMarkWhatsappSent,
  });

  final Shipment? shipment;
  final Future<bool> Function() onMarkWhatsappSent;

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
          if (shipment?.numberCount != null) ...[
            const SizedBox(height: 8),
            _Info(
              Icons.inventory_2_outlined,
              '${shipment!.numberCount}',
              AppLocaleKey.shipmentPackageCount,
            ),
          ],
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
              isAr
                  ? shipment!.statusLabelAr ?? shipment!.statusLabel!
                  : shipment!.statusLabel!,
              AppLocaleKey.shipmentStatus,
            ),
          ],
          const SizedBox(height: 20),
          _ContactButtons(
            shipment: shipment,
            onMarkWhatsappSent: onMarkWhatsappSent,
          ),
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

class _ContactButtons extends StatefulWidget {
  const _ContactButtons({
    required this.shipment,
    required this.onMarkWhatsappSent,
  });

  final Shipment? shipment;
  final Future<bool> Function() onMarkWhatsappSent;

  @override
  State<_ContactButtons> createState() => _ContactButtonsState();
}

class _ContactButtonsState extends State<_ContactButtons>
    with WidgetsBindingObserver {
  late bool _whatsappSent = widget.shipment?.whatsappSent ?? false;
  bool _isSending = false;
  bool _waitingForWhatsappReturn = false;
  bool _leftAppForWhatsapp = false;
  bool _showingWhatsappConfirmation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ContactButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shipment?.id != widget.shipment?.id) {
      _whatsappSent = widget.shipment?.whatsappSent ?? false;
    } else if (widget.shipment?.whatsappSent == true) {
      _whatsappSent = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_waitingForWhatsappReturn) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _leftAppForWhatsapp = true;
    } else if (state == AppLifecycleState.resumed && _leftAppForWhatsapp) {
      _waitingForWhatsappReturn = false;
      _leftAppForWhatsapp = false;
      unawaited(_confirmWhatsappSent());
    }
  }

  String? get _phone => widget.shipment?.customerPhone;

  bool get _hasPhone => _phone != null && _phone!.trim().isNotEmpty;

  /// Keeps digits only and converts local Saudi format (05xxxxxxxx)
  /// to international format (9665xxxxxxxx) for WhatsApp.
  String _whatsappNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '966${digits.substring(1)}';
    if (digits.startsWith('5') && digits.length == 9) digits = '966$digits';
    return digits;
  }

  Future<bool> _saveOrderNumberAsContactName() async {
    final phoneNumber = _whatsappNumber(_phone!.trim());
    final orderNumber =
        (widget.shipment?.orderId ?? widget.shipment?.id)?.trim() ?? '';
    final contactName = widget.shipment?.numberCount == null
        ? orderNumber
        : '${widget.shipment!.numberCount}-$orderNumber';
    if (phoneNumber.isEmpty || orderNumber.isEmpty) {
      showLocalMessage(
        context,
        tr(context, AppLocaleKey.whatsappContactSaveFailed),
      );
      return false;
    }
    final permissionRequiredMessage =
        tr(context, AppLocaleKey.whatsappContactPermissionRequired);
    final saveFailedMessage =
        tr(context, AppLocaleKey.whatsappContactSaveFailed);

    try {
      final permission =
          await FlutterContacts.permissions.request(PermissionType.readWrite);
      if (!mounted) return false;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        showLocalMessage(context, permissionRequiredMessage);
        return false;
      }

      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone},
      );
      if (!mounted) return false;
      Contact? matchingContact;
      for (final contact in contacts) {
        if (contact.phones.any(
          (phone) => _whatsappNumber(phone.number) == phoneNumber,
        )) {
          matchingContact = contact;
          break;
        }
      }

      if (matchingContact != null) {
        await FlutterContacts.update(
          matchingContact.copyWith(name: Name(first: contactName)),
        );
      } else {
        await FlutterContacts.create(
          Contact(
            name: Name(first: contactName),
            phones: [Phone(number: '+$phoneNumber')],
          ),
        );
      }
      return true;
    } on PlatformException catch (error) {
      if (!mounted) return false;
      showLocalMessage(context, error.message ?? saveFailedMessage);
      return false;
    }
  }

  Future<void> _openWhatsapp() async {
    if (!_hasPhone || _isSending) return;
    final shouldSendMessage = !_whatsappSent;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final message = shouldSendMessage
        ? (isAr
                ? widget.shipment?.whatsappMessageAr
                : widget.shipment?.whatsappMessageEn) ??
            (isAr
                ? widget.shipment?.whatsappMessageEn
                : widget.shipment?.whatsappMessageAr)
        : null;
    if (shouldSendMessage && (message == null || message.trim().isEmpty)) {
      showLocalMessage(
        context,
        tr(context, AppLocaleKey.whatsappMessageUnavailable),
      );
      return;
    }

    if (!await _saveOrderNumberAsContactName() || !mounted) return;

    if (shouldSendMessage) {
      _waitingForWhatsappReturn = true;
      _leftAppForWhatsapp = false;
    }
    setState(() => _isSending = true);
    try {
      final uri = Uri.https(
        'wa.me',
        '/${_whatsappNumber(_phone!.trim())}',
        message == null ? null : {'text': message},
      );
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && shouldSendMessage) {
        _waitingForWhatsappReturn = false;
        _leftAppForWhatsapp = false;
        if (mounted) {
          showLocalMessage(
              context, tr(context, AppLocaleKey.openWhatsappFailed));
        }
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _confirmWhatsappSent() async {
    if (!mounted || _showingWhatsappConfirmation) return;
    _showingWhatsappConfirmation = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr(context, AppLocaleKey.whatsappSentConfirmationTitle)),
          content: Text(
            tr(context, AppLocaleKey.whatsappSentConfirmationMessage),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr(context, AppLocaleKey.whatsappNotSent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(tr(context, AppLocaleKey.whatsappIHaveSent)),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      final markedSent = await widget.onMarkWhatsappSent();
      if (mounted) setState(() => _whatsappSent = markedSent);
    } finally {
      _showingWhatsappConfirmation = false;
    }
  }

  Future<void> _call() async {
    if (!_hasPhone) return;
    final uri = Uri(scheme: 'tel', path: _phone!.trim());
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            onPressed: _hasPhone && !_isSending ? _openWhatsapp : () {},
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
