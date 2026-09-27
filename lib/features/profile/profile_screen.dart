import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../support/support_screen.dart';

/// Figma 11:359 — courier profile, support and sign-out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onSignOut});
  final VoidCallback onSignOut;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('حسابي')), body: PageBody(children: [
    SurfaceCard(child: Column(children: [const CircleAvatar(radius: 36, backgroundColor: Color(0xFFFFEDF0), child: Icon(Icons.person, size: 38, color: AppColors.red)), const SizedBox(height: 12), const Text('أحمد السعيد', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const Text('مندوب توصيل', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 8), const Text('رقم المندوب: FX-1002', style: TextStyle(color: AppColors.muted))])),
    const SizedBox(height: 20), const SectionTitle('البيانات الشخصية'), const SizedBox(height: 8), const SurfaceCard(child: Column(children: [_ProfileRow(Icons.phone_outlined, 'رقم الجوال', '055 123 4567'), Divider(), _ProfileRow(Icons.mail_outline, 'البريد الإلكتروني', 'ahmed@futureexpress.sa'), Divider(), _ProfileRow(Icons.location_on_outlined, 'المدينة', 'الرياض')])),
    const SizedBox(height: 19), SurfaceCard(child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())), child: const Row(children: [Icon(Icons.headset_mic_outlined, color: AppColors.red), SizedBox(width: 10), Expanded(child: Text('الدعم والمساعدة', style: TextStyle(fontWeight: FontWeight.w700))), Icon(Icons.chevron_left)]))),
    const SizedBox(height: 20), ActionButton(label: 'تسجيل الخروج', icon: Icons.logout, outlined: true, onPressed: onSignOut),
  ]));
}
class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.title, this.value);
  final IconData icon;
  final String title, value;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, color: AppColors.muted, size: 20), const SizedBox(width: 9), Text(title), const Spacer(), Flexible(child: Text(value, textAlign: TextAlign.left, style: const TextStyle(color: AppColors.muted, fontSize: 12)))]));
}
