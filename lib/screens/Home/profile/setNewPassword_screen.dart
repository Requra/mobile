// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:requra/widgets/circular_icon.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/global_widgets/custom_text_field.dart';
import 'package:requra/widgets/password_rules_checklist.dart';
import 'package:requra/core/di/di_project.dart';

class setNewPasswordScreen extends StatelessWidget {
  const setNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>(),
      child: const _SetNewPasswordView(),
    );
  }
}

class _SetNewPasswordView extends StatefulWidget {
  const _SetNewPasswordView();

  @override
  State<_SetNewPasswordView> createState() => _SetNewPasswordViewState();
}

class _SetNewPasswordViewState extends State<_SetNewPasswordView> {
  final TextEditingController _currentpasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _currentPasswordError;
  bool _passwordTypingStarted = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentpasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (!PasswordRules.isValid(value)) {
      return 'Password must meet all requirements below';
    }

    return null;
  }

  String? _validateCurrentPassword(String value) {
    if (value.trim().isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _onPasswordChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        _passwordTypingStarted = true;
      }

      _passwordError = _validatePassword(value);
      _confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
        value,
      );
    });
  }

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      _confirmPasswordError = _validateConfirmPassword(
        value,
        _passwordController.text,
      );
    });
  }

  void _onCurrentPasswordChanged(String value) {
    setState(() {
      _currentPasswordError = _validateCurrentPassword(value);
    });
  }

  bool _validateForm() {
    final String? currentPasswordError = _validateCurrentPassword(
      _currentpasswordController.text,
    );
    final String? passwordError = _validatePassword(_passwordController.text);
    final String? confirmPasswordError = _validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    setState(() {
      _currentPasswordError = currentPasswordError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return currentPasswordError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  void _handleUpdatePassword() {
    if (!_validateForm()) {
      return;
    }

    context.read<ProfileCubit>().changePassword(
      _currentpasswordController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushReplacementNamed('/passwordUpdated');
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.h,
                          horizontal: 20.w,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.r),
                            ),
                            border: Border.all(
                              color: AppColors.lightgrey,
                              width: 1.5.w,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 14.w,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularIcon(icon: Icons.key),
                                SizedBox(height: 16.h),
                                Text(
                                  "Set New Password",
                                  style: boldStyle(
                                    fontSize: FontSize.font20,
                                    color: AppColors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "Create a strong password that you haven't used before.",
                                  style: regularStyle(
                                    fontSize: FontSize.font14,
                                    color: AppColors.lightgrey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 4.w,
                                    bottom: 1.5.h,
                                  ),
                                  child: Align(
                                    alignment: AlignmentGeometry.topLeft,
                                    child: Text(
                                      "Current Password",
                                      style: semiBoldStyle(
                                        fontSize: FontSize.font14,
                                        color: AppColors.lightgrey,
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextField(
                                  hintText: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  controller: _currentpasswordController,
                                  onChanged: _onCurrentPasswordChanged,
                                  errorText: _currentPasswordError,
                                ),
                                SizedBox(height: 16.h),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 4.w,
                                    bottom: 1.5.h,
                                  ),
                                  child: Align(
                                    alignment: AlignmentGeometry.topLeft,
                                    child: Text(
                                      "New Password",
                                      style: semiBoldStyle(
                                        fontSize: FontSize.font14,
                                        color: AppColors.lightgrey,
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextField(
                                  hintText: 'New Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  controller: _passwordController,
                                  onChanged: _onPasswordChanged,
                                  errorText: _passwordTypingStarted
                                      ? _passwordError
                                      : null,
                                ),
                                if (_passwordTypingStarted) ...[
                                  SizedBox(height: 8.h),
                                  PasswordRulesChecklist(
                                    password: _passwordController.text,
                                  ),
                                ],
                                SizedBox(height: 16.h),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 4.w,
                                    bottom: 1.5.h,
                                  ),
                                  child: Align(
                                    alignment: AlignmentGeometry.topLeft,
                                    child: Text(
                                      "Confirm New Password",
                                      style: semiBoldStyle(
                                        fontSize: FontSize.font14,
                                        color: AppColors.lightgrey,
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextField(
                                  hintText: 'Confirm Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  controller: _confirmPasswordController,
                                  onChanged: _onConfirmPasswordChanged,
                                  errorText: _confirmPasswordError,
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        text: "Cancel",
                                        onTap: () {
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop();
                                        },
                                        color1: AppColors.lightButton,
                                        color2: AppColors.lightButton,
                                        borderColor: AppColors.borderButton,
                                        textColor: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: CustomButton(
                                        text: isLoading
                                            ? 'Updating...'
                                            : 'Update',
                                        onTap: isLoading
                                            ? null
                                            : _handleUpdatePassword,
                                        color1: AppColors.primaryText,
                                        color2: AppColors.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
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
        );
      },
    );
  }
}
