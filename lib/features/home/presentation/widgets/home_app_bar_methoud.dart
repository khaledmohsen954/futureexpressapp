import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/utils/navigator_methods.dart';

AppBar buildHomeAppBar(BuildContext context) {
  return AppBar(
    leading: Builder(
      builder: (scaffoldContext) => IconButton(
        tooltip: tr(context, AppLocaleKey.menu),
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
      ),
    ),
    title: Text(tr(context, AppLocaleKey.home)),
    actions: [
      IconButton(
        tooltip: tr(context, AppLocaleKey.help),
        icon: const Icon(Icons.headset_mic_outlined),
        onPressed: () => NavigatorMethods.pushNamed(context, RoutesName.supportScreen),
      ),
    ],
  );
}
