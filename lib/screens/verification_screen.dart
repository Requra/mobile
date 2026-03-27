import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/screens/create_NewPassword_screen.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons_row.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {

  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
                    text: 'Verify Code',
                    onTap: () {
                      String code = _controllers.map((c) => c.text).join();
                      if(code.length == 6) {
                        print("Verification code: $code");
                        Navigator.push(context, MaterialPageRoute<void>(builder: (context) =>  CreateNewpasswordScreen(),));
                      }
                      else{
                        /// phase 2
                      }
                    },
                  ),

                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Didn’t receive the email?' , style: regularStyle(fontSize: FontSize.font14, color: AppColors.black)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'resend the reset link',
                            style: regularStyle(fontSize: FontSize.font14, color: AppColors.primaryText).copyWith(decoration: TextDecoration.underline),
                        ),
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
