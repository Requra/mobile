import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final List<int>? counts;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.counts,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundHomeScreen,
      child: Builder(builder: (context) {
        final ctrl = DefaultTabController.of(context);
        return AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) {
            return TabBar(
              isScrollable: isScrollable,
              tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.sp,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: List.generate(tabs.length, (i) {
                final active = ctrl.index == i;
                final bool showCount = counts != null && i < counts!.length;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabs[i],
                        style: semiBoldStyle(
                          fontSize: FontSize.font12,
                          color: active ? AppColors.primary : AppColors.grey,
                        ),
                      ),
                      if (showCount) ...[
                        SizedBox(width: 4.w),
                        Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.lightPrimary
                                : AppColors.lightgrey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${counts![i]}',
                              style: semiBoldStyle(
                                fontSize: FontSize.font12,
                                color:
                                    active ? AppColors.primary : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              }),
            );
          },
        );
      }),
    );
  }
}
