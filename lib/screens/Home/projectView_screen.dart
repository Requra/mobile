// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';
import 'package:requra/widgets/project_Card.dart';

class ProjectviewScreen extends StatefulWidget {
  const ProjectviewScreen({super.key});

  @override
  State<ProjectviewScreen> createState() => _ProjectviewScreenState();
}

class _ProjectviewScreenState extends State<ProjectviewScreen> {
  final tabs = ["Processing", "Completed", "Draft"];
  final tabCounts = [3, 2, 1];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.backgroundHomeScreen,

        appBar: AppBar(
          backgroundColor: AppColors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Image.asset("assets/images/logo.png", height: 35.h),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, color: AppColors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu, color: AppColors.black),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: AppColors.white,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "All Projects",
                    style: boldStyle(
                      fontSize: FontSize.font22,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Manage and organize your AI-generated requirement projects",
                    textAlign: TextAlign.center,
                    style: regularStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "+ New Project",
                        style: semiBoldStyle(
                          fontSize: FontSize.font16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10.w),
                          Icon(Icons.search, color: AppColors.grey, size: 18.sp),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search by project name, client...",
                                hintStyle: regularStyle(
                                  fontSize: FontSize.font12,
                                  color: AppColors.grey,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 42.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.grey),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Sort by",
                          style: regularStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.keyboard_arrow_down, size: 18.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            Container(
              color: AppColors.backgroundHomeScreen,
              child: Builder(
                builder: (context) {
                  final controller = DefaultTabController.of(context);
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      return TabBar(
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 2.sp,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: List.generate(tabs.length, (index) {
                          final isActive = controller.index == index;
                          return Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tabs[index],
                                  style: semiBoldStyle(
                                    fontSize: FontSize.font12,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.grey,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.lightPrimary
                                        : AppColors.lightgrey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${tabCounts[index]}",
                                      style: semiBoldStyle(
                                        fontSize: FontSize.font12,
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.grey,
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
                },
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    children: const [
                      ProjectCard(),
                      ProjectCard(),
                      ProjectCard(),
                    ],
                  ),

                  ListView(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    children: const [
                      ProjectCard(),
                      ProjectCard(),
                    ],
                  ),

                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          children: const [
                            ProjectCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

