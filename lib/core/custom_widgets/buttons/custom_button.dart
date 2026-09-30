import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_app_directionality/app_directionality.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';

import '../../network/status.state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final double radius;
  final double? width;
  final double height;
  final TextStyle? style;
  final String? text;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? child;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final StatusState? cubitState;
  final bool isLoading;
  final bool isMainColor;
  final bool hasShadow;
  final void Function()? onPressed;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool? hasArrow;
  final bool? isSecoundryStyle;

  const CustomButton({
    super.key,
    this.radius = 12,
    this.width,
    this.height = 50,
    this.style,
    this.text,
    this.prefixIcon = const SizedBox(),
    this.suffixIcon = const SizedBox(),
    this.color,
    this.gradient,
    this.cubitState,
    this.isLoading = false,
    this.isMainColor = true,
    this.hasShadow = false,
    this.onPressed,
    this.child,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.hasArrow = true,
    this.isSecoundryStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: isSecoundryStyle == true
              ? (color ?? AppColor.lightMain100AppColor(context).withAlpha(50))
              : null,
          gradient: isSecoundryStyle == true
              ? null
              : (LinearGradient(
                  colors: [
                    color ?? AppColor.darkMainAppColor(context),
                    color ?? AppColor.linearMainAppColor(context),
                  ],
                )),
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          boxShadow: hasShadow ? boxShadow : null,
          border: (isSecoundryStyle == true || borderColor != null)
              ? Border.all(color: borderColor ?? AppColor.mainAppColor(context), width: 2)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (cubitState?.isLoading == true || onPressed == null)
                ? null
                : () {
                    if (Debounce.canClick()) onPressed!();
                  },
            child: Center(
              child: cubitState?.isLoading == true
                  ? CustomLoading(color: AppColor.onlyWhiteColor(context), size: 25)
                  : AppDirectionality(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (prefixIcon != null) ...{prefixIcon!, const SizedBox(width: 5)},
                          Flexible(
                            child: child ??
                                Text(
                                  text ?? "",
                                  textAlign: TextAlign.center,
                                  style: style ??
                                      (isSecoundryStyle == true
                                          ? AppTextStyle.buttonStyle(
                                              context,
                                            ).copyWith(color: AppColor.mainAppColor(context))
                                          : AppTextStyle.buttonStyle(context)),
                                ),
                          ),
                          const SizedBox(width: 15),
                          if (suffixIcon != null) ...{
                            suffixIcon!,
                          },
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class Debounce {
  static int _lastClick = 0;

  static bool canClick([int delayMs = 800]) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastClick < delayMs) return false;
    _lastClick = now;
    return true;
  }
}
