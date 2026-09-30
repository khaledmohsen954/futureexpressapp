import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';
import '../../../../core/widgets.dart';

/// Figma 11:359 — account details and an Arabic/English language switch.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.profile))),
      body: PageBody(children: [
        SurfaceCard(
            child: Column(children: [
          const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.paleRed,
              child: Icon(Icons.person, size: 38, color: AppColors.red)),
          const SizedBox(height: 12),
          Text(tr(context, AppLocaleKey.courierName),
              style: Theme.of(context).textTheme.titleLarge),
          Text(tr(context, AppLocaleKey.courier),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(tr(context, AppLocaleKey.courierNumber),
              style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 20),
        SectionTitle(tr(context, AppLocaleKey.personalData)),
        const SizedBox(height: 8),
        SurfaceCard(
            child: Column(children: [
          _ProfileRow(Icons.phone_outlined, tr(context, AppLocaleKey.phone),
              state.phone),
          const Divider(),
          _ProfileRow(Icons.mail_outline, tr(context, AppLocaleKey.email),
              'ahmed@futureexpress.sa'),
          const Divider(),
          _ProfileRow(Icons.location_on_outlined,
              tr(context, AppLocaleKey.city), tr(context, AppLocaleKey.riyadh)),
        ])),
        const SizedBox(height: 19),
        SurfaceCard(
            child: InkWell(
                onTap: state.toggleLanguage,
                child: Row(children: [
                  const Icon(Icons.language, color: AppColors.red),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(tr(context, AppLocaleKey.changeLanguage),
                          style: Theme.of(context).textTheme.labelLarge)),
                  const Icon(Icons.chevron_left),
                ]))),
        const SizedBox(height: 10),
        SurfaceCard(
            child: InkWell(
                onTap: () => NavigatorMethods.pushNamed(
                    context, RoutesName.supportScreen),
                child: Row(children: [
                  const Icon(Icons.headset_mic_outlined, color: AppColors.red),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(tr(context, AppLocaleKey.help),
                          style: Theme.of(context).textTheme.labelLarge)),
                  const Icon(Icons.chevron_left),
                ]))),
        const SizedBox(height: 20),
        ActionButton(
            label: tr(context, AppLocaleKey.logout),
            icon: Icons.logout,
            outlined: true,
            onPressed: state.signOut),
      ]),
    );
  }
}

/// Label and value for one courier profile field.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.title, this.value);
  final IconData icon;
  final String title, value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: AppColors.muted, size: 20),
        const SizedBox(width: 9),
        Text(title),
        const Spacer(),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall)),
      ]));
}
