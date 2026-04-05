import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/auth/data/models/auth_response.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';

import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';

enum VerificationSource {
  signup,
  forgotPassword,
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    this.source = VerificationSource.signup,
    this.email,
  });

  final VerificationSource source;
  final String? email;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {

  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final AuthService _authService = const AuthService();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendSecondsRemaining = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    if (_isLoading) {
      return;
    }

    final String code = _controllers.map((c) => c.text).join();
    final bool isForgotPasswordFlow =
        widget.source == VerificationSource.forgotPassword;
    final bool isValidLength =
        isForgotPasswordFlow ? code.length >= 5 : code.length == 6;
    if (!isValidLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isForgotPasswordFlow
                ? 'Please enter a valid OTP code.'
                : 'Please enter the 6-digit code.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    late final AuthResponse response;
    if (widget.source == VerificationSource.signup) {
      final String email = (widget.email ?? '').trim();
      if (email.isEmpty) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is missing. Please register again.')),
        );
        return;
      }

      response = await _authService.confirmAccount(
        email: email,
        otpCode: code,
      );
    } else {
      response = await _authService.verifyOtp(otp: code);
    }

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

      if (widget.source == VerificationSource.signup) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, '/createPassword');
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();

    setState(() {
      _resendSecondsRemaining = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _resendSecondsRemaining = 0;
        });
      } else {
        setState(() {
          _resendSecondsRemaining--;
        });
      }
    });
  }

  Future<void> _handleResendCode() async {
    if (_resendSecondsRemaining > 0 || _isResending) {
      return;
    }

    final String email = (widget.email ?? '').trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is missing. Please go back and try again.')),
      );
      return;
    }

    _startResendCooldown();

    setState(() {
      _isResending = true;
    });

    try {
      final int otpType =
          widget.source == VerificationSource.signup ? 0 : 1;

      final response = await _authService.resendOtp(
        email: email,
        otpType: otpType,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to resend code right now. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Check Your Email',
              subtitle: 'We sent a verification code to your email. Enter the code below to continue.',
            ),
            Padding(
              padding: EdgeInsets.symmetric( vertical: 20.h , horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: screenWidth/8,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 22.h,
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.r))),
                          ),
                          onChanged: (value) {
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
                  CustomButton(
                    text: _isLoading ? 'Verifying...' : 'Verify Code',
                    onTap: _handleVerifyCode,
                  ),

                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Didn’t receive the email?' , style: regularStyle(fontSize: FontSize.font14, color: AppColors.black)),
                      Builder(
                        builder: (context) {
                          final bool canResend =
                              _resendSecondsRemaining == 0 && !_isResending;
                          final Color resendColor =
                              canResend ? AppColors.primaryText : AppColors.lightgrey;

                          return TextButton(
                            onPressed: canResend ? _handleResendCode : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'resend code',
                                  style: regularStyle(
                                    fontSize: FontSize.font14,
                                    color: resendColor,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                if (_isResending || _resendSecondsRemaining > 0)
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
  }
}
