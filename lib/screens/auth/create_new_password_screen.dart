import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/utils/validators.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:requra/screens/auth/reset_password_successfully_screen.dart';
import 'package:requra/core/theme/color_manager.dart';

import '../../widgets/auth_header.dart';
import '../../core/global_widgets/custom_button.dart';
import '../../core/global_widgets/custom_text_field.dart';
import '../../widgets/password_rules_checklist.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Local-only UI state: inline field errors and password-checklist visibility.
  bool _passwordTypingStarted = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Inline validation ──────────────────────────────────────────────────────

  void _onPasswordChanged(String value) {
    setState(() {
      if (value.isNotEmpty) _passwordTypingStarted = true;
      _passwordError = Validators.password(value);
      _confirmPasswordError = Validators.confirmPassword(
        _confirmPasswordController.text,
        value,
      );
    });
  }

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      _confirmPasswordError = Validators.confirmPassword(
        value,
        _passwordController.text,
      );
    });
  }

  bool _validateForm() {
    final String? passErr = Validators.password(_passwordController.text);
    final String? confirmErr = Validators.confirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );
    setState(() {
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });
    return passErr == null && confirmErr == null;
  }

  // ── Action delegated to ForgotPasswordCubit ────────────────────────────────

  void _handleResetPassword(BuildContext context) {
    if (!_validateForm()) return;
    context.read<ForgotPasswordCubit>().resetPassword(
          newPassword: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen:
          (ForgotPasswordState previous, ForgotPasswordState current) =>
              current is ForgotPasswordSuccess ||
              current is ForgotPasswordError,
      listener: (BuildContext context, ForgotPasswordState state) {
        if (state is ForgotPasswordSuccess) {
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const ResetPasswordSuccessfullyScreen(),
            ),
          );
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (BuildContext context, ForgotPasswordState state) {
        final bool isLoading = state is ForgotPasswordLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AuthHeader(
                  title: 'Create a new password',
                  subtitle: '',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 20.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomTextField(
                        hintText: 'New Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        onChanged: _onPasswordChanged,
                        errorText:
                            _passwordTypingStarted ? _passwordError : null,
                      ),
                      if (_passwordTypingStarted) ...<Widget>[
                        SizedBox(height: 8.h),
                        PasswordRulesChecklist(
                          password: _passwordController.text,
                        ),
                      ],
                      SizedBox(height: 14.h),
                      CustomTextField(
                        hintText: 'Confirm Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        onChanged: _onConfirmPasswordChanged,
                        errorText: _confirmPasswordError,
                      ),
                      SizedBox(height: 14.h),
                      CustomButton(
                        text: isLoading ? 'Updating...' : 'Update Password',
                        onTap: isLoading
                            ? null
                            : () => _handleResetPassword(context),
                      ),
                    ],
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
