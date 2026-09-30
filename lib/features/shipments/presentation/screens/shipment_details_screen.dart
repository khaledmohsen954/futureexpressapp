import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/utils/navigator_methods.dart';
import 'package:futureexpressapp/core/widgets/action_button.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_details_card.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_qr_card.dart';

class ShipmentDetailsScreen extends StatelessWidget {
  const ShipmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, AppLocaleKey.shipmentDetails)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ShipmentQRCad(),
              SizedBox(
                height: 15,
              ),
              ShipmentDetailsCard(),
              SizedBox(
                height: 15,
              ),
              ActionButton(
                  label: tr(context, AppLocaleKey.markDelivered),
                  icon: Icons.check_circle_outline,
                  color: AppColors.green,
                  onPressed: () {
                    if (AppScope.of(context).deliver('0')) {
                      showLocalMessage(context, tr(context, AppLocaleKey.deliverySaved));
                    }
                  }),
              const SizedBox(height: 10),
              ActionButton(
                label: tr(context, AppLocaleKey.deliveryFailure),
                icon: Icons.report_problem_outlined,
                outlined: true,
                onPressed: () => NavigatorMethods.pushNamed(
                  context,
                  RoutesName.deliveryFailureScreen,
                  arguments: "1",
                ),
              ),
              if (AppScope.of(context).failureReasons.containsKey("1"))
                Text(
                    '${tr(context, AppScope.of(context).failureReasons["1"]!)} ${AppScope.of(context).failureNotes["1"] ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
