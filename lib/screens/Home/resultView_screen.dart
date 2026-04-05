// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

import 'package:requra/widgets/userstories_tabView.dart';

class ResultviewScreen extends StatefulWidget {
  const ResultviewScreen({super.key});

  @override
  State<ResultviewScreen> createState() => _resultviewScreenState();
}

class _resultviewScreenState extends State<ResultviewScreen> {
  final tabs = ["Overview", "User Stories", "Requirements" , "Exports"];

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
                            child: Text(
                              tabs[index],
                              style: regularStyle(
                                fontSize: FontSize.font10,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.grey,
                              ),
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
                  ///make it card don't use users stories tab view
                  Center(child: Text("tab1")),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w , vertical: 10.h),
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: UserstoriesTabview(),
                      );
                    },),
                  ),
                  Center(child: Text("tab3")),
                  Center(child: Text("tab4")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

