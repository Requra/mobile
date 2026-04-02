import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

class PasswordRules {
  PasswordRules._();

  static bool hasMinLength(String value) => value.length >= 8;

  static bool hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);

  static bool hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);

  static bool hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);

  static bool hasSpecialCharacter(String value) =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(value);

  static bool isValid(String value) {
    return hasMinLength(value) &&
        hasUppercase(value) &&
        hasLowercase(value) &&
        hasNumber(value) &&
        hasSpecialCharacter(value);
  }
}

class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({
    super.key,
    required this.password,
  });

  final String password;

  static const Color _successColor = Color(0xFF09B54D);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ruleItem(
          isMet: PasswordRules.hasMinLength(password),
          text: 'At least 8 characters',
        ),
        _ruleItem(
          isMet: PasswordRules.hasUppercase(password),
          text: 'One uppercase letter',
        ),
        _ruleItem(
          isMet: PasswordRules.hasLowercase(password),
          text: 'One lowercase letter',
        ),
        _ruleItem(
          isMet: PasswordRules.hasNumber(password),
          text: 'One number',
        ),
        _ruleItem(
          isMet: PasswordRules.hasSpecialCharacter(password),
          text: 'One special character',
          withBottomSpacing: false,
        ),
      ],
    );
  }

  Widget _ruleItem({
    required bool isMet,
    required String text,
    bool withBottomSpacing = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: withBottomSpacing ? 8.h : 0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle,
            color: isMet ? _successColor : Colors.grey.shade300,
            size: 14.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            text,
            style: regularStyle(
              fontSize: FontSize.font14,
              color: isMet ? _successColor : AppColors.lightgrey,
            ),
          ),
        ],
      ),
    );
  }
}
