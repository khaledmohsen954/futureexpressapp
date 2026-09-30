import 'package:bot_toast/bot_toast.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';

import 'core/state/app_state.dart';
import 'core/theme.dart';
import 'core/theme/cubit/app_theme_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/app_shell.dart';

/// Root widget wires state, locale, theme and the signed-in navigation shell.
class FutureExpressApp extends StatefulWidget {
  const FutureExpressApp({super.key, required this.state});
  final AppState state;
  @override
  State<FutureExpressApp> createState() => _FutureExpressAppState();
}

class _FutureExpressAppState extends State<FutureExpressApp> {
  late final AppState state = widget.state;
  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => BlocProvider(
          create: (_) => AppThemeCubit(),
          child: AnimatedBuilder(
            animation: state,
            builder: (context, _) => MaterialApp(
              title: 'Future Express',
              debugShowCheckedModeBanner: false,
              theme: appTheme(),
              locale: state.locale,
              supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                CountryLocalizations.delegate,
              ],
              home: state.signedIn ? const AppShell() : const LoginScreen(),
              onGenerateRoute: AppRouters.onGenerateRoute,
              navigatorKey: AppRouters.navigatorKey,
              builder: (context, child) => BotToastInit()(
                context,
                AppScope(state: state, child: child!),
              ),
              navigatorObservers: [BotToastNavigatorObserver()],
            ),
          ),
        ),
      );
}
