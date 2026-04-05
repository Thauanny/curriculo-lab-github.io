import 'package:flutter/material.dart';
import 'package:revisor_curriculo/app/theme/app_theme.dart';
import 'package:revisor_curriculo/features/resume_optimizer/presentation/pages/resume_optimizer_page.dart';

class ResumeReviewApp extends StatelessWidget {
  const ResumeReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curriculo Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ResumeOptimizerPage(),
    );
  }
}