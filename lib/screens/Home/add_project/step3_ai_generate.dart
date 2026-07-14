import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/add_project/presentation/cubit/add_project_cubit.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/project/data/models/project_creation_result.dart';

class Step3AiGenerate extends StatefulWidget {
  final VoidCallback onViewResults;

  const Step3AiGenerate({
    super.key,
    required this.onViewResults,
  });

  @override
  State<Step3AiGenerate> createState() => _Step3AiGenerateState();
}

class _Step3AiGenerateState extends State<Step3AiGenerate> {
  // Rotating text for loading state
  final List<String> _loadingMessages = [
    'Understanding Stakeholders...',
    'Parsing documents...',
    'Identifying actors...',
    'Generating requirements...',
    'Classifying requirements...',
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _startLoadingMessages();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _startLoadingMessages() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  void _onViewResults() {
    context.read<AddProjectCubit>().reset();
    widget.onViewResults();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProjectCubit, AddProjectState>(
      listener: (context, state) {
        if (state is AddProjectSuccess || state is AddProjectError) {
          _messageTimer?.cancel();
        }
        if (state is AddProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate project: ${state.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildStateContent(context, state),
        );
      },
    );
  }

  Widget _buildStateContent(BuildContext context, AddProjectState state) {
    if (state is AddProjectCreating) {
      return _buildLoadingState();
    } else if (state is AddProjectSuccess) {
      return _buildSuccessState(state.result);
    } else if (state is AddProjectError) {
      return _buildErrorState(context, state.message);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      key: const ValueKey('loading_state'),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'AI is Analyzing Your Project',
            style: boldStyle(
              fontSize: FontSize.font22,
              color: AppColors.darkgrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Our AI is processing your sources and\ngenerating structured requirements.',
              style: regularStyle(
                fontSize: FontSize.font13,
                color: AppColors.lightgrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40.h),

          // Robot Avatar 2
          Image.asset(
            'assets/images/RequraAvatar2.png',
            height: 220.h,
            fit: BoxFit.contain,
          ),

          SizedBox(height: 40.h),

          // Rotating Loading Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: const Color(0xFFEBEBEB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: Text(
                    _loadingMessages[_currentMessageIndex],
                    key: ValueKey<String>(
                      _loadingMessages[_currentMessageIndex],
                    ),
                    style: semiBoldStyle(
                      fontSize: FontSize.font13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ProjectCreationResult result) {
    return SingleChildScrollView(
      key: const ValueKey('success_state'),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'AI Successfully Generated Your Requirements',
            style: boldStyle(
              fontSize: FontSize.font22,
              color: AppColors.darkgrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Your documents have been analyzed and\nstructured requirements are ready to review.',
              style: regularStyle(
                fontSize: FontSize.font13,
                color: AppColors.lightgrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),

          // Robot Avatar with Checkmark
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/RequraAvatar.png',
                height: 200.h,
                fit: BoxFit.contain,
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Summary Cards Row (Horizontally Scrollable)
          SizedBox(
            height: 120.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _buildSummaryCard(
                  icon: Icons.person_outline,
                  iconColor: AppColors.primary,
                  iconBgColor: const Color(0xFFEBE6F5),
                  count: result.actorsCount,
                  title: 'Actors Identified',
                  subtitle: result.actorsSummary,
                ),
                SizedBox(width: 16.w),
                _buildSummaryCard(
                  icon: Icons.checklist_rtl,
                  iconColor: Colors.green,
                  iconBgColor: const Color(0xFFE8F5E9),
                  count: result.requirementsCount,
                  title: 'Requirements Generated',
                  subtitle: result.requirementsSummary,
                ),
                SizedBox(width: 16.w),
                _buildSummaryCard(
                  icon: Icons.assignment_outlined,
                  iconColor: Colors.orange,
                  iconBgColor: const Color(0xFFFFF3E0),
                  count: result.userStoriesCount,
                  title: 'User Stories Created',
                  subtitle: result.userStoriesSummary,
                ),
              ],
            ),
          ),

          SizedBox(height: 40.h),

          // Buttons
          Row(
            children: [
              // Back
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.read<AddProjectCubit>().goBackToStep2(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppColors.borderButton),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // View Results
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: const LinearGradient(
                      colors: [AppColors.lightPrimary, AppColors.primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onViewResults,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Center(
                          child: Text(
                            'View Results',
                            style: boldStyle(
                              fontSize: FontSize.font14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      key: const ValueKey('error_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64.r),
          SizedBox(height: 16.h),
          Text(
            'Generation Failed',
            style: boldStyle(fontSize: FontSize.font18, color: AppColors.darkgrey),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: regularStyle(fontSize: FontSize.font14, color: AppColors.lightgrey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          OutlinedButton(
            onPressed: () => context.read<AddProjectCubit>().goBackToStep2(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required int count,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 260.w, // Fixed width for horizontal scrolling
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24.r),
              ),
              SizedBox(width: 16.w),
              Text(
                count.toString(),
                style: boldStyle(fontSize: 28.sp, color: AppColors.darkgrey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: semiBoldStyle(
              fontSize: FontSize.font13,
              color: const Color(0xFF51525C), // grey
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: regularStyle(
              fontSize: FontSize.font11,
              color: AppColors.lightgrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

