import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/utils/d_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/widgets/app_buttons.dart';
import '../../../core/common/widgets/app_date_field.dart';
import '../../../core/common/widgets/app_header.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/common/widgets/bottom_action_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/job_create_controller.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _validate() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final dateValid = ref.read(jobCreateProvider.notifier).validateDate();
    return formValid && dateValid;
  }

  Future<void> _createJob() {
    return ref.read(jobCreateProvider.notifier).createJob();
  }

  @override
  Widget build(BuildContext context) {
    DPrint.log("Create Job Screen");
    final notifier = ref.read(jobCreateProvider.notifier);

    return AppScaffold(
      isLoading: ref.watch(
        jobCreateProvider.select((state) => state.isLoading),
      ),
      header: const AppHeader(title: 'Create Job'),
      bottomBar: BottomActionBar(
        child: AppPrimaryButton(
          label: 'Create Job',
          onValidate: _validate,
          onSimplePressed: _createJob,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final date = ref.watch(jobCreateProvider.select((s) => s.date));
                final dateError = ref.watch(
                  jobCreateProvider.select((s) => s.dateError),
                );
                return Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppDateField(
                      label: 'Date',
                      value: date,
                      onChanged: notifier.setDate,
                    ),
                    if (dateError.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        dateError,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Customer Name',
              hint: 'e.g. Sarah Johnson',
              onChanged: notifier.setCustomerName,
              validator: (value) =>
                  notifier.validateRequired(value, 'Customer name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Property Address',
              hint: 'e.g. 42 Maple Grove, Riverside',
              onChanged: notifier.setPropertyAddress,
              validator: (value) =>
                  notifier.validateRequired(value, 'Property address'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number',
              hint: '+(555) 000-0000',
              keyboardType: .phone,
              onChanged: notifier.setPhoneNumber,
              validator: (value) =>
                  notifier.validateRequired(value, 'Phone number'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email Address',
              hint: 'Customer@gmail.com',
              keyboardType: .emailAddress,
              onChanged: notifier.setEmailAddress,
              validator: notifier.validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes',
              hint: 'Design preferences, special requirements...',
              maxLines: 4,
              onChanged: notifier.setNotes,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final errMsg = ref.watch(
                  jobCreateProvider.select((s) => s.errorMsg),
                );
                if (errMsg.isEmpty) return const SizedBox.shrink();
                return Text(
                  errMsg,
                  style: const TextStyle(color: AppColors.error),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
