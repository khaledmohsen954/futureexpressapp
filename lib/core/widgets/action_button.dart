import 'package:flutter/material.dart';
import '../theme.dart';

/// Elevated, centered call-to-action with an optional semantic icon.
class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.color = AppColors.red,
      this.outlined = false,
      this.isLoading = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool outlined;
  final bool isLoading;

  Widget _icon() => isLoading
      ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: outlined ? color : AppColors.onDark,
          ),
        )
      : Icon(icon ?? Icons.arrow_forward);

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                      color: color.withValues(alpha: .2),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ]),
      child: SizedBox(
          width: double.infinity,
          height: 51,
          child: outlined
              ? OutlinedButton.icon(
                  onPressed: isLoading ? null : onPressed,
                  icon: _icon(),
                  label: Text(label),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center))
              : FilledButton.icon(
                  onPressed: isLoading ? null : onPressed,
                  icon: _icon(),
                  label: Text(label),
                  style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: AppColors.onDark,
                      textStyle: Theme.of(context).textTheme.labelLarge,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center))));
}
