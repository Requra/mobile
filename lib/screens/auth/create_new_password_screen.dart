import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/screens/auth/reset_password_successfully_screen.dart';
import 'package:requra/theme/color_manager.dart';

import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/password_rules_checklist.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _isLoading = false;
  bool _passwordTypingStarted = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'New password is required';
    }

    if (!PasswordRules.isValid(value)) {
      return 'Password must meet all requirements below';
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

  bool _validateForm() {
    final String? passwordError = _validatePassword(_passwordController.text);
    final String? confirmPasswordError = _validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    setState(() {
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return passwordError == null && confirmPasswordError == null;
  }

  Future<void> _handleResetPassword() async {
    if (_isLoading) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    final response = await _authService.resetPassword(password: password);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const ResetPasswordSuccessfullyScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.firstError)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Create a new password',
              subtitle: '',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h,horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    hintText: 'New Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    onChanged: _onPasswordChanged,
                    errorText: _passwordTypingStarted ? _passwordError : null,
                  ),
                  if (_passwordTypingStarted) ...[
                    SizedBox(height: 8.h),
                    PasswordRulesChecklist(password: _passwordController.text),
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
                    text: _isLoading ? 'Updating...' : 'Update Password',
                    onTap: _handleResetPassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
