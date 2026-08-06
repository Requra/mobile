import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:requra/core/global_widgets/custom_button.dart';
import 'package:requra/core/theme/color_manager.dart';
import 'package:requra/core/theme/font_manager.dart';
import 'package:requra/core/theme/style_manager.dart';
import 'package:requra/features/result_view/domain/entities/document.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/widgets/overview/document_tile.dart';

class FileManagementSection extends StatelessWidget {
  final List<Document> documents;
  final String projectId;

  const FileManagementSection({
    super.key,
    required this.documents,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.backgroundHomeScreen,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  size: 20.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Management',
                      style: boldStyle(
                        fontSize: FontSize.font16,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      '${documents.length} source documents attached',
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
          
          SizedBox(height: 16.h),
          
          CustomButton(
            text: 'Upload File',
            icon: Icons.upload_file,
            isRegularStyle: true,
            transparent: true,
            borderColor: AppColors.grey,
            onTap: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'docx', 'mp3', 'wav', 'm4a', 'aac'],
                );
                if (result != null && result.files.single.path != null) {
                  File file = File(result.files.single.path!);
                  String fileName = result.files.single.name;
                  String extension = result.files.single.extension ?? 'pdf';

                  if (context.mounted) {
                    final error = await context.read<ResultViewCubit>().uploadDocument(
                          file: file,
                          projectId: projectId,
                          title: fileName,
                          type: extension,
                          language: 'En',
                        );
                        
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to pick file: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),

          if (documents.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (_, __) => Divider(color: const Color(0xFFE5E7EB), height: 24.h),
              itemBuilder: (context, index) {
                final document = documents[index];
                return InkWell(
                  onTap: () async {
                    if (document.status == 999) return; // Don't download if uploading
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading document...')),
                    );
                    
                    final result = await context.read<ResultViewCubit>().downloadDocument(document: document);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result ?? 'Download finished'),
                          backgroundColor: result != null && result.contains('Success') 
                            ? AppColors.statusFinished 
                            : AppColors.error,
                        ),
                      );
                    }
                  },
                  child: DocumentTile(document: document),
                );
              },
            ),
          ]
        ],
      ),
    );
  }
}
