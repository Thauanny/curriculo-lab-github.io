import 'package:flutter/foundation.dart';
import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/analysis_bundle.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/repositories/resume_optimizer_repository.dart';

class AnalyzeResumeUseCase {
  const AnalyzeResumeUseCase(this._repository);

  final ResumeOptimizerRepository _repository;

  /// Runs ATS engine first (deterministic), then AI analysis enriched with
  /// those results. Returns both in an [AnalysisBundle].
  Future<AnalysisBundle> execute(ResumeReviewRequest request) async {
    if (request.jobDescription.trim().isEmpty) {
      throw const AppException(
        'Descreva a vaga para calcular compatibilidade e aderência ATS.',
      );
    }

    if ((request.pastedResumeText ?? '').trim().isEmpty &&
        request.resumeDocument == null) {
      throw const AppException(
        'Anexe um curriculo ou cole o texto do curriculo.',
      );
    }

    final resumeText = request.pastedResumeText?.trim() ?? '';

    // Step 1: Deterministic ATS analysis (fast, runs in JS)
    var atsResult = await (() async {
      try {
        if (resumeText.isNotEmpty) {
          return await _repository.runAtsAnalysis(
            resumeText: resumeText,
            jobDescription: request.jobDescription,
            jobTitle: request.jobTitle,
          );
        }
      } catch (e) {
        debugPrint('[AnalyzeResumeUseCase] ATS engine error: $e');
      }
      return null;
    })();

    // Step 2: AI analysis enriched with ATS results
    final analysis = await _repository.analyzeResume(
      request,
      atsResult: atsResult,
    );

    return AnalysisBundle(atsResult: atsResult, analysis: analysis);
  }
}