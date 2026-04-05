/// Raw result from the deterministic ATS engine (JS).
class AtsResult {
  const AtsResult({
    required this.overallScore,
    required this.keywordScore,
    required this.sectionScore,
    required this.readabilityScore,
    required this.contactScore,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.detectedSections,
    required this.missingSections,
    required this.issues,
    required this.contactInfo,
    required this.readability,
  });

  final double overallScore;
  final double keywordScore;
  final double sectionScore;
  final double readabilityScore;
  final double contactScore;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> detectedSections;
  final List<String> missingSections;
  final List<String> issues;
  final Map<String, bool> contactInfo;
  final ReadabilityMetrics readability;
}

class ReadabilityMetrics {
  const ReadabilityMetrics({
    required this.wordCount,
    required this.sentenceCount,
    required this.bulletCount,
    required this.avgSentenceLength,
    required this.actionVerbCount,
    required this.quantifiableCount,
  });

  final int wordCount;
  final int sentenceCount;
  final int bulletCount;
  final double avgSentenceLength;
  final int actionVerbCount;
  final int quantifiableCount;
}
