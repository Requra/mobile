import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final String id;
  final String title;
  final int? type;
  final String? storageUrl;
  final double? fileSize;
  final int status;
  final DateTime? createdAt;

  const Document({
    required this.id,
    required this.title,
    this.type,
    this.storageUrl,
    this.fileSize,
    required this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        storageUrl,
        fileSize,
        status,
        createdAt,
      ];
}
