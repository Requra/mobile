import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

import '../../core/global_widgets/custom_button.dart';
import '../../core/services/deep_link_handler.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/theme/color_manager.dart';
import '../../core/theme/font_manager.dart';
import '../../core/theme/style_manager.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../widgets/auth_header.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleContinue(BuildContext context) {
    if (_selectedRole == null || _selectedRole == 'None') {
      AppSnackbar.showError(context, 'Please select a role to continue.');
      return;
    }
    context.read<AuthCubit>().changeRole(_selectedRole!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Complete Your Profile',
                    subtitle:
                        'Please select your role to continue setting up your account.',
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 20.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your Role',
                          style: semiBoldStyle(
                            fontSize: FontSize.font16,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          hint: const Text('Select your role'),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.work_outline,
                              color: AppColors.primaryText,
                              size: 20.r,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.h,
                              horizontal: 16.w,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: AppColors.primaryText,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.primaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: AppColors.primaryText,
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Stakeholder',
                              child: Text('Stakeholder'),
                            ),
                            DropdownMenuItem(
                              value: 'BusinessAnalyst',
                              child: Text('Business Analyst'),
                            ),
                            DropdownMenuItem(
                              value: 'ProjectManager',
                              child: Text('Project Manager'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 40.h),
                        CustomButton(
                          text: isLoading ? 'Saving...' : 'Continue',
                          onTap: isLoading
                              ? null
                              : () => _handleContinue(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
