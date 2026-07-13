import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

import '../../widgets/auth_header.dart';
import '../../core/global_widgets/custom_button.dart';

// ---------------------------------------------------------------------------
// Mode enum — replaces the old VerificationSource so naming is consistent
// with the cubit vocabulary.
// ---------------------------------------------------------------------------

enum VerificationMode {
  /// Confirming a newly registered account.
  signup,

  /// Verifying an OTP as part of the password-reset flow.
  passwordReset,
}

/// Backwards-compatible alias so existing callers that use `VerificationSource`
/// still compile without change.
typedef VerificationSource = VerificationMode;

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    this.mode = VerificationMode.signup,
    this.email,
  });

  final VerificationMode mode;
  final String? email;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List<FocusNode>.generate(6, (_) => FocusNode());

  // ── Local-only UI state ────────────────────────────────────────────────────
  // The 60-second resend countdown is purely a presentation concern — it must
  // NOT be moved into a cubit.
  bool _isResending = false;
  int _resendSecondsRemaining = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isPasswordResetMode =>
      widget.mode == VerificationMode.passwordReset;

  // ── Timer cooldown (pure UI) ───────────────────────────────────────────────

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsRemaining = 60);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _resendSecondsRemaining = 0);
      } else {
        setState(() => _resendSecondsRemaining--);
      }
    });
  }

  // ── Submit — dispatches to the correct cubit based on mode ─────────────────

  void _handleVerifyCode(BuildContext context) {
    final String code = _otp;
    final bool isValidLength =
        _isPasswordResetMode ? code.length >= 5 : code.length == 6;

    if (!isValidLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPasswordResetMode
                ? 'Please enter a valid OTP code.'
                : 'Please enter the 6-digit code.',
          ),
        ),
      );
      return;
    }

    if (_isPasswordResetMode) {
      context.read<ForgotPasswordCubit>().verifyResetOtp(otp: code);
    } else {
      final String email = (widget.email ?? '').trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is missing. Please register again.'),
          ),
        );
        return;
      }
      context.read<AuthCubit>().confirmAccount(
            email: email,
            otpCode: code,
          );
    }
  }

  // ── Resend — delegates to the appropriate cubit helper ────────────────────

  Future<void> _handleResendCode() async {
    if (_resendSecondsRemaining > 0 || _isResending) return;

    final String email = (widget.email ?? '').trim();
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is missing. Please go back and try again.'),
        ),
      );
      return;
    }

    // Start the 60-second UI countdown immediately (pure presentation).
    _startResendCooldown();
    setState(() => _isResending = true);

    try {
      // Capture cubit references before the async gap.
      final ForgotPasswordCubit forgotCubit =
          context.read<ForgotPasswordCubit>();
      final AuthCubit authCubit = context.read<AuthCubit>();

      final String message = _isPasswordResetMode
          ? await forgotCubit.resendResetOtp(email: email)
          : await authCubit.resendConfirmationOtp(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to resend code right now. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        // ── Signup OTP confirmed ───────────────────────────────────────────
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (AuthState previous, AuthState current) =>
              widget.mode == VerificationMode.signup &&
              (current is AuthUnauthenticated || current is AuthError),
          listener: (BuildContext context, AuthState state) {
            if (state is AuthUnauthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account confirmed! Please sign in.'),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (Route<dynamic> route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),

        // ── Password-reset OTP verified ───────────────────────────────────
        BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
          listenWhen: (ForgotPasswordState previous,
                  ForgotPasswordState current) =>
              widget.mode == VerificationMode.passwordReset &&
              (current is ForgotPasswordOtpVerified ||
                  current is ForgotPasswordError),
          listener: (BuildContext context, ForgotPasswordState state) {
            if (state is ForgotPasswordOtpVerified) {
              Navigator.pushReplacementNamed(context, '/createPassword');
            } else if (state is ForgotPasswordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],

      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState authState) {
          return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            builder:
                (BuildContext context, ForgotPasswordState forgotState) {
              final bool isLoading =
                  (widget.mode == VerificationMode.signup &&
                          authState is AuthLoading) ||
                      (widget.mode == VerificationMode.passwordReset &&
                          forgotState is ForgotPasswordLoading);

              return Scaffold(
                backgroundColor: AppColors.white,
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const AuthHeader(
                        title: 'Check Your Email',
                        subtitle:
                            'We sent a verification code to your email. Enter the code below to continue.',
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.h,
                          horizontal: 20.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // ── OTP digit boxes ─────────────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children:
                                  List<Widget>.generate(6, (int index) {
                                return SizedBox(
                                  width: screenWidth / 8,
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: <TextInputFormatter>[
                                      LengthLimitingTextInputFormatter(1),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 22.h),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.r),
                                        ),
                                      ),
                                    ),
                                    onChanged: (String value) {
                                      if (value.isNotEmpty && index < 5) {
                                        _focusNodes[index + 1].requestFocus();
                                      } else if (value.isEmpty && index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),

                            SizedBox(height: 16.h),

                            // ── Submit button ───────────────────────────
                            CustomButton(
                              text:
                                  isLoading ? 'Verifying...' : 'Verify Code',
                              onTap: isLoading
                                  ? null
                                  : () => _handleVerifyCode(context),
                            ),

                            SizedBox(height: 6.h),

                            // ── Resend row ──────────────────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Didn\'t receive the email?',
                                  style: regularStyle(
                                    fontSize: FontSize.font14,
                                    color: AppColors.black,
                                  ),
                                ),
                                Builder(
                                  builder: (BuildContext ctx) {
                                    final bool canResend =
                                        _resendSecondsRemaining == 0 &&
                                            !_isResending;
                                    final Color resendColor = canResend
                                        ? AppColors.primaryText
                                        : AppColors.lightgrey;

                                    return TextButton(
                                      onPressed: canResend
                                          ? _handleResendCode
                                          : null,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            'resend code',
                                            style: regularStyle(
                                              fontSize: FontSize.font14,
                                              color: resendColor,
                                            ).copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          if (_isResending ||
                                              _resendSecondsRemaining > 0)
                                            SizedBox(width: 6.w),
                                          if (_isResending)
                                            Text(
                                              '...',
                                              style: regularStyle(
                                                fontSize: FontSize.font14,
                                                color: AppColors.lightgrey,
                                              ),
                                            )
                                          else if (_resendSecondsRemaining > 0)
                                            Text(
                                              '${_resendSecondsRemaining}s',
                                              style: regularStyle(
                                                fontSize: FontSize.font14,
                                                color: AppColors.lightgrey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
