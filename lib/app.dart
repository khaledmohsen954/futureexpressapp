import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/state/app_state.dart';
import 'core/theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/app_shell.dart';

/// Root widget wires state, locale, theme and the signed-in navigation shell.
class FutureExpressApp extends StatefulWidget {
  const FutureExpressApp({super.key, required this.state});
  final AppState state;
  @override State<FutureExpressApp> createState() => _FutureExpressAppState();
}

class _FutureExpressAppState extends State<FutureExpressApp> {
  late final AppState state = widget.state;
  @override void dispose() { state.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
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
      ],
      builder: (context, child) => AppScope(state: state, child: child!),
      home: state.signedIn ? const AppShell() : const LoginScreen(),
    ),
  );
}
