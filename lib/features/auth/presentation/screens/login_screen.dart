import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

/// Figma 11:2 — bilingual local sign-in; the phone is stored in AppState.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final phone = TextEditingController();
  bool obscure = true;
  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                            onPressed: AppScope.of(context).toggleLanguage,
                            icon: const Icon(Icons.language),
                            label: Text(
                                tr(context, AppLocaleKey.changeLanguage)))),
                    const SizedBox(height: 18),
                    Image.asset(
                      AppImages.fexLogo1024_500NoBG,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    const SizedBox(height: 26),
                    Text(tr(context, AppLocaleKey.loginTitle),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(tr(context, AppLocaleKey.loginSubtitle),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 36),
                    Text(tr(context, AppLocaleKey.phone),
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                            hintText: tr(context, AppLocaleKey.phoneHint),
                            prefixIcon: const Icon(Icons.phone_outlined)),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? tr(context, AppLocaleKey.phoneRequired)
                                : null),
                    const SizedBox(height: 20),
                    Text(tr(context, AppLocaleKey.password),
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                        obscureText: obscure,
                        decoration: InputDecoration(
                            hintText: tr(context, AppLocaleKey.passwordHint),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                                icon: Icon(obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined))),
                        validator: (value) => value == null || value.isEmpty
                            ? tr(context, AppLocaleKey.passwordRequired)
                            : null),
                    Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                            onPressed: () => showLocalMessage(context,
                                tr(context, AppLocaleKey.passwordHelp)),
                            child: Text(tr(context, AppLocaleKey.forgot),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppColors.red)))),
                    const SizedBox(height: 18),
                    ActionButton(
                        label: tr(context, AppLocaleKey.login),
                        icon: Icons.login,
                        onPressed: () {
                          if (formKey.currentState!.validate())
                            AppScope.of(context).signIn(phone.text.trim());
                        }),
                    const SizedBox(height: 28),
                    Text(tr(context, AppLocaleKey.loginFooter),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
            )),
      )));
}
