import 'dart:convert';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';

class AtsResultModel extends AtsResult {
  AtsResultModel({
    required super.overallScore,
    required super.keywordScore,
    required super.sectionScore,
    required super.readabilityScore,
    required super.contactScore,
    required super.matchedKeywords,
    required super.missingKeywords,
    required super.detectedSections,
    required super.missingSections,
    required super.issues,
    required super.contactInfo,
    required super.readability,
  });

  factory AtsResultModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return AtsResultModel.fromJson(json);
  }

  factory AtsResultModel.fromJson(Map<String, dynamic> json) {
    final readabilityMap = json['readability'] as Map<String, dynamic>? ?? {};
    final contactMap = json['contactInfo'] as Map<String, dynamic>? ?? {};

    return AtsResultModel(
      overallScore: _toDouble(json['overallScore']),
      keywordScore: _toDouble(json['keywordScore']),
      sectionScore: _toDouble(json['sectionScore']),
      readabilityScore: _toDouble(json['readabilityScore']),
      contactScore: _toDouble(json['contactScore']),
      matchedKeywords: _toList(json['matchedKeywords']),
      missingKeywords: _toList(json['missingKeywords']),
      detectedSections: _toList(json['detectedSections']),
      missingSections: _toList(json['missingSections']),
      issues: _toList(json['issues']),
      contactInfo: contactMap.map((k, v) => MapEntry(k, v == true)),
      readability: ReadabilityMetrics(
        wordCount: _toInt(readabilityMap['wordCount']),
        sentenceCount: _toInt(readabilityMap['sentenceCount']),
        bulletCount: _toInt(readabilityMap['bulletCount']),
        avgSentenceLength: _toDouble(readabilityMap['avgSentenceLength']),
        actionVerbCount: _toInt(readabilityMap['actionVerbCount']),
        quantifiableCount: _toInt(readabilityMap['quantifiableCount']),
      ),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static List<String> _toList(dynamic v) {
    if (v is List) return v.map((e) => '$e').toList(growable: false);
    return const [];
  }
}
