import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';
import 'package:requra/widgets/circular_icon.dart';
import 'package:requra/widgets/custom_button.dart';
import 'package:requra/widgets/custom_text_field.dart';
import 'package:requra/widgets/password_rules_checklist.dart';


class setNewPasswordScreen extends StatefulWidget {
  const setNewPasswordScreen({super.key});

  @override
  State<setNewPasswordScreen> createState() => _setNewPasswordScreenState();
}

class _setNewPasswordScreenState extends State<setNewPasswordScreen> {

  final TextEditingController _currentpasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final RegExp _emailRegex =
  RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical:  20.h , horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.r)),
                    border: Border.all(
                      color: AppColors.lightgrey,
                      width: 1.5.w,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical:  12.h , horizontal: 14.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularIcon(icon: FontAwesomeIcons.key),
                        SizedBox(height: 16.h,),
                        Text("Set New Password" , style: boldStyle(fontSize: FontSize.font20, color: AppColors.black),textAlign: TextAlign.center,),
                        SizedBox(height: 16.h,),
                        Text("Create a strong password that you haven't used before." , style: regularStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),textAlign: TextAlign.center,),
                        SizedBox(height: 16.h,),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w , bottom: 1.5.h),
                          child: Align(alignment: AlignmentGeometry.topLeft, child: Text("Current Password" , style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),)),
                        ),
                        CustomTextField(
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _currentpasswordController,
                          // onChanged: _onPasswordChanged,
                          // errorText: _passwordError,
                        ),
                        SizedBox(height: 16.h,),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w , bottom: 1.5.h),
                          child: Align(alignment: AlignmentGeometry.topLeft, child: Text("New Password" , style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),)),
                        ),
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
                        SizedBox(height: 16.h,),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w , bottom: 1.5.h),
                          child: Align(alignment: AlignmentGeometry.topLeft, child: Text("Confirm New Password" , style: semiBoldStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),)),
                        ),
                        CustomTextField(
                          hintText: 'Confirm Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _confirmPasswordController,
                          onChanged: _onConfirmPasswordChanged,
                          errorText: _confirmPasswordError,
                        ),
                        SizedBox(height: 16.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: "Cancel",
                                onTap: () {},
                                color1: AppColors.lightButton,
                                color2: AppColors.lightButton,
                                borderColor: AppColors.borderButton,
                                textColor: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: CustomButton(
                                text: "Update",
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, "/passwordUpdated");
                                },
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
    );
  }
}




