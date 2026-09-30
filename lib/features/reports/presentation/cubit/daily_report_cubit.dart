import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/features/reports/data/models/daily_report.dart';
import 'package:futureexpressapp/features/reports/data/repositories/daily_report_repository.dart';

enum DailyReportStatus { initial, submitting, submitted, failure }

class DailyReportState extends Equatable {
  const DailyReportState({
    this.status = DailyReportStatus.initial,
    this.report,
    this.isLoadingSummary = false,
    this.errorMessage,
    this.successMessage,
  });

  final DailyReportStatus status;
  final DailyReport? report;
  final bool isLoadingSummary;
  final String? errorMessage;
  final String? successMessage;

  bool get isSubmitting =>
      status == DailyReportStatus.submitting || isLoadingSummary;

  @override
  List<Object?> get props =>
      [status, report, isLoadingSummary, errorMessage, successMessage];
}

class DailyReportCubit extends Cubit<DailyReportState> {
  DailyReportCubit({required DailyReportRepository repository})
      : _repository = repository,
        super(const DailyReportState());

  final DailyReportRepository _repository;

  void setSummary(DailyReport report) {
    if (state.report == report) return;
    emit(DailyReportState(report: report));
  }

  Future<void> loadSummary() async {
    if (state.isLoadingSummary || state.report != null) return;
    emit(const DailyReportState(isLoadingSummary: true));
    final result = await _repository.getDailyReport();
    if (isClosed) return;
    result.fold(
      (failure) => emit(DailyReportState(
        status: DailyReportStatus.failure,
        errorMessage: failure.errMessage,
      )),
      (report) => emit(DailyReportState(report: report)),
    );
  }

  Future<void> submit({
    required String notes,
    required int clientId,
  }) async {
    final report = state.report;
    if (state.isSubmitting ||
        state.status == DailyReportStatus.submitted ||
        report == null) {
      return;
    }

    emit(DailyReportState(
      status: DailyReportStatus.submitting,
      report: report,
    ));
    final result = await _repository.submitDailyReport(
      notes: notes,
      clientId: clientId,
      report: report,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(DailyReportState(
        status: DailyReportStatus.failure,
        report: report,
        errorMessage: failure.errMessage,
      )),
      (message) => emit(DailyReportState(
        status: DailyReportStatus.submitted,
        report: report,
        successMessage: message,
      )),
    );
  }
}
