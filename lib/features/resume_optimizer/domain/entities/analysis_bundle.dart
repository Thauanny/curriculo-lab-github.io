import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';

/// Groups the deterministic ATS result and the AI-enriched analysis.
class AnalysisBundle {
  const AnalysisBundle({this.atsResult, required this.analysis});

  final AtsResult? atsResult;
  final ResumeAnalysis analysis;
}
