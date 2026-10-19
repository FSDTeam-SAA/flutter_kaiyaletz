import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_kaiyaletz/core/utils/app_snackbar.dart';
import 'package:flutter_kaiyaletz/core/utils/d_print.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/job/models/job_create_response_model.dart';
import 'package:flutter_kaiyaletz/features/job/models/layout_model.dart';
import 'package:flutter_kaiyaletz/features/job/models/proposal_model.dart';
import 'package:flutter_kaiyaletz/features/job/repos/job_repo.dart';
import 'package:flutter_kaiyaletz/features/job/screens/job_pogress_screen.dart';
import 'package:flutter_kaiyaletz/features/job/widgets/elevation_view.dart';
import 'package:flutter_kaiyaletz/features/measure/model/room_spec.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/single_job_reponse_model.dart';

/// Names of the job workflow steps, in order, matching [JobModel.currentStep].
const List<String> jobStepNames = [
  "Job Details", // Step 1
  "Room Capture", // Step 2
  "Measurements", // Step 3
  "Select Product", // Step 4
  "AI Layout", // Step 5
  "Design", // Step 6
  "Estimate", // Step 7
  "Proposal", // Step 8
];

final jobProvider = NotifierProvider.autoDispose<JobController, JobState>(
  JobController.new,
);

class JobState {
  final List<JobModel>? job;
  final SingleJobResponseModel? singleJob;

  final bool? isLoading;
  final bool? isJobLoading;
  final bool isLoadingMore;

  final String jobStepTitle;
  final int? currentStep;

  final Map<String, int> selectedQty;

  /// Room being captured/edited in steps 2–3. Saved on Measurements → Continue.
  final RoomSpec? roomDraft;

  /// Cabinet placement: the saved design if there is one, else the
  /// generated layout. Rearranged in step 6. Cleared when the walls or
  /// products it was built from are saved again.
  final JobLayout? layout;
  final bool isGeneratingLayout;

  /// Estimate step inputs, saved on Estimate → Continue.
  final double installationCharge;
  final double deliveryCharge;

  /// Built by the backend; also the source of the PDF.
  final ProposalModel? proposal;
  final bool isLoadingProposal;

  final String search;
  final String? status;
  final int page;
  final int? totalPages;

  JobState({
    this.job,
    this.singleJob,

    this.isLoading = false,
    this.isJobLoading = false,
    this.isLoadingMore = false,

    this.jobStepTitle = '',
    this.currentStep,
    this.selectedQty = const {},
    this.roomDraft,
    this.layout,
    this.isGeneratingLayout = false,
    this.installationCharge = 0,
    this.deliveryCharge = 0,
    this.proposal,
    this.isLoadingProposal = false,

    this.search = '',
    this.status,
    this.page = 1,
    this.totalPages,
  });

  bool get hasMore => totalPages == null || page < totalPages!;

  JobState copyWith({
    List<JobModel>? job,
    SingleJobResponseModel? singleJob,

    bool? isLoading,
    bool? isJobLoading,
    bool? isLoadingMore,
    bool clearStatus = false,

    String? jobStepTitle,
    int? currentStep,

    Map<String, int>? selectedQty,
    RoomSpec? roomDraft,
    bool clearRoomDraft = false,
    JobLayout? layout,
    bool clearLayout = false,
    bool? isGeneratingLayout,
    double? installationCharge,
    double? deliveryCharge,
    ProposalModel? proposal,
    bool clearProposal = false,
    bool? isLoadingProposal,

    String? search,
    String? status,
    int? page,
    int? totalPages,
  }) {
    return JobState(
      job: job ?? this.job,
      singleJob: singleJob ?? this.singleJob,
      isLoading: isLoading ?? this.isLoading,
      isJobLoading: isJobLoading ?? this.isJobLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      jobStepTitle: jobStepTitle ?? this.jobStepTitle,
      currentStep: currentStep ?? this.currentStep,
      selectedQty: selectedQty ?? this.selectedQty,
      roomDraft: clearRoomDraft ? null : (roomDraft ?? this.roomDraft),
      layout: clearLayout ? null : (layout ?? this.layout),
      isGeneratingLayout: isGeneratingLayout ?? this.isGeneratingLayout,
      installationCharge: installationCharge ?? this.installationCharge,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      proposal: clearProposal ? null : (proposal ?? this.proposal),
      isLoadingProposal: isLoadingProposal ?? this.isLoadingProposal,
      search: search ?? this.search,
      status: clearStatus ? null : (status ?? this.status),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class JobController extends Notifier<JobState> {
  Timer? _searchDebounce;

  @override
  JobState build() {
    ref.onDispose(() => _searchDebounce?.cancel());
    Future.microtask(getJobs);
    return JobState();
  }

  /// Fetches page 1 with the current search/status filters, replacing the list.
  Future<void> getJobs() async {
    final repo = ref.read(jobRepo);

    state = state.copyWith(isLoading: true, page: 1);

    repo.getJobs(search: state.search, status: state.status, page: 1).listen((
      either,
    ) {
      either.fold(
        (f) {
          state = state.copyWith(isLoading: false);
        },
        (s) {
          state = state.copyWith(
            job: s.data,
            isLoading: false,
            page: s.pagination?.page ?? 1,
            totalPages: s.pagination?.pages,
          );
        },
      );
    });
  }

  /// Fetches the next page and appends it, for infinite scroll.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading == true || !state.hasMore) {
      return;
    }

    final repo = ref.read(jobRepo);
    final nextPage = state.page + 1;

    state = state.copyWith(isLoadingMore: true);

    repo
        .getJobs(search: state.search, status: state.status, page: nextPage)
        .listen((either) {
          either.fold(
            (f) {
              state = state.copyWith(isLoadingMore: false);
            },
            (s) {
              state = state.copyWith(
                job: [...?state.job, ...s.data],
                isLoadingMore: false,
                page: s.pagination?.page ?? nextPage,
                totalPages: s.pagination?.pages,
              );
            },
          );
        });
  }

  /// Debounces user input before re-querying page 1.
  void setSearch(String value) {
    state = state.copyWith(search: value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), getJobs);
  }

  /// Pass `null` to clear the status filter.
  void setStatus(String? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
    getJobs();
  }

  void addJob(JobModel job) {
    state = state.copyWith(job: [job, ...?state.job]);
  }

  /// Adds a catalog product to a job. Returns true on success.
  Future<bool> addProductToJob({
    required String jobId,
    required String productId,
    int quantity = 1,
  }) async {
    state = state.copyWith(isJobLoading: true);

    final result = await ref
        .read(jobRepo)
        .addProductToJob(
          jobId: jobId,
          productId: productId,
          quantity: quantity,
        );

    state = state.copyWith(isJobLoading: false);
    return result.isRight();
  }

  /// e.g. "Step 4: AI Layout" for currentStep == 4.
  String jobStepLabel(int currentStep) {
    final index = (currentStep - 1).clamp(0, jobStepNames.length - 1);
    return 'Step $currentStep: ${jobStepNames[index]}';
  }

  Future<void> getJobById(String jobId) async {
    final repo = ref.read(jobRepo);

    state = state.copyWith(isJobLoading: true);

    final result = await repo.getSingleJob(jobId: jobId);

    result.fold(
      (f) {
        state = state.copyWith(isJobLoading: false);
      },
      (s) {
        final step = s.data.currentStep.clamp(1, jobStepNames.length);
        final layout = s.data.design?.layout ?? s.data.aiLayout?.layoutData;

        state = state.copyWith(
          singleJob: s.data,
          currentStep: step,
          jobStepTitle: jobStepNames[step - 1],
          roomDraft: s.data.measurements?.room,
          clearRoomDraft: s.data.measurements?.room == null,
          selectedQty: {
            for (final p in s.data.selectedProducts ?? const [])
              p.productId.id: p.quantity,
          },
          layout: layout,
          clearLayout: layout == null,
          installationCharge:
              s.data.estimate?.installationCharge.toDouble() ?? 0,
          deliveryCharge: s.data.estimate?.deliveryCharge.toDouble() ?? 0,
          clearProposal: true,
          isJobLoading: false,
        );

        AppNav.to(JobPogressScreen());
      },
    );
  }

