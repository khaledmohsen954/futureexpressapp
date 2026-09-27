import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../support/support_screen.dart';

/// Figma 11:359 — account details and an Arabic/English language switch.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(appBar: AppBar(title: Text(tr(context, 'profile'))),
      body: PageBody(children: [
        SurfaceCard(child: Column(children: [
          const CircleAvatar(radius: 36, backgroundColor: Color(0xFFFFEDF0),
            child: Icon(Icons.person, size: 38, color: AppColors.red)),
          const SizedBox(height: 12),
          Text(tr(context, 'courierName'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          Text(tr(context, 'courier'), style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(tr(context, 'courierNumber'), style: const TextStyle(color: AppColors.muted)),
        ])),
        const SizedBox(height: 20), SectionTitle(tr(context, 'personalData')),
        const SizedBox(height: 8),
        SurfaceCard(child: Column(children: [
          _ProfileRow(Icons.phone_outlined, tr(context, 'phone'), state.phone),
          const Divider(),
          _ProfileRow(Icons.mail_outline, tr(context, 'email'), 'ahmed@futureexpress.sa'),
          const Divider(),
          _ProfileRow(Icons.location_on_outlined, tr(context, 'city'), tr(context, 'riyadh')),
        ])),
        const SizedBox(height: 19),
        SurfaceCard(child: InkWell(onTap: state.toggleLanguage, child: Row(children: [
          const Icon(Icons.language, color: AppColors.red), const SizedBox(width: 10),
          Expanded(child: Text(tr(context, 'changeLanguage'),
            style: const TextStyle(fontWeight: FontWeight.w700))),
          const Icon(Icons.chevron_left),
        ]))),
        const SizedBox(height: 10),
        SurfaceCard(child: InkWell(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SupportScreen())),
          child: Row(children: [
            const Icon(Icons.headset_mic_outlined, color: AppColors.red),
            const SizedBox(width: 10),
            Expanded(child: Text(tr(context, 'help'),
              style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_left),
          ]))),
        const SizedBox(height: 20),
        ActionButton(label: tr(context, 'logout'), icon: Icons.logout,
          outlined: true, onPressed: state.signOut),
      ]),
    );
  }
}

/// Label and value for one courier profile field.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.title, this.value);
  final IconData icon;
  final String title, value;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Icon(icon, color: AppColors.muted, size: 20), const SizedBox(width: 9),
      Text(title), const Spacer(),
      Flexible(child: Text(value, textAlign: TextAlign.end,
        style: const TextStyle(color: AppColors.muted, fontSize: 12))),
    ]));
}
