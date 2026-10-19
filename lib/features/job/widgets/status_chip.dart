import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Job statuses shown in the design.
enum JobStatus { newJob, inProgress, proposalSent, completed }

extension JobStatusX on JobStatus {
  String get label => switch (this) {
    .newJob => 'New',
    .inProgress => 'In Progress',
    .proposalSent => 'Proposal Sent',
    .completed => 'Completed',
  };

  Color get color => switch (this) {
    .newJob => AppColors.statusNew,
    .inProgress => AppColors.statusInProgress,
    .proposalSent => AppColors.statusProposalSent,
    .completed => AppColors.statusCompleted,
  };

  /// The API's status string, e.g. "in_progress".
  String get apiValue => switch (this) {
    .newJob => 'new',
    .inProgress => 'in_progress',
    .proposalSent => 'proposal_sent',
    .completed => 'completed',
  };
}

/// Maps the API's status string (e.g. "in_progress") to [JobStatus].
JobStatus jobStatusFromApi(String status) {
  switch (status.toLowerCase().replaceAll('_', '')) {
    case 'inprogress':
      return .inProgress;
    case 'proposalsent':
      return .proposalSent;
    case 'completed':
      return .completed;
    default:
      return .newJob;
  }
}

/// Colored status label.
///
/// Figma: padding 6/2, background = status color at 20%,
/// text DM Sans Regular 10 in the status color.
/// Used on: Home (Recent Jobs), All Jobs, Catalog Add.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required JobStatus this.status, this.radius = 0})
    : _label = null,
      _color = null;

  /// For any other label/color (e.g. the "AI" badge on Room Capture).
  const StatusChip.custom({
    super.key,
    required String this._label,
    required Color this._color,
    this.radius = 0,
  }) : status = null;

  final JobStatus? status;
  final String? _label;
  final Color? _color;

  /// The design has square corners. Increase for a pill look.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = status?.color ?? _color!;
    final label = status?.label ?? _label!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
