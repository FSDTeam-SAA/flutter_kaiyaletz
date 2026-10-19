import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/app_loading_indicator.dart';
import 'package:flutter_kaiyaletz/core/common/widgets/widgets.dart';
import 'package:flutter_kaiyaletz/core/constants/assets_const.dart' hide Icons;
import 'package:flutter_kaiyaletz/core/theme/app_colors.dart';
import 'package:flutter_kaiyaletz/core/theme/app_text_styles.dart';
import 'package:flutter_kaiyaletz/core/utils/app_svg.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/home/controller/dashboard_controller.dart';
import 'package:flutter_kaiyaletz/features/home/models/dashboard_response_model.dart';
import 'package:flutter_kaiyaletz/features/job/screens/create_job_screen.dart';
import 'package:flutter_kaiyaletz/features/nav/controller/bottom_nav_controller.dart';
import 'package:flutter_kaiyaletz/features/profile/controller/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/d_print.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/greeting.dart';
import '../../job/controller/job_controller.dart';
import '../widgets/home_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DPrint.log("Home Screen");

    return AppScaffold(
      // isLoading: ,
      header: Consumer(
        builder: (context, ref, _) {
          final profile = ref.watch(profileProvider.select((s) => s.user));

          String greeting = greetingForNow();

          return AppHeader.custom(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceTag,
              backgroundImage:
                  profile != null && profile.profileImage.url.isNotEmpty
                  ? NetworkImage(profile.profileImage.url)
                  : null,
              child: profile == null || profile.profileImage.url.isEmpty
                  ? const Icon(Icons.person_outline, color: AppColors.textDark)
                  : null,
            ),

            middle: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(greeting, style: AppTextStyles.overline),
                Text(
                  profile?.firstName ?? "",
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textWarmDark,
                  ),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ],
            ),

            trailing: InkResponse(
              onTap: () {},
              radius: 20,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceTag,
                child: AppSvg(
                  asset: AppAssets.icons.notification,
                  width: 20,
                  height: 20,
                  color: AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
      body: Consumer(
        builder: (context, ref, _) => RefreshIndicator.adaptive(
          onRefresh: () => ref.read(dashboardProvider.notifier).getDashboard(),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            HomeHeroCard(
              illustration: Image.asset(AppAssets.img.illustration),
              onTap: () => AppNav.to(CreateJobScreen()),
            ),

            const Gap(h: 20),

            Text('Overview', style: AppTextStyles.h2),
            const Gap(h: 12),
            Consumer(
              builder: (context, ref, child) {
                final dashboard = ref.watch(
                  dashboardProvider.select((s) => s.dashboard),
                );

                return OverviewStats(
                  activeJobs: dashboard?.activeJobs ?? 0,
                  proposals: dashboard?.proposalSentJobs ?? 0,
                  thisMonthRevenue: dashboard?.thisMonthRevenue ?? 0,
                );
              },
            ),

            const Gap(h: 24),
            Consumer(
              builder: (context, ref, child) {
                return SectionHeader(
                  title: 'Recent Jobs',
                  onAction: () =>
                      ref.watch(bottomNavCtrlProvider.notifier).setIndex(1),
                );
              },
            ),

            const Gap(h: 8),
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(
                  dashboardProvider.select((s) => s.isLoading),
                );
                final recentJobs = ref.watch(
                  dashboardProvider.select((s) => s.dashboard?.recentJobs),
                );

                if (isLoading && recentJobs == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: AppLoadingIndicator()),
                  );
                }

                final jobs = recentJobs ?? [];

                if (jobs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No jobs yet')),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _RecentJobTile(job: jobs[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentJobTile extends ConsumerWidget {
  const _RecentJobTile({required this.job});

  final DashboardRecentJob job;

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
      onTap: () {
        jobCtrl.getJobById(job.id);
      },
    );
  }
}
