import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Figma 11:2 — sign-in form and local entry into the app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool obscure = true;
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24), child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 35), Image.asset('assets/auth/future_express_logo.png', height: 96, fit: BoxFit.contain),
      const SizedBox(height: 36), const Text('مرحبًا بعودتك', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8), const Text('سجل دخولك لمتابعة شحناتك اليومية', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 36), const Text('رقم الجوال', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
      TextFormField(keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(hintText: '05xxxxxxxx', prefixIcon: Icon(Icons.phone_outlined)),
        validator: (value) => value == null || value.trim().isEmpty ? 'أدخل رقم الجوال' : null),
      const SizedBox(height: 20), const Text('كلمة المرور', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
      TextFormField(obscureText: obscure, decoration: InputDecoration(hintText: 'أدخل كلمة المرور', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => obscure = !obscure))),
        validator: (value) => value == null || value.isEmpty ? 'أدخل كلمة المرور' : null),
      Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => showLocalMessage(context, 'تواصل مع الدعم لاستعادة كلمة المرور'), child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: AppColors.red)))),
      const SizedBox(height: 18), ActionButton(label: 'تسجيل الدخول', icon: Icons.login, onPressed: () { if (formKey.currentState!.validate()) widget.onLogin(); }),
      const SizedBox(height: 28), const Text('Future Express  •  خدمات توصيل أسرع', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
    ]))))));
}
