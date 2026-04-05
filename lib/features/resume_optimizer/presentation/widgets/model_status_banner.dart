import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ModelStatusBanner extends StatelessWidget {
  const ModelStatusBanner({
    super.key,
    required this.isReady,
    this.errorMessage,
    this.progressText,
    this.progressPercent,
    this.onRetry,
  });

  final bool isReady;
  final String? errorMessage;
  final String? progressText;
  final double? progressPercent;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color borderColor;
    Color accentColor;
    IconData icon;
    String title;
    String subtitle;

    if (isReady) {
      bgColor = const Color(0xFFECFDF5);
      borderColor = const Color(0xFFA7F3D0);
      accentColor = AppColors.emerald;
      icon = Icons.check_circle_rounded;
      title = 'Modelo pronto';
      subtitle = '100% privado — nenhum dado sai do navegador';
    } else if (errorMessage != null) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      accentColor = AppColors.red;
      icon = Icons.error_outline_rounded;
      title = 'Erro ao carregar modelo';
      subtitle = 'Verifique se o navegador suporta WebGPU';
    } else {
      bgColor = AppColors.primaryLight;
      borderColor = const Color(0xFFC7D2FE);
      accentColor = AppColors.primary;
      icon = Icons.downloading_rounded;
      title = 'Carregando modelo de IA...';
      subtitle = progressText ?? 'Primeira carga leva 2-3 min (~2 GB)';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accentColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (errorMessage != null)
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(foregroundColor: accentColor),
                  child: const Text('Tentar novamente'),
                ),
              if (progressPercent != null && !isReady && errorMessage == null)
                Text(
                  '${progressPercent!.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: accentColor,
                    fontSize: 20,
                  ),
                ),
            ],
          ),
          if (progressPercent != null && !isReady && errorMessage == null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressPercent! / 100,
                minHeight: 6,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
