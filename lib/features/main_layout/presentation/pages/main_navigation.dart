import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/features/Dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:requra/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:requra/features/Dashboard/presentation/pages/dashboard_screen.dart';
import 'package:requra/screens/Home/profile_screen.dart';
import 'package:requra/features/project_view/presentation/pages/project_view_screen.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.of(context, rootNavigator: true).pushNamed('/addProject');
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DashboardCubit>()..loadDashboard(),
        ),
        BlocProvider(
          create: (_) => sl<ProfileCubit>()..loadProfileIfNeeded(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const DashboardScreen(),
            ProjectViewScreen(
              onAddProject: () {
                Navigator.of(context, rootNavigator: true).pushNamed('/addProject');
              },
            ),
            const SizedBox(), // Placeholder for Add Project tab index
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                elevation: 0,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: const Color(0xFFB0B7C3),
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.folder_outlined),
                    activeIcon: Icon(Icons.folder_open_rounded),
                    label: 'Projects',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline, size: 32.sp, color: AppColors.primary),
                    activeIcon: Icon(Icons.add_circle_outline, size: 32.sp, color: AppColors.primary),
                    label: 'Add Project',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}