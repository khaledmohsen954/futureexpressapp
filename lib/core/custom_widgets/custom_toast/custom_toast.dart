import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/core/theme.dart';

enum ToastType { success, error, offline, warning, help }

class CustomToast extends StatelessWidget {
  final ToastType type;
  final String? title;
  final String? icon;
  final String message;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomToast({
    super.key,
    required this.type,
    this.title,
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor ?? _backgroundColor(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Center(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: backgroundColor ?? _backgroundColor(),
                child: SvgPicture.asset(
                  icon ?? _icons(),
                  height: 30,
                  width: 30,
                  colorFilter: const ColorFilter.mode(
                    AppColors.onDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title != null) ...{
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textColor ?? AppColors.onDark,
                          ),
                    ),
                    //   const SizedBox(height: 5),
                  },
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor ?? AppColors.onDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _backgroundColor() {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.red;
      case ToastType.offline:
        return AppColors.offline;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.help:
        return AppColors.info;
    }
  }

  String _icons() {
    switch (type) {
      case ToastType.success:
        return AppImages.assetsGlobalIconSuccess;
      case ToastType.error:
        return AppImages.assetsGlobalIconErrorIcon;
      case ToastType.offline:
        return AppImages.assetsGlobalIconOfflineIcon;
      case ToastType.warning:
        return AppImages.assetsGlobalIconWarning;
      case ToastType.help:
        return AppImages.assetsGlobalIconHelp;
    }
  }
}
