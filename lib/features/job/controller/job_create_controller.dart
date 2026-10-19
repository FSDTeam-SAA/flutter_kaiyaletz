import 'package:flutter_kaiyaletz/core/utils/app_snackbar.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/core/utils/validators.dart';
import 'package:flutter_kaiyaletz/features/job/repos/job_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'job_controller.dart';

final jobCreateProvider =
    NotifierProvider.autoDispose<JobCreateController, JobCreateState>(
      JobCreateController.new,
    );

class JobCreateState {
  final DateTime? date;
  final String customerName;
  final String propertyAddress;
  final String phoneNumber;
  final String emailAddress;
  final String notes;

  final bool isLoading;
  final String dateError;
  final String errorMsg;

  JobCreateState({
    this.date,
    this.customerName = '',
    this.propertyAddress = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.notes = '',
    this.isLoading = false,
    this.dateError = '',
    this.errorMsg = '',
  });

  JobCreateState copyWith({
    DateTime? date,
    String? customerName,
    String? propertyAddress,
    String? phoneNumber,
    String? emailAddress,
    String? notes,
    bool? isLoading,
    String? dateError,
    String? errorMsg,
  }) {
    return JobCreateState(
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      dateError: dateError ?? this.dateError,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

class JobCreateController extends Notifier<JobCreateState> {
  @override
  JobCreateState build() {
    return JobCreateState();
  }

  /// [Function] update the selected job date
  void setDate(DateTime date) {
    state = state.copyWith(date: date, dateError: '');
  }

  /// [Function] flag that no date has been selected yet
  void markDateRequired() {
    state = state.copyWith(dateError: 'Please select a date');
  }

  /// [Function] validate the selected date, flagging it if missing
  bool validateDate() {
    final hasDate = state.date != null;
    if (!hasDate) markDateRequired();
    return hasDate;
  }

  String? validateRequired(String? value, String fieldName) {
    return Validators.required(value, message: '$fieldName is required');
  }

  String? validateEmail(String? value) {
    return Validators.email(
      value,
      requiredMessage: 'Email address is required',
      invalidMessage: 'Enter a valid email address',
    );
  }

  void setCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  void setPropertyAddress(String value) {
    state = state.copyWith(propertyAddress: value);
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  void setEmailAddress(String value) {
    state = state.copyWith(emailAddress: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  /// [Function] create a new job
  Future<void> createJob() async {
    if (state.date == null) {
      state = state.copyWith(dateError: 'Please select a date');
      return;
    }

    final repo = ref.read(jobRepo);

    state = state.copyWith(isLoading: true, dateError: '', errorMsg: '');

    final result = await repo.createJob(
      date: state.date!,
      customerName: state.customerName,
      propertyAddress: state.propertyAddress,
      phoneNumber: state.phoneNumber,
      emailAddress: state.emailAddress,
      notes: state.notes,
    );

    result.fold(
      (f) {
        state = state.copyWith(isLoading: false, errorMsg: f.message);
      },
      (s) async {
        state = state.copyWith(errorMsg: '');
        AppSnackbar.success(s.message);
        ref.read(jobProvider.notifier).addJob(s.data);

        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(isLoading: false);
        AppNav.back();
      },
    );
  }
}
