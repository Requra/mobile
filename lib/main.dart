import 'package:flutter/material.dart';
import 'package:requra/screens/auth/create_new_password_screen.dart';
import 'package:requra/screens/auth/forgot_password_screen.dart';
import 'package:requra/screens/Home/home_screen.dart';
import 'package:requra/screens/auth/login_screen.dart';
import 'package:requra/screens/Home/projectView_screen.dart';
import 'package:requra/screens/auth/reset_password_successfully_screen.dart';
import 'package:requra/screens/Home/resultView_screen.dart';
import 'package:requra/screens/auth/signup_screen.dart';
import 'package:requra/screens/auth/verification_screen.dart';
import 'package:requra/widgets/userstories_tabView.dart';
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
            "/users": (_) => const UserstoriesTabview(),

          },
          initialRoute: "/splash",
        );
      },

    );
  }
}
