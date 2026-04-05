import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/repositories/resume_optimizer_repository.dart';

class RebuildResumeUseCase {
  const RebuildResumeUseCase(this._repository);

  final ResumeOptimizerRepository _repository;

  Future<String> execute({
    required ResumeReviewRequest request,
    required AtsResult? atsResult,
    required ResumeAnalysis analysis,
  }) {
    return _repository.rebuildResume(
      request: request,
      atsResult: atsResult,
      analysis: analysis,
    );
  }
}
