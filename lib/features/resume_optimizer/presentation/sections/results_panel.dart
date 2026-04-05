import 'package:flutter/material.dart';

import '../../domain/entities/ats_result.dart';
import '../controllers/resume_optimizer_controller.dart';
import '../controllers/resume_optimizer_state.dart';
import '../theme/app_colors.dart';
import '../widgets/analysis_section_card.dart';
import '../widgets/ats_detail_widgets.dart';
import '../widgets/data_display.dart';
import '../widgets/metric_badge.dart';
import '../widgets/preview_row.dart';
import '../widgets/process_step.dart';
import '../widgets/resume_editor_section.dart';

class ResultsPanel extends StatelessWidget {
  const ResultsPanel({
    super.key,
    required this.state,
    required this.controller,
  });

  final ResumeOptimizerState state;
  final ResumeOptimizerController controller;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return AnalysisSectionCard(
        title: 'Processando com IA',
        subtitle: 'Analisando currículo, mapeando compatibilidade e preparando reescrita.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              child: LinearProgressIndicator(
                minHeight: 6,
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            SizedBox(height: 20),
            ProcessStep(icon: Icons.document_scanner_outlined, label: 'Leitura e extração do currículo'),
            ProcessStep(icon: Icons.compare_arrows_rounded, label: 'Mapeamento ATS e compatibilidade com a vaga'),
            ProcessStep(icon: Icons.edit_note_rounded, label: 'Reescrita otimizada do currículo'),
          ],
        ),
      );
    }

    final analysis = state.analysis;
    if (analysis == null) {
      return AnalysisSectionCard(
        title: 'Resultado da análise',
        subtitle: 'Envie os dados acima para ver o diagnóstico completo.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            PreviewRow(
              icon: Icons.show_chart_rounded,
              title: 'Compatibilidade com a vaga',
              text: 'Score de match, keywords e lacunas.',
            ),
            SizedBox(height: 12),
            PreviewRow(
              icon: Icons.verified_outlined,
              title: 'Diagnóstico ATS',
              text: 'Leitura estrutural e termos importantes.',
            ),
            SizedBox(height: 12),
            PreviewRow(
              icon: Icons.auto_fix_high_rounded,
              title: 'Currículo recriado',
              text: 'Versão em markdown pronta para exportar.',
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        AnalysisSectionCard(
          title: 'Diagnóstico executivo',
          subtitle: analysis.atsOptimizedHeadline,
          child: Text(analysis.executiveSummary, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 20),
        AnalysisSectionCard(
          title: 'Perfil extraído',
          subtitle: '${analysis.candidateProfile.fullName}  ·  ${analysis.candidateProfile.professionalTitle}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experiência: ${analysis.candidateProfile.yearsOfExperience}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              ChipGroup(items: analysis.candidateProfile.topSkills),
              const SizedBox(height: 16),
              BulletColumn(title: 'Conquistas', items: analysis.candidateProfile.keyAchievements),
              const SizedBox(height: 16),
              BulletColumn(title: 'Formação', items: analysis.candidateProfile.education),
              const SizedBox(height: 16),
              BulletColumn(title: 'Idiomas e certificações', items: [
                ...analysis.candidateProfile.languages,
                ...analysis.candidateProfile.certifications,
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnalysisSectionCard(
          title: 'Compatibilidade com a vaga',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricBadge(
                label: 'Match com a vaga',
                score: analysis.jobCompatibility.score,
                caption: 'Aderência entre perfil e posição (calculado pela IA).',
              ),
              const SizedBox(height: 18),
              SplitLists(
                leftTitle: 'Keywords aderentes',
                leftItems: analysis.jobCompatibility.matchedKeywords,
                rightTitle: 'Keywords ausentes',
                rightItems: analysis.jobCompatibility.missingKeywords,
              ),
              const SizedBox(height: 18),
              SplitLists(
                leftTitle: 'Forças',
                leftItems: analysis.jobCompatibility.strengths,
                rightTitle: 'Riscos / lacunas',
                rightItems: analysis.jobCompatibility.risks,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnalysisSectionCard(
          title: 'Leitura ATS',
          subtitle: 'Scores calculados pelo ATS Engine (algorítmico).',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_rounded, size: 14, color: AppColors.emerald),
                SizedBox(width: 4),
                Text(
                  'ATS Engine',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  MetricBadge(
                    label: 'Leitura ATS',
                    score: analysis.atsAssessment.overallScore,
                    caption: 'Compatibilidade estrutural com sistemas ATS.',
                  ),
                  MetricBadge(
                    label: 'Keywords',
                    score: analysis.atsAssessment.keywordAlignmentScore,
                    caption: 'Cobertura de termos relevantes.',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  MetricBadge(
                    label: 'Completude',
                    score: analysis.atsAssessment.sectionCompletenessScore,
                    caption: 'Presença das seções esperadas pelo ATS.',
                  ),
                  MetricBadge(
                    label: 'Legibilidade',
                    score: analysis.atsAssessment.readabilityScore,
                    caption: 'Clareza e estrutura do texto para leitura automática.',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SplitLists(
                leftTitle: 'Problemas',
                leftItems: analysis.atsAssessment.issues,
                rightTitle: 'Recomendações',
                rightItems: analysis.atsAssessment.recommendations,
              ),
              if (state.atsResult != null) ..._buildAtsDetails(context, state.atsResult!),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Rebuild resume button / PDF viewer ───────────────────────
        _buildResumeRebuildSection(context),

        const SizedBox(height: 20),
        AnalysisSectionCard(
          title: 'Preparação para entrevista',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BulletColumn(title: 'Destaques para reforçar', items: analysis.resumeHighlights),
              const SizedBox(height: 16),
              BulletColumn(title: 'Ajustes recomendados', items: analysis.rewriteRecommendations),
              const SizedBox(height: 16),
              BulletColumn(title: 'Perguntas prováveis', items: analysis.interviewQuestions),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAtsDetails(BuildContext context, AtsResult ats) {
    final theme = Theme.of(context);

    // contact field labels
    const contactLabels = {
      'email': 'E-mail',
      'phone': 'Telefone',
      'linkedin': 'LinkedIn',
      'github': 'GitHub',
      'location': 'Localiza\u00e7\u00e3o',
      'website': 'Site',
    };

    return [
      const SizedBox(height: 16),
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.slate200),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: const Icon(Icons.manage_search_rounded, size: 18, color: AppColors.slate500),
            title: Text(
              'Ver todos os dados extra\u00eddos pelo ATS Engine',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.slate700,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: AppColors.slate500,
            collapsedIconColor: AppColors.slate400,
            children: [
              // ── Se\u00e7\u00f5es ─────────────────────────────────────────────────────
              AtsDetailBlock(
                icon: Icons.view_list_rounded,
                label: 'Se\u00e7\u00f5es do curr\u00edculo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ats.detectedSections.isNotEmpty) ...[
                      AtsChipRow(
                        label: 'Encontradas (${ats.detectedSections.length})',
                        items: ats.detectedSections,
                        found: true,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (ats.missingSections.isNotEmpty)
                      AtsChipRow(
                        label: 'Ausentes (${ats.missingSections.length})',
                        items: ats.missingSections,
                        found: false,
                      ),
                    if (ats.missingSections.isEmpty)
                      AtsInfoLine(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'Todas as se\u00e7\u00f5es esperadas foram detectadas.',
                        color: AppColors.emerald,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Keywords ────────────────────────────────────────────────
              AtsDetailBlock(
                icon: Icons.tag_rounded,
                label: 'Keywords da vaga',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ats.matchedKeywords.isNotEmpty) ...[
                      AtsChipRow(
                        label: 'Presentes no curr\u00edculo (${ats.matchedKeywords.length})',
                        items: ats.matchedKeywords,
                        found: true,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (ats.missingKeywords.isNotEmpty)
                      AtsChipRow(
                        label: 'Ausentes no curr\u00edculo (${ats.missingKeywords.length})',
                        items: ats.missingKeywords,
                        found: false,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Contato ─────────────────────────────────────────────────
              AtsDetailBlock(
                icon: Icons.contact_mail_outlined,
                label: 'Dados de contato detectados',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: contactLabels.entries.map((e) {
                    final found = ats.contactInfo[e.key] == true;
                    return AtsStatusChip(label: e.value, found: found);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // ── M\u00e9tricas de texto ─────────────────────────────────────────
              AtsDetailBlock(
                icon: Icons.bar_chart_rounded,
                label: 'M\u00e9tricas de texto',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    AtsMetricChip(label: 'Palavras', value: '${ats.readability.wordCount}'),
                    AtsMetricChip(label: 'Frases', value: '${ats.readability.sentenceCount}'),
                    AtsMetricChip(label: 'Bullets', value: '${ats.readability.bulletCount}'),
                    AtsMetricChip(label: 'Verbos de a\u00e7\u00e3o', value: '${ats.readability.actionVerbCount}'),
                    AtsMetricChip(label: 'Dados mensur\u00e1veis', value: '${ats.readability.quantifiableCount}'),
                    AtsMetricChip(
                      label: 'M\u00e9dia palavras/frase',
                      value: ats.readability.avgSentenceLength.toStringAsFixed(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildResumeRebuildSection(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isRebuilding) {
      return AnalysisSectionCard(
        title: 'Recriando currículo...',
        subtitle: 'A IA está aplicando as correções de ATS e gerando o PDF.',
        child: Column(
          children: [
            const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              child: LinearProgressIndicator(
                minHeight: 6,
                color: AppColors.primary,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            const ProcessStep(icon: Icons.auto_fix_high_rounded, label: 'Aplicando correções de keywords e seções'),
            const ProcessStep(icon: Icons.description_outlined, label: 'Gerando versão otimizada em PDF'),
          ],
        ),
      );
    }

    if (state.rebuiltResume != null && state.rebuiltResume!.isNotEmpty) {
      return ResumeEditorSection(
        markdown: state.rebuiltResume!,
        pdfBytes: state.rebuiltPdfBytes,
        onRegeneratePdf: controller.regeneratePdf,
        onRebuild: controller.rebuildResume,
        language: state.resumeLanguage,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_fix_high_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Recriar Currículo',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'A IA vai aplicar todas as correções de ATS, inserir keywords ausentes e gerar uma versão otimizada em PDF.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Idioma do currículo:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final entry in [
                ('pt-BR', 'PT-BR'),
                ('en', 'EN'),
                ('es', 'ES'),
              ])
                GestureDetector(
                  onTap: () => controller.setResumeLanguage(entry.$1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: state.resumeLanguage == entry.$1
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.resumeLanguage == entry.$1
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      entry.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: state.resumeLanguage == entry.$1
                            ? const Color(0xFF1E1B4B)
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: state.canRebuild ? controller.rebuildResume : null,
              icon: const Icon(Icons.bolt_rounded, size: 20),
              label: const Text('Gerar Currículo com IA'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E1B4B),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
