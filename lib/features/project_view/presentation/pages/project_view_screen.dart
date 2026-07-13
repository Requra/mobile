import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/customAppBar.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/features/project_view/presentation/cubit/project_state.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_header.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_search_sort_bar.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_tab_bar.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_list_view.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_error_state.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_loading_state.dart';

class ProjectViewScreen extends StatefulWidget {
  final VoidCallback onAddProject;

  const ProjectViewScreen({super.key, required this.onAddProject});

  @override
  State<ProjectViewScreen> createState() => _ProjectViewScreenState();
}

class _ProjectViewScreenState extends State<ProjectViewScreen> {
  static const _tabs = ['Processing', 'Completed', 'Draft'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().fetchProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.backgroundHomeScreen,
        appBar: CustomAppBar(),
        body: Column(
          children: [
            ProjectHeader(onAddProject: widget.onAddProject),
            SizedBox(height: 10.h),
            ProjectSearchSortBar(
              searchController: _searchController,
              sortBy: "Name",
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: BlocConsumer<ProjectCubit, ProjectState>(
                listener: (context, state) {
                  if (state is ProjectActionError) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ));
                  }
                  if (state is ProjectActionSuccess) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.statusFinished,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ));
                  }
                },
                builder: (context, state) {
                  if (state is ProjectLoading || state is ProjectInitial) {
                    return const Center(child: ProjectLoadingState());
                  }

                  if (state is ProjectError) {
                    return ProjectErrorState(
                      onRetry: () =>
                          context.read<ProjectCubit>().fetchProjects(),
                    );
                  }

                  if (state is ProjectLoaded) {
                    return Column(
                      children: [
                        ProjectTabBar(
                          tabs: _tabs,
                          counts: [
                            state.processingProjects.length,
                            state.completedProjects.length,
                            state.draftProjects.length,
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ProjectListView(
                                  projects: state.processingProjects,
                                  tabIndex: 0,
                                  onAddProject: widget.onAddProject),
                              ProjectListView(
                                  projects: state.completedProjects,
                                  tabIndex: 1,
                                  onAddProject: widget.onAddProject),
                              ProjectListView(
                                  projects: state.draftProjects,
                                  tabIndex: 2,
                                  onAddProject: widget.onAddProject),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
