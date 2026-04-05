import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'package:revisor_curriculo/core/services/webllm_service.dart';
import 'package:revisor_curriculo/features/resume_optimizer/config/ai_prompts.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/models/resume_analysis_model.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';

/// AI analysis data source — sends resume + job + ATS engine results to the local AI model
/// so the LLM can validate and enrich the deterministic ATS findings.
class AiAnalysisDataSource {
  const AiAnalysisDataSource(this._webllmService);

  final WebLLMService _webllmService;

  Future<ResumeAnalysisModel> analyze(
    ResumeReviewRequest request,
    AtsResult? atsResult,
  ) async {
    if (!_webllmService.isInitialized) {
      throw const AppException(
        'Modelo de IA não está carregado. Aguarde o carregamento do modelo.',
      );
    }

    final resumeContent = _extractResumeText(request);

    final prompt = _buildPrompt(
      jobTitle: request.jobTitle,
      companyName: request.companyName,
      jobDescription: request.jobDescription,
      extraContext: request.extraContext,
      resumeContent: resumeContent,
      atsResult: atsResult,
    );

    final response = await _webllmService.generate(
      systemInstruction: AiPrompts.analysisSystemInstruction,
      prompt: prompt,
      maxTokens: 4096,
      temperature: 0.3,
      topP: 0.9,
    );

    try {
      final jsonString = _extractJSON(response);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Merge ATS engine scores into the AI response for reliable scoring
      if (atsResult != null) {
        _mergeAtsScores(data, atsResult);
      }

      return ResumeAnalysisModel.fromJson(data);
    } catch (error, stackTrace) {
      debugPrint('[AiAnalysisDataSource] JSON parsing/model creation error: $error\n$stackTrace');
      debugPrint('[AiAnalysisDataSource] Raw response from WebLLM: ${response.substring(0, response.length > 500 ? 500 : response.length)}...');
      throw AppException(
        'Erro ao processar resposta da IA: $error. Tente novamente.',
      );
    }
  }

  String _extractResumeText(ResumeReviewRequest request) {
    final pasted = request.pastedResumeText;
    if (pasted != null && pasted.trim().isNotEmpty) return pasted;
    return 'Arquivo: ${request.resumeDocument?.fileName ?? "desconhecido"}';
  }

  String _buildPrompt({
    required String jobTitle,
    required String companyName,
    required String jobDescription,
    required String extraContext,
    required String resumeContent,
    AtsResult? atsResult,
  }) {
    return AiPrompts.buildAnalysisPrompt(
      jobTitle: jobTitle,
      companyName: companyName,
      jobDescription: jobDescription,
      extraContext: extraContext,
      resumeContent: resumeContent,
      atsResult: atsResult,
    );
  }

  /// Override AI-generated ATS scores with the reliable algorithmic ones.
  void _mergeAtsScores(Map<String, dynamic> data, AtsResult ats) {
    final assessment = data['atsAssessment'];
    if (assessment is Map<String, dynamic>) {
      assessment['overallScore'] = ats.overallScore;
      assessment['keywordAlignmentScore'] = ats.keywordScore;
      assessment['sectionCompletenessScore'] = ats.sectionScore;
      assessment['readabilityScore'] = ats.readabilityScore;
      assessment['issues'] = ats.issues;
    }

    final compatibility = data['jobCompatibility'];
    if (compatibility is Map<String, dynamic>) {
      compatibility['matchedKeywords'] = ats.matchedKeywords;
      compatibility['missingKeywords'] = ats.missingKeywords;
    }
  }

  String _extractJSON(String response) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    return match?.group(0) ?? response;
  }
}
