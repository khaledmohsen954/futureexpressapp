import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/home/data/repositories/shift_repository.dart';

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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr(context, AppLocaleKey.shiftStatus),
            style: Theme.of(context).textTheme.labelLarge),
        Text(tr(context, AppLocaleKey.shiftHint),
            style: Theme.of(context).textTheme.bodySmall),
      ])),
      Switch(
        value: state.onDuty,
        activeTrackColor: AppColors.green,
        onChanged: state.isUpdatingDuty
            ? null
            : (value) async {
                final result = await state.setDuty(
                  value,
                  sl<ShiftRepository>(),
                );
                if (!context.mounted) return;
                result.fold(
                  (failure) => showLocalMessage(context, failure.errMessage),
                  (_) {},
                );
              },
      ),
    ]));
  }
}
