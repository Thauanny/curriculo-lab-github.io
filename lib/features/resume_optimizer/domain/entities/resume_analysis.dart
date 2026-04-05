class ResumeAnalysis {
  const ResumeAnalysis({
    required this.executiveSummary,
    required this.atsOptimizedHeadline,
    required this.candidateProfile,
    required this.atsAssessment,
    required this.jobCompatibility,
    required this.resumeHighlights,
    required this.rewriteRecommendations,
    required this.rewrittenResume,
    required this.interviewQuestions,
  });

  final String executiveSummary;
  final String atsOptimizedHeadline;
  final CandidateProfile candidateProfile;
  final AtsAssessment atsAssessment;
  final JobCompatibility jobCompatibility;
  final List<String> resumeHighlights;
  final List<String> rewriteRecommendations;
  final String rewrittenResume;
  final List<String> interviewQuestions;
}

class CandidateProfile {
  const CandidateProfile({
    required this.fullName,
    required this.professionalTitle,
    required this.yearsOfExperience,
    required this.topSkills,
    required this.keyAchievements,
    required this.education,
    required this.languages,
    required this.certifications,
  });

  final String fullName;
  final String professionalTitle;
  final String yearsOfExperience;
  final List<String> topSkills;
  final List<String> keyAchievements;
  final List<String> education;
  final List<String> languages;
  final List<String> certifications;
}

class AtsAssessment {
  const AtsAssessment({
    required this.overallScore,
    required this.sectionCompletenessScore,
    required this.keywordAlignmentScore,
    required this.readabilityScore,
    required this.issues,
    required this.recommendations,
  });

  final double overallScore;
  final double sectionCompletenessScore;
  final double keywordAlignmentScore;
  final double readabilityScore;
  final List<String> issues;
  final List<String> recommendations;
}

class JobCompatibility {
  const JobCompatibility({
    required this.score,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.strengths,
    required this.risks,
  });

  final double score;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> strengths;
  final List<String> risks;
}