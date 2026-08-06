import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'screens/splash_screen.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/routes/app_routes.dart';

void main() {
  initProjectDI();
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
              create: (_) =>
                  ForgotPasswordCubit(authService: const AuthService()),
            ),
            BlocProvider<ProjectCubit>(create: (_) => sl<ProjectCubit>()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            routes: AppRoutes.getRoutes(),
            initialRoute: AppRoutes.splash,
          ),
        );
      },
    );
  }
}
