import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:requra/theme/color_manager.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.55, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        // );

        Navigator.pushReplacementNamed(context, "/login");
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            width: 140.w,
            height: 140.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}


//////////////////////////////////////////////////
/*
fix requra.ai text and make photo animated well
* */


