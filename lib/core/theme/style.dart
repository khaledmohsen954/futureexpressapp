import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import 'app_colors.dart';
import 'app_text_style.dart';
import 'app_theme.dart';

ThemeData appThemeData(BuildContext context) {
  final base = ThemeData(
    primaryColor: AppColor.mainAppColor(context),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: false,

    hintColor: AppColor.hintColor(context),
    brightness: AppTheme.getByTheme(
      context,
      light: Brightness.light,
      dark: Brightness.dark,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColor.mainAppColor(context),
      alignedDropdown: true,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColor.whiteColor(context),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColor.mainAppColor(context),
      secondary: AppColor.secondAppColor(context),
      surface: AppColor.whiteColor(context),
      brightness: AppTheme.getByTheme(
        context,
        light: Brightness.light,
        dark: Brightness.dark,
      ),
    ),
    radioTheme: RadioThemeData(
      overlayColor: WidgetStateProperty.fromMap({
        WidgetState.selected: AppColor.lightMainAppColor(context),
      }),
      fillColor: WidgetStateProperty.fromMap({
        WidgetState.selected: AppColor.mainAppColor(context),
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.secondAppColor(context),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyle.appBarStyle(context),
      foregroundColor: AppColor.appBarTextColor(context),
    ),
    scaffoldBackgroundColor: AppColor.scaffoldColor(context),
    fontFamily: context.fontFamily(),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColor.mainAppColor(context),
    ),
    platform: TargetPlatform.iOS,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      heightFactor: context.fontHeight(),
      fontFamily: context.fontFamily(),
    ),
  );
}

List<BoxShadow> appShadow = [
  const BoxShadow(
    color: Color(0x3FD3D1D8),
    blurRadius: 22.5,
    offset: Offset(11.25, 11.25),
    spreadRadius: 0,
  ),
];
