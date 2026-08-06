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
            sortBy: "Name",
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: BlocConsumer<ProjectCubit, ProjectState>(
              buildWhen: (prev, curr) => curr is ProjectLoading || curr is ProjectLoaded || curr is ProjectError || curr is ProjectInitial,
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
                        context.read<ProjectCubit>().fetchProjects(
                          status: _statusValues[_tabController.index].isEmpty ? null : _statusValues[_tabController.index],
                          page: 1,
                        ),
                  );
                }

                if (state is ProjectLoaded) {
                  return Column(
                    children: [
                      // We provide DefaultTabController here just for CustomTabBar to read it
                      DefaultTabController(
                        length: _tabs.length,
                        initialIndex: _tabController.index,
                        child: Builder(
                          builder: (context) {
                            // Sync DefaultTabController with our TabController
                            final defaultTabController = DefaultTabController.of(context);
                            _tabController.addListener(() {
                              if (defaultTabController.index != _tabController.index) {
                                defaultTabController.animateTo(_tabController.index);
                              }
                            });
                            defaultTabController.addListener(() {
                              if (defaultTabController.index != _tabController.index) {
                                _tabController.animateTo(defaultTabController.index);
                              }
                            });
                            
                            return CustomTabBar(
                              tabs: _tabs,
                              // Only show count for the active tab since we only load one tab's data at a time from server
                              counts: List.generate(_tabs.length, (i) => i == _tabController.index ? state.totalCount : -1),
                            );
                          }
                        ),
                      ),
                      Expanded(
                        child: ProjectListView(
                          projects: state.filteredProjects,
                          tabIndex: _tabController.index,
                          onAddProject: widget.onAddProject,
                          scrollController: _scrollController,
                          isLoadingMore: state.isLoadingMore,
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
    );
  }
}
