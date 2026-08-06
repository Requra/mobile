import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/presentation/helpers/date_helper.dart';

class DocumentTile extends StatelessWidget {
  final Document document;

  const DocumentTile({super.key, required this.document});

  String get _statusLabel {
    // Arbitrary mapping based on standard statuses for mock API
    switch (document.status) {
      case 999:
        return 'UPLOADING';
      case 0:
        return 'PENDING';
      case 1:
        return 'PROCESSING';
      case 2:
        return 'PROCESSED';
      case 3:
        return 'FAILED';
      default:
        return 'UNKNOWN';
    }
  }

  Color get _statusColor {
    switch (_statusLabel) {
      case 'PROCESSED':
        return AppColors.statusFinished;
      case 'FAILED':
        return AppColors.error;
      case 'PENDING':
      case 'PROCESSING':
      case 'UPLOADING':
        return AppColors.statusInProgress;
      default:
        return AppColors.grey;
    }
  }

  Color get _statusBg {
    switch (_statusLabel) {
      case 'PROCESSED':
        return AppColors.statusFinishedLight.withValues(alpha: 0.2);
      case 'FAILED':
        return AppColors.error.withValues(alpha: 0.1);
      case 'PENDING':
      case 'PROCESSING':
      case 'UPLOADING':
        return AppColors.statusInProgressLight.withValues(alpha: 0.5);
      default:
        return AppColors.lightgrey.withValues(alpha: 0.2);
    }
  }

  String get _sizeStr {
    if (document.fileSize == null) return 'Unknown size';
    // Ensure it's absolute, just in case
    final absSize = document.fileSize!.abs();
    final mb = absSize / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUploading = document.status == 999;
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.lightPrimaryBorder,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: isUploading
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(
                  Icons.description_outlined,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                document.title,
                style: semiBoldStyle(
                  fontSize: FontSize.font13,
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                '$_sizeStr • ${document.createdAt != null ? formatDate(document.createdAt!) : ''}',
                style: regularStyle(
                  fontSize: FontSize.font11,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _statusLabel,
            style: boldStyle(
              fontSize: FontSize.font10,
              color: _statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
