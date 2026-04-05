import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'O que você recebe',
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Tudo que você precisa para passar nas triagens e impressionar recrutadores',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            if (wide) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: _ScoreCard()),
                      SizedBox(width: 16),
                      Expanded(child: _KeywordsCard()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: _ResumeCard()),
                      SizedBox(width: 16),
                      Expanded(child: _InterviewCard()),
                    ],
                  ),
                ],
              );
            }
            return const Column(
              children: [
                _ScoreCard(),
                SizedBox(height: 16),
                _KeywordsCard(),
                SizedBox(height: 16),
                _ResumeCard(),
                SizedBox(height: 16),
                _InterviewCard(),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Card base ─────────────────────────────────────────────────────────────────

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ── Card 1: Score de compatibilidade ─────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ShowcaseCard(
      icon: Icons.analytics_outlined,
      iconColor: AppColors.primary,
      iconBg: AppColors.primaryLight,
      title: 'Score de Compatibilidade',
      description: 'Veja o quanto você se encaixa na vaga',
      child: Row(
        children: [
          _CircleScore(value: 78, color: AppColors.primary, label: 'Match'),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreBar(
                  label: 'ATS',
                  value: 0.85,
                  color: AppColors.emerald,
                  theme: theme,
                ),
                const SizedBox(height: 10),
                _ScoreBar(
                  label: 'Keywords',
                  value: 0.72,
                  color: AppColors.amber,
                  theme: theme,
                ),
                const SizedBox(height: 10),
                _ScoreBar(
                  label: 'Formato',
                  value: 0.90,
                  color: AppColors.primary,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleScore extends StatelessWidget {
  const _CircleScore({
    required this.value,
    required this.color,
    required this.label,
  });
  final int value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 6,
              backgroundColor: AppColors.slate100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: AppColors.slate400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });
  final String label;
  final double value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style:
                  theme.textTheme.labelSmall?.copyWith(color: AppColors.slate500),
            ),
            Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.slate700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppColors.slate100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Card 2: Palavras-chave ────────────────────────────────────────────────────

class _KeywordsCard extends StatelessWidget {
  const _KeywordsCard();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      icon: Icons.key_rounded,
      iconColor: AppColors.emerald,
      iconBg: const Color(0xFFECFDF5),
      title: 'Mapeamento de Palavras-chave',
      description: 'Identifique o que está faltando no seu CV',
      child: Column(
        children: const [
          _KeywordRow(text: 'Liderança de equipes', found: true),
          _KeywordRow(text: 'Gestão de projetos ágeis', found: true),
          _KeywordRow(text: 'Análise de dados', found: true),
          _KeywordRow(text: 'Power BI / Tableau', found: false),
          _KeywordRow(text: 'Inglês avançado', found: false),
        ],
      ),
    );
  }
}

class _KeywordRow extends StatelessWidget {
  const _KeywordRow({required this.text, required this.found});
  final String text;
  final bool found;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            found ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: found ? AppColors.emerald : AppColors.slate300,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: found ? AppColors.slate700 : AppColors.slate400,
              fontWeight: found ? FontWeight.w500 : FontWeight.w400,
              decoration:
                  found ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 3: Currículo reescrito ───────────────────────────────────────────────

class _ResumeCard extends StatelessWidget {
  const _ResumeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ShowcaseCard(
      icon: Icons.auto_fix_high_rounded,
      iconColor: const Color(0xFF7C3AED),
      iconBg: const Color(0xFFF5F3FF),
      title: 'Currículo Reescrito pela IA',
      description: 'Versão otimizada exportável em PDF',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Gerado por IA · Privado',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _MockLine(width: 0.8, height: 10, color: AppColors.slate200),
            const SizedBox(height: 6),
            _MockLine(width: 1.0, height: 6, color: AppColors.slate100),
            const SizedBox(height: 4),
            _MockLine(width: 0.9, height: 6, color: AppColors.slate100),
            const SizedBox(height: 4),
            _MockLine(width: 0.6, height: 6, color: AppColors.slate100),
            const SizedBox(height: 10),
            _MockLine(width: 0.5, height: 8, color: AppColors.slate200),
            const SizedBox(height: 6),
            _MockLine(width: 1.0, height: 6, color: AppColors.slate100),
            const SizedBox(height: 4),
            _MockLine(width: 0.85, height: 6, color: AppColors.slate100),
          ],
        ),
      ),
    );
  }
}

class _MockLine extends StatelessWidget {
  const _MockLine({
    required this.width,
    required this.height,
    required this.color,
  });
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

// ── Card 4: Perguntas de entrevista ───────────────────────────────────────────

class _InterviewCard extends StatelessWidget {
  const _InterviewCard();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      icon: Icons.forum_outlined,
      iconColor: AppColors.amber,
      iconBg: const Color(0xFFFFFBEB),
      title: 'Perguntas de Entrevista',
      description: 'Preparação personalizada para a vaga',
      child: Column(
        children: const [
          _QuestionRow(
            text:
                'Como você liderou times multifuncionais em projetos com prazos apertados?',
          ),
          _QuestionRow(
            text:
                'Descreva uma situação em que usou dados para tomar uma decisão estratégica.',
          ),
          _QuestionRow(
            text:
                'Quais metodologias ágeis você domina e em quais contextos as aplicaria?',
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.slate600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
