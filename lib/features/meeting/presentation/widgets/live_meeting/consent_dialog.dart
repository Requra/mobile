import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/core/theme/font_manager.dart';

class ConsentDialog extends StatelessWidget {
  final VoidCallback onAgree;

  const ConsentDialog({super.key, required this.onAgree});

  static Future<bool?> show(BuildContext context, {required VoidCallback onAgree}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(onAgree: onAgree),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF0F0F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
            decoration: BoxDecoration(
              color: const Color(0xFF202025),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Privacy Protection Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2D62),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF4C3B82)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.privacy_tip_outlined, color: const Color(0xFF9876E8), size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'PRIVACY PROTECTION',
                            style: semiBoldStyle(
                              fontSize: FontSize.font10,
                              color: const Color(0xFF9876E8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text(
                        'Consent',
                        style: boldStyle(fontSize: 28.sp, color: const Color(0xFF9876E8)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'This meeting is being captured. Please review our recording policy to continue.',
                      textAlign: TextAlign.center,
                      style: regularStyle(fontSize: 14.sp, color: Colors.white70),
                    ),
                  ],
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white54, size: 20.sp),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                // Decorative faint icon in background
                Positioned(
                  right: -20,
                  top: 0,
                  child: Icon(
                    Icons.videocam_outlined,
                    size: 100.sp,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ],
            ),
          ),
          
          // List Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              children: [
                _buildInfoCard(
                  icon: Icons.mic_none_rounded,
                  iconColor: const Color(0xFF7A49D5),
                  title: 'Audio Capture',
                  description: 'Your voice and ambient sounds will be recorded for requirement extraction and meeting summaries.',
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.error_outline_rounded,
                  iconColor: const Color(0xFFE58D2D),
                  title: 'Data Usage',
                  description: 'The recording will be securely stored and only accessible by project members with appropriate permissions.',
                ),
              ],
            ),
          ),
          
          // Action Buttons Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: Colors.black12, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.black, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'DECLINE',
                          style: boldStyle(fontSize: 14.sp, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      onAgree();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: const Color(0xFF7A49D5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'AGREE & JOIN',
                          style: boldStyle(fontSize: 14.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: boldStyle(fontSize: 15.sp, color: Colors.black87),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: regularStyle(fontSize: 13.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
