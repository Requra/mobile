/// Enum for the project type field.
/// The backend expects the integer value, not the label.
enum ProjectType {
  none(0, 'None'),
  financial(1, 'Financial'),
  medical(2, 'Medical'),
  educational(3, 'Educational');

  const ProjectType(this.value, this.label);
  final int value;
  final String label;

  /// Look up a [ProjectType] by its integer value.
  static ProjectType fromValue(int v) =>
      ProjectType.values.firstWhere((e) => e.value == v, orElse: () => none);
}

/// Enum for the document / source type field.
/// The backend expects the integer value.
enum DocumentType {
  pdf(0, 'PDF'),
  docx(1, 'DOCX'),
  audio(2, 'Audio'),
  liveSession(3, 'Live Session');

  const DocumentType(this.value, this.label);
  final int value;
  final String label;

  /// Look up a [DocumentType] by its integer value.
  static DocumentType fromValue(int v) =>
      DocumentType.values.firstWhere((e) => e.value == v, orElse: () => pdf);

  /// Infer the document type from a file extension string (e.g. ".pdf").
  static DocumentType fromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return DocumentType.pdf;
      case '.docx':
      case '.doc':
        return DocumentType.docx;
      case '.mp3':
      case '.mp4':
      case '.wav':
      case '.m4a':
        return DocumentType.audio;
      default:
        return DocumentType.pdf;
    }
  }
}
