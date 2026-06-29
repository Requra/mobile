import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_cubit.dart';
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
      builder: (BuildContext context, Widget? child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              // A single AuthCubit instance shared across Splash, Login, Signup,
              // and VerificationScreen (signup mode).
              create: (_) => AuthCubit(
                authService: const AuthService(),
                googleSignIn: GoogleSignIn(
                  scopes: <String>['email', 'profile'],
                ),
              ),
            ),
            BlocProvider<ForgotPasswordCubit>(
              // Covers ForgotPasswordScreen, VerificationScreen (password-reset
              // mode), and CreateNewPasswordScreen.
              create: (_) => ForgotPasswordCubit(
                authService: const AuthService(),
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            routes: <String, WidgetBuilder>{
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/forgotPassword': (_) => const ForgotPasswordScreen(),
              '/verification': (_) => const VerificationScreen(),
              '/createPassword': (_) => const CreateNewPasswordScreen(),
              '/home': (_) => const HomeScreen(),
              '/main': (_) => const MainNavigation(),
              '/profile': (_) => const ProfileScreen(),
              '/projectView': (_) => const ProjectviewScreen(),
              '/resultView': (_) => const ResultviewScreen(),
              '/users': (_) => const UserstoriesTabview(),
              '/resetPassword': (_) => const setNewPasswordScreen(),
              '/passwordUpdated': (_) => const UpdatepasswordScreen(),
              '/liveMeeting': (_) => const LiveMeetingScreen(),
              '/addProject': (_) => const AddProjectScreen(),
            },
            initialRoute: '/',
          ),
        );
      },
    );
  }
}
