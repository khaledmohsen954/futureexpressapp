import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Figma 11:428 — records a failed delivery against the selected shipment.
class DeliveryFailureScreen extends StatefulWidget {
  const DeliveryFailureScreen({super.key, required this.shipmentId});
  final String shipmentId;
  @override State<DeliveryFailureScreen> createState() => _DeliveryFailureScreenState();
}

class _DeliveryFailureScreenState extends State<DeliveryFailureScreen> {
  String? reasonKey;
  final note = TextEditingController();
  final reasons = const ['reasonUnavailable', 'reasonAddress', 'reasonRefused', 'reasonOther'];
  @override void dispose() { note.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, 'deliveryFailure'))),
    body: PageBody(children: [
      SurfaceCard(child: Row(children: [
        const Icon(Icons.inventory_2_outlined, color: AppColors.red),
        const SizedBox(width: 12), Text('#${widget.shipmentId}',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      ])),
      const SizedBox(height: 23),
      Text(tr(context, 'reasonTitle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      for (final key in reasons) Padding(padding: const EdgeInsets.only(bottom: 8),
        child: SurfaceCard(padding: EdgeInsets.zero, child: RadioListTile<String>(
          title: Text(tr(context, key)), value: key, groupValue: reasonKey,
          activeColor: AppColors.red, onChanged: (value) => setState(() => reasonKey = value)))),
      const SizedBox(height: 13),
      Text(tr(context, 'notes'), style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      TextField(controller: note, maxLines: 3,
        decoration: InputDecoration(hintText: tr(context, 'extraDetails'))),
      const SizedBox(height: 24),
      ActionButton(label: tr(context, 'confirmFailure'), icon: Icons.report_problem_outlined,
        onPressed: () {
          if (reasonKey == null) {
            showLocalMessage(context, tr(context, 'chooseReason'));
            return;
          }
          AppScope.of(context).fail(widget.shipmentId, reasonKey!, note.text.trim());
          showLocalMessage(context, tr(context, 'failureSaved'));
          Navigator.pop(context);
        }),
    ]),
  );
}
