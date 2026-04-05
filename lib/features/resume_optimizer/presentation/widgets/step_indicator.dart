import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StepPill extends StatelessWidget {
  const StepPill({
    super.key,
    required this.number,
    required this.label,
    required this.isComplete,
    required this.isActive,
    this.isLoading = false,
  });

  final int number;
  final String label;
  final bool isComplete;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;

    if (isComplete) {
      bg = AppColors.primary;
      fg = Colors.white;
      border = AppColors.primary;
    } else if (isActive) {
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
      border = const Color(0xFFC7D2FE);
    } else {
      bg = AppColors.slate100;
      fg = AppColors.slate400;
      border = AppColors.slate200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(fg)),
            )
          else if (isComplete)
            Icon(Icons.check_rounded, size: 16, color: fg)
          else
            Text(
              '$number',
              style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class StepDash extends StatelessWidget {
  const StepDash({super.key, required this.isComplete});
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Container(
          height: 2,
          width: 20,
          decoration: BoxDecoration(
            color: isComplete ? AppColors.primary : AppColors.slate200,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
