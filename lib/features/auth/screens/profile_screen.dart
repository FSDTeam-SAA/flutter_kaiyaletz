import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/common/widgets/app_header.dart';
import '../../../core/common/widgets/app_buttons.dart';
import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/constants/assets_const.dart' hide Icons;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/gap.dart';
import '../../profile/controller/profile_controller.dart';
import '../controller/auth_controller.dart';

/// Shared full-name/contact/address form, used both for first-time profile
/// setup (after signup, when there's no stored name yet — see [AuthGate]
/// and [AuthController.login]) and for editing an existing profile from
/// Settings. [isEditing] switches the header/title/button copy and, when
/// true, prefills the fields from [profileProvider] and pops back to
/// Settings on save instead of replacing the stack with [BottomNavScreen].
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final fullNameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  final ValueNotifier<File?> avatar = ValueNotifier(null);
  String existingAvatarUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final user = ref.read(profileProvider).user;
      fullNameController.text = user?.fullName.trim() ?? '';
      contactController.text = user?.phoneNumber ?? '';
      addressController.text = user?.address ?? '';
      existingAvatarUrl = user?.profileImage.url ?? '';
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    contactController.dispose();
    addressController.dispose();
    avatar.dispose();
    super.dispose();
  }

  Future<void> pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: Text('Take a photo', style: AppTextStyles.bodyLarge),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Choose from gallery',
                style: AppTextStyles.bodyLarge,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            Gap.h(8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );

    if (picked != null) {
      avatar.value = File(picked.path);
    }
  }

  void removeAvatar() {
    avatar.value = null;
  }

  Future<void> save() {
    return ref
        .read(authCtrlProvider.notifier)
        .updateProfile(
          fullName: fullNameController.text.trim(),
          phoneNumber: contactController.text.trim(),
          address: addressController.text.trim(),
          profileImage: avatar.value,
          isEditing: widget.isEditing,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: widget.isEditing ? const AppHeader(title: 'Edit Profile') : null,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 420,
              ),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  if (!widget.isEditing) ...[
                    AppLogo(images: AppAssets.img.logo, h: 90, fit: .cover),

                    Gap.h(20),

                    /// [Text] widget for the screen title.
                    Text('Profile Setup', style: AppTextStyles.h1),

                    Gap.h(24),
                  ],

                  /// [Avatar] widget with edit/remove controls.
                  ValueListenableBuilder<File?>(
                    valueListenable: avatar,
                    builder: (context, image, child) {
                      final hasExisting =
                          image == null && existingAvatarUrl.isNotEmpty;
                      final ImageProvider? backgroundImage = image != null
                          ? FileImage(image)
                          : hasExisting
                          ? NetworkImage(existingAvatarUrl)
                          : null;

                      return Center(
                        child: Stack(
                          clipBehavior: .none,
                          children: [
                            GestureDetector(
                              onTap: pickAvatar,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: AppColors.surfaceCream,
                                backgroundImage: backgroundImage,
                                child: backgroundImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 55,
                                        color: AppColors.textMuted,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: GestureDetector(
                                onTap: backgroundImage != null
                                    ? removeAvatar
                                    : pickAvatar,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: .circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(
                                    image != null
                                        ? Icons.delete_outline
                                        : Icons.camera_alt_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  Gap.h(24),

                  /// [Text] widget for the full name label.
                  Align(
                    alignment: .centerLeft,
                    child: Text('Full Name', style: AppTextStyles.inputLabel),
                  ),
                  Gap.h(8),

                  Consumer(
                    builder: (context, ref, child) {
                      final isLoading = ref.watch(
                        authCtrlProvider.select((s) => s.isLoading),
                      );
                      return AppTextField(
                        hint: 'Enter your full name',
                        controller: fullNameController,
                        textInputAction: .next,
                        enabled: !isLoading,
                      );
                    },
                  ),

                  Gap.h(12),

                  /// [Text] widget for the contact number label.
                  Align(
                    alignment: .centerLeft,
                    child: Text(
                      'Contact Number',
                      style: AppTextStyles.inputLabel,
                    ),
                  ),
                  Gap.h(8),

                  Consumer(
                    builder: (context, ref, child) {
                      final isLoading = ref.watch(
                        authCtrlProvider.select((s) => s.isLoading),
                      );
                      return AppTextField(
                        hint: 'Enter your contact number',
                        controller: contactController,
                        keyboardType: .phone,
                        textInputAction: .next,
                        enabled: !isLoading,
                      );
                    },
                  ),

                  Gap.h(12),

                  /// [Text] widget for the address label.
                  Align(
                    alignment: .centerLeft,
                    child: Text('Address', style: AppTextStyles.inputLabel),
                  ),
                  Gap.h(8),

                  Consumer(
                    builder: (context, ref, child) {
                      final isLoading = ref.watch(
                        authCtrlProvider.select((s) => s.isLoading),
                      );
                      return AppTextField(
                        hint: 'Enter your address',
                        controller: addressController,
                        textInputAction: .done,
                        enabled: !isLoading,
                      );
                    },
                  ),

                  Gap.h(24),

                  /// [errMsg]
                  Consumer(
                    builder: (context, ref, child) {
                      final errMsg = ref.watch(
                        authCtrlProvider.select((s) => s.profileErrMsg),
                      );

                      if (errMsg.isEmpty) return const SizedBox.shrink();

                      return Column(
                        children: [
                          Text(
                            errMsg,
                            style: TextStyle(color: AppColors.error),
                          ),
                          Gap.h(8),
                        ],
                      );
                    },
                  ),

                  /// [AppPrimaryButton] widget for the save action.
                  AppPrimaryButton(
                    label: widget.isEditing ? 'Save' : 'Save Profile',
                    onAsyncPressed: save,
                  ),

                  Gap.h(16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
