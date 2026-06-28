import 'dart:typed_data';

import 'package:requra/features/project/data/models/project_enums.dart';

/// Holds the data collected in Step 1 of the wizard.
class ProjectDetails {
  final String projectName;
  final String clientEmail;
  final int projectType; // integer enum value
  final String description;
  final List<String> teamMembers; // list of email strings

  const ProjectDetails({
    required this.projectName,
    required this.clientEmail,
    required this.projectType,
    required this.description,
    required this.teamMembers,
  });

  Map<String, dynamic> toJson() => {
        'projectName': projectName,
        'clientEmail': clientEmail,
        'projectType': projectType,
        'description': description,
        'teamMembers': teamMembers,
      };
}

/// Represents a single uploaded / pasted source in Step 2.
class SourceItem {
  final String fileName;
  final int fileSizeBytes;
  final int documentType; // integer enum value
  final Uint8List? fileBytes; // non-null for uploaded files
  final String? transcriptText; // non-null for pasted transcripts

  const SourceItem({
    required this.fileName,
    required this.fileSizeBytes,
    required this.documentType,
    this.fileBytes,
    this.transcriptText,
  });

  /// Human-readable file size.
  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// The label of the document type.
  String get typeLabel => DocumentType.fromValue(documentType).label;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'documentType': documentType,
        if (transcriptText != null) 'transcriptText': transcriptText,
      };
}
