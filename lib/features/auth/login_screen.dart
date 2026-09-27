import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Figma 11:2 — bilingual local sign-in; the phone is stored in AppState.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final phone = TextEditingController();
  bool obscure = true;
  @override void dispose() { phone.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(
    child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Align(alignment: AlignmentDirectional.centerEnd, child: TextButton.icon(
          onPressed: AppScope.of(context).toggleLanguage,
          icon: const Icon(Icons.language), label: Text(tr(context, 'changeLanguage')))),
        const SizedBox(height: 18),
        Image.asset('assets/auth/future_express_logo.png', height: 96, fit: BoxFit.contain),
        const SizedBox(height: 36),
        Text(tr(context, 'loginTitle'), textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(tr(context, 'loginSubtitle'), textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 36),
        Text(tr(context, 'phone'), style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(controller: phone, keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(hintText: tr(context, 'phoneHint'),
            prefixIcon: const Icon(Icons.phone_outlined)),
          validator: (value) => value == null || value.trim().isEmpty
              ? tr(context, 'phoneRequired') : null),
        const SizedBox(height: 20),
        Text(tr(context, 'password'), style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(obscureText: obscure,
          decoration: InputDecoration(hintText: tr(context, 'passwordHint'),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
          validator: (value) => value == null || value.isEmpty
              ? tr(context, 'passwordRequired') : null),
        Align(alignment: AlignmentDirectional.centerEnd, child: TextButton(
          onPressed: () => showLocalMessage(context, tr(context, 'passwordHelp')),
          child: Text(tr(context, 'forgot'), style: const TextStyle(color: AppColors.red)))),
        const SizedBox(height: 18),
        ActionButton(label: tr(context, 'login'), icon: Icons.login,
          onPressed: () { if (formKey.currentState!.validate()) AppScope.of(context).signIn(phone.text.trim()); }),
        const SizedBox(height: 28),
        Text(tr(context, 'loginFooter'), textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted)),
      ]),
    )),
  )));
}
