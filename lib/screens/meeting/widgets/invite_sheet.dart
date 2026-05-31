import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/meeting/data/models/meeting_models.dart';
import 'package:requra/features/meeting/data/services/meeting_service.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// Tabbed invite bottom sheet: Members / Stakeholders / Guests.
class InviteSheet extends StatefulWidget {
  const InviteSheet({
    super.key,
    required this.meetingId,
    required this.projectId,
    required this.onInvited,
  });

  final String meetingId;
  final String projectId;
  final VoidCallback onInvited;

  /// Convenience helper.
  static Future<void> show(
    BuildContext context, {
    required String meetingId,
    required String projectId,
    required VoidCallback onInvited,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => InviteSheet(
        meetingId: meetingId,
        projectId: projectId,
        onInvited: onInvited,
      ),
    );
  }

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MeetingService _service = const MeetingService();

  // ── Members tab state ──
  List<ProjectMember> _members = [];
  final Set<String> _selectedMemberIds = {};
  bool _loadingMembers = true;

  // ── Stakeholders tab state ──
  List<ProjectStakeholder> _stakeholders = [];
  final Set<String> _selectedStakeholderIds = {};
  bool _loadingStakeholders = true;
  final TextEditingController _newStakeholderName = TextEditingController();
  final TextEditingController _newStakeholderEmail = TextEditingController();

  // ── Guests tab state ──
  final List<_GuestEntry> _guests = [_GuestEntry()];

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMembers();
    _fetchStakeholders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newStakeholderName.dispose();
    _newStakeholderEmail.dispose();
    for (final g in _guests) {
      g.name.dispose();
      g.email.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    final response = await _service.getProjectMembers(widget.projectId);
    if (!mounted) return;
    setState(() {
      _loadingMembers = false;
      if (response.isSuccess) {
        final data = response.data;
        List? list;
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          list = data['items'] as List;
        }
        if (list != null) {
          _members = list
              .map((e) => ProjectMember.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    });
  }

  Future<void> _fetchStakeholders() async {
    final response = await _service.getProjectStakeholders(widget.projectId);
    if (!mounted) return;
    setState(() {
      _loadingStakeholders = false;
      if (response.isSuccess) {
        final data = response.data;
        List? list;
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          list = data['items'] as List;
        }
        if (list != null) {
          _stakeholders = list
              .map((e) => ProjectStakeholder.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    });
  }

  // ── Submit handlers ──

  Future<void> _submitMembers() async {
    if (_selectedMemberIds.isEmpty) return;
    setState(() => _submitting = true);
    final response = await _service.inviteProjectMembers(
      widget.meetingId,
      _selectedMemberIds.toList(),
      'PARTICIPANT',
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (response.isSuccess) {
      widget.onInvited();
      Navigator.pop(context);
    } else {
      _showError(response.message);
    }
  }

  Future<void> _submitStakeholders() async {
    final bool hasExisting = _selectedStakeholderIds.isNotEmpty;
    final bool hasNew = _newStakeholderName.text.trim().isNotEmpty &&
        _newStakeholderEmail.text.trim().isNotEmpty;
    if (!hasExisting && !hasNew) return;

    setState(() => _submitting = true);
    final response = await _service.inviteStakeholders(
      widget.meetingId,
      stakeholderIds: hasExisting ? _selectedStakeholderIds.toList() : null,
      newStakeholders: hasNew
          ? [
              {
                'displayName': _newStakeholderName.text.trim(),
                'email': _newStakeholderEmail.text.trim(),
              }
            ]
          : null,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (response.isSuccess) {
      widget.onInvited();
      Navigator.pop(context);
    } else {
      _showError(response.message);
    }
  }

  Future<void> _submitGuests() async {
    final List<Map<String, String>> guestList = _guests
        .where((g) =>
            g.name.text.trim().isNotEmpty && g.email.text.trim().isNotEmpty)
        .map((g) => {
              'displayName': g.name.text.trim(),
              'email': g.email.text.trim(),
            })
        .toList();
    if (guestList.isEmpty) return;

    setState(() => _submitting = true);
    final expiresAt =
        DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String();
    final response = await _service.inviteGuests(
      widget.meetingId,
      guestList,
      'PARTICIPANT',
      expiresAt,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (response.isSuccess) {
      widget.onInvited();
      Navigator.pop(context);
    } else {
      _showError(response.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.liveRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.8.sh),
      decoration: BoxDecoration(
        color: AppColors.meetingCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(color: AppColors.meetingCardBorder, width: 1),
          left: BorderSide(color: AppColors.meetingCardBorder, width: 1),
          right: BorderSide(color: AppColors.meetingCardBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Title ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    color: AppColors.primary, size: 22.r),
                SizedBox(width: 10.w),
                Text(
                  'Invite to Meeting',
                  style: semiBoldStyle(
                    fontSize: FontSize.font18,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Tab bar ──
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: AppColors.meetingBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10.r),
              ),
              dividerColor: Colors.transparent,
              labelColor: AppColors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: semiBoldStyle(
                fontSize: FontSize.font12,
                color: AppColors.white,
              ),
              unselectedLabelStyle: regularStyle(
                fontSize: FontSize.font12,
                color: Colors.white38,
              ),
              tabs: const [
                Tab(text: 'Members'),
                Tab(text: 'Stakeholders'),
                Tab(text: 'Guests'),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ── Tab views ──
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(),
                _buildStakeholdersTab(),
                _buildGuestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Members tab ──
  Widget _buildMembersTab() {
    if (_loadingMembers) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _members.isEmpty
              ? Center(
                  child: Text(
                    'No project members found',
                    style: regularStyle(
                      fontSize: FontSize.font14,
                      color: Colors.white38,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: _members.length,
                  itemBuilder: (_, index) {
                    final member = _members[index];
                    final selected = _selectedMemberIds.contains(member.id);
                    return _SelectableRow(
                      initials: _initials(member.displayName),
                      name: member.displayName,
                      subtitle: member.email,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedMemberIds.remove(member.id);
                          } else {
                            _selectedMemberIds.add(member.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        _buildSubmitButton(
          label: 'Invite ${_selectedMemberIds.length} member${_selectedMemberIds.length == 1 ? '' : 's'}',
          enabled: _selectedMemberIds.isNotEmpty && !_submitting,
          onTap: _submitMembers,
        ),
      ],
    );
  }

  // ── Stakeholders tab ──
  Widget _buildStakeholdersTab() {
    if (_loadingStakeholders) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            children: [
              ..._stakeholders.map((s) {
                final selected = _selectedStakeholderIds.contains(s.id);
                return _SelectableRow(
                  initials: _initials(s.displayName),
                  name: s.displayName,
                  subtitle: s.email,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedStakeholderIds.remove(s.id);
                      } else {
                        _selectedStakeholderIds.add(s.id);
                      }
                    });
                  },
                );
              }),
              SizedBox(height: 16.h),
              Divider(color: AppColors.meetingCardBorder),
              SizedBox(height: 8.h),
              Text(
                'New Stakeholder',
                style: semiBoldStyle(
                  fontSize: FontSize.font13,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8.h),
              _DarkTextField(controller: _newStakeholderName, hint: 'Name'),
              SizedBox(height: 8.h),
              _DarkTextField(controller: _newStakeholderEmail, hint: 'Email'),
            ],
          ),
        ),
        _buildSubmitButton(
          label: 'Invite stakeholder(s)',
          enabled: (_selectedStakeholderIds.isNotEmpty ||
                  (_newStakeholderName.text.trim().isNotEmpty &&
                      _newStakeholderEmail.text.trim().isNotEmpty)) &&
              !_submitting,
          onTap: _submitStakeholders,
        ),
      ],
    );
  }

  // ── Guests tab ──
  Widget _buildGuestsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            children: [
              for (int i = 0; i < _guests.length; i++) ...[
                if (i > 0) SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _DarkTextField(
                        controller: _guests[i].name,
                        hint: 'Name',
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _DarkTextField(
                        controller: _guests[i].email,
                        hint: 'Email',
                      ),
                    ),
                    if (_guests.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _guests[i].name.dispose();
                            _guests[i].email.dispose();
                            _guests.removeAt(i);
                          });
                        },
                        icon: Icon(Icons.remove_circle_outline,
                            color: AppColors.liveRed, size: 20.r),
                      ),
                  ],
                ),
              ],
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _guests.add(_GuestEntry())),
                  icon: Icon(Icons.add_rounded,
                      color: AppColors.primary, size: 18.r),
                  label: Text(
                    'Add another guest',
                    style: semiBoldStyle(
                      fontSize: FontSize.font13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildSubmitButton(
          label: 'Invite guest(s)',
          enabled: _guests.any((g) =>
                  g.name.text.trim().isNotEmpty &&
                  g.email.text.trim().isNotEmpty) &&
              !_submitting,
          onTap: _submitGuests,
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: _submitting
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _GuestEntry {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String initials;
  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: semiBoldStyle(
                  fontSize: FontSize.font11,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: semiBoldStyle(
                      fontSize: FontSize.font14,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: regularStyle(
                      fontSize: FontSize.font11,
                      color: Colors.white38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      color: Colors.white, size: 14.r)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: regularStyle(fontSize: FontSize.font14, color: AppColors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: regularStyle(fontSize: FontSize.font14, color: Colors.white24),
        filled: true,
        fillColor: AppColors.meetingBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.meetingCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.meetingCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
