import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Expandable block with a labelled icon header used inside the ATS details section.
class AtsDetailBlock extends StatelessWidget {
  const AtsDetailBlock({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.slate500),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.slate500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// A labelled row of chips coloured green (found) or red (missing).
class AtsChipRow extends StatelessWidget {
  const AtsChipRow({
    super.key,
    required this.label,
    required this.items,
    required this.found,
  });

  final String label;
  final List<String> items;
  final bool found;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = found ? AppColors.emerald : AppColors.red;
    final bg = found ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final border = found ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.slate400),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    found ? Icons.check_rounded : Icons.close_rounded,
                    size: 11,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item,
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// A pill chip showing presence/absence of a contact field.
class AtsStatusChip extends StatelessWidget {
  const AtsStatusChip({super.key, required this.label, required this.found});

  final String label;
  final bool found;

  @override
  Widget build(BuildContext context) {
    final color = found ? AppColors.emerald : AppColors.slate400;
    final bg = found ? const Color(0xFFECFDF5) : AppColors.slate100;
    final border = found ? const Color(0xFFA7F3D0) : AppColors.slate200;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            found
                ? Icons.check_circle_outline_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small card displaying a numeric ATS text metric (e.g. word count).
class AtsMetricChip extends StatelessWidget {
  const AtsMetricChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.slate400),
          ),
        ],
      ),
    );
  }
}

/// A simple icon + text informational line used inside ATS details.
class AtsInfoLine extends StatelessWidget {
  const AtsInfoLine({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
