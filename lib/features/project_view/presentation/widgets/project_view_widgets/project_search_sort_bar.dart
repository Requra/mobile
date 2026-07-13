import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/core/global_widgets/custom_text_field.dart';

class ProjectSearchSortBar extends StatelessWidget {
  final TextEditingController searchController;
  final String sortBy;

  const ProjectSearchSortBar({
    super.key,
    required this.searchController,
    required this.sortBy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42.h,
              child:CustomTextField(
                controller: searchController,
                onChanged: (v) => context.read<ProjectCubit>().searchProjects(v),
                hintText: 'Search project...',
                icon: Icons.search,
                searchStyle: true,
                borderColor: AppColors.grey,
                borderRadius: 8,
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sortBy,
                icon: Icon(Icons.keyboard_arrow_down, size: 18.sp),
                style: regularStyle(fontSize: FontSize.font10, color: AppColors.black),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<ProjectCubit>().sortProjects(newValue);
                  }
                },
                items: <String>['Name', 'Features', 'Comments']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Sort by $value', style: regularStyle(fontSize: FontSize.font10, color: AppColors.black)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
