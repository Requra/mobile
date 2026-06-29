import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/utils/validators.dart';
import 'package:requra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import 'forgot_password_screen.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_auth_buttons_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Local-only UI state: inline field errors and the "remember me" toggle.
  // These are pure presentation concerns — AuthCubit never knows about them.
  bool _rememberMe = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Inline validation (runs on every keystroke and on submit) ──────────────

  void _onEmailChanged(String value) {
    setState(() => _emailError = Validators.email(value));
  }

  void _onPasswordChanged(String value) {
    setState(() => _passwordError = Validators.loginPassword(value));
  }

  bool _validateForm() {
    final String? emailErr = Validators.email(_emailController.text);
    final String? passErr = Validators.loginPassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  // ── Actions delegated to AuthCubit ─────────────────────────────────────────

  void _handleLogin(BuildContext context) {
    if (!_validateForm()) return;
    context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _handleGoogleLogin(BuildContext context) {
    context.read<AuthCubit>().loginWithGoogle();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      // Only react to transitions that are relevant to this screen.
      listenWhen: (AuthState previous, AuthState current) =>
          current is AuthAuthenticated ||
          current is AuthError ||
          current is AuthUnauthenticated,
      listener: (BuildContext context, AuthState state) {
        if (state is AuthAuthenticated) {
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
        // AuthUnauthenticated on this screen means Google sign-in was
        // cancelled — simply dismiss the loader, nothing else needed.
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
                  title: 'Welcome Back to Requra.ai',
                  subtitle:
                      'Sign in to access your AI-powered requirements workspace.',
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                        errorText: _passwordError,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _rememberMe,
                            visualDensity: VisualDensity.compact,
                            activeColor: AppColors.primaryText,
                            onChanged: (bool? value) {
                              setState(() => _rememberMe = value!);
                            },
                          ),
                          Text(
                            'Remember me',
                            style: regularStyle(
                              fontSize: FontSize.font16,
                              color: AppColors.black,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot your password?',
                              style: regularStyle(
                                fontSize: FontSize.font16,
                                color: AppColors.primaryText,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      CustomButton(
                        text: isLoading ? 'Loading...' : 'Login',
                        onTap: isLoading
                            ? null
                            : () => _handleLogin(context),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'New here? ',
                            style: regularStyle(
                              fontSize: FontSize.font14,
                              color: AppColors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: Text(
                              'Create an account',
                              style: semiBoldStyle(
                                fontSize: FontSize.font14,
                                color: AppColors.primaryText,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SocialAuthButtonsRow(
                        onGoogleTap: () => _handleGoogleLogin(context),
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
