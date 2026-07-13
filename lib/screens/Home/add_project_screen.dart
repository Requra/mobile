import 'package:flutter/material.dart';
import 'package:requra/features/project/data/models/add_project_model.dart';
import 'package:requra/screens/Home/add_project/step1_project_details.dart';
import 'package:requra/screens/Home/add_project/step2_add_sources.dart';
import 'package:requra/screens/Home/add_project/step3_ai_generate.dart';
import 'package:requra/screens/Home/add_project/widgets/project_stepper.dart';
import 'package:requra/core/theme/color_manager.dart';

/// Multi-step "Add Project" wizard.
///
/// Manages three steps:
///   0 → Project Details (form)
///   1 → Add Sources (Meeting / Documents / Transcript)
///   2 → AI Generate (Loading & Success)
class AddProjectScreen extends StatefulWidget {
  final VoidCallback? onViewResults;

  const AddProjectScreen({super.key, this.onViewResults});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  int _currentStep = 0;

  // Collected data
  ProjectDetails? _projectDetails;
  List<SourceItem> _sources = [];

  // ── Navigation callbacks ─────────────────────────────────────────────────

  void _goToStep2(ProjectDetails details) {
    setState(() {
      _projectDetails = details;
      _currentStep = 1;
    });
  }

  void _backToStep1() {
    setState(() => _currentStep = 0);
  }

  void _exitWizard() {
    // Pop back to the previous screen / Dashboard
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _backToStep2() {
    setState(() => _currentStep = 1);
  }

  void _onStep2Continue() {
    setState(() {
      _currentStep = 2;
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Stepper ──
            ProjectStepper(currentStep: _currentStep),

            // ── Step content ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _currentStep == 0
                    ? Step1ProjectDetails(
                        key: const ValueKey('step1'),
                        initialData: _projectDetails,
                        onContinue: _goToStep2,
                        onBack: _exitWizard,
                      )
                    : _currentStep == 1
                        ? Step2AddSources(
                            key: const ValueKey('step2'),
                            sources: _sources,
                            onSourcesChanged: (updated) =>
                                setState(() => _sources = updated),
                            onContinue: _onStep2Continue,
                            onBack: _backToStep1,
                          )
                        : Step3AiGenerate(
                            key: const ValueKey('step3'),
                            projectDetails: _projectDetails,
                            sources: _sources,
                            onBack: _backToStep2,
                            onViewResults: widget.onViewResults ?? () {},
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
