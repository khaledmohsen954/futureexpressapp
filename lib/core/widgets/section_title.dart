import 'package:flutter/material.dart';
import '../theme.dart';

/// Heading with an optional navigation action for a page section.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override Widget build(BuildContext context) => Row(children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const Spacer(),
    if (action != null) TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.red)))]);
}
