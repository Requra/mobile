import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/screens/Home/profile/setNewPassword_screen.dart';
import 'package:requra/screens/Home/profile/updatePassword_screen.dart';
import 'package:requra/screens/auth/create_new_password_screen.dart';
import 'package:requra/screens/auth/forgot_password_screen.dart';
import 'package:requra/screens/Home/home_screen.dart';
import 'package:requra/screens/Home/profile_screen.dart';
import 'package:requra/screens/auth/login_screen.dart';
import 'package:requra/features/project_view/presentation/pages/project_view_screen.dart';
import 'package:requra/features/project_view/presentation/pages/edit_project_screen.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/result_view/presentation/pages/result_view_screen.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/screens/auth/signup_screen.dart';
import 'package:requra/screens/auth/verification_screen.dart';
import 'package:requra/screens/meeting/live_meeting_screen.dart';
import 'package:requra/screens/Home/add_project_screen.dart';
import 'package:requra/widgets/userstories_tabView.dart';
import 'package:requra/features/main_layout/presentation/pages/main_navigation.dart';
import 'package:requra/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotPassword';
  static const String verification = '/verification';
  static const String createPassword = '/createPassword';
  static const String home = '/home';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String projectView = '/projectView';
  static const String resultView = '/resultView';
  static const String users = '/users';
  static const String resetPassword = '/resetPassword';
  static const String passwordUpdated = '/passwordUpdated';
  static const String liveMeeting = '/liveMeeting';
  static const String addProject = '/addProject';
  static const String editProject = '/editProject';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (_) => const SplashScreen(),
      login: (_) => const LoginScreen(),
      signup: (_) => const SignupScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      verification: (_) => const VerificationScreen(),
      createPassword: (_) => const CreateNewPasswordScreen(),
      home: (_) => const HomeScreen(),
      main: (_) => const MainNavigation(),
      profile: (_) => const ProfileScreen(),
      projectView: (context) => ProjectViewScreen(
        onAddProject: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.addProject),
      ),
      resultView: (context) {
        final project = ModalRoute.of(context)!.settings.arguments as Project;
        return BlocProvider(
          create: (_) => sl<ResultViewCubit>(),
          child: ResultViewScreen(project: project),
        );
      },
      users: (_) => const UserstoriesTabview(),
      resetPassword: (_) => const setNewPasswordScreen(),
      passwordUpdated: (_) => const UpdatepasswordScreen(),
      liveMeeting: (_) => const LiveMeetingScreen(),
      addProject: (_) => const AddProjectScreen(),
      editProject: (context) {
        final project = ModalRoute.of(context)!.settings.arguments as Project;
        return EditProjectScreen(project: project);
      },
    };
  }
}

