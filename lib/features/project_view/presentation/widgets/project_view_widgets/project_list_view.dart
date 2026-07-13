import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_card.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_empty_state.dart';

class ProjectListView extends StatelessWidget {
  final List<Project> projects;
  final int tabIndex;
  final VoidCallback onAddProject;

  const ProjectListView({
    super.key,
    required this.projects,
    required this.tabIndex,
    required this.onAddProject,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<ProjectCubit>().fetchProjects(),
        child: ProjectEmptyState(
          tabIndex: tabIndex,
          onAddProject: onAddProject,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<ProjectCubit>().fetchProjects(),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final p = projects[index];
          return ProjectCard(
            project: p,
            onDeleted: () => context.read<ProjectCubit>().deleteProject(p.id),
          );
        },
      ),
    );
  }
}
