import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/features/scanner/presentation/screen/scanner_screen.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/qr_code_scanner.dart';

void main() {
  testWidgets('does not mount the camera while the scanner tab is inactive',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScannerScreen(isActive: false),
      ),
    );

    expect(find.byType(QrCodeScanner), findsNothing);
  });
}
