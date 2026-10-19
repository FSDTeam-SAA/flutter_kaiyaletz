import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/gap.dart';
import '../models/proposal_model.dart';
import '../repos/job_repo.dart';

/// Wraps the on-screen [ProposalCard] so it can be saved as a PNG.
/// Only one proposal is on screen at a time.
final proposalCardKey = GlobalKey();

/// 1182.5 -> "$1,182.50", 875 -> "$875"
String formatMoney(num v) {
  final fixed = v.toStringAsFixed(v % 1 == 0 ? 0 : 2);
  final [whole, ...cents] = fixed.split('.');
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '\$$grouped${cents.isEmpty ? '' : '.${cents.first}'}';
}

/// The proposal as the client sees it. Mirrors the PDF's sections; every
/// value comes from [proposal] unchanged.
class ProposalCard extends StatelessWidget {
  const ProposalCard({super.key, required this.proposal});

  final ProposalModel proposal;

  @override
  Widget build(BuildContext context) {
    final p = proposal;
    final brown = AppTextStyles.bodyMedium.copyWith(color: AppColors.primary);

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: brown),
          Gap(h: 8),
          ...children,
        ],
      ),
    );

    Widget line(String label, num value, {bool bold = false}) {
      final style =
          (bold
                  ? AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                  : AppTextStyles.bodyMedium)
              .copyWith(color: AppColors.textPrimary);
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(formatMoney(value), style: style),
          ],
        ),
      );
    }

    const divider = Divider(height: 1, color: AppColors.border);

    return RepaintBoundary(
      key: proposalCardKey,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.surfaceTag,
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.business.name,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(p.business.tagline, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatLongDate(p.date),
                        style: AppTextStyles.bodySmall,
                      ),
                      Text('Ref: ${p.jobRef}', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            section('Prepared For', [
              Text(p.customer.name, style: AppTextStyles.listTitle),
              if (p.customer.address.isNotEmpty)
                Text(p.customer.address, style: AppTextStyles.caption),
              Text(
                [
                  p.customer.phone,
                  p.customer.email,
                ].where((s) => s.isNotEmpty).join(' · '),
                style: AppTextStyles.caption,
              ),
            ]),
            if (p.layoutImageUrl case final url?) ...[
              divider,
              section('Cabinet Layout', [
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Text(
                    'Layout drawing unavailable',
                    style: AppTextStyles.caption,
                  ),
                ),
              ]),
            ],
            divider,
            section('Quotation Summary', [
              for (final l in p.lines)
                line('${l.quantity}× ${l.name}', l.lineTotal),
              Gap(h: 4),
              line('Products subtotal', p.subTotal),
              if (p.installationCharge != 0)
                line('Installation', p.installationCharge),
              if (p.deliveryCharge != 0) line('Delivery', p.deliveryCharge),
              line(
                'Tax (${p.taxRate.toStringAsFixed(p.taxRate % 1 == 0 ? 0 : 1)}%)',
                p.taxAmount,
              ),
              divider,
              Gap(h: 8),
              line('Total', p.total, bold: true),
            ]),
            divider,
            section('Terms', [Text(p.terms, style: AppTextStyles.caption)]),
          ],
        ),
      ),
    );
  }
}

/// "Download" on the Proposal step: PDF from the backend, or a PNG of the
/// card on screen. Both go to the system share sheet (Save to Files,
/// Photos, email, chat apps).
Future<void> showProposalDownloadSheet(
  BuildContext context,
  WidgetRef ref, {
  required String jobId,
  required ProposalModel proposal,
}) async {
  // iPad needs an anchor for the share popover.
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('PDF'),
            subtitle: const Text('Best for email and printing'),
            onTap: () => Navigator.pop(context, 'pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Image (PNG)'),
            subtitle: const Text('Best for chat apps'),
            onTap: () => Navigator.pop(context, 'png'),
          ),
        ],
      ),
    ),
  );
  if (choice == null) return;

  try {
    final file = choice == 'pdf'
        ? await _downloadPdf(ref.read(jobRepo), jobId, proposal)
        : await _capturePng(proposal);
    if (file == null) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], sharePositionOrigin: origin),
    );
  } catch (e) {
    AppSnackbar.error('Could not prepare the ${choice.toUpperCase()}');
  }
}

/// Through our API: the PDF is private and needs the user's token.
Future<File?> _downloadPdf(JobRepo repo, String jobId, ProposalModel p) async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/Proposal-${p.jobRef}.pdf';
  final result = await repo.downloadProposalPdf(jobId: jobId, savePath: path);
  return result.fold((f) {
    AppSnackbar.error(f.message);
    return null;
  }, (_) => File(path));
}

Future<File> _capturePng(ProposalModel p) async {
  final boundary =
      proposalCardKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/Proposal-${p.jobRef}.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  return file;
}