  void goToStep(int currentStep) {
    final s = currentStep.clamp(1, jobStepNames.length);

    DPrint.info("Step : $s");

    state = state.copyWith(currentStep: s, jobStepTitle: jobStepNames[s - 1]);
  }

  void nextStep() => goToStep((state.currentStep ?? 1) + 1);
  void previousStep() => goToStep((state.currentStep ?? 1) - 1);

  /// Bottom-bar Continue: saves the current step when it has data, then
  /// advances. Stays on the step if saving fails.
  Future<void> continueStep() async {
    final ok = switch (state.currentStep) {
      2 => await _saveRoomCapture(),
      3 => await _saveMeasurements(),
      4 => await _saveSelectedProducts(),
      5 => _hasLayout(),
      6 => await _saveDesign(),
      7 => await _saveEstimate(),
      _ => true,
    };
    if (ok) nextStep();
  }

  void setRoomDraft(RoomSpec room) => state = state.copyWith(roomDraft: room);

  Future<bool> _saveRoomCapture() async {
    final room = state.roomDraft;
    final jobId = state.singleJob?.id;
    if (room == null) {
      AppSnackbar.warning('Choose how to capture the room');
      return false;
    }
    if (jobId == null) return false;

    final result = await ref
        .read(jobRepo)
        .saveRoomCapture(
          jobId: jobId,
          method: room.source == .manual ? 'Manual' : 'Room Scan',
        );
    return result.fold((f) {
      AppSnackbar.error(f.message);
      return false;
    }, (_) => true);
  }

  Future<bool> _saveMeasurements() async {
    final room = state.roomDraft;
    final jobId = state.singleJob?.id;
    if (room == null) {
      AppSnackbar.warning('Capture the room first');
      return false;
    }
    if (jobId == null) return false;

    final errors = room.validate();
    if (errors.isNotEmpty) {
      AppSnackbar.warning(errors.first);
      return false;
    }

    final result = await ref
        .read(jobRepo)
        .saveMeasurements(jobId: jobId, room: room);
    return result.fold((f) {
      AppSnackbar.error(f.message);
      return false;
    }, (_) => _inputsChanged());
  }

  Future<bool> _saveSelectedProducts() async {
    final jobId = state.singleJob?.id;
    if (state.selectedQty.isEmpty) {
      AppSnackbar.warning('Select at least one product');
      return false;
    }
    if (jobId == null) return false;

    final result = await ref
        .read(jobRepo)
        .saveSelectedProducts(
          jobId: jobId,
          products: [
            for (final MapEntry(key: id, value: qty)
                in state.selectedQty.entries)
              SelectedProductInput(productId: id, quantity: qty),
          ],
        );
    return result.fold((f) {
      AppSnackbar.error(f.message);
      return false;
    }, (_) => _inputsChanged());
  }

  /// The backend drops the layout when walls or products change; match it.
  bool _inputsChanged() {
    state = state.copyWith(clearLayout: true);
    return true;
  }

  bool _hasLayout() {
    if (state.layout != null) return true;
    AppSnackbar.warning('Generate the layout first');
    return false;
  }

  /// Design step: swaps cabinet [index] with its neighbour in direction
  /// [dir] (-1 left, +1 right). Returns false if that move isn't allowed.
  bool moveItem(int index, int dir) {
    final room = state.roomDraft;
    final next = room == null
        ? null
        : state.layout?.swapWithNeighbour(room, index, dir);
    if (next == null) return false;
    state = state.copyWith(layout: next);
    return true;
  }

