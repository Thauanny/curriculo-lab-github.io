import 'package:revisor_curriculo/core/services/ats_service.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/models/ats_result_model.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';

/// Data source for deterministic ATS analysis via the JS engine.
class AtsDataSource {
  const AtsDataSource(this._atsService);

  final AtsService _atsService;

  Future<AtsResult> analyze({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  }) async {
    final jsonString = await _atsService.analyze(
      resumeText: resumeText,
      jobDescription: jobDescription,
      jobTitle: jobTitle,
    );
    return AtsResultModel.fromJsonString(jsonString);
  }
}
