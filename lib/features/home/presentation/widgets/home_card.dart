import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class HomeCard extends StatelessWidget {
  const HomeCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.iconWidget,
      required this.onTap});
  final String label, value;
  final IconData icon;
  final Widget? iconWidget;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SurfaceCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.red),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 3),
            iconWidget ?? SizedBox()
          ],
        ),
        const SizedBox(height: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ])));
}
