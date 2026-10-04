import 'dart:async';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/home/data/models/home_summary.dart';
import 'package:futureexpressapp/features/home/data/repositories/home_summary_repository.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_app_bar_methoud.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_card_staus_list.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_drawer.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_shift_status_card.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/widgets.dart';

/// Figma 11:23 — dashboard statistics come from the home summary API.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onTab, this.repository});

  final ValueChanged<int> onTab;
  final HomeSummaryRepository? repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSummary? _summary;
  String? _summaryError;
  bool _isLoadingSummary = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
  }

  Future<void> _loadSummary() async {
    if (mounted) {
      setState(() {
        _isLoadingSummary = true;
        _summaryError = null;
      });
    }
    final result = await (widget.repository ?? sl<HomeSummaryRepository>()).getHomeSummary();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isLoadingSummary = false;
        _summaryError = failure.errMessage;
      }),
      (summary) {
        AppScope.of(context).syncShiftStatus(summary.shiftStatus);
        setState(() {
          _summary = summary;
          _isLoadingSummary = false;
          _summaryError = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      drawer: HomeDrawer(state: state),
      appBar: buildHomeAppBar(context),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.welcome).replaceAll('{}', state.name ?? ''),
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 15),
        ShiftStatusCard(state: state),
        const SizedBox(height: 15),
        if (_isLoadingSummary) const LinearProgressIndicator(),
        if (_summaryError != null)
          Row(
            children: [
              Expanded(child: Text(_summaryError!)),
              TextButton(
                onPressed: _isLoadingSummary ? null : _loadSummary,
                child: Text(tr(context, AppLocaleKey.retry)),
              ),
            ],
          ),
        const SizedBox(height: 19),
        HomeCardStatusList(
          state: state,
          onTab: widget.onTab,
          summary: _summary,
          useSummary: true,
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 20),
      ]),
    );
  }
}
