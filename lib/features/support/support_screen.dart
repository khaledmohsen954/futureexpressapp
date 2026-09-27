import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Figma 11:465 — help options shown without contact integration.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('الدعم والمساعدة')), body: PageBody(children: [
    const SizedBox(height: 12), const Center(child: CircleAvatar(radius: 40, backgroundColor: Color(0xFFFFEDF0), child: Icon(Icons.headset_mic_outlined, size: 42, color: AppColors.red))),
    const SizedBox(height: 14), const Text('كيف نقدر نساعدك؟', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
    const SizedBox(height: 5), const Text('فريق الدعم موجود لمساعدتك أثناء الوردية', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)), const SizedBox(height: 26),
    SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.chat_outlined, color: AppColors.green), SizedBox(width: 9), Text('واتساب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]), const SizedBox(height: 8), const Text('تواصل مع الدعم عبر الرسائل', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 14), ActionButton(label: 'فتح واتساب', icon: Icons.chat, color: AppColors.green, onPressed: () => showLocalMessage(context, 'أضف رقم الدعم لتفعيل واتساب'))])),
    const SizedBox(height: 13), SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.phone_outlined, color: AppColors.red), SizedBox(width: 9), Text('اتصل بنا', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]), const SizedBox(height: 8), const Text('اتصل بفريق الدعم مباشرة', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 14), ActionButton(label: 'اتصال هاتفي', icon: Icons.call_outlined, onPressed: () => showLocalMessage(context, 'أضف رقم الدعم لتفعيل الاتصال'))])),
    const SizedBox(height: 20), const Text('ساعات العمل: يوميًا على مدار الساعة', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
  ]));
}
