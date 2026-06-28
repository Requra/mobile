import 'package:flutter/material.dart';
import 'package:requra/screens/Home/profile/setNewPassword_screen.dart';
import 'package:requra/screens/Home/profile/updatePassword_screen.dart';
import 'package:requra/screens/auth/create_new_password_screen.dart';
import 'package:requra/screens/auth/forgot_password_screen.dart';
import 'package:requra/screens/Home/home_screen.dart';
import 'package:requra/screens/Home/profile_screen.dart';
import 'package:requra/screens/auth/login_screen.dart';
import 'package:requra/screens/Home/projectView_screen.dart';
import 'package:requra/screens/Home/resultView_screen.dart';
import 'package:requra/screens/auth/signup_screen.dart';
import 'package:requra/screens/auth/verification_screen.dart';
import 'package:requra/screens/meeting/live_meeting_screen.dart';
import 'package:requra/screens/Home/add_project_screen.dart';
import 'package:requra/widgets/userstories_tabView.dart';
import 'package:requra/screens/main_navigation.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          routes: {
            "/": (_) => const SplashScreen(),
            "/login": (_) => const LoginScreen(),
            "/signup": (_) => const SignupScreen(),
            "/forgotPassword": (_) => const ForgotPasswordScreen(),
            "/verification": (_) => const VerificationScreen(),
            "/createPassword": (_) => const CreateNewPasswordScreen(),
            "/home": (_) => const HomeScreen(),
            "/main": (_) => const MainNavigation(),
            "/profile": (_) => const ProfileScreen(),
            "/projectView": (_) => const ProjectviewScreen(),
            "/resultView": (_) => const ResultviewScreen(),
            "/users": (_) => const UserstoriesTabview(),
            "/resetPassword": (_) => const setNewPasswordScreen(),
            "/passwordUpdated": (_) => const UpdatepasswordScreen(),
            "/liveMeeting": (_) => const LiveMeetingScreen(),
            "/addProject": (_) => const AddProjectScreen(),
          },
          initialRoute: "/",
        );
      },
    );
  }
}
