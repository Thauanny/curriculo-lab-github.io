import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class UploadCard extends StatefulWidget {
  const UploadCard({super.key, this.fileName, this.onPick, this.onClear});

  final String? fileName;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  @override
  State<UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<UploadCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = widget.fileName != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primaryLight : AppColors.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : hasFile
                      ? AppColors.emerald.withValues(alpha: 0.4)
                      : AppColors.slate200,
              width: _hovering ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: hasFile ? const Color(0xFFECFDF5) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasFile ? Icons.check_circle_outline_rounded : Icons.cloud_upload_outlined,
                  size: 28,
                  color: hasFile ? AppColors.emerald : AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                hasFile ? widget.fileName! : 'Arraste ou selecione o arquivo',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: hasFile ? AppColors.emerald : AppColors.slate900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Apenas PDF · até 10 MB',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: widget.onPick,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(hasFile ? 'Trocar arquivo' : 'Selecionar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (hasFile)
                    OutlinedButton.icon(
                      onPressed: widget.onClear,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Remover'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate500,
                        side: const BorderSide(color: AppColors.slate200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
