import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';
import '../../../../core/widgets.dart';

class HomePickupCard extends StatelessWidget {
  const HomePickupCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
        color: AppColors.navy,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.local_shipping_outlined, color: AppColors.onDark),
            const SizedBox(width: 9),
            Text(tr(context, "pickup"),
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onDarkMuted))
          ]),
          const SizedBox(height: 7),
          Text(tr(context, "PicUp"),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onDark)),
          const SizedBox(height: 12),
          ActionButton(
              label: tr(context, AppLocaleKey.startPickup),
              icon: Icons.qr_code_scanner,
              onPressed: () => NavigatorMethods.pushNamed(context, RoutesName.pickupScreen)),
        ]));
  }
}
