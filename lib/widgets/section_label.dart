import 'package:flutter/material.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: semiBoldStyle(
        fontSize: FontSize.font10,
        color: AppColors.primaryText,
      ).copyWith(letterSpacing: 1.5),
    );
  }
}
