import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'package:revisor_curriculo/core/services/webllm_service.dart';
import 'package:revisor_curriculo/features/resume_optimizer/config/ai_prompts.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';

/// Data source for rebuilding the resume via the local AI model.
/// Uses ATS gaps and AI recommendations to guide the rewrite.
class ResumeBuilderDataSource {
  const ResumeBuilderDataSource(this._webllmService);

  final WebLLMService _webllmService;

  Future<String> rebuild({
    required ResumeReviewRequest request,
    required AtsResult? atsResult,
    required ResumeAnalysis analysis,
  }) async {
    if (!_webllmService.isInitialized) {
      throw const AppException(
        'Modelo de IA não está carregado. Aguarde o carregamento.',
      );
    }

    final resumeContent = _extractResumeText(request);
    final prompt = _buildPrompt(
      resumeContent: resumeContent,
      jobTitle: request.jobTitle,
      jobDescription: request.jobDescription,
      atsResult: atsResult,
      analysis: analysis,
      language: request.language,
    );

    final response = await _webllmService.generate(
      systemInstruction: AiPrompts.builderSystemInstruction,
      prompt: prompt,
      maxTokens: 4096,
      temperature: 0.4,
      topP: 0.9,
    );

    return response.trim();
  }

  String _extractResumeText(ResumeReviewRequest request) {
    final pasted = request.pastedResumeText;
    if (pasted != null && pasted.trim().isNotEmpty) return pasted;
    return 'Arquivo: ${request.resumeDocument?.fileName ?? "desconhecido"}';
  }

  String _buildPrompt({
    required String resumeContent,
    required String jobTitle,
    required String jobDescription,
    AtsResult? atsResult,
    required ResumeAnalysis analysis,
    String language = 'pt-BR',
  }) {
    return AiPrompts.buildBuilderPrompt(
      resumeContent: resumeContent,
      jobTitle: jobTitle,
      jobDescription: jobDescription,
      atsResult: atsResult,
      analysis: analysis,
      language: language,
    );
  }
}
