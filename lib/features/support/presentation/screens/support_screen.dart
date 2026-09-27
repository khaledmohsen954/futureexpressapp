import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

/// Figma 11:465 — bilingual contact preview until real support details exist.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, 'help'))),
    body: PageBody(children: [
      const SizedBox(height: 12),
      const Center(child: CircleAvatar(radius: 40, backgroundColor: Color(0xFFFFEDF0),
        child: Icon(Icons.headset_mic_outlined, size: 42, color: AppColors.red))),
      const SizedBox(height: 14),
      Text(tr(context, 'helpTitle'), textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(tr(context, 'helpSubtitle'), textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted)),
      const SizedBox(height: 26),
      SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.chat_outlined, color: AppColors.green),
          const SizedBox(width: 9), Text(tr(context, 'whatsapp'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 8),
        Text(tr(context, 'whatsappHint'), style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 14),
        ActionButton(label: tr(context, 'openWhatsapp'), icon: Icons.chat,
          color: AppColors.green,
          onPressed: () => showLocalMessage(context, tr(context, 'addSupportNumber'))),
      ])),
      const SizedBox(height: 13),
      SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.phone_outlined, color: AppColors.red),
          const SizedBox(width: 9), Text(tr(context, 'call'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 8),
        Text(tr(context, 'callHint'), style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 14),
        ActionButton(label: tr(context, 'phoneCall'), icon: Icons.call_outlined,
          onPressed: () => showLocalMessage(context, tr(context, 'addSupportNumber'))),
      ])),
      const SizedBox(height: 20),
      Text(tr(context, 'supportHours'), textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted)),
    ]),
  );
}
