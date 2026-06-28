
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/features/project/data/models/project_enums.dart';
import 'package:requra/screens/Home/add_project/widgets/source_item_card.dart';
import 'package:requra/theme/color_manager.dart';
import 'package:requra/theme/font_manager.dart';
import 'package:requra/theme/style_manager.dart';

/// Step 2 of the Add Project wizard — "Add Requirement Sources".
///
/// Contains 3 internal tabs (Meeting, Documents, Transcript) and a global
/// list of uploaded sources that is shared across all tabs.
class Step2AddSources extends StatefulWidget {
  const Step2AddSources({
    super.key,
    required this.sources,
    required this.onSourcesChanged,
    required this.onContinue,
    required this.onBack,
  });

  /// Current list of collected sources.
  final List<SourceItem> sources;

  /// Notify parent whenever the source list changes.
  final ValueChanged<List<SourceItem>> onSourcesChanged;

  /// Called when the user taps "Continue" to move to Step 3.
  final VoidCallback onContinue;

  /// Called when the user taps "Back" to return to Step 1.
  final VoidCallback onBack;

  @override
  State<Step2AddSources> createState() => _Step2AddSourcesState();
}

class _Step2AddSourcesState extends State<Step2AddSources>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Transcript tab state
  final _transcriptCtrl = TextEditingController();
  DocumentType _transcriptType = DocumentType.pdf;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transcriptCtrl.dispose();
    super.dispose();
  }

  // ── Source management ────────────────────────────────────────────────────

  void _addSource(SourceItem source) {
    final updated = List<SourceItem>.from(widget.sources)..add(source);
    widget.onSourcesChanged(updated);
  }

  void _removeSource(int index) {
    final updated = List<SourceItem>.from(widget.sources)..removeAt(index);
    widget.onSourcesChanged(updated);
  }

  // ── Meetings ─────────────────────────────────────────────────────────────

  void _startMeeting() {
    // Add a live session source as a placeholder
    _addSource(SourceItem(
      fileName: 'Live Meeting Session',
      fileSizeBytes: 0,
      documentType: DocumentType.liveSession.value,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Live meeting session added'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── File upload ──────────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'mp3', 'mp4'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    for (final file in result.files) {
      final ext = '.${file.extension ?? ''}';
      _addSource(SourceItem(
        fileName: file.name,
        fileSizeBytes: file.size,
        documentType: DocumentType.fromExtension(ext).value,
        fileBytes: file.bytes,
      ));
    }
  }

  // ── Transcript ───────────────────────────────────────────────────────────

  void _saveTranscript() {
    final text = _transcriptCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter transcript text'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final ext = _transcriptType == DocumentType.pdf ? '.pdf' : '.docx';
    _addSource(SourceItem(
      fileName: 'transcript$ext',
      fileSizeBytes: text.length,
      documentType: _transcriptType.value,
      transcriptText: text,
    ));

    _transcriptCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transcript saved'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Center(
            child: Column(
              children: [
                Text(
                  'Add Requirement Sources',
                  style: boldStyle(
                    fontSize: FontSize.font22,
                    color: AppColors.darkgrey,
                  ),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Choose one or more sources to help AI understand your project',
                    style: regularStyle(
                      fontSize: FontSize.font13,
                      color: AppColors.lightgrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ── Tabs ──
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFEEEEF0),
                  width: 1.h,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.lightgrey,
              labelStyle: semiBoldStyle(
                fontSize: FontSize.font13,
                color: AppColors.primary,
              ),
              unselectedLabelStyle: regularStyle(
                fontSize: FontSize.font13,
                color: AppColors.lightgrey,
              ),
              tabs: [
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_none_outlined, size: 16.r),
                        SizedBox(width: 4.w),
                        const Text('Meeting'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_upload_outlined, size: 16.r),
                        SizedBox(width: 4.w),
                        const Text('Documents'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_outlined, size: 16.r),
                        SizedBox(width: 4.w),
                        const Text('Transcript'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Tab content (not using TabBarView to avoid nested scroll) ──
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, _) {
              switch (_tabController.index) {
                case 0:
                  return _buildMeetingTab();
                case 1:
                  return _buildDocumentsTab();
                case 2:
                  return _buildTranscriptTab();
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
          SizedBox(height: 24.h),

          // ── Uploaded Sources ──
          Text(
            'Uploaded Sources',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.darkgrey,
            ),
          ),
          SizedBox(height: 12.h),
          if (widget.sources.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFEEEEF0)),
              ),
              child: Center(
                child: Text(
                  'No sources added yet',
                  style: regularStyle(
                    fontSize: FontSize.font12,
                    color: AppColors.lightgrey,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 72.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.sources.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (_, i) => SourceItemCard(
                  source: widget.sources[i],
                  onRemove: () => _removeSource(i),
                ),
              ),
            ),
          SizedBox(height: 28.h),

          // ── Buttons ──
          Row(
            children: [
              // Back
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
              // Continue
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
                      onTap: widget.onContinue,
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
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 18.r),
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
    );
  }

  // ── Meeting Tab ──────────────────────────────────────────────────────────

  Widget _buildMeetingTab() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Mic icon circle
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.lightPrimaryBorder,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic, color: AppColors.primary, size: 28.r),
          ),
          SizedBox(height: 16.h),
          Text(
            'Ready to Capture Live Meeting',
            style: semiBoldStyle(
              fontSize: FontSize.font14,
              color: AppColors.darkgrey,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Transcript in real-time, extract requirements, and\nmap stakeholder input instantly',
            style: regularStyle(
              fontSize: FontSize.font11,
              color: AppColors.lightgrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          OutlinedButton(
            onPressed: _startMeeting,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Start Meeting',
              style: semiBoldStyle(
                fontSize: FontSize.font14,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Documents Tab ────────────────────────────────────────────────────────

  Widget _buildDocumentsTab() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD0D0D5),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFD0D0D5),
            radius: 16.r,
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 40.r, color: AppColors.lightgrey),
              SizedBox(height: 12.h),
              Text(
                'Click or drag file to this area to upload',
                style: semiBoldStyle(
                  fontSize: FontSize.font13,
                  color: AppColors.darkgrey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Supported formats: PDF, DOCX, TXT, MP3, MP4.',
                style: regularStyle(
                  fontSize: FontSize.font11,
                  color: AppColors.lightgrey,
                ),
              ),
              SizedBox(height: 20.h),
              OutlinedButton(
                onPressed: _pickFiles,
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                  side: BorderSide(color: AppColors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Upload Files',
                  style: semiBoldStyle(
                    fontSize: FontSize.font14,
                    color: AppColors.darkgrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Transcript Tab ───────────────────────────────────────────────────────

  Widget _buildTranscriptTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text area
        TextFormField(
          controller: _transcriptCtrl,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'What is this project about? Goals, users, constraints...',
            hintStyle: regularStyle(
              fontSize: FontSize.font13,
              color: AppColors.lightgrey,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
        SizedBox(height: 16.h),

        // Source Type label
        Text(
          'Source Type',
          style: semiBoldStyle(
            fontSize: FontSize.font13,
            color: AppColors.darkgrey,
          ),
        ),
        SizedBox(height: 8.h),

        // Dropdown: PDF or DOCX only
        DropdownButtonFormField<DocumentType>(
          initialValue: _transcriptType,
          decoration: InputDecoration(
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
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          borderRadius: BorderRadius.circular(12.r),
          items: [DocumentType.pdf, DocumentType.docx]
              .map((dt) => DropdownMenuItem<DocumentType>(
                    value: dt,
                    child: Text(
                      dt.label,
                      style: regularStyle(
                        fontSize: FontSize.font14,
                        color: AppColors.darkgrey,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _transcriptType = v);
          },
        ),
        SizedBox(height: 18.h),

        // Save button
        Center(
          child: OutlinedButton(
            onPressed: _saveTranscript,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Save Transcript',
              style: semiBoldStyle(
                fontSize: FontSize.font14,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for dashed border effect on the Documents upload zone.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // The dashed effect is handled by the parent container's border.
    // This painter is a placeholder for visual enhancement if needed.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
