import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Tudo em um único fluxo',
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Análise inteligente com IA, otimização ATS e reescrita profissional',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final cards = [
              FeatureCard(
                icon: Icons.show_chart_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryLight,
                title: 'Análise de Match',
                description: 'Compatibilidade entre perfil e vaga com scoring detalhado.',
              ),
              FeatureCard(
                icon: Icons.verified_outlined,
                iconColor: AppColors.emerald,
                iconBg: const Color(0xFFECFDF5),
                title: 'Verificação ATS',
                description: 'Leitura estrutural, keywords e conformidade com sistemas.',
              ),
              FeatureCard(
                icon: Icons.auto_fix_high_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF5F3FF),
                title: 'Reescrita Inteligente',
                description: 'Currículo em markdown otimizado e pronto para exportar.',
              ),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  cards.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i > 0 ? 16 : 0),
                      child: cards[i],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(
                cards.length,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < cards.length - 1 ? 14 : 0),
                  child: cards[i],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
