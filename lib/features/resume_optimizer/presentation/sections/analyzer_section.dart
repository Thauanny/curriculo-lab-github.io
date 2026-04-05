import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/resume_optimizer_controller.dart';
import '../controllers/resume_optimizer_state.dart';
import '../theme/app_colors.dart';
import 'input_panel.dart';
import 'results_panel.dart';

class AnalyzerSection extends ConsumerWidget {
  const AnalyzerSection({
    super.key,
    required this.analyzerKey,
    required this.state,
    required this.controller,
    required this.jobTitleController,
    required this.companyController,
    required this.jobDescriptionController,
    required this.extraContextController,
  });

  final GlobalKey analyzerKey;
  final ResumeOptimizerState state;
  final ResumeOptimizerController controller;
  final TextEditingController jobTitleController;
  final TextEditingController companyController;
  final TextEditingController jobDescriptionController;
  final TextEditingController extraContextController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      key: analyzerKey,
      children: [
        Text(
          'Comece agora',
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Preencha os dados abaixo para gerar sua análise completa',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              InputPanel(
                state: state,
                controller: controller,
                jobTitleController: jobTitleController,
                companyController: companyController,
                jobDescriptionController: jobDescriptionController,
                extraContextController: extraContextController,
              ),
              const SizedBox(height: 24),
              if (state.isLoading || state.analysis != null)
                ResultsPanel(state: state, controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}
