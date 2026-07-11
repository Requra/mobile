import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';

/// An input field that collects email addresses and displays them as removable chips.
///
/// When the user types an email and presses Enter (or the submit button on the keyboard),
/// the email is validated and added as a chip below the input.
class TeamMemberInput extends StatefulWidget {
  const TeamMemberInput({
    super.key,
    required this.emails,
    required this.onChanged,
  });

  /// Current list of email addresses.
  final List<String> emails;

  /// Called whenever the list changes (add or remove).
  final ValueChanged<List<String>> onChanged;

  @override
  State<TeamMemberInput> createState() => _TeamMemberInputState();
}

class _TeamMemberInputState extends State<TeamMemberInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorText;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void _addEmail() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_emailRegex.hasMatch(text)) {
      setState(() => _errorText = 'Please enter a valid email');
      return;
    }

    if (widget.emails.contains(text)) {
      setState(() => _errorText = 'Email already added');
      return;
    }

    setState(() => _errorText = null);
    _controller.clear();

    final updated = List<String>.from(widget.emails)..add(text);
    widget.onChanged(updated);
  }

  void _removeEmail(String email) {
    final updated = List<String>.from(widget.emails)..remove(email);
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addEmail(),
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
          decoration: InputDecoration(
            hintText: 'Invite teammates to review and export',
            hintStyle: regularStyle(
              fontSize: FontSize.font13,
              color: AppColors.lightgrey,
            ),
            errorText: _errorText,
            errorStyle: TextStyle(
              color: Colors.red,
              fontSize: 11.sp,
              height: 1.2,
            ),
            suffixIcon: IconButton(
              onPressed: _addEmail,
              icon: Icon(Icons.add_circle_outline,
                  color: AppColors.primary, size: 22.r),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
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
          ),
        ),

        // Chips
        if (widget.emails.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.emails.map((email) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimaryBorder,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle_outlined,
                        size: 16.r, color: AppColors.primary),
                    SizedBox(width: 6.w),
                    Text(
                      email,
                      style: regularStyle(
                        fontSize: FontSize.font11,
                        color: AppColors.darkgrey,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => _removeEmail(email),
                      child: Icon(Icons.close,
                          size: 14.r, color: AppColors.lightgrey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
