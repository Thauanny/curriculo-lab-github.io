import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';

abstract class ResumeOptimizerRepository {
  /// Run the deterministic ATS engine on resume text + job description.
  Future<AtsResult> runAtsAnalysis({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  });

  /// Run AI analysis enriched with ATS results.
  Future<ResumeAnalysis> analyzeResume(
    ResumeReviewRequest request, {
    AtsResult? atsResult,
  });

  /// Rebuild the resume using AI, guided by ATS gaps.
  Future<String> rebuildResume({
    required ResumeReviewRequest request,
    required AtsResult? atsResult,
    required ResumeAnalysis analysis,
  });
}