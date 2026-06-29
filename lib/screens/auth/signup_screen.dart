import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/utils/validators.dart';
import 'package:requra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import 'verification_screen.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/password_rules_checklist.dart';
import '../../widgets/social_auth_buttons_row.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Local-only UI state: inline field errors and password-checklist visibility.
  // AuthCubit never sees these; they are pure presentation concerns.
  bool _passwordTypingStarted = false;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Inline validation (runs on every keystroke and on submit) ──────────────

  void _onFullNameChanged(String value) {
    setState(() => _fullNameError = Validators.required(value, 'Full name'));
  }

  void _onEmailChanged(String value) {
    setState(() => _emailError = Validators.email(value));
  }

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
    final String? fullNameErr =
        Validators.required(_fullNameController.text, 'Full name');
    final String? emailErr = Validators.email(_emailController.text);
    final String? passErr = Validators.password(_passwordController.text);
    final String? confirmErr = Validators.confirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    setState(() {
      _fullNameError = fullNameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });

    return fullNameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  // ── Actions delegated to AuthCubit ─────────────────────────────────────────

  void _handleSignup(BuildContext context) {
    if (!_validateForm()) return;
    context.read<AuthCubit>().signup(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  void _handleGoogleSignup(BuildContext context) {
    context.read<AuthCubit>().loginWithGoogle();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current is AuthAuthenticated ||
          current is AuthVerificationRequired ||
          current is AuthError ||
          current is AuthUnauthenticated,
      listener: (BuildContext context, AuthState state) {
        if (state is AuthVerificationRequired) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => VerificationScreen(
                mode: VerificationSource.signup,
                email: state.email,
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          // Google sign-up succeeded.
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (Route<dynamic> route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        // AuthUnauthenticated means Google sign-in was cancelled — no action.
      },
      builder: (BuildContext context, AuthState state) {
        final bool isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AuthHeader(
                  title: 'Create your Requra.ai account',
                  subtitle:
                      'Start generating requirements from meetings and documents using AI.',
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
                        hintText: 'Full Name',
                        icon: Icons.person_outline,
                        controller: _fullNameController,
                        onChanged: _onFullNameChanged,
                        errorText: _fullNameError,
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        hintText: 'Email Address',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _onEmailChanged,
                        errorText: _emailError,
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        onChanged: _onPasswordChanged,
                        errorText: _passwordTypingStarted ? _passwordError : null,
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
                      SizedBox(height: 22.h),
                      CustomButton(
                        text: isLoading ? 'Creating...' : 'Create Account',
                        onTap: isLoading
                            ? null
                            : () => _handleSignup(context),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Already have an account? ',
                            style: regularStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Back to Login',
                              style: regularStyle(
                                fontSize: FontSize.font12,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SocialAuthButtonsRow(
                        onGoogleTap: () => _handleGoogleSignup(context),
                        isGoogleLoading: isLoading,
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
