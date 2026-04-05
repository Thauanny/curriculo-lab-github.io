import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ── Chip Group ─────────────────────────────────────────────────────────────
class ChipGroup extends StatelessWidget {
  const ChipGroup({super.key, required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('Nenhuma skill identificada.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => Chip(label: Text(item))).toList(growable: false),
    );
  }
}

// ── Bullet Column ──────────────────────────────────────────────────────────
class BulletColumn extends StatelessWidget {
  const BulletColumn({super.key, required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final visible = items.where((i) => i.trim().isNotEmpty).toList(growable: false);
    if (visible.isEmpty) return Text('$title: sem dados suficientes.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...visible.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Split Lists ────────────────────────────────────────────────────────────
class SplitLists extends StatelessWidget {
  const SplitLists({
    super.key,
    required this.leftTitle,
    required this.leftItems,
    required this.rightTitle,
    required this.rightItems,
  });

  final String leftTitle;
  final List<String> leftItems;
  final String rightTitle;
  final List<String> rightItems;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BulletColumn(title: leftTitle, items: leftItems)),
              const SizedBox(width: 16),
              Expanded(child: BulletColumn(title: rightTitle, items: rightItems)),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BulletColumn(title: leftTitle, items: leftItems),
            const SizedBox(height: 16),
            BulletColumn(title: rightTitle, items: rightItems),
          ],
        );
      },
    );
  }
}

// ── Mini Metric ────────────────────────────────────────────────────────────
class MiniMetric extends StatelessWidget {
  const MiniMetric({super.key, required this.label, required this.score});
  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Text(
        '$label: ${score.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
