import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requra/features/result_view/domain/entities/project_details.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/analysis_overview_card.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/project_description_card.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/project_header_section.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/file_management_section.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/project_metadata_card.dart';

class OverviewTab extends StatelessWidget {
  final ProjectDetails details;
  final int totalRequirements;
  final List<Document> documents;
  final String projectId;

  const OverviewTab({
    super.key,
    required this.details,
    required this.totalRequirements,
    required this.documents,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Project header (name, status, date)
          ProjectHeaderSection(details: details),

          SizedBox(height: 12.h),

          /// Analysis Overview metrics card
          AnalysisOverviewCard(totalRequirements: totalRequirements),

          SizedBox(height: 16.h),

          /// Project Description card
          ProjectDescriptionCard(description: details.description),

          SizedBox(height: 16.h),

          /// Project Metadata card (client, team, etc.)
          ProjectMetadataCard(details: details),

          SizedBox(height: 16.h),

          /// File Management section
          FileManagementSection(
            documents: documents,
            projectId: projectId,
          ),
        ],
      ),
    );
  }
}
