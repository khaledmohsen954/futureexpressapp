import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

/// Figma 11:465 — bilingual contact preview until real support details exist.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr(context, AppLocaleKey.help))),
        body: PageBody(children: [
          const SizedBox(height: 12),
          const Center(
              child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.paleRed,
                  child: Icon(Icons.headset_mic_outlined,
                      size: 42, color: AppColors.red))),
          const SizedBox(height: 14),
          Text(tr(context, AppLocaleKey.helpTitle),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(tr(context, AppLocaleKey.helpSubtitle),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 26),
          SurfaceCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.chat_outlined, color: AppColors.green),
                  const SizedBox(width: 9),
                  Text(tr(context, AppLocaleKey.whatsapp),
                      style: Theme.of(context).textTheme.titleSmall)
                ]),
                const SizedBox(height: 8),
                Text(tr(context, AppLocaleKey.whatsappHint),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                ActionButton(
                    label: tr(context, AppLocaleKey.openWhatsapp),
                    icon: Icons.chat,
                    color: AppColors.green,
                    onPressed: () => showLocalMessage(
                        context, tr(context, AppLocaleKey.addSupportNumber))),
              ])),
          const SizedBox(height: 13),
          SurfaceCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.phone_outlined, color: AppColors.red),
                  const SizedBox(width: 9),
                  Text(tr(context, AppLocaleKey.call),
                      style: Theme.of(context).textTheme.titleSmall)
                ]),
                const SizedBox(height: 8),
                Text(tr(context, AppLocaleKey.callHint),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                ActionButton(
                    label: tr(context, AppLocaleKey.phoneCall),
                    icon: Icons.call_outlined,
                    onPressed: () => showLocalMessage(
                        context, tr(context, AppLocaleKey.addSupportNumber))),
              ])),
          const SizedBox(height: 20),
          Text(tr(context, AppLocaleKey.supportHours),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}
