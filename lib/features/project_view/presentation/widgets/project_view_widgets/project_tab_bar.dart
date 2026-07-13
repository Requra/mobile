import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

class ProjectTabBar extends StatelessWidget {
  final List<String> tabs;
  final List<int> counts;

  const ProjectTabBar({super.key, required this.tabs, required this.counts});

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
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.sp,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: List.generate(tabs.length, (i) {
                final active = ctrl.index == i;
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
                      SizedBox(width: 4.w),
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: active ? AppColors.lightPrimary : AppColors.lightgrey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${counts[i]}',
                            style: semiBoldStyle(
                              fontSize: FontSize.font12,
                              color: active ? AppColors.primary : AppColors.grey,
                            ),
                          ),
                        ),
                      ),
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
