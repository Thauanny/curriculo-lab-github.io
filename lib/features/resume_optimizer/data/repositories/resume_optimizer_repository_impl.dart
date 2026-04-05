import 'package:revisor_curriculo/features/resume_optimizer/data/datasources/ai_analysis_data_source.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/datasources/ats_data_source.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/datasources/resume_builder_data_source.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/repositories/resume_optimizer_repository.dart';

class ResumeOptimizerRepositoryImpl implements ResumeOptimizerRepository {
  const ResumeOptimizerRepositoryImpl({
    AtsDataSource? atsDataSource,
    AiAnalysisDataSource? aiAnalysisDataSource,
    ResumeBuilderDataSource? resumeBuilderDataSource,
  })  : _atsDataSource = atsDataSource,
        _aiAnalysisDataSource = aiAnalysisDataSource,
        _resumeBuilderDataSource = resumeBuilderDataSource;

  final AtsDataSource? _atsDataSource;
  final AiAnalysisDataSource? _aiAnalysisDataSource;
  final ResumeBuilderDataSource? _resumeBuilderDataSource;

  @override
  Future<AtsResult> runAtsAnalysis({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  }) {
    if (_atsDataSource == null) {
      throw UnsupportedError('ATS engine não disponível');
    }
    return _atsDataSource.analyze(
      resumeText: resumeText,
      jobDescription: jobDescription,
      jobTitle: jobTitle,
    );
  }

  @override
  Future<ResumeAnalysis> analyzeResume(
    ResumeReviewRequest request, {
    AtsResult? atsResult,
  }) {
    if (_aiAnalysisDataSource == null) {
      throw UnsupportedError('Motor de IA local não disponível');
    }
    return _aiAnalysisDataSource.analyze(request, atsResult);
  }

  @override
  Future<String> rebuildResume({
    required ResumeReviewRequest request,
    required AtsResult? atsResult,
    required ResumeAnalysis analysis,
  }) {
    if (_resumeBuilderDataSource == null) {
      throw UnsupportedError('Resume builder não disponível');
    }
    return _resumeBuilderDataSource.rebuild(
      request: request,
      atsResult: atsResult,
      analysis: analysis,
    );
  }
}