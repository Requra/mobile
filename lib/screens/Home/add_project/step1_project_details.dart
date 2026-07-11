import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_enums.dart';
import 'package:requra/screens/Home/add_project/widgets/team_member_input.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// Step 1 of the Add Project wizard — "Create New Project".
///
/// Collects project name, client email, type, description, and team members.
class Step1ProjectDetails extends StatefulWidget {
  const Step1ProjectDetails({
    super.key,
    required this.onContinue,
    required this.onBack,
    this.initialData,
  });

  /// Called when the form is valid and the user taps "Continue".
  final ValueChanged<ProjectDetails> onContinue;

  /// Called when the user taps "Back" (exits the wizard).
  final VoidCallback onBack;

  /// Pre-fill the form when navigating back from Step 2.
  final ProjectDetails? initialData;

  @override
  State<Step1ProjectDetails> createState() => _Step1ProjectDetailsState();
}

class _Step1ProjectDetailsState extends State<Step1ProjectDetails> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _clientCtrl;
  late final TextEditingController _descCtrl;

  ProjectType _selectedType = ProjectType.none;
  List<String> _teamEmails = [];

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameCtrl = TextEditingController(text: d?.projectName ?? '');
    _clientCtrl = TextEditingController(text: d?.clientEmail ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    if (d != null) {
      _selectedType = ProjectType.fromValue(d.projectType);
      _teamEmails = List<String>.from(d.teamMembers);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onContinue(ProjectDetails(
      projectName: _nameCtrl.text.trim(),
      clientEmail: _clientCtrl.text.trim(),
      projectType: _selectedType.value,
      description: _descCtrl.text.trim(),
      teamMembers: _teamEmails,
    ));
  }

  // ── Shared input decoration ──────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: regularStyle(
        fontSize: FontSize.font13,
        color: AppColors.lightgrey,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.lightgrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.lightgrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.4.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
      errorStyle: TextStyle(
        color: Colors.red,
        fontSize: 11.sp,
        height: 1.2,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Center(
              child: Column(
                children: [
                  Text(
                    'Create New Project',
                    style: boldStyle(
                      fontSize: FontSize.font22,
                      color: AppColors.darkgrey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Set up your project details before adding sources',
                    style: regularStyle(
                      fontSize: FontSize.font13,
                      color: AppColors.lightgrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Project Name ──
            _buildLabel('Project Name'),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration(hint: 'Ecommerce Platform'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Project name is required' : null,
            ),
            SizedBox(height: 18.h),

            // ── Client / Stakeholder ──
            _buildLabel('Client / Stakeholder'),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _clientCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(hint: 'client@company.com'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Client email is required';
                if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 18.h),

            // ── Project Type ──
            _buildLabel('Project Type'),
            SizedBox(height: 8.h),
            DropdownButtonFormField<ProjectType>(
              initialValue: _selectedType,
              decoration: _inputDecoration(hint: 'Select Type'),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
              borderRadius: BorderRadius.circular(12.r),
              items: ProjectType.values.map((pt) {
                return DropdownMenuItem<ProjectType>(
                  value: pt,
                  child: Text(
                    pt == ProjectType.none ? 'Select Type' : pt.label,
                    style: regularStyle(
                      fontSize: FontSize.font14,
                      color: pt == ProjectType.none
                          ? AppColors.lightgrey
                          : AppColors.darkgrey,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            SizedBox(height: 18.h),

            // ── Description ──
            _buildLabel('Description'),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: _inputDecoration(
                hint: 'What is this project about? Goals, users, constraints...',
              ),
            ),
            SizedBox(height: 18.h),

            // ── Team Members ──
            _buildLabel('Team Members'),
            SizedBox(height: 8.h),
            TeamMemberInput(
              emails: _teamEmails,
              onChanged: (updated) => setState(() => _teamEmails = updated),
            ),
            SizedBox(height: 32.h),

            // ── Buttons ──
            Row(
              children: [
                // Back button
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
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
                // Continue button
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
                        onTap: _submit,
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: boldStyle(
                                  fontSize: FontSize.font14,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 18.r),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: semiBoldStyle(
        fontSize: FontSize.font13,
        color: AppColors.darkgrey,
      ),
    );
  }
}
