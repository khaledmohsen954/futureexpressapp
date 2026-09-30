import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futureexpressapp/core/theme.dart';

BoxDecoration appContainerDecoration(
  BuildContext context, {
  bool? isSelected,
  Color? unselectedBorderColor,
}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(15.r),
    border: Border.all(
      color: isSelected ?? false
          ? AppColors.red
          : unselectedBorderColor ?? AppColors.border,
      width: 1.5,
    ),
  );
}
