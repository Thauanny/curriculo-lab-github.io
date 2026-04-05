import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/step_card.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Como funciona',
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Três passos para transformar seu currículo',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final steps = [
              StepCard(number: '01', title: 'Descreva a vaga', description: 'Cole a descrição, requisitos, stack e contexto da posição.'),
              StepCard(number: '02', title: 'Envie o currículo', description: 'Upload de PDF, TXT ou Markdown para análise completa.'),
              StepCard(number: '03', title: 'Receba o diagnóstico', description: 'Match, diagnóstico ATS e versão reescrita em segundos.'),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  steps.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 16 : 0),
                      child: steps[i],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(
                steps.length,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 14 : 0),
                  child: steps[i],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        const _SecurityBadgeRow(),
      ],
    );
  }
}

class _SecurityBadgeRow extends StatelessWidget {
  const _SecurityBadgeRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const badges = [
      (Icons.lock_outline_rounded, '100% Gratuito'),
      (Icons.shield_outlined, 'Nenhum dado sai do navegador'),
      (Icons.memory_rounded, 'IA roda localmente'),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: badges
          .map(
            (b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(b.$1, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    b.$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
