import 'package:requra/features/result_view/domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.title,
    super.type,
    super.storageUrl,
    super.fileSize,
    required super.status,
    super.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] as int?,
      storageUrl: json['storageUrl'],
      // fileSize comes in as various numeric types (can be negative due to mock data)
      fileSize: _parseFileSize(json['fileSize']),
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  static double? _parseFileSize(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble().abs();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.abs();
    }
    return null;
  }
}
