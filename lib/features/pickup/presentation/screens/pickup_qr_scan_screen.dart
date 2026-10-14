import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/qr_code_scanner.dart';

class PickupQrScanScreen extends StatelessWidget {
  const PickupQrScanScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr(context, AppLocaleKey.verifyShipment))),
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
