// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/widgets/project_Card.dart';
import 'package:http/http.dart' as http;
import 'package:requra/features/auth/data/models/projects_model.dart';

class ProjectviewScreen extends StatefulWidget {
  const ProjectviewScreen({super.key});

  @override
  State<ProjectviewScreen> createState() => _ProjectviewScreenState();
}

class _ProjectviewScreenState extends State<ProjectviewScreen> {
  final tabs = ['Processing', 'Completed', 'Draft'];

  List<Project> allProjects = [];
  bool isLoading = true;

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> fetchProjects() async {
    setState(() => isLoading = true);
    try {
      final uri = Uri.parse(
        'https://mock.apidog.com/m1/1212435-1208182-default/api/projects',
      );
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ANY_TOKEN',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final projectResponse = ProjectResponse.fromJson(jsonData);
        setState(() {
          allProjects = projectResponse.items;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('fetchProjects error: $e');
      setState(() => isLoading = false);
    }
  }

  void _removeProject(String id) =>
      setState(() => allProjects.removeWhere((p) => p.id == id));

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  // ── Tab filtering ─────────────────────────────────────────────────────────

  List<Project> get processingProjects =>
     // allProjects.where((p) => p.status == 'InProgress').toList();
      allProjects.toList();

  List<Project> get completedProjects =>
      allProjects.where((p) => p.status == 'Completed').toList();

  List<Project> get draftProjects =>
      allProjects.where((p) => p.status == 'Drafted').toList();



  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _emptyState(int tabIndex) {
    const labels = ['processing', 'completed', 'draft'];
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty.png',
              width: 180.w,
              height: 180.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            Text(
              'No ${labels[tabIndex]} found',
              style:
                  boldStyle(fontSize: FontSize.font18, color: AppColors.black),
            ),
            SizedBox(height: 8.h),
            Text(
              "You haven't started any projects in this category yet.\nLet's create your first AI-generated requirement project!",
              textAlign: TextAlign.center,
              style: regularStyle(
                  fontSize: FontSize.font14, color: AppColors.grey),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  'Start New Project',
                  style: semiBoldStyle(
                      fontSize: FontSize.font16, color: AppColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List builder ──────────────────────────────────────────────────────────

  Widget _buildList(List<Project> projects, int tabIndex) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (projects.isEmpty) return _emptyState(tabIndex);

    return RefreshIndicator(
      onRefresh: fetchProjects,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final p = projects[index];
          return ProjectCard(
            id: p.id,
            title: p.name,
            clientName: p.clientName,
            status: p.status,
            description: p.description,
            comments: p.totalComments.toString(),
            onDeleted: () => _removeProject(p.id),
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
          title: Image.asset('assets/images/logo.png', height: 35.h),
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
            // ── Header ───────────────────────────────────────────────────────
            Container(
              color: AppColors.white,
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'All Projects',
                    style: boldStyle(
                        fontSize: FontSize.font22, color: AppColors.black),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Manage and organize your AI-generated requirement projects',
                    textAlign: TextAlign.center,
                    style: regularStyle(
                        fontSize: FontSize.font14, color: AppColors.grey),
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
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text(
                        '+ New Project',
                        style: semiBoldStyle(
                            fontSize: FontSize.font16,
                            color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // ── Search + Sort ─────────────────────────────────────────────
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
                          Icon(Icons.search,
                              color: AppColors.grey, size: 18.sp),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText:
                                    'Search by project name, client...',
                                hintStyle: regularStyle(
                                    fontSize: FontSize.font12,
                                    color: AppColors.grey),
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
                        Text('Sort by',
                            style: regularStyle(
                                fontSize: FontSize.font14,
                                color: AppColors.black)),
                        SizedBox(width: 4.w),
                        Icon(Icons.keyboard_arrow_down, size: 18.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // ── Tab Bar ───────────────────────────────────────────────────
            Container(
              color: AppColors.backgroundHomeScreen,
              child: Builder(builder: (context) {
                final ctrl = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: ctrl,
                  builder: (context, _) {
                    final counts = [
                      processingProjects.length,
                      completedProjects.length,
                      draftProjects.length,
                    ];
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
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.grey,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                width: 20.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.lightPrimary
                                      : AppColors.lightgrey,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${counts[i]}',
                                    style: semiBoldStyle(
                                      fontSize: FontSize.font12,
                                      color: active
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
              }),
            ),

            // ── Tab Views ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(processingProjects, 0),
                  _buildList(completedProjects, 1),
                  _buildList(draftProjects, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
