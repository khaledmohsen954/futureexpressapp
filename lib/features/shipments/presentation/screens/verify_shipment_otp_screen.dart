import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';

class VerifyShipmentOtpScreen extends StatefulWidget {
  const VerifyShipmentOtpScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.image,
    this.repository,
  });

  final String orderId;
  final int userId;
  final File image;
  final ShipmentsRepository? repository;

  @override
  State<VerifyShipmentOtpScreen> createState() =>
      _VerifyShipmentOtpScreenState();
}

class _VerifyShipmentOtpScreenState extends State<VerifyShipmentOtpScreen> {
  final _otpController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_isSubmitting) return;
    final otp = CommonMethods.toEnglishDigits(_otpController.text.trim());
    if (otp.isEmpty) {
      setState(
          () => _errorMessage = tr(context, AppLocaleKey.pleaseEnterYourOtp));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await (widget.repository ?? sl<ShipmentsRepository>())
        .confirmShipmentOtp(
      orderId: widget.orderId,
      otp: otp,
      userId: widget.userId,
      image: widget.image,
    );
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.errMessage;
      }),
      (_) => Navigator.pop(context, true),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_isSubmitting,
        child: Scaffold(
          appBar: AppBar(
            title: Text(tr(context, AppLocaleKey.verifyShipmentOtp)),
          ),
          body: PageBody(children: [
            Text(
              tr(context, AppLocaleKey.shipmentOtpInstruction),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  widget.image,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => SizedBox(
                    height: 230,
                    child: Center(
                      child:
                          Text(tr(context, AppLocaleKey.statusImageRequired)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '#${widget.orderId}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('shipment-otp-input'),
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
              ],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _verifyOtp(),
              decoration: InputDecoration(
                labelText: tr(context, AppLocaleKey.otp),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            ActionButton(
              label: tr(context, AppLocaleKey.confirm),
              icon: Icons.verified_outlined,
              color: AppColors.green,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _verifyOtp,
            ),
          ]),
        ),
      );
}
