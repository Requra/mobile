// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/features/profile/data/services/profile_screen_service.dart';
import 'package:requra/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:requra/features/profile/presentation/widgets/danger_zone_card.dart';
import 'package:requra/features/profile/presentation/widgets/profile_card.dart';
import 'package:requra/widgets/app_top_bar.dart';
import 'package:requra/widgets/section_label.dart';
import 'package:requra/widgets/settings_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final ProfileScreenService _profileService = ProfileScreenService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncControllerWithState(ProfileState state) {
    if (state is ProfileLoaded && !state.isEditing) {
      if (_nameController.text != state.profile.name) {
        _nameController.text = state.profile.name;
      }
    }
  }

  Future<void> _pickAvatarFromGallery() async {
    await _profileService.pickAvatarFromGallery(context);
  }

  Future<void> _confirmDeleteAccount() async {
    await _profileService.confirmDeleteAccount(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        _syncControllerWithState(state);

        if (state is ProfileActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ProfileDeleted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (state is ProfileLoggedOut) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state is ProfileLoading || state is ProfileInitial;
        ProfileLoaded? loadedState;

        if (state is ProfileLoaded) {
          loadedState = state;
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundHomeScreen,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(height: 2.h, color: AppColors.statusInProgress),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppTopBar(),
                            SizedBox(height: 18.h),
                            Text(
                              'Profile Settings',
                              style: boldStyle(
                                fontSize: FontSize.font24,
                                color: AppColors.darkgrey,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            if (loadedState != null)
                              ProfileCard(
                                nameController: _nameController,
                                email: loadedState.profile.email,
                                role: loadedState.profile.jobTitle,
                                isEditing: loadedState.isEditing,
                                displayName: loadedState.profile.name,
                                avatarImage: _profileService.resolveAvatarImage(
                                  loadedState,
                                ),
                                isUploadingAvatar:
                                    loadedState.isUploadingAvatar,
                                onEditAvatar: _pickAvatarFromGallery,
                                onStartEditing: () =>
                                    context.read<ProfileCubit>().startEditing(),
                                onCancelEditing: () => context
                                    .read<ProfileCubit>()
                                    .cancelEditing(),
                                onUpdateProfile: () => context
                                    .read<ProfileCubit>()
                                    .updateProfile(_nameController.text),
                                isUpdatingProfile:
                                    loadedState.isUpdatingProfile,
                              )
                            else if (state is ProfileError)
                              Container(
                                height: 200.h,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Failed to load profile',
                                      style: regularStyle(
                                        fontSize: FontSize.font14,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    ElevatedButton(
                                      onPressed: () => context
                                          .read<ProfileCubit>()
                                          .loadProfile(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                height: 200.h,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryText,
                                ),
                              ),
                            SizedBox(height: 16.h),
                            const SectionLabel(label: 'ACCOUNT'),
                            SizedBox(height: 10.h),
                            SettingsTile(
                              title: 'Email',
                              subtitle:
                                  loadedState?.profile.email ??
                                  (state is ProfileError
                                      ? 'Error'
                                      : 'Loading...'),
                              icon: Icons.mail_outline,
                              iconColor: const Color(0xFF7B5DD4),
                              iconBackground: const Color(0xFFEDE7FF),
                            ),
                            SettingsTile(
                              title: 'Change Password',
                              icon: Icons.lock_outline,
                              iconColor: const Color(0xFF7B5DD4),
                              iconBackground: const Color(0xFFEDE7FF),
                              onTap: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed('/resetPassword');
                              },
                            ),
                            SettingsTile(
                              title: 'Role',
                              subtitle:
                                  loadedState?.profile.jobTitle ??
                                  (state is ProfileError
                                      ? 'Error'
                                      : 'Loading...'),
                              icon: Icons.manage_accounts_outlined,
                              iconColor: const Color(0xFF7B5DD4),
                              iconBackground: const Color(0xFFEDE7FF),
                            ),
                            SizedBox(height: 12.h),
                            SettingsTile(
                              title: 'Log Out',
                              subtitle: 'Sign out of your account',
                              icon: Icons.logout,
                              iconColor: const Color(0xFFD04A2B),
                              iconBackground: const Color(0xFFFFECE7),
                              onTap: () => _profileService.confirmLogout(
                                context,
                                () => context.read<ProfileCubit>().logout(),
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Text(
                              'Danger Zone',
                              style: semiBoldStyle(
                                fontSize: FontSize.font14,
                                color: const Color(0xFFD04A2B),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            DangerZoneCard(onDelete: _confirmDeleteAccount),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading && loadedState == null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.6),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
