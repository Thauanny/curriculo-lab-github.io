import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isWide ? 6 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '100% gratuito · Sem envio de dados',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Transforme seu currículo\nem uma versão preparada\npara ATS.',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: isWide ? 38 : 30,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Envie o currículo, informe a vaga e receba análise de aderência, diagnóstico ATS e uma nova versão mais forte.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isWide ? 40 : 0, height: isWide ? 0 : 28),
              Expanded(
                flex: isWide ? 4 : 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroInfoRow(icon: Icons.input_rounded, label: 'Entrada', value: 'Vaga + currículo'),
                      SizedBox(height: 16),
                      _HeroInfoRow(icon: Icons.output_rounded, label: 'Saída', value: 'Match · ATS · Reescrita'),
                      SizedBox(height: 16),
                      _HeroInfoRow(icon: Icons.speed_rounded, label: 'Ideal para', value: 'Ajustar antes de aplicar'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroInfoRow extends StatelessWidget {
  const _HeroInfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
