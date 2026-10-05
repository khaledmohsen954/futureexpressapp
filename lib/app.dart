import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/session/auth_session.dart';

import 'core/l10n/app_strings.dart';
import 'core/widgets/internet_connection_gate.dart';
import 'core/state/app_state.dart';
import 'core/theme.dart';
import 'core/theme/cubit/app_theme_cubit.dart';
import 'core/utils/location_requirement.dart';
import 'features/profile/presentation/screens/profile_splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/app_shell.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/support/presentation/widgets/app_update_gate.dart';

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
  void initState() {
    super.initState();
    AuthSession.onUnauthenticated = state.expireSession;
    if (state.signedIn) {
      unawaited(state.refreshProfile(sl<ProfileRepository>()));
    }
  }

  @override
  void dispose() {
    AuthSession.onUnauthenticated = null;
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
              key: ValueKey(state.signedIn),
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
              home: !state.signedIn
                  ? const LoginScreen()
                  : state.isCheckingProfile
                      ? const ProfileSplashScreen()
                      : state.profileLoadError != null
                          ? _ProfileLoadErrorScreen(
                              message: state.profileLoadError!,
                              onRetry: () => state.refreshProfile(
                                sl<ProfileRepository>(),
                              ),
                            )
                          : const _LocationStartupPrompt(child: AppShell()),
              onGenerateRoute: AppRouters.onGenerateRoute,
              navigatorKey: AppRouters.navigatorKey,
              builder: (context, child) => BotToastInit()(
                context,
                InternetConnectionGate(
                  child: AppUpdateGate(
                    child: AppScope(state: state, child: child!),
                  ),
                ),
              ),
              navigatorObservers: [BotToastNavigatorObserver()],
            ),
          ),
        ),
      );
}

class _LocationStartupPrompt extends StatefulWidget {
  const _LocationStartupPrompt({required this.child});

  final Widget child;

  @override
  State<_LocationStartupPrompt> createState() => _LocationStartupPromptState();
}

class _LocationStartupPromptState extends State<_LocationStartupPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) LocationRequirement.requestOnAppOpen(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ProfileLoadErrorScreen extends StatelessWidget {
  const _ProfileLoadErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: Text(tr(context, AppLocaleKey.retry)),
                ),
              ],
            ),
          ),
        ),
      );
}
