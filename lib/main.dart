import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/app_shell.dart';

/// Application entry point; screens work locally without network services.
void main() => runApp(const FutureExpressApp());

class FutureExpressApp extends StatefulWidget {
  const FutureExpressApp({super.key});
  @override State<FutureExpressApp> createState() => _FutureExpressAppState();
}

class _FutureExpressAppState extends State<FutureExpressApp> {
  bool signedIn = false;
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Future Express', debugShowCheckedModeBanner: false,
    theme: appTheme(), locale: const Locale('ar', 'SA'),
    builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    home: signedIn ? AppShell(onSignOut: () => setState(() => signedIn = false))
      : LoginScreen(onLogin: () => setState(() => signedIn = true)),
  );
}
