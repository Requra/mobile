import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/project_view/domain/entities/project.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/features/project_view/presentation/cubit/project_state.dart';
import 'package:requra/features/project_view/presentation/widgets/edit_project_widgets/core_info_section.dart';
import 'package:requra/features/project_view/presentation/widgets/edit_project_widgets/classification_section.dart';
import 'package:requra/features/project_view/presentation/widgets/edit_project_widgets/collaboration_section.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _memberCtrl;

  late String _selectedStatus;
  late String _selectedType;
  late List<String> _teamMembers;

  static const _statusOptions = ['InProgress', 'Completed', 'Drafted', 'Cancelled'];

  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.project.name);
    _descCtrl = TextEditingController(text: widget.project.description);
    // Use clientEmail if available, fallback to clientName
    _clientCtrl = TextEditingController(
        text: widget.project.clientEmail ?? widget.project.clientName);
    _memberCtrl = TextEditingController();
    _selectedStatus = _statusOptions.contains(widget.project.status)
        ? widget.project.status
        : _statusOptions.first;
    _selectedType = widget.project.projectType ?? 'None';
    _teamMembers = widget.project.teamMembers != null 
        ? List<String>.from(widget.project.teamMembers!) 
        : [];
    if (_clientCtrl.text.isNotEmpty) {
      _teamMembers.removeWhere((email) => email.toLowerCase() == _clientCtrl.text.toLowerCase());
    }
        
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final details = await context.read<ProjectCubit>().getProjectDetails(widget.project.id);
    if (mounted && details != null) {
      setState(() {
        _nameCtrl.text = details.name;
        _descCtrl.text = details.description;
        _clientCtrl.text = details.clientEmail ?? details.clientName;
        _selectedStatus = _statusOptions.contains(details.status)
            ? details.status
            : _statusOptions.first;
        _selectedType = details.projectType ?? 'None';
        if (details.teamMembers != null) {
          _teamMembers = List<String>.from(details.teamMembers!);
          if (_clientCtrl.text.isNotEmpty) {
            _teamMembers.removeWhere((email) => email.toLowerCase() == _clientCtrl.text.toLowerCase());
          }
        }
        _isLoadingDetails = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _clientCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  void _addMember() {
    final email = _memberCtrl.text.trim();
    if (email.isNotEmpty && !_teamMembers.contains(email)) {
      if (_clientCtrl.text.isNotEmpty && email.toLowerCase() == _clientCtrl.text.trim().toLowerCase()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client email cannot be added as a team member')),
        );
        return;
      }
      setState(() {
        _teamMembers.add(email);
        _memberCtrl.clear();
      });
    }
  }

  void _removeMember(String email) =>
      setState(() => _teamMembers.remove(email));

  void _onTypeChanged(String type) => setState(() {
        _selectedType = type;
      });

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ProjectCubit>().editProject(
      widget.project.id,
      {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'projectType': _selectedType,
        'status': _selectedStatus,
        'clientEmail': _clientCtrl.text.trim(),
        'language': 'En',
        'teamMembers': _teamMembers.map((e) => {'email': e}).toList(),
      },
    );

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHomeScreen,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Project',
          style: boldStyle(fontSize: FontSize.font18, color: AppColors.black),
        ),
      ),
      body: BlocListener<ProjectCubit, ProjectState>(
        listenWhen: (prev, curr) => curr is ProjectActionError,
        listener: (_, state) {
          if (state is ProjectActionError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            );
          }
        },
        child: _isLoadingDetails
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Page header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimaryBorder,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.edit_note,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Project',
                            style: boldStyle(
                              fontSize: FontSize.font22,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Refine your project requirements and manage team access',
                            style: regularStyle(
                              fontSize: FontSize.font12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                /// Form card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CoreInfoSection(
                        nameController: _nameCtrl,
                        clientController: _clientCtrl,
                        selectedStatus: _selectedStatus,
                        statusOptions: _statusOptions,
                        onStatusChanged: (v) =>
                            setState(() => _selectedStatus = v),
                      ),
                      SizedBox(height: 24.h),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      SizedBox(height: 24.h),
                      ClassificationSection(
                        selectedType: _selectedType,
                        onTypeChanged: _onTypeChanged,
                      ),
                      SizedBox(height: 24.h),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      SizedBox(height: 24.h),
                      CollaborationSection(
                        descriptionController: _descCtrl,
                        memberController: _memberCtrl,
                        teamMembers: _teamMembers,
                        onAddMember: _addMember,
                        onRemoveMember: _removeMember,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                /// Action buttons
                BlocBuilder<ProjectCubit, ProjectState>(
                  buildWhen: (prev, curr) {
                    if (prev is ProjectLoaded && curr is ProjectLoaded) {
                      return prev.isSubmitting != curr.isSubmitting;
                    }
                    return curr is ProjectLoaded;
                  },
                  builder: (_, state) {
                    bool isSubmitting = false;
                    if (state is ProjectLoaded) {
                      isSubmitting = state.isSubmitting;
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            transparent: true,
                            borderColor: AppColors.lightgrey,
                            onTap: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomButton(
                            text: isSubmitting ? 'Saving...' : 'Save Changes',
                            icon: isSubmitting ? null : Icons.save_outlined,
                            onTap: isSubmitting ? null : _onSave,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
