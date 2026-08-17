import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:requra/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/routes/app_routes.dart';
import 'package:requra/core/navigation/navigator_key.dart';
import 'package:requra/core/services/deep_link_service.dart';
import 'package:requra/core/services/deep_link_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initProjectDI();
  await DeepLinkService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.instance.onDeepLink.listen((meetingId) {
      DeepLinkHandler.handleMeetingLink(meetingId);
    });
  }

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
            navigatorKey: navigatorKey,
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
