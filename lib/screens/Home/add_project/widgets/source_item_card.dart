import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_enums.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// A card that displays a single uploaded source file in the sources list.
///
/// Shows a coloured type icon, file name, size, status, and a remove button.
class SourceItemCard extends StatelessWidget {
  const SourceItemCard({
    super.key,
    required this.source,
    required this.onRemove,
  });

  final SourceItem source;
  final VoidCallback onRemove;

  Color get _iconBg {
    switch (DocumentType.fromValue(source.documentType)) {
      case DocumentType.pdf:
        return const Color(0xFFFFF0E6);
      case DocumentType.docx:
        return const Color(0xFFE6F0FF);
      case DocumentType.audio:
        return const Color(0xFFE8F5E9);
      case DocumentType.liveSession:
        return const Color(0xFFF3E5F5);
    }
  }

  Color get _iconColor {
    switch (DocumentType.fromValue(source.documentType)) {
      case DocumentType.pdf:
        return const Color(0xFFE65100);
      case DocumentType.docx:
        return const Color(0xFF1565C0);
      case DocumentType.audio:
        return const Color(0xFF2E7D32);
      case DocumentType.liveSession:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (DocumentType.fromValue(source.documentType)) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case DocumentType.docx:
        return Icons.description_outlined;
      case DocumentType.audio:
        return Icons.audiotrack_outlined;
      case DocumentType.liveSession:
        return Icons.mic_outlined;
    }
  }

  String get _statusLabel {
    if (source.transcriptText != null) return 'Pasted';
    if (source.documentType == DocumentType.liveSession.value) return 'Session';
    return 'Uploaded';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEEEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(_icon, color: _iconColor, size: 18.r),
          ),
          SizedBox(width: 10.w),

          // Name + size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  source.fileName,
                  style: semiBoldStyle(
                    fontSize: FontSize.font11,
                    color: AppColors.darkgrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${source.formattedSize} • $_statusLabel',
                  style: regularStyle(
                    fontSize: FontSize.font10,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12.r, color: AppColors.lightgrey),
            ),
          ),
        ],
      ),
    );
  }
}
