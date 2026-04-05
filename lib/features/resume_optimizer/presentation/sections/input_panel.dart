import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/resume_optimizer_controller.dart';
import '../controllers/resume_optimizer_state.dart';
import '../providers/resume_optimizer_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/inline_alert.dart';
import '../widgets/model_status_banner.dart';
import '../widgets/section_label.dart';
import '../widgets/step_indicator.dart';
import '../widgets/upload_card.dart';

class InputPanel extends ConsumerWidget {
  const InputPanel({
    super.key,
    required this.state,
    required this.controller,
    required this.jobTitleController,
    required this.companyController,
    required this.jobDescriptionController,
    required this.extraContextController,
  });

  final ResumeOptimizerState state;
  final ResumeOptimizerController controller;
  final TextEditingController jobTitleController;
  final TextEditingController companyController;
  final TextEditingController jobDescriptionController;
  final TextEditingController extraContextController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final webllmInit = ref.watch(webllmInitProvider);
    final isModelReady = webllmInit.valueOrNull == true;
    final modelError = webllmInit.error?.toString();
    final progressAsync = ref.watch(webllmProgressProvider);
    final progressText = progressAsync.valueOrNull;

    double? progressPercent;
    if (progressText != null) {
      final match = RegExp(r'(\d+)%').firstMatch(progressText);
      if (match != null) {
        progressPercent = double.tryParse(match.group(1)!);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configure a Análise',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Modelo de IA · 100% local e privado',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Model status ────────────────────────────────────────────
          ModelStatusBanner(
            isReady: isModelReady,
            errorMessage: modelError,
            progressText: progressText,
            progressPercent: progressPercent,
            onRetry: () => ref.invalidate(webllmInitProvider),
          ),
          const SizedBox(height: 28),

          // ── Stepper ─────────────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StepPill(
                    number: 1,
                    label: 'Vaga',
                    isComplete: state.jobDescription.isNotEmpty,
                    isActive: true,
                  ),
                  StepDash(isComplete: state.jobDescription.isNotEmpty),
                  StepPill(
                    number: 2,
                    label: 'Currículo',
                    isComplete: state.selectedDocument != null,
                    isActive: state.jobDescription.isNotEmpty,
                  ),
                  StepDash(isComplete: state.isLoading),
                  StepPill(
                    number: 3,
                    label: 'Análise',
                    isComplete: state.analysis != null,
                    isActive: state.isLoading,
                    isLoading: state.isLoading,
                  ),
                  StepDash(isComplete: state.analysis != null),
                  StepPill(
                    number: 4,
                    label: 'Resultado',
                    isComplete: state.analysis != null,
                    isActive: state.analysis != null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Form: Job details ───────────────────────────────────────
          SectionLabel(number: '1', label: 'Vaga Alvo', subtitle: 'Detalhe a posição para uma análise precisa.'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: jobTitleController,
                  onChanged: controller.setJobTitle,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Senior DevOps Engineer',
                    prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: companyController,
                  onChanged: controller.setCompanyName,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Acme Corp',
                    prefixIcon: Icon(Icons.apartment_rounded, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: jobDescriptionController,
            maxLines: 5,
            onChanged: controller.setJobDescription,
            decoration: const InputDecoration(
              hintText: 'Cole a descrição completa da vaga: requisitos, stack, senioridade...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Icon(Icons.subject_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: extraContextController,
            maxLines: 2,
            onChanged: controller.setExtraContext,
            decoration: const InputDecoration(
              hintText: 'Opcional: contexto extra, keywords prioritárias...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Icon(Icons.tips_and_updates_outlined, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Form: Resume upload ─────────────────────────────────────
          SectionLabel(number: '2', label: 'Seu Currículo', subtitle: 'Envie seu currículo em PDF.'),
          const SizedBox(height: 14),
          UploadCard(
            fileName: state.selectedDocument?.fileName,
            onPick: state.isLoading ? null : controller.pickResume,
            onClear: state.isLoading || state.selectedDocument == null ? null : controller.clearDocument,
          ),
          const SizedBox(height: 12),
          const _UploadPrivacyNotice(),

          // Error
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            InlineAlert(message: state.errorMessage!),
          ],

          const SizedBox(height: 28),
          // ── Freeze warning ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A IA roda localmente no seu navegador — a tela pode travar levemente durante o processamento. '
                    'Tempo estimado: 1 a 3 minutos dependendo do dispositivo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ── Submit ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: (state.canAnalyze && isModelReady) ? controller.analyze : null,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt_rounded, size: 20),
              label: Text(
                state.isLoading ? 'Analisando...' : 'Gerar Análise Completa',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.slate200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPrivacyNotice extends StatelessWidget {
  const _UploadPrivacyNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.slate400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prefere não usar dados reais? Sem problema. '
              'A análise foca exclusivamente em habilidades, experiências profissionais, '
              'formação acadêmica e demais conteúdos relevantes — não em nome, telefone ou e-mail. '
              'Nenhuma informação sai do seu navegador.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.slate400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
