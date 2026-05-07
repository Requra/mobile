import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const int _maxAvatarBytes = 5 * 1024 * 1024;

  final TextEditingController _nameController = TextEditingController(text: 'ziad');
  final AuthService _authService = const AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isEditing = false;
  bool _isUpdatingProfile = false;
  bool _isLoadingProfile = false;
  bool _pushNotificationsEnabled = true;
  bool _emailDigestsEnabled = false;
  bool _isUploadingAvatar = false;
  String _selectedLanguage = 'English';
  String _avatarUrl = '';
  File? _avatarFile;

  String _savedName = 'ziad';
  String _email = 'ziad@gmail.com';
  String _jobTitle = 'Project Manager';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    _nameController.text = _savedName;

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _loadProfile() async {
    if (_isLoadingProfile) {
      return;
    }

    setState(() {
      _isLoadingProfile = true;
    });

    final response = await _authService.getProfile();

    if (!mounted) {
      return;
    }

    if (response.isSuccess && response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final String loadedName = (data['name'] ?? _savedName).toString().trim();
      final String loadedEmail = (data['email'] ?? _email).toString().trim();
      final String loadedJobTitle =
          (data['jobTitle'] ?? _jobTitle).toString().trim();
      final String loadedAvatar =
          (data['avatarUrl'] ?? _avatarUrl).toString().trim();

      setState(() {
        _savedName = loadedName.isEmpty ? _savedName : loadedName;
        _email = loadedEmail.isEmpty ? _email : loadedEmail;
        _jobTitle = loadedJobTitle.isEmpty ? _jobTitle : loadedJobTitle;
        if (loadedAvatar.isNotEmpty) {
          _avatarUrl = loadedAvatar;
          _avatarFile = null;
        }
        _nameController.text = _savedName;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }

    setState(() {
      _isLoadingProfile = false;
    });
  }

  Future<void> _updateProfile() async {
    if (_isUpdatingProfile) {
      return;
    }

    final String newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required.')),
      );
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    final response = await _authService.updateProfile(name: newName);

    if (!mounted) {
      return;
    }

    if (response.isSuccess && response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final String updatedName = (data['name'] ?? newName).toString().trim();
      final String updatedEmail = (data['email'] ?? _email).toString().trim();
      final String updatedJobTitle =
          (data['jobTitle'] ?? _jobTitle).toString().trim();
      final String updatedAvatar =
          (data['avatarUrl'] ?? _avatarUrl).toString().trim();

      setState(() {
        _savedName = updatedName.isEmpty ? _savedName : updatedName;
        _email = updatedEmail.isEmpty ? _email : updatedEmail;
        _jobTitle = updatedJobTitle.isEmpty ? _jobTitle : updatedJobTitle;
        if (updatedAvatar.isNotEmpty) {
          _avatarUrl = updatedAvatar;
          _avatarFile = null;
        }
        _nameController.text = _savedName;
        _isEditing = false;
      });
    }

    setState(() {
      _isUpdatingProfile = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }

  ImageProvider _resolveAvatarImage() {
    if (_avatarFile != null) {
      return FileImage(_avatarFile!);
    }

    if (_avatarUrl.trim().isNotEmpty) {
      return NetworkImage(_avatarUrl);
    }

    return const AssetImage('assets/images/RequraAvatar.png');
  }

  Future<void> _pickAvatarFromGallery() async {
    await _pickAvatar(ImageSource.gallery);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    if (_isUploadingAvatar) {
      return;
    }

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      return;
    }

    final File file = File(pickedFile.path);
    final int sizeBytes = await file.length();

    if (sizeBytes > _maxAvatarBytes) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size must be less than 5MB.')),
      );
      return;
    }

    final File? previousFile = _avatarFile;
    final String previousUrl = _avatarUrl;

    setState(() {
      _isUploadingAvatar = true;
      _avatarFile = file;
    });

    final response = await _authService.uploadAvatar(file: file);

    if (!mounted) {
      return;
    }

    if (response.isSuccess && response.data is Map<String, dynamic>) {
      final String newUrl =
          (response.data['avatarUrl'] ?? '').toString().trim();
      if (newUrl.isNotEmpty) {
        setState(() {
          _avatarUrl = newUrl;
        });
      }
    } else {
      setState(() {
        _avatarFile = previousFile;
        _avatarUrl = previousUrl;
      });
    }

    setState(() {
      _isUploadingAvatar = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }

  Future<void> _confirmDeleteAccount() async {
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
      _handleDeleteAccount();
    }
  }

  Future<void> _handleDeleteAccount() async {
    final response = await _authService.deleteAccount();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );

    if (response.isSuccess) {
      await _authService.clearSessionTokens();
      if (!mounted) {
        return;
      }
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  Future<void> _chooseLanguage() async {
    final String? selected = await showModalBottomSheet<String>(
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
                _LanguageOption(
                  label: 'English',
                  isSelected: _selectedLanguage == 'English',
                  onTap: () => Navigator.pop(context, 'English'),
                ),
                _LanguageOption(
                  label: 'Arabic',
                  isSelected: _selectedLanguage == 'Arabic',
                  onTap: () => Navigator.pop(context, 'Arabic'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _selectedLanguage) {
      setState(() {
        _selectedLanguage = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHomeScreen,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 2.h,
                  color: AppColors.statusInProgress,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TopBar(),
                        SizedBox(height: 18.h),
                        Text(
                          'Profile Settings',
                          style: boldStyle(
                            fontSize: FontSize.font24,
                            color: AppColors.darkgrey,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _ProfileCard(
                          nameController: _nameController,
                          email: _email,
                          role: _jobTitle,
                          isEditing: _isEditing,
                          displayName: _savedName,
                          avatarImage: _resolveAvatarImage(),
                          isUploadingAvatar: _isUploadingAvatar,
                          onEditAvatar: _pickAvatarFromGallery,
                          onStartEditing: _startEditing,
                          onCancelEditing: _cancelEditing,
                          onUpdateProfile: _updateProfile,
                          isUpdatingProfile: _isUpdatingProfile,
                        ),
                        SizedBox(height: 16.h),
                        const _SectionLabel(label: 'ACCOUNT'),
                        SizedBox(height: 10.h),
                        _SettingsTile(
                          title: 'Email',
                          subtitle: _email,
                          icon: Icons.mail_outline,
                          iconColor: Color(0xFF7B5DD4),
                          iconBackground: Color(0xFFEDE7FF),
                        ),
                        _SettingsTile(
                          title: 'Change Password',
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFF7B5DD4),
                          iconBackground: const Color(0xFFEDE7FF),
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed('/resetPassword');
                          },
                        ),
                        _SettingsTile(
                          title: 'Role',
                          subtitle: _jobTitle,
                          icon: Icons.manage_accounts_outlined,
                          iconColor: Color(0xFF7B5DD4),
                          iconBackground: Color(0xFFEDE7FF),
                        ),
                        SizedBox(height: 12.h),
                        const _SectionLabel(label: 'PREFERENCES'),
                        SizedBox(height: 10.h),
                        _SettingsTile(
                          title: 'Language',
                          subtitle: _selectedLanguage,
                          icon: Icons.language,
                          iconColor: Color(0xFF7B5DD4),
                          iconBackground: Color(0xFFEDE7FF),
                          showChevron: true,
                          onTap: _chooseLanguage,
                        ),
                        _SettingsToggleTile(
                          title: 'Push Notifications',
                          subtitle: 'AI complete, approvals, comments',
                          icon: Icons.notifications_none,
                          iconColor: const Color(0xFFE2A310),
                          iconBackground: const Color(0xFFFFF3CF),
                          value: _pushNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _pushNotificationsEnabled = value;
                            });
                          },
                        ),
                        _SettingsToggleTile(
                          title: 'Email Digests',
                          subtitle: 'Weekly summary',
                          icon: Icons.mail_outline,
                          iconColor: const Color(0xFF3383E1),
                          iconBackground: const Color(0xFFDDEBFF),
                          value: _emailDigestsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _emailDigestsEnabled = value;
                            });
                          },
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
                        _DangerZoneCard(
                          onDelete: _confirmDeleteAccount,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoadingProfile)
              Positioned.fill(
                child: Container(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.6),
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
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: const Color(0xFFEDE7FF),
          ),
          child: Image(image:const AssetImage('assets/images/logo.png'), height: 16.h, width: 16.w, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.smart_toy,
              color: const Color(0xFF7B5DD4),
              size: 14.sp,
            );
          }),
        ),
        const Spacer(),
        const _ActionIcon(icon: Icons.notifications_none),
        SizedBox(width: 10.w),
        const _ActionIcon(icon: Icons.menu),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE4E4E8)),
      ),
      child: Icon(
        icon,
        color: AppColors.grey,
        size: 17.sp,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.nameController,
    required this.email,
    required this.role,
    required this.displayName,
    required this.isEditing,
    required this.avatarImage,
    required this.isUploadingAvatar,
    required this.onEditAvatar,
    required this.onStartEditing,
    required this.onCancelEditing,
    required this.onUpdateProfile,
    required this.isUpdatingProfile,
  });

  final TextEditingController nameController;
  final String email;
  final String role;
  final String displayName;
  final bool isEditing;
  final ImageProvider avatarImage;
  final bool isUploadingAvatar;
  final VoidCallback onEditAvatar;
  final VoidCallback onStartEditing;
  final VoidCallback onCancelEditing;
  final VoidCallback onUpdateProfile;
  final bool isUpdatingProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightPrimary, width: 1.1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 52.w,
                height: 52.w,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 52.w,
                      height: 52.w,
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundImage: avatarImage,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD8D8DE)),
                        ),
                        child: isUploadingAvatar
                            ? Padding(
                                padding: EdgeInsets.all(2.w),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryText,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.camera_alt),
                                iconSize: 10.sp,
                                color: AppColors.lightgrey,
                                padding: EdgeInsets.zero,
                                onPressed: onEditAvatar,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: semiBoldStyle(
                        fontSize: FontSize.font16,
                        color: AppColors.darkgrey,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: regularStyle(
                        fontSize: FontSize.font12,
                        color: AppColors.lightgrey,
                      ),
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   icon: Icon(Icons.close),
              //   iconSize: 18.sp,
              //   color: AppColors.grey,
              //   onPressed: () {},
              // ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFE5E5EA), height: 1.h),
          SizedBox(height: 10.h),
          _ProfileInfoRow(
            label: 'Name',
            value: displayName,
            isEditable: true,
            isEditing: isEditing,
            controller: nameController,
          ),
          _ProfileInfoRow(label: 'Email account', value: email),
          _ProfileInfoRow(label: 'Role', value: role),
          SizedBox(height: 4.h),
          isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Cancel',
                        isPrimary: false,
                        onTap: onCancelEditing,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _ActionButton(
                        label: isUpdatingProfile ? 'Updating...' : 'Update',
                        isPrimary: true,
                        onTap: onUpdateProfile,
                      ),
                    ),
                  ],
                )
              : _ActionButton(
                  label: 'Edit',
                  isPrimary: true,
                  onTap: onStartEditing,
                  fullWidth: true,
                ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.isEditable = false,
    this.isEditing = false,
    this.controller,
  });

  final String label;
  final String value;
  final bool isEditable;
  final bool isEditing;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: regularStyle(
                fontSize: FontSize.font14,
                color: AppColors.darkgrey,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          if (isEditable && isEditing && controller != null)
            SizedBox(
              width: 160.w,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.end,
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFD5D5DB)),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: regularStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      height: 40.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primaryText : const Color(0xFFF2F2F7),
          foregroundColor: isPrimary ? AppColors.white : AppColors.primaryText,
          elevation: 0,
          side: BorderSide(
            color: isPrimary ? AppColors.primaryText : const Color(0xFFC8C8D0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          label,
          style: semiBoldStyle(
            fontSize: FontSize.font14,
            color: isPrimary ? AppColors.white : AppColors.primaryText,
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: semiBoldStyle(
        fontSize: FontSize.font10,
        color: AppColors.primaryText,
      ).copyWith(letterSpacing: 1.5),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.subtitle,
    this.showChevron = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: iconBackground,
              ),
              child: Icon(
                icon,
                size: 19.sp,
                color: iconColor,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: semiBoldStyle(
                      fontSize: FontSize.font16,
                      color: AppColors.darkgrey,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        subtitle!,
                        style: regularStyle(
                          fontSize: FontSize.font12,
                          color: AppColors.lightgrey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: AppColors.lightgrey,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: iconBackground,
            ),
            child: Icon(
              icon,
              size: 19.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: semiBoldStyle(
                    fontSize: FontSize.font16,
                    color: AppColors.darkgrey,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.darkPrimary,
            inactiveThumbColor: const Color(0xFFBFC4CC),
            inactiveTrackColor: const Color(0xFFE1E4E8),
          ),
        ],
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF0C9C0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: const Color(0xFFD04A2B),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Account',
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.darkgrey,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Permanently remove your account and all associated data.',
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            height: 36.h,
            child: ElevatedButton(
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD04A2B),
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Delete Account',
                style: semiBoldStyle(
                  fontSize: FontSize.font12,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryText : const Color(0xFFD8D8DE),
          ),
          color: isSelected ? const Color(0xFFF2EEFF) : AppColors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: regularStyle(
                  fontSize: FontSize.font14,
                  color: AppColors.darkgrey,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18.sp,
                color: AppColors.primaryText,
              ),
          ],
        ),
      ),
    );
  }
}

