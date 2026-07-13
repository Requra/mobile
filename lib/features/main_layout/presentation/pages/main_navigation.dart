import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:requra/screens/Home/add_project_screen.dart';
import 'package:requra/features/Dashboard/presentation/pages/dashboard_screen.dart';
import 'package:requra/screens/Home/profile_screen.dart';
import 'package:requra/features/project_view/presentation/pages/project_view_screen.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/screens/Home/resultView_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const DashboardScreen(),
      ProjectViewScreen(
        onAddProject: () {
          _controller.jumpToTab(2);
        },
      ),
      AddProjectScreen(
        onViewResults: () {
          _controller.jumpToTab(3);
        },
      ),
      const ResultviewScreen(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_rounded),
        inactiveIcon: const Icon(Icons.home_outlined),
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: const Color(0xFFB0B7C3),
        iconSize: 26,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.folder_open_rounded),
        inactiveIcon: const Icon(Icons.folder_outlined),
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: const Color(0xFFB0B7C3),
        iconSize: 26,
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.primary,
        iconSize: 32,
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.bar_chart_rounded),
        inactiveIcon: const Icon(Icons.bar_chart_outlined),
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: const Color(0xFFB0B7C3),
        iconSize: 26,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_rounded),
        inactiveIcon: const Icon(Icons.person_outline_rounded),
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: const Color(0xFFB0B7C3),
        iconSize: 26,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -0.5),
            blurRadius: 15,
            color: Colors.grey
          ),
        ],
      ),
      navBarStyle: NavBarStyle.style15,
    );
  }
}