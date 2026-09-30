import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futureexpressapp/core/extension/context_extension.dart';

import 'app_colors.dart';

class AppTextStyle {
  static TextStyle appBarStyle(BuildContext context, {bool listen = true}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: AppColor.appBarTextColor(context, listen: listen),
    );
  }

  static TextStyle buttonStyle(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w900,
      color: color ?? AppColor.buttonTextColor(context, listen: listen),
    );
  }

  static TextStyle textR12B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w900,
      fontFamily: context.fontFamily(),
      color: color ?? AppColor.redColor(context, listen: listen),
    );
  }

  static TextStyle textR14B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w900,
      fontFamily: context.fontFamily(),
      color: color ?? AppColor.redColor(context, listen: listen),
    );
  }

  static TextStyle textD16B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w900,
      fontFamily: context.fontFamily(),
      color: color ?? AppColor.redColor(context, listen: listen),
    );
  }

  //?================================== not used yet ========================================
  static TextStyle textD20B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD24B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD34B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 34.sp,
      fontWeight: FontWeight.w800,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD22B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textW22B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textD16SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      fontFamily: context.fontFamily(),
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD14B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD10B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD14SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD18SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD18B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD14R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textM14B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.mainTextColor(context, listen: listen),
    );
  }

  //*
  static TextStyle textW14B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textW16B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textD16R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textW20B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textW14SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textM14SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.mainTextColor(context, listen: listen),
    );
  }

  static TextStyle textW12SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textW12R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textW14R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textW10R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.whiteTextColor(context, listen: listen),
    );
  }

  static TextStyle textR12SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.redColor(context, listen: listen),
    );
  }

  static TextStyle textR10B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.redColor(context, listen: listen),
    );
  }

  static TextStyle textM12B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.mainTextColor(context, listen: listen),
    );
  }

  static TextStyle textM10R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.mainTextColor(context, listen: listen),
    );
  }

  static TextStyle textM14R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.mainTextColor(context, listen: listen),
    );
  }

  static TextStyle textD11SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD10R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textG10SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle textG10M(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle textD12R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD12SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textD12B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle textG12R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle textG12M(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle textG14R(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  //*
  static TextStyle textG12SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle textG14SB(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle textG14B(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle text16SDark(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle text14MPrimary(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.mainAppColor(context, listen: listen),
    );
  }

  static TextStyle text16MSecond(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.secondAppColor(context, listen: listen),
    );
  }

  static TextStyle text14RGrey(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.greyColor(context, listen: listen),
    );
  }

  static TextStyle textFormStyle(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.darkTextColor(context, listen: listen),
    );
  }

  static TextStyle formTitleStyle(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColor.blackColor(context, listen: listen),
    );
  }

  static TextStyle labelStyle(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.grayTextColor(context, listen: listen),
    );
  }

  static TextStyle mainAppColor(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: color ?? AppColor.mainAppColor(context, listen: listen),
    );
  }

  static TextStyle hintStyle(BuildContext context, {bool listen = true, Color? color}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: color ?? AppColor.hintColor(context, listen: listen),
    );
  }
}
