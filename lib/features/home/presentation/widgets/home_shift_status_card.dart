import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class ShiftStatusCard extends StatelessWidget {
  const ShiftStatusCard({
    super.key,
    required this.state,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
        child: Row(children: [
      const Icon(Icons.power_settings_new, color: AppColors.red),
      const SizedBox(width: 12),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr(context, AppLocaleKey.shiftStatus), style: Theme.of(context).textTheme.labelLarge),
        Text(tr(context, AppLocaleKey.shiftHint), style: Theme.of(context).textTheme.bodySmall),
      ])),
      Switch(value: state.onDuty, activeTrackColor: AppColors.green, onChanged: state.setDuty),
    ]));
  }
}
