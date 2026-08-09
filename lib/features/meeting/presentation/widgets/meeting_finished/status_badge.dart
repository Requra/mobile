import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/meeting/domain/entities/meeting_summary.dart';

class StatusBadge extends StatelessWidget {
  final ProcessingStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color bgColor;
    Color textColor;

    switch (status) {
      case ProcessingStatus.ready:
        text = 'READY';
        bgColor = const Color(0xFFE8F5E9); // Light green bg
        textColor = const Color(0xFF2E7D32); // Dark green text
        break;
      case ProcessingStatus.processing:
        text = 'PROCESSING';
        bgColor = const Color(0xFFFFF3E0); // Light orange bg
        textColor = const Color(0xFFE65100); // Dark orange text
        break;
      case ProcessingStatus.failed:
        text = 'FAILED';
        bgColor = const Color(0xFFFFEBEE); // Light red bg
        textColor = const Color(0xFFC62828); // Dark red text
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: boldStyle(
          fontSize: FontSize.font11,
          color: textColor,
        ),
      ),
    );
  }
}
