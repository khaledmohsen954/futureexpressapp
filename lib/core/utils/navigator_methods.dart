import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';
import 'package:futureexpressapp/core/theme.dart';

class NavigatorMethods {
  static Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<dynamic> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static Future<dynamic> pushNamedAndRemoveUntilNoAnimation(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    return Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        settings: RouteSettings(name: routeName, arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) {
          final route = AppRouters.onGenerateRoute(
            RouteSettings(name: routeName, arguments: arguments),
          );
          if (route is MaterialPageRoute) {
            return route.builder(context);
          }
          return const Scaffold(); // Fallback
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }

  static void showAppBottomSheet(
    BuildContext context,
    Widget bottomSheet, {
    bool willPop = true,
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: isScrollControlled,
      isDismissible: willPop,
      enableDrag: enableDrag,
      context: context,
      builder: (context) {
        return PopScope(canPop: willPop, child: bottomSheet);
      },
    );
  }

  static void loading({
    double size = 60,
    double radius = 30,
    double loadingSize = 30,
    Color? backgroundColor,
    Color? loadingColor,
  }) {
    FocusScope.of(
      AppRouters.navigatorKey.currentContext!,
    ).requestFocus(FocusNode());
    BotToast.showCustomLoading(
      toastBuilder: (cancelFunc) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(child: CustomLoading(size: loadingSize)),
      ),
    );
  }

  static void loadingOff() {
    BotToast.closeAllLoading();
  }
}
