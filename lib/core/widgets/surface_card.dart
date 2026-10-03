import 'package:flutter/material.dart';

import '../theme.dart';

/// Reusable surface with soft border and spacing matching Figma cards.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard(
      {super.key,
      required this.child,
      this.color = AppColors.surface,
      this.padding = const EdgeInsets.all(17)});
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color == AppColors.surface ? AppColors.border : color),
          boxShadow: [
            BoxShadow(
                color: AppColors.navy.withValues(alpha: .035),
                blurRadius: 18,
                offset: const Offset(0, 5))
          ]),
      child: child);
}
