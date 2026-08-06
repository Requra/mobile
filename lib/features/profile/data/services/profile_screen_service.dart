import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:requra/features/profile/presentation/widgets/language_option.dart';

class ProfileScreenService {
  static const int _maxAvatarBytes = 5 * 1024 * 1024;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickAvatarFromGallery(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    final File file = File(pickedFile.path);
    final int sizeBytes = await file.length();

    if (sizeBytes > _maxAvatarBytes) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size must be less than 5MB.')),
      );
      return;
    }

    cubit.uploadAvatar(file);
  }

  Future<void> confirmDeleteAccount(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'This action will permanently remove your account and data. Proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD04A2B),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      cubit.deleteAccount();
    }
  }

  Future<String?> chooseLanguage(
    BuildContext context,
    String currentLanguage,
  ) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose language',
                  style: semiBoldStyle(
                    fontSize: FontSize.font18,
                    color: AppColors.darkgrey,
                  ),
                ),
                SizedBox(height: 12.h),
                LanguageOption(
                  label: 'English',
                  isSelected: currentLanguage == 'English',
                  onTap: () => Navigator.pop(context, 'English'),
                ),
                LanguageOption(
                  label: 'Arabic',
                  isSelected: currentLanguage == 'Arabic',
                  onTap: () => Navigator.pop(context, 'Arabic'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ImageProvider resolveAvatarImage(ProfileLoaded state) {
    if (state.avatarFile != null) {
      return FileImage(state.avatarFile!);
    }

    if (state.profile.avatarUrl.trim().isNotEmpty) {
      return NetworkImage(state.profile.avatarUrl);
    }

    return const AssetImage('assets/images/RequraAvatar.png');
  }

  Future<void> confirmLogout(
    BuildContext context,
    VoidCallback onConfirmed,
  ) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD04A2B),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      onConfirmed();
    }
  }
}
