import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requra/core/di/di_project.dart';
import 'package:requra/features/add_project/presentation/cubit/add_project_cubit.dart';
import 'package:requra/screens/Home/add_project/step1_project_details.dart';
import 'package:requra/screens/Home/add_project/step2_add_sources.dart';
import 'package:requra/screens/Home/add_project/step3_ai_generate.dart';
import 'package:requra/screens/Home/add_project/widgets/project_stepper.dart';
import 'package:requra/core/theme/color_manager.dart';

/// Multi-step "Add Project" wizard.
class AddProjectScreen extends StatelessWidget {
  final VoidCallback? onViewResults;

  const AddProjectScreen({super.key, this.onViewResults});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddProjectCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocBuilder<AddProjectCubit, AddProjectState>(
            builder: (context, state) {
              int currentStep = 0;
              if (state is AddProjectStep2) {
                currentStep = 1;
              } else if (state is AddProjectCreating || state is AddProjectSuccess || state is AddProjectError) {
                currentStep = 2;
              }

              return Column(
                children: [
                  // ── Stepper ──
                  ProjectStepper(currentStep: currentStep),

                  // ── Step content ──
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _buildStepContent(context, state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, AddProjectState state) {
    if (state is AddProjectStep1) {
      return Step1ProjectDetails(
        key: const ValueKey('step1'),
        initialData: state.details,
      );
    } else if (state is AddProjectStep2) {
      return Step2AddSources(
        key: const ValueKey('step2'),
      );
    } else {
      return Step3AiGenerate(
        key: const ValueKey('step3'),
        onViewResults: onViewResults ?? () {},
      );
    }
  }
}
