import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/custom_widgets/buttons/custom_button.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/theme/app_colors.dart';
import 'package:futureexpressapp/core/utils/location_requirement.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/utils/navigator_methods.dart';
import 'package:futureexpressapp/core/widgets/action_button.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/qr_code_scanner.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipment_status_cubit.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/capture_status_image.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/verify_shipment_otp_screen.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_details_card.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_qr_card.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  const ShipmentDetailsScreen({super.key, required this.shipment});

  final Shipment shipment;

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  late Shipment _shipment = widget.shipment;
  bool _isSubmittingDelivery = false;

  @override
  void didUpdateWidget(covariant ShipmentDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shipment != widget.shipment) {
      _shipment = widget.shipment;
    }
  }

  Future<bool> _markWhatsappSent() async {
    final repository = sl<ShipmentsRepository>();
    final orderId = _shipment.orderId ?? _shipment.id;
    final result = await repository.markWhatsappSent(orderId);
    if (!mounted) return false;

    final markedSent = result.fold(
      (failure) {
        showLocalMessage(context, failure.errMessage);
        return false;
      },
      (_) => true,
    );
    if (!markedSent) return false;

    final refreshed = await repository.scanOrder(orderId);
    if (!mounted) return true;
    refreshed.fold(
      (failure) => showLocalMessage(context, failure.errMessage),
      (shipment) => setState(
        () => _shipment = shipment.copyWith(whatsappSent: true),
      ),
    );
    return true;
  }

  Future<void> _submitDelivery() async {
    if (_isSubmittingDelivery) return;
    final amountConfirmed = await _confirmCollectedAmount(context);
    if (!mounted || !amountConfirmed) return;

    setState(() => _isSubmittingDelivery = true);
    File? failureImage;
    try {
      final scannedOrderNumber = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => const _ShipmentQrScanScreen(),
        ),
      );
      if (!mounted || scannedOrderNumber == null) return;
      final expectedOrderNumber = (_shipment.orderId ?? _shipment.id).trim();
      if (scannedOrderNumber.trim() != expectedOrderNumber) {
        showLocalMessage(context, tr(context, AppLocaleKey.shipmentQrMismatch));
        return;
      }

      failureImage = await captureStatusImage(context);
      if (!mounted || failureImage == null) return;
      final userId = AppScope.of(context).clientId;
      if (userId == null) {
        showLocalMessage(
            context, tr(context, AppLocaleKey.reportClientIdMissing));
        return;
      }
      final otpVerified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => VerifyShipmentOtpScreen(
            orderId: _shipment.id,
            userId: userId,
            image: failureImage!,
            repository: sl<ShipmentsRepository>(),
          ),
        ),
      );
      if (!mounted || otpVerified != true) return;
      final locationReady =
          await LocationRequirement.ensureForShipmentStatus(context);
      if (!mounted || !locationReady) return;
      final success = await context.read<ShipmentStatusCubit>().updateStatus(
        orderIds: [_shipment.id],
        statusId: ShipmentStatusApi.statusDelivered,
        notes: '',
        failureImage: failureImage,
      );
      if (!mounted) return;
      if (!success) {
        final state = context.read<ShipmentStatusCubit>().state;
        showLocalMessage(
          context,
          state.locationUnavailable
              ? tr(context, AppLocaleKey.shipmentStatusLocationRequired)
              : state.errorMessage ??
                  tr(context, AppLocaleKey.shipmentStatusUpdateFailed),
        );
        return;
      }
      showLocalMessage(
        context,
        context.read<ShipmentStatusCubit>().state.successMessage ??
            tr(context, AppLocaleKey.deliverySaved),
      );
      Navigator.pop(context, true);
    } finally {
      await CommonMethods.cleanupStagingFiles([failureImage]);
      if (mounted) setState(() => _isSubmittingDelivery = false);
    }
  }

  Future<bool> _confirmCollectedAmount(BuildContext context) async {
    final amount = double.tryParse(_shipment.amountLabel ?? '') ??
        _shipment.amount.toDouble();
    if (amount <= 0) return true;

    return await showDialog<bool>(
          context: context,
          builder: (_) => _CollectedAmountDialog(amount: amount),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final statusCubit = context.watch<ShipmentStatusCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, AppLocaleKey.shipmentDetails)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ShipmentQRCad(shipment: _shipment),
              const SizedBox(height: 15),
              ShipmentDetailsCard(
                shipment: _shipment,
                onMarkWhatsappSent: _markWhatsappSent,
              ),
              const SizedBox(height: 15),
              if ((_shipment.apiStatusId ==
                  ShipmentStatusApi.statusInTransit)) ...[
                ActionButton(
                  label: tr(context, AppLocaleKey.markDelivered),
                  icon: Icons.check_circle_outline,
                  color: AppColors.green,
                  isLoading:
                      _isSubmittingDelivery || statusCubit.state.isLoading,
                  onPressed:
                      _isSubmittingDelivery || statusCubit.state.isLoading
                          ? null
                          : () => unawaited(_submitDelivery()),
                ),
                const SizedBox(height: 10),
                ActionButton(
                  label: tr(context, AppLocaleKey.deliveryFailure),
                  icon: Icons.report_problem_outlined,
                  outlined: true,
                  onPressed: statusCubit.state.isLoading
                      ? null
                      : () async {
                          final success = await NavigatorMethods.pushNamed(
                            context,
                            RoutesName.deliveryFailureScreen,
                            arguments: _shipment,
                          );
                          if (success == true && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                ),
              ] else ...[
                CustomButton(
                  height: 40,
                  color: AppColor.secondAppColor(context),
                  text: Localizations.localeOf(context).languageCode == 'ar'
                      ? _shipment.statusLabelAr ??
                          tr(context, _shipment.status.name)
                      : _shipment.statusLabel ??
                          tr(context, _shipment.status.name),
                )
              ],
              if (AppScope.of(context).failureReasons.containsKey(_shipment.id))
                Text(
                  '${tr(context, AppScope.of(context).failureReasons[_shipment.id]!)} ${AppScope.of(context).failureNotes[_shipment.id] ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShipmentQrScanScreen extends StatelessWidget {
  const _ShipmentQrScanScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(tr(context, AppLocaleKey.verifyShipment)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                tr(context, AppLocaleKey.verifyShipmentInstruction),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              QrCodeScanner(
                title: '',
                description: '',
                showAppBar: false,
                onScan: (value) => Navigator.of(context).pop(value),
              ),
            ],
          ),
        ),
      );
}

class _CollectedAmountDialog extends StatefulWidget {
  const _CollectedAmountDialog({required this.amount});

  final double amount;

  @override
  State<_CollectedAmountDialog> createState() => _CollectedAmountDialogState();
}

class _CollectedAmountDialogState extends State<_CollectedAmountDialog> {
  final _controller = TextEditingController();
  bool _amountMismatch = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(tr(context, AppLocaleKey.confirmCollectedAmount)),
        content: TextField(
          key: const Key('collected-amount-input'),
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: tr(context, AppLocaleKey.amount),
            helperText: tr(context, AppLocaleKey.enterCollectedAmount),
            errorText: _amountMismatch
                ? tr(context, AppLocaleKey.collectedAmountMismatch)
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr(context, AppLocaleKey.cancel)),
          ),
          TextButton(
            onPressed: () {
              final enteredAmount = double.tryParse(_controller.text.trim());
              if (enteredAmount == null ||
                  (enteredAmount * 100).round() !=
                      (widget.amount * 100).round()) {
                setState(() => _amountMismatch = true);
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(tr(context, AppLocaleKey.confirm)),
          ),
        ],
      );
}
