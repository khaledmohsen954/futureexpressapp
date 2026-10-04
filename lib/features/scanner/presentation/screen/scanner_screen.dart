import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/core/error/failures.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/utils/navigator_methods.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/qr_code_scanner.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey<QrCodeScannerState> scannerKey =
      GlobalKey<QrCodeScannerState>();
  String? _detectedCodeValue;
  bool _isLoading = false;
  bool _scannerActive = true;
  bool _scanFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.pickup))),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.scanInstruction),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 22),
        if (widget.isActive && _scannerActive)
          QrCodeScanner(
            key: scannerKey,
            isLoading: _isLoading,
            onScan: (value) async {
              if (_isLoading || !_scannerActive) return;
              setState(() => _isLoading = true);
              await scannerKey.currentState?.stop();
              if (!context.mounted) return;
              final result = await _scanOrder(value);
              if (!context.mounted) return;
              if (result == null) {
                setState(() {
                  _isLoading = false;
                  _scannerActive = false;
                  _scanFailed = true;
                  _detectedCodeValue = value;
                });
                showLocalMessage(
                    context, tr(context, AppLocaleKey.scanOrderFailed));
                return;
              }
              final error = result.fold<String?>(
                  (failure) => failure.errMessage, (_) => null);
              final shipment = result.fold(
                (_) => null,
                (shipment) => shipment,
              );
              setState(() {
                _isLoading = false;
                _scannerActive = false;
                _scanFailed = error != null || shipment == null;
                _detectedCodeValue = value;
              });
              if (error != null) {
                showLocalMessage(context, error);
                return;
              }
              if (shipment == null) {
                showLocalMessage(
                    context, tr(context, AppLocaleKey.scanOrderFailed));
                return;
              }
              await NavigatorMethods.pushNamed(
                context,
                RoutesName.shipmentDetailsScreen,
                arguments: shipment,
              );
            },
            description: "",
            title: "",
            showAppBar: false,
          )
        else if (widget.isActive)
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      _scanFailed
                          ? Icons.qr_code_2
                          : Icons.check_circle_outline,
                      size: 40,
                      color: _scanFailed ? AppColors.red : AppColors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(
                        context,
                        _scanFailed ? AppLocaleKey.retry : AppLocaleKey.scanNew,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.isActive && _isLoading) ...[
          const SizedBox(height: 14),
          const SurfaceCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CustomLoading(size: 32),
              ),
            ),
          ),
        ] else if (widget.isActive && _detectedCodeValue != null) ...[
          const SizedBox(height: 14),
          SurfaceCard(
            child: Row(
              children: [
                const Icon(Icons.qr_code_2, color: AppColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR / Barcode Value',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _detectedCodeValue!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 20),
        if (widget.isActive && !_scannerActive)
          ActionButton(
            label: tr(
              context,
              _scanFailed ? AppLocaleKey.retry : AppLocaleKey.scanNew,
            ),
            icon: Icons.qr_code_scanner,
            onPressed: () {
              setState(() {
                _scannerActive = true;
                _scanFailed = false;
                _detectedCodeValue = null;
              });
            },
          ),
        const SizedBox(height: 14),
      ]),
    );
  }

  Future<Either<Failure, Shipment>?> _scanOrder(String value) async {
    try {
      return await sl<ShipmentsRepository>().scanOrder(value);
    } catch (error, stackTrace) {
      debugPrint('Failed to scan order: $error\n$stackTrace');
      return null;
    }
  }
}
