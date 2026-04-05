import 'dart:convert';
import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'package:revisor_curriculo/core/services/webllm_service.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/models/resume_analysis_model.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';

/// WebLLM-based datasource for resume analysis using a local AI model
class WebLLMResumeDataSource {
  final WebLLMService _webllmService;

  const WebLLMResumeDataSource(this._webllmService);

  static const String _systemInstruction = '''Você é um especialista sênior em recrutamento, análise de currículos e otimização de ATS (Applicant Tracking System).

Sua especialização:
- Conhecimento profundo de sistemas ATS: como funcionam, suas limitações e como otimizar documentos para aprovação
- Expertise em análise de compatibilidade entre perfil do candidato e requisitos da vaga
- Ability to rewrite resumes with focus on keywords, clarity, impact and ATS compliance
- Portuguese language expertise for resume writing

Requisitos críticos para sua resposta:
1. SEMPRE responda em JSON válido, sem markdown ou tipografia adicional
2. Forneça análise detalhada com scores, keywords, lacunas e recomendações
3. Use scores de 0 a 100 para todas as métricas
4. Seja objetivo, profissional e baseado em dados
5. Forneça recomendações actionable e específicas

Retorne a resposta em JSON puro, sem wrapper ou comentários.''';

  Future<ResumeAnalysisModel> analyzeResume(ResumeReviewRequest request) async {
    if (!_webllmService.isInitialized) {
      throw AppException(
        'Modelo de IA não está carregado. Aguarde o carregamento do modelo.',
      );
    }

    try {
      final pastedText = request.pastedResumeText;
      final resumeContent = (pastedText?.isNotEmpty ?? false)
          ? pastedText!
          : 'Arquivo enviado: ${request.resumeDocument?.fileName ?? "desconhecido"}';

      final prompt = _buildPrompt(
        request.jobTitle,
        request.companyName,
        request.jobDescription,
        request.extraContext ?? '',
        resumeContent,
      );

      final response = await _webllmService.generate(
        systemInstruction: _systemInstruction,
        prompt: prompt,
        maxTokens: 4096,
        temperature: 0.3, // Mais baixo para respostas consistentes
        topP: 0.9,
      );

      // Parse JSON response
      final jsonResponse = _extractJSON(response);
      final analysisData = jsonDecode(jsonResponse) as Map<String, dynamic>;

      return ResumeAnalysisModel.fromJson(analysisData);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Erro ao analisar currículo: $e');
    }
  }

  String _buildPrompt(
    String jobTitle,
    String companyName,
    String jobDescription,
    String extraContext,
    String resumeContent,
  ) {
    return '''Analise o currículo do candidato em relação à vaga e forneça um diagnóstico completo.

VAGA ALVO:
Posição: $jobTitle
Empresa: $companyName

Descrição da Vaga:
$jobDescription

${extraContext.isNotEmpty ? 'Contexto Adicional:\n$extraContext\n' : ''}

CURRÍCULO DO CANDIDATO:
$resumeContent

IMPORTANTE: Retorne exatamente este JSON (sem alterações na estrutura):
{
  "executiveSummary": "Resumo executivo da análise em 2-3 frases",
  "atsOptimizedHeadline": "Headline otimizada para ATS (40-50 caracteres)",
  "candidateProfile": {
    "fullName": "Nome completo extraído",
    "professionalTitle": "Título profissional mais recente",
    "yearsOfExperience": "X anos",
    "topSkills": ["skill1", "skill2", "skill3", "skill4", "skill5"],
    "keyAchievements": ["Achievement 1", "Achievement 2"],
    "education": ["Formação 1", "Formação 2"],
    "languages": ["Idioma 1", "Idioma 2"],
    "certifications": ["Certificação 1"]
  },
  "atsAssessment": {
    "overallScore": 75,
    "sectionCompletenessScore": 80,
    "readabilityScore": 85,
    "keywordAlignmentScore": 70,
    "issues": ["Risco 1", "Risco 2"],
    "recommendations": ["Recomendação 1", "Recomendação 2"]
  },
  "jobCompatibility": {
    "score": 78,
    "matchedKeywords": ["keyword1", "keyword2"],
    "missingKeywords": ["keyword3", "keyword4"],
    "strengths": ["Força 1", "Força 2"],
    "risks": ["Gap 1", "Gap 2"]
  },
  "resumeHighlights": ["Destaque 1", "Destaque 2"],
  "rewriteRecommendations": ["Mudança 1", "Mudança 2"],
  "rewrittenResume": "# NOME DO CANDIDATO\\n\\n[Versão reescrita do currículo em markdown com keywords otimizadas]",
  "interviewQuestions": ["Pergunta 1", "Pergunta 2", "Pergunta 3"]
}''';
  }

  String _extractJSON(String response) {
    // Try to extract JSON block from response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (jsonMatch != null) {
      return jsonMatch.group(0) ?? response;
    }
    return response;
  }
}
