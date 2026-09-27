import 'package:flutter/material.dart';
import 'theme.dart';

/// Consistent padded page container for all right-to-left screens.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 24)});
  final List<Widget> children;
  final EdgeInsets padding;
  @override Widget build(BuildContext context) => SafeArea(child: ListView(padding: padding, children: children));
}

/// Elevated, centered call-to-action with an optional semantic icon.
class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.label, required this.onPressed, this.icon, this.color = AppColors.red, this.outlined = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool outlined;
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: outlined ? null : [BoxShadow(color: color.withValues(alpha: .2), blurRadius: 14, offset: const Offset(0, 6))]),
    child: SizedBox(width: double.infinity, height: 51, child: outlined
      ? OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon ?? Icons.arrow_forward), label: Text(label), style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), alignment: Alignment.center))
      : FilledButton.icon(onPressed: onPressed, icon: Icon(icon ?? Icons.arrow_forward), label: Text(label), style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), alignment: Alignment.center))));
}

/// Reusable surface with soft border and spacing matching Figma cards.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.color = Colors.white, this.padding = const EdgeInsets.all(17)});
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: padding,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), border: Border.all(color: color == Colors.white ? AppColors.border : color), boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: .035), blurRadius: 18, offset: const Offset(0, 5))]), child: child);
}

/// The new Saudi Riyal sign is used throughout every monetary value.
class Money extends StatelessWidget {
  const Money(this.amount, {super.key, this.color = AppColors.navy, this.size = 16});
  final String amount;
  final Color color;
  final double size;
  @override Widget build(BuildContext context) => Text('$amount \u20c1', textDirection: TextDirection.ltr,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: color));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override Widget build(BuildContext context) => Row(children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const Spacer(),
    if (action != null) TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.red)))]);
}

void showLocalMessage(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
