import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../../shipments/domain/shipment.dart';

/// Figma 11:326 — balance and transaction rows track delivered shipments.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final english = state.locale.languageCode == 'en';
    final paid = state.shipments.where((s) => s.status == ShipmentStatus.delivered).toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.wallet))),
      body: PageBody(children: [
        SurfaceCard(
            color: AppColors.navy,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.onDark),
                const SizedBox(width: 8),
                Text(tr(context, AppLocaleKey.currentBalance),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onDarkMuted))
              ]),
              const SizedBox(height: 13),
              Money(state.totalCollected, color: AppColors.onDark, size: 33),
              const SizedBox(height: 8),
              Text(tr(context, AppLocaleKey.lastUpdated),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onDarkMuted)),
            ])),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _Balance(tr(context, AppLocaleKey.todayCollection), state.totalCollected,
                  Icons.payments_outlined)),
          const SizedBox(width: 9),
          Expanded(
              child: _Balance(tr(context, AppLocaleKey.dueAmounts), state.pendingAmount,
                  Icons.receipt_long_outlined)),
        ]),
        const SizedBox(height: 20),
        SectionTitle(tr(context, AppLocaleKey.recentTransactions)),
        const SizedBox(height: 8),
        if (paid.isEmpty) SurfaceCard(child: Text(tr(context, AppLocaleKey.noShipments))),
        if (paid.isNotEmpty)
          SurfaceCard(
              child: Column(children: [
            for (var index = 0; index < paid.length; index++) ...[
              if (index > 0) const Divider(),
              _Transaction('${tr(context, AppLocaleKey.shipmentCollection)} #${paid[index].id}',
                  paid[index].amount, english ? paid[index].customerEn : paid[index].customerAr),
            ],
          ])),
      ]),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance(this.title, this.amount, this.icon);
  final String title;
  final int amount;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SurfaceCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.red),
        const SizedBox(height: 10),
        Money(
          amount,
          size: 20,
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ]));
}

class _Transaction extends StatelessWidget {
  const _Transaction(this.title, this.amount, this.customer);
  final String title, customer;
  final int amount;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        const CircleAvatar(
            backgroundColor: AppColors.paleRed,
            child: Icon(Icons.arrow_downward, color: AppColors.red)),
        const SizedBox(width: 11),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          Text(customer, style: Theme.of(context).textTheme.bodySmall),
        ])),
        Money(
          amount,
          color: AppColors.green,
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      ]));
}
