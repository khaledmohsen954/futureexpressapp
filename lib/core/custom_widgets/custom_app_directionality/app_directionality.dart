import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/extension/context_extension.dart';

class AppDirectionality extends StatelessWidget {
  const AppDirectionality({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.isRTL() ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: child,
    );
  }
}
