import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/utils/navigator_methods.dart';
import 'package:futureexpressapp/core/widgets/action_button.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipment_status_cubit.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_details_card.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_qr_card.dart';

class ShipmentDetailsScreen extends StatelessWidget {
  const ShipmentDetailsScreen({super.key, required this.shipment});

  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final statusCubit = context.watch<ShipmentStatusCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, AppLocaleKey.shipmentDetails)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ShipmentQRCad(shipment: shipment),
              const SizedBox(height: 15),
              ShipmentDetailsCard(shipment: shipment),
              const SizedBox(height: 15),
              ActionButton(
                label: tr(context, AppLocaleKey.markDelivered),
                icon: Icons.check_circle_outline,
                color: AppColors.green,
                onPressed: statusCubit.state.isLoading
                    ? null
                    : () async {
                        final success = await context
                            .read<ShipmentStatusCubit>()
                            .updateStatus(
                          orderIds: [
                            shipment.orderId ?? shipment.id,
                          ],
                          statusId: ShipmentStatusApi.statusDelivered,
                          notes: '',
                        );
                        if (!context.mounted) return;
                        if (!success) {
                          final state =
                              context.read<ShipmentStatusCubit>().state;
                          showLocalMessage(
                            context,
                            state.locationUnavailable
                                ? tr(
                                    context,
                                    AppLocaleKey.shipmentStatusLocationRequired,
                                  )
                                : state.errorMessage ??
                                    tr(
                                      context,
                                      AppLocaleKey.shipmentStatusUpdateFailed,
                                    ),
                          );
                          return;
                        }
                        showLocalMessage(
                          context,
                          context
                                  .read<ShipmentStatusCubit>()
                                  .state
                                  .successMessage ??
                              tr(context, AppLocaleKey.deliverySaved),
                        );
                        Navigator.pop(context, true);
                      },
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: tr(context, AppLocaleKey.deliveryFailure),
                icon: Icons.report_problem_outlined,
                outlined: true,
                onPressed: statusCubit.state.isLoading
                    ? null
                    : () async {
                        final success = await NavigatorMethods.pushNamed(
                          context,
                          RoutesName.deliveryFailureScreen,
                          arguments: shipment,
                        );
                        if (success == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
              ),
              if (AppScope.of(context).failureReasons.containsKey(shipment.id))
                Text(
                  '${tr(context, AppScope.of(context).failureReasons[shipment.id]!)} ${AppScope.of(context).failureNotes[shipment.id] ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
