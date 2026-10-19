import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatter.dart';
import '../controller/job_controller.dart';
import '../models/job_create_response_model.dart';
import 'job_card.dart';
import 'status_chip.dart';

/// Renders the current [jobProvider] list as [JobCard]s, handling the
/// loading / empty states.
///
/// Set [paginate] to load more pages as the user scrolls (All Jobs);
/// leave it off for a fixed, non-scrolling preview embedded in another
/// scroll view (Home "Recent Jobs" — shows just the first page).
class JobListView extends ConsumerWidget {
  const JobListView({super.key, this.paginate = false, this.onJobTap});

  final bool paginate;

  /// Called when a job is tapped. Defaults to opening the job's progress
  /// screen.
  final ValueChanged<JobModel>? onJobTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(jobProvider.select((s) => s.isLoading));
    final job = ref.watch(jobProvider.select((s) => s.job));

    if (isLoading == true && job == null) {
      return Center(child: CircularProgressIndicator());
    }

    final jobs = job ?? [];

    if (jobs.isEmpty && !paginate) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No jobs yet')),
      );
    }

    if (!paginate) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _JobListTile(job: jobs[index], onJobTap: onJobTap),
      );
    }

    final hasMore = ref.watch(jobProvider.select((s) => s.hasMore));
    final isLoadingMore = ref.watch(jobProvider.select((s) => s.isLoadingMore));

    return RefreshIndicator.adaptive(
      onRefresh: () => ref.read(jobProvider.notifier).getJobs(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final nearBottom =
              notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200;
          if (nearBottom) ref.read(jobProvider.notifier).loadMore();
          return false;
        },
        child: jobs.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No jobs yet')),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: jobs.length + (hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= jobs.length) {
                    if (!isLoadingMore) return const SizedBox.shrink();
                    return Center(child: CircularProgressIndicator());
                  }
                  return _JobListTile(job: jobs[index], onJobTap: onJobTap);
                },
              ),
      ),
    );
  }
}

class _JobListTile extends ConsumerWidget {
  const _JobListTile({required this.job, this.onJobTap});

  final JobModel job;
  final ValueChanged<JobModel>? onJobTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobCtrl = ref.read(jobProvider.notifier);
    return JobCard(
      style: .card,
      customerName: job.customerName,
      address: job.propertyAddress,
      status: jobStatusFromApi(job.status),
      currentStep: job.currentStep,
      totalSteps: jobStepNames.length,
      stepLabel: jobCtrl.jobStepLabel(job.currentStep),
      date: formatDate(job.date),
      onTap: () => onJobTap != null
          ? onJobTap!(job)
          : jobCtrl.getJobById(job.id),
    );
  }
}
