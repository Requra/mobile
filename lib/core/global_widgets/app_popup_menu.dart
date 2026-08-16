import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class PopupMenuItemData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const PopupMenuItemData({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

class AppPopupMenu extends StatelessWidget {
  final List<PopupMenuItemData> items;
  final IconData triggerIcon;
  final Color? triggerColor;

  const AppPopupMenu({
    super.key,
    required this.items,
    this.triggerIcon = Icons.more_vert,
    this.triggerColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupMenuItemData>(
      icon: Icon(triggerIcon, color: triggerColor ?? AppColors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: Colors.white,
      elevation: 4,
      offset: const Offset(0, 40),
      onSelected: (item) => item.onTap(),
      itemBuilder: (context) {
        return items.map((item) {
          final color = item.color ?? AppColors.darkgrey;
          return PopupMenuItem<PopupMenuItemData>(
            value: item,
            child: Row(
              children: [
                Icon(item.icon, size: 20.sp, color: color),
                SizedBox(width: 12.w),
                Text(
                  item.title,
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
