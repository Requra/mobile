import 'package:flutter/material.dart';
import 'package:requra/screens/login_screen.dart';

import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_auth_buttons_row.dart';

class ResetPasswordSuccessfullyScreen extends StatelessWidget {
  const ResetPasswordSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: '',
              subtitle: '',
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  border: Border.all(
                    color: Color(0xFFD7CBF3),
                    width: 1.5,
                  ),
                  // color: Colors.red
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Password Reset Successfully"),
                      SizedBox(height: 8,),
                      Text("Your password has been updated. You can now sign in with your new password."),
                      SizedBox(height: 8,),
                      Image.asset(
                        'assets/images/RequraAvatar.png',
                        height: 300,
                        width: 350,
                        fit: BoxFit.cover,

                      ),
                      SizedBox(height: 16,),
                      CustomButton(
                        text: 'Back to Sign in',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute<void>(builder: (context) => LoginScreen(),));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
