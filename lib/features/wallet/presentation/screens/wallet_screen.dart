import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/wallet/data/models/balance.dart';
import 'package:futureexpressapp/features/wallet/data/repositories/balance_repository.dart';
import 'package:futureexpressapp/features/wallet/presentation/cubit/balance_cubit.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, this.repository});

  final BalanceRepository? repository;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => BalanceCubit(
          repository: repository ?? sl<BalanceRepository>(),
        )..loadBalance(),
        child: const _WalletView(),
      );
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<BalanceCubit>().state;
    final balance = walletState.balance;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.wallet))),
      body: PageBody(children: [
        if (walletState.status == BalanceStatus.loading)
          const LinearProgressIndicator(),
        if (walletState.status == BalanceStatus.failure) ...[
          Text(
            walletState.errorMessage ??
                tr(context, AppLocaleKey.balanceLoadFailed),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.red),
          ),
          TextButton(
            onPressed: () => context.read<BalanceCubit>().loadBalance(),
            child: Text(tr(context, AppLocaleKey.retry)),
          ),
        ],
        if (balance != null) _WalletContent(balance: balance),
      ]),
    );
  }
}

class _WalletContent extends StatelessWidget {
  const _WalletContent({required this.balance});

  final Balance balance;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurfaceCard(
            color: AppColors.navy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.onDark),
                  const SizedBox(width: 8),
                  Text(
                    tr(context, AppLocaleKey.currentBalance),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onDarkMuted),
                  ),
                ]),
                const SizedBox(height: 13),
                Money(balance.totalCashCod, color: AppColors.onDark, size: 33),
                const SizedBox(height: 8),
                Text(
                  tr(context, AppLocaleKey.lastUpdated),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onDarkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: _Balance(
                tr(context, AppLocaleKey.todayCollection),
                balance.todayCollection,
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _Balance(
                tr(context, AppLocaleKey.dueAmounts),
                balance.balanceUnderSettlement,
                Icons.receipt_long_outlined,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          SectionTitle(tr(context, AppLocaleKey.recentTransactions)),
          const SizedBox(height: 8),
          if (balance.transactions.isEmpty)
            SurfaceCard(child: Text(tr(context, AppLocaleKey.noShipments))),
          for (final transaction in balance.transactions)
            _Transaction(transaction: transaction),
        ],
      );
}

class _Balance extends StatelessWidget {
  const _Balance(this.title, this.amount, this.icon);

  final String title;
  final num amount;
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
        ]),
      );
}

class _Transaction extends StatelessWidget {
  const _Transaction({required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final title = transaction['title'] ??
        transaction['description'] ??
        transaction['order_id'] ??
        transaction['id'] ??
        tr(context, AppLocaleKey.shipmentCollection);
    final amount = transaction['amount'] ??
        transaction['total'] ??
        transaction['cash_amount'] ??
        transaction['pos_amount'] ??
        0;
    final subtitle = transaction['date'] ?? transaction['notes'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        child: Row(children: [
          const CircleAvatar(
            backgroundColor: AppColors.paleRed,
            child: Icon(Icons.arrow_downward, color: AppColors.red),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title', style: Theme.of(context).textTheme.labelLarge),
                if (subtitle.toString().isNotEmpty)
                  Text('$subtitle',
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Money(amount, color: AppColors.green),
        ]),
      ),
    );
  }
}
