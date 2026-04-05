// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

class UserstoriesTabview extends StatefulWidget {
  const UserstoriesTabview({super.key});

  @override
  State<UserstoriesTabview> createState() => _userstoriesTabviewState();
}

class _userstoriesTabviewState extends State<UserstoriesTabview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.r))
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "IDETIFIER",
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.grey,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4.h,
                    horizontal: 10.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.statusInProgress),
                    color: AppColors.statusInProgressLight,
                  ),
                  child: Text(
                    "Extracted",
                    style: regularStyle(
                      fontSize: FontSize.font10,
                      color: AppColors.statusInProgress,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "US-01",
              style: boldStyle(
                fontSize: FontSize.font16,
                color: AppColors.primaryText,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText("As a", "Content Creator"),
                  SizedBox(height: 10.h),
                  RichText(
                    "I want to",
                    "automatically tag requirements with metadata",
                  ),
                  SizedBox(height: 10.h),
                  RichText(
                    "So that",
                    "I can filter the backlog by technical complexity",
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.lightPrimary.withOpacity(0.7),
                border: Border.all(color: AppColors.lightPrimary, width: 1.w),
                borderRadius: BorderRadius.all(Radius.circular(3.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message_outlined, color: AppColors.black),
                        SizedBox(width: 3.w),
                        Text(
                          "Stakeholder Feedback",
                          style: semiBoldStyle(
                            fontSize: FontSize.font14,
                            color: AppColors.black,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 25.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: AppColors.lightgrey,
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10.h, 8.h),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "1",
                              style: regularStyle(
                                fontSize: FontSize.font10,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Consider adding a 'priority' tag alongside complexity. — Shawky.",
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        "Show all Comments →",
                        style: regularStyle(
                          fontSize: FontSize.font14,
                          color: AppColors.primary,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Divider(),
            SizedBox(height: 10.h),

            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 550 ? 70 : 50,
                      height: MediaQuery.of(context).size.width > 550 ? 70 : 50,
                      child: CircularProgressIndicator(
                        value: 0.85,
                        strokeWidth: 4,
                        backgroundColor: AppColors.IndicatorBG,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      "85%",
                      style: regularStyle(
                        fontSize: FontSize.font18,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                Text(
                  "QUALITY SCORE",
                  style: regularStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.grey,
                  ),
                ),
                Spacer(),
                Icon(Icons.verified_outlined, color: AppColors.grey),
                SizedBox(width: 5.w),
                Icon(Icons.mode_edit_outline_outlined, color: AppColors.grey),
                SizedBox(width: 5.w),
                Icon(Icons.delete_forever_outlined, color: AppColors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Text RichText(String boldName, String regularName) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "$boldName ",
            style: boldStyle(fontSize: FontSize.font12, color: Colors.black),
          ),
          TextSpan(
            text: regularName,
            style: regularStyle(fontSize: FontSize.font12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
