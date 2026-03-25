import 'package:flutter/material.dart';
import 'package:requra/screens/resetPasswordSuccessfully_Screen.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons_row.dart';

class CreateNewpasswordScreen extends StatefulWidget {
  const CreateNewpasswordScreen({super.key});

  @override
  State<CreateNewpasswordScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<CreateNewpasswordScreen> {
  bool rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Create a new password',
              subtitle: '',
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomTextField(
                    hintText: 'New Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  const CustomTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: 'Update Password',
                    onTap: () {
                      // controller then check new == confirm PSWD
                      Navigator.push(context, MaterialPageRoute<void>(builder: (context) => ResetPasswordSuccessfullyScreen(),));
                    },
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
