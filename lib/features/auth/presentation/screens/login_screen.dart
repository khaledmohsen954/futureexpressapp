import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/auth/data/repositories/login_repository.dart';
import 'package:futureexpressapp/features/auth/presentation/cubit/login_cubit.dart';
import 'package:futureexpressapp/features/profile/data/models/user_profile.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

/// Figma 11:2 — bilingual sign-in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final phone = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (_) => LoginCubit(repository: sl<LoginRepository>()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          final user = state.user;
          if (state.status == LoginStatus.success && user != null) {
            AppScope.of(context).signIn(
              phone: user.phone ?? phone.text.trim(),
              clientId: user.id,
              name: user.name,
              email: user.email,
              city: user.city,
              profile: UserProfile.fromLoginUser(user),
            );
          } else if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Login failed. Please try again.',
                ),
              ),
            );
          }
        },
        builder: (context, loginState) => Scaffold(
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
                          controller: password,
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
                          onPressed: loginState.status == LoginStatus.loading
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<LoginCubit>().login(
                                          phone: phone.text.trim(),
                                          password: password.text,
                                        );
                                  }
                                }),
                      const SizedBox(height: 28),
                      Text(tr(context, AppLocaleKey.loginFooter),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
              )),
        ))),
      ));
}
