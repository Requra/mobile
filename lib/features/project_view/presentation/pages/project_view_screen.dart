import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/customAppBar.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/features/project_view/presentation/cubit/project_state.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_header.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_search_sort_bar.dart';
import 'package:requra/core/global_widgets/custom_tab_bar.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_list_view.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_error_state.dart';
import 'package:requra/features/project_view/presentation/widgets/project_view_widgets/project_loading_state.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class ProjectViewScreen extends StatefulWidget {
  final VoidCallback onAddProject;

  const ProjectViewScreen({super.key, required this.onAddProject});

  @override
  State<ProjectViewScreen> createState() => _ProjectViewScreenState();
}

class _ProjectViewScreenState extends State<ProjectViewScreen> with SingleTickerProviderStateMixin {
  static const _tabs = ['All Projects', 'In Progress', 'Drafted', 'Completed', 'Cancelled'];
  static const _statusValues = ['', 'InProgress', 'Drafted', 'Completed', 'Cancelled'];
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    _scrollController.addListener(_onScroll);
    context.read<ProjectCubit>().fetchProjects(status: null, page: 1);
  }
  
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final status = _statusValues[_tabController.index];
      context.read<ProjectCubit>().changeTab(status.isEmpty ? null : status);
    }
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProjectCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHomeScreen,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          ProjectHeader(onAddProject: widget.onAddProject),
          SizedBox(height: 10.h),
          ProjectSearchSortBar(
            searchController: _searchController,
          ),
          SizedBox(height: 10.h),
          BlocBuilder<ProjectCubit, ProjectState>(
            buildWhen: (prev, curr) => curr is ProjectLoaded,
            builder: (context, state) {
              int totalCount = -1;
              if (state is ProjectLoaded) totalCount = state.totalCount;
              return CustomTabBar(
                tabs: _tabs,
                controller: _tabController,
                counts: List.generate(_tabs.length, (i) => i == _tabController.index ? totalCount : -1),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final status = _statusValues[_tabController.index];
                await context.read<ProjectCubit>().fetchProjects(status: status.isEmpty ? null : status, page: 1);
              },
              child: BlocConsumer<ProjectCubit, ProjectState>(
                buildWhen: (prev, curr) => curr is ProjectLoading || curr is ProjectLoaded || curr is ProjectError || curr is ProjectInitial,
                listener: (context, state) {
                  if (state is ProjectActionError) {
                    AppSnackbar.showError(context, state.message);
                  }
                  if (state is ProjectActionSuccess) {
                    AppSnackbar.showError(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is ProjectLoading || state is ProjectInitial) {
                    // Must be in a scrollable widget so pull-to-refresh works even when loading
                    return CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: const Center(child: ProjectLoadingState()),
                        )
                      ],
                    );
                  }

                  if (state is ProjectError) {
                    return CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: ProjectErrorState(
                            onRetry: () =>
                                context.read<ProjectCubit>().fetchProjects(
                                  status: _statusValues[_tabController.index].isEmpty ? null : _statusValues[_tabController.index],
                                  page: 1,
                                ),
                          ),
                        )
                      ],
                    );
                  }

                  if (state is ProjectLoaded) {
                    return ProjectListView(
                      projects: state.filteredProjects,
                      tabIndex: _tabController.index,
                      onAddProject: widget.onAddProject,
                      scrollController: _scrollController,
                      isLoadingMore: state.isLoadingMore,
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
