import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';

class ResumeAnalysisModel extends ResumeAnalysis {
  ResumeAnalysisModel({
    required super.executiveSummary,
    required super.atsOptimizedHeadline,
    required super.candidateProfile,
    required super.atsAssessment,
    required super.jobCompatibility,
    required super.resumeHighlights,
    required super.rewriteRecommendations,
    required super.rewrittenResume,
    required super.interviewQuestions,
  });

  factory ResumeAnalysisModel.fromJson(Map<String, dynamic> json) {
    final candidate = _readMap(json['candidateProfile']);
    final ats = _readMap(json['atsAssessment']);
    final compatibility = _readMap(json['jobCompatibility']);

    return ResumeAnalysisModel(
      executiveSummary: _readString(
        json,
        const ['executiveSummary', 'summary', 'analysisSummary'],
      ),
      atsOptimizedHeadline: _readString(
        json,
        const ['atsOptimizedHeadline', 'headline', 'optimizedHeadline'],
      ),
      candidateProfile: CandidateProfile(
        fullName: _readString(candidate, const ['fullName', 'name']),
        professionalTitle: _readString(
          candidate,
          const ['professionalTitle', 'headline', 'title'],
        ),
        yearsOfExperience: _readString(
          candidate,
          const ['yearsOfExperience', 'experience'],
        ),
        topSkills: _readList(candidate['topSkills']),
        keyAchievements: _readList(candidate['keyAchievements']),
        education: _readList(candidate['education']),
        languages: _readList(candidate['languages']),
        certifications: _readList(candidate['certifications']),
      ),
      atsAssessment: AtsAssessment(
        overallScore: _readScore(ats['overallScore']),
        sectionCompletenessScore: _readScore(ats['sectionCompletenessScore']),
        keywordAlignmentScore: _readScore(ats['keywordAlignmentScore']),
        readabilityScore: _readScore(ats['readabilityScore']),
        issues: _readList(ats['issues']),
        recommendations: _readList(ats['recommendations']),
      ),
      jobCompatibility: JobCompatibility(
        score: _readScore(compatibility['score']),
        matchedKeywords: _readList(compatibility['matchedKeywords']),
        missingKeywords: _readList(compatibility['missingKeywords']),
        strengths: _readList(compatibility['strengths']),
        risks: _readList(compatibility['risks']),
      ),
      resumeHighlights: _readList(json['resumeHighlights']),
      rewriteRecommendations: _readList(json['rewriteRecommendations']),
      rewrittenResume: _readString(
        json,
        const ['rewrittenResume', 'rewrittenResumeMarkdown', 'optimizedResume'],
      ),
      interviewQuestions: _readList(json['interviewQuestions']),
    );
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, nestedValue) => MapEntry('$key', nestedValue));
    }

    return <String, dynamic>{};
  }

  static String _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return 'Nao informado';
  }

  static List<String> _readList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(RegExp(r'\n|;|\u2022|-'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    return const <String>[];
  }

  static double _readScore(dynamic value) {
    if (value is num) {
      final parsed = value.toDouble();
      return parsed <= 1 ? parsed * 100 : parsed.clamp(0, 100).toDouble();
    }

    if (value is String) {
      final sanitized = value.replaceAll('%', '').replaceAll(',', '.').trim();
      final parsed = double.tryParse(sanitized);
      if (parsed != null) {
        return parsed <= 1 ? parsed * 100 : parsed.clamp(0, 100);
      }
    }

    return 0;
  }
}