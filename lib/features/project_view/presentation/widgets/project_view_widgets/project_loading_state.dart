import 'package:flutter/material.dart';
import 'package:requra/core/theme/color_manager.dart';

class ProjectLoadingState extends StatelessWidget {
  const ProjectLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
