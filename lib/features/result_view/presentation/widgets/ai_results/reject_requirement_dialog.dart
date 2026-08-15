import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/features/result_view/domain/entities/ai_results_dashboard.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';
import 'package:requra/features/result_view/presentation/widgets/ai_results/shared/reject_item_dialog.dart';

class RejectRequirementDialog extends StatelessWidget {
  final AiRequirement requirement;
  final String projectId;

  const RejectRequirementDialog({
    super.key,
    required this.requirement,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return RejectItemDialog(
      title: 'Reject requirement',
      subtitle: 'Explain what must change so the decision remains useful and auditable.',
      successMessage: 'Requirement rejected successfully',
      onReject: (feedback) async {
        final cubit = context.read<ResultViewCubit>();
        return await cubit.updateRequirementStatus(
          projectId,
          requirement.id,
          'REJECTED',
          reviewFeedback: feedback,
        );
      },
    );
  }
}
