import 'package:flutter/material.dart';
import 'package:requra/screens/create_new_password_screen.dart';
import 'package:requra/screens/forgot_password_screen.dart';
import 'package:requra/screens/home_screen.dart';
import 'package:requra/screens/login_screen.dart';
import 'package:requra/screens/projectView_screen.dart';
import 'package:requra/screens/reset_password_successfully_screen.dart';
import 'package:requra/screens/resultView_screen.dart';
import 'package:requra/screens/signup_screen.dart';
import 'package:requra/screens/verification_screen.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() {
  runApp(const RequraApp());
}

class RequraApp extends StatelessWidget {
  const RequraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true, //IN FUTURE may make app not allow split
      builder: (context,child){
        return MaterialApp(
          title: 'Requra Auth',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A3D9A)),
            useMaterial3: true,
          ),
          routes: {
            "/login": (_) => const LoginScreen(),
            "/signup": (_) => const SignupScreen(),
            "/forgetPassword": (_) => const ForgotPasswordScreen(),
            "/createPassword": (_) => const CreateNewPasswordScreen(),
            "/resetPasswordSuccessfully": (_) => const ResetPasswordSuccessfullyScreen(),
            "/splash": (_) => const SplashScreen(),
            "/verification" : (_) => const VerificationScreen(),
            "/home": (_) => const HomeScreen(),
            "/projectView": (_) => const ProjectviewScreen(),
            "/resultView": (_) => const ResultviewScreen(),
          },
          initialRoute: "/splash",
        );
      },

    );
  }
}