  /// Sends the rearranged layout plus an elevation PNG for the proposal.
  /// The backend re-checks it and returns it with fillers and checks rebuilt.
  Future<bool> _saveDesign() async {
    final room = state.roomDraft;
    final layout = state.layout;
    final jobId = state.singleJob?.id;
    if (room == null || layout == null) {
      AppSnackbar.warning('Generate the layout first');
      return false;
    }
    if (jobId == null) return false;

    Uint8List? png;
    try {
      png = await renderElevationPng(room, layout);
    } catch (e) {
      // The design is still worth saving; the proposal just lacks a drawing.
      DPrint.error('Elevation PNG failed: $e');
    }

    final result = await ref
        .read(jobRepo)
        .saveDesign(jobId: jobId, layout: layout, layoutPng: png);
    return result.fold(
      (f) {
        AppSnackbar.error(f.message);
        return false;
      },
      (s) {
        final saved = JobLayout.tryParse(s.data['design']?['layout']);
        if (saved != null) state = state.copyWith(layout: saved);
        final failed = saved?.checks.where((c) => !c.passed) ?? const [];
        if (failed.isNotEmpty) {
          AppSnackbar.warning(failed.map((c) => c.label).join(' · '));
        }
        return true;
      },
    );
  }

  void setCharges({double? installation, double? delivery}) => state = state
      .copyWith(installationCharge: installation, deliveryCharge: delivery);

  Future<bool> _saveEstimate() async {
    final jobId = state.singleJob?.id;
    if (jobId == null) return false;

    final result = await ref
        .read(jobRepo)
        .saveEstimate(
          jobId: jobId,
          installationCharge: state.installationCharge,
          deliveryCharge: state.deliveryCharge,
          taxRate: state.singleJob?.estimate?.taxRate ?? 10,
        );
    return result.fold(
      (f) {
        AppSnackbar.error(f.message);
        return false;
      },
      (_) {
        state = state.copyWith(clearProposal: true);
        return true;
      },
    );
  }

  /// Asks the backend for the proposal. It rebuilds the PDF only when
  /// something on it changed, so calling this on every visit is cheap.
  Future<void> loadProposal() async {
    final jobId = state.singleJob?.id;
    if (jobId == null || state.isLoadingProposal) return;

    state = state.copyWith(isLoadingProposal: true);
    final result = await ref.read(jobRepo).generateProposal(jobId: jobId);

    result.fold(
      (f) {
        state = state.copyWith(isLoadingProposal: false);
        AppSnackbar.error(f.message);
      },
      (s) {
        ProposalModel? proposal;
        try {
          proposal = ProposalModel.fromJson(
            s.data['proposal'] as Map<String, dynamic>,
          );
        } catch (e) {
          DPrint.error('Proposal parse failed: $e');
        }
        state = state.copyWith(proposal: proposal, isLoadingProposal: false);
        if (proposal == null) AppSnackbar.error('Could not read the proposal');
      },
    );
  }

  /// Runs the backend layout engine for the saved walls and products.
  Future<void> generateLayout() async {
    final jobId = state.singleJob?.id;
    if (jobId == null || state.isGeneratingLayout) return;

    state = state.copyWith(isGeneratingLayout: true);
    final result = await ref.read(jobRepo).generateAILayout(jobId: jobId);

    result.fold(
      (f) {
        state = state.copyWith(isGeneratingLayout: false);
        AppSnackbar.error(f.message);
      },
      (s) {
        final layout = JobLayout.tryParse(s.data['aiLayout']?['layoutData']);
        state = state.copyWith(
          layout: layout,
          clearLayout: layout == null,
          isGeneratingLayout: false,
        );
        if (layout == null) AppSnackbar.error('Could not read the layout');
      },
    );
  }

  void toggleProduct(String id) {
    final next = Map<String, int>.from(state.selectedQty);
    if (next.containsKey(id)) {
      next.remove(id);
    } else {
      next[id] = 1;
    }
    state = state.copyWith(selectedQty: next);
  }

  void setQuantity(String id, int qty) {
    if (!state.selectedQty.containsKey(id)) return;
    if (qty < 1) return;
    state = state.copyWith(selectedQty: {...state.selectedQty, id: qty});
  }
}
