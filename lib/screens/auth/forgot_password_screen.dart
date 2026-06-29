import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/utils/validators.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:requra/screens/auth/verification_screen.dart';
import 'package:requra/theme/color_manager.dart';

import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  // Local-only UI state: inline validation error.
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Inline validation ──────────────────────────────────────────────────────

  void _onEmailChanged(String value) {
    setState(() => _emailError = Validators.email(value));
  }

  bool _validateForm() {
    final String? err = Validators.email(_emailController.text);
    setState(() => _emailError = err);
    return err == null;
  }

  // ── Action delegated to ForgotPasswordCubit ────────────────────────────────

  void _handleSendCode(BuildContext context) {
    if (!_validateForm()) return;
    context.read<ForgotPasswordCubit>().sendResetCode(
          email: _emailController.text,
        );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (ForgotPasswordState previous, ForgotPasswordState current) =>
          current is ForgotPasswordOtpSent || current is ForgotPasswordError,
      listener: (BuildContext context, ForgotPasswordState state) {
        if (state is ForgotPasswordOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent to your email.')),
          );
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => VerificationScreen(
                mode: VerificationMode.passwordReset,
                email: state.email,
              ),
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
                  title: 'Forgot Your Password?',
                  subtitle:
                      'Enter your email and we\'ll send you a verification code to reset your password.',
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 8.h),
                      CustomTextField(
                        hintText: 'Email Address',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _onEmailChanged,
                        errorText: _emailError,
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        text: isLoading ? 'Sending...' : 'Send Code',
                        onTap: isLoading
                            ? null
                            : () => _handleSendCode(context),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: const Text('Back to Login'),
                        ),
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
