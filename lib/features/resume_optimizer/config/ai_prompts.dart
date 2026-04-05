import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';

/// Central repository for all AI prompt strings and builders.
/// Keep prompts here so they can be reviewed, tweaked, and versioned in one place
/// without touching the data-access layer.
abstract final class AiPrompts {
  // ── System instructions ───────────────────────────────────────────────────

  static const String analysisSystemInstruction = '''Você é um especialista sênior em recrutamento e análise de currículos.

Você recebe:
1. O currículo do candidato (ou nome do arquivo, se disponível)
2. A descrição da vaga
3. Resultados de uma análise ATS algorítmica (scores, keywords, seções)

Seu papel:
- VALIDAR os scores do ATS algorítmico e fornecer sua avaliação qualitativa
- Identificar nuances que o algoritmo não consegue detectar (tom, clareza, impacto)
- Fornecer análise de compatibilidade entre candidato e vaga
- Dar recomendações específicas e acionáveis
- Gerar perguntas de entrevista situacionais, técnicas e comportamentais baseadas nos requisitos da vaga
- NÃO reescreva o currículo — foque apenas na análise

Requisitos críticos:
1. Responda SOMENTE em JSON válido, sem markdown externo
2. Use scores de 0 a 100
3. Seja objetivo e profissional
4. Considere os dados do ATS algorítmico como referência confiável
5. SEMPRE preencha interviewQuestions com exatamente 5 perguntas relevantes para a vaga — mesmo quando o conteúdo do currículo for limitado, gere as perguntas a partir dos requisitos da descrição da vaga
6. Para yearsOfExperience: some TODOS os períodos de experiência profissional listados no currículo. Se o currículo contiver qualquer cargo, empresa ou período com datas, calcule o tempo total acumulado. Só retorne "0 anos" se o currículo não contiver literalmente nenhuma experiência profissional
7. Para executiveSummary: escreva um diagnóstico executivo rico e detalhado com 4 a 6 frases cobrindo: perfil geral do candidato, pontos fortes mais relevantes, lacunas críticas em relação à vaga, adequação ao nível da posição e recomendação geral''';

  static const String builderSystemInstruction =
      '''Você é um redator profissional de currículos, especialista em otimização para sistemas ATS.

REGRA ABSOLUTA — Fidelidade factual (nunca viole):
- NUNCA invente, crie ou adicione experiências profissionais que não existem no currículo original
- NUNCA invente habilidades, ferramentas ou tecnologias que o candidato não mencionou
- NUNCA crie formações acadêmicas, cursos ou certificações fictícias
- NUNCA adicione números, métricas ou realizações que não estão no original
- APENAS reorganize, reformule com linguagem mais forte e otimize o que já existe
- Se não houver dados para uma seção, simplesmente omita-a em vez de inventar conteúdo

Seu papel (dentro da regra acima):
- Reformular bullets com verbos de ação mais fortes (mantendo a essência do original)
- Inserir keywords ausentes APENAS em contextos em que o candidato já demonstrou aquela habilidade
- Reorganizar e estruturar seções para melhor leitura por sistemas ATS
- Adaptar vocabulário e terminologia para a língua-alvo do currículo

Formato markdown obrigatório — siga EXATAMENTE esta estrutura:

# Nome Completo
**Título Profissional | Especialidade | Área**
*Contato: tel | Email: email | LinkedIn: url | Github: url*
---

## RESUMO PROFISSIONAL
- Frase 1 sobre perfil e experiência
- Frase 2 sobre especialização e diferenciais

## COMPETÊNCIAS TÉCNICAS
Skill1, Skill2, Skill3, Skill4 (uma única linha, vírgula como separador)

## EXPERIÊNCIA PROFISSIONAL

### Empresa - Cliente (ou só Empresa)
**Cidade, Estado (Modalidade)**
*Cargo - Mês Ano - Mês Ano*
- Realização com verbo de ação + contexto + resultado mensurável
- Realização 2

## FORMAÇÃO ACADÊMICA

### Nome da Instituição
**Cidade, Estado**
*Nível - Área de formação*
*Data: Mês Ano - Mês Ano*

## IDIOMAS
- Idioma - Nível

## CERTIFICAÇÕES
- Certificação (omita esta seção se não houver dados)

IMPORTANTE: Nomes das seções devem estar no idioma-alvo do currículo.''';

  // ── Analysis prompt builder ───────────────────────────────────────────────

  static String buildAnalysisPrompt({
    required String jobTitle,
    required String companyName,
    required String jobDescription,
    required String extraContext,
    required String resumeContent,
    AtsResult? atsResult,
  }) {
    final atsBlock = atsResult != null
        ? '''
RESULTADOS DO ATS ALGORÍTMICO (referência confiável):
- Score Geral: ${atsResult.overallScore.toStringAsFixed(0)}
- Keywords: ${atsResult.keywordScore.toStringAsFixed(0)} (${atsResult.matchedKeywords.length} encontradas, ${atsResult.missingKeywords.length} ausentes)
- Seções: ${atsResult.sectionScore.toStringAsFixed(0)} (detectadas: ${atsResult.detectedSections.join(', ')})
- Legibilidade: ${atsResult.readabilityScore.toStringAsFixed(0)}
- Keywords encontradas: ${atsResult.matchedKeywords.join(', ')}
- Keywords ausentes: ${atsResult.missingKeywords.join(', ')}
- Seções faltando: ${atsResult.missingSections.join(', ')}
- Problemas detectados: ${atsResult.issues.join('; ')}
'''
        : '';

    return '''Analise o currículo em relação à vaga e forneça um diagnóstico completo.

VAGA ALVO:
Posição: $jobTitle
Empresa: $companyName
Descrição: $jobDescription
${extraContext.isNotEmpty ? 'Contexto adicional: $extraContext' : ''}

$atsBlock
CURRÍCULO DO CANDIDATO:
$resumeContent

Retorne EXATAMENTE este JSON (sem rewrittenResume — a reescrita será feita separadamente):
{
  "executiveSummary": "Diagnóstico executivo detalhado em 4-6 frases: perfil do candidato, pontos fortes, lacunas em relação à vaga, adequação ao nível da posição e recomendação geral",
  "atsOptimizedHeadline": "Headline otimizada para ATS",
  "candidateProfile": {
    "fullName": "Nome",
    "professionalTitle": "Título",
    "yearsOfExperience": "X anos",
    "topSkills": [],
    "keyAchievements": [],
    "education": [],
    "languages": [],
    "certifications": []
  },
  "atsAssessment": {
    "overallScore": 0,
    "sectionCompletenessScore": 0,
    "readabilityScore": 0,
    "keywordAlignmentScore": 0,
    "issues": [],
    "recommendations": []
  },
  "jobCompatibility": {
    "score": 0,
    "matchedKeywords": [],
    "missingKeywords": [],
    "strengths": [],
    "risks": []
  },
  "resumeHighlights": [],
  "rewriteRecommendations": [],
  "rewrittenResume": "",
  "interviewQuestions": [
    "Pergunta técnica ou situacional específica da vaga",
    "Pergunta sobre experiência relevante exigida na descrição",
    "Pergunta comportamental (método STAR) alinhada aos requisitos",
    "Pergunta sobre competência ou ferramenta chave da vaga",
    "Pergunta sobre motivação ou adequação cultural"
  ]
}

OBRIGATÓRIO: preencha interviewQuestions com exatamente 5 perguntas reais e específicas para a vaga de $jobTitle — baseie-se nos requisitos da descrição da vaga e no perfil identificado.''';
  }

  // ── Builder (resume rewrite) prompt builder ───────────────────────────────

  static String buildBuilderPrompt({
    required String resumeContent,
    required String jobTitle,
    required String jobDescription,
    required AtsResult? atsResult,
    required ResumeAnalysis analysis,
    String language = 'pt-BR',
  }) {
    final missingKeywords =
        atsResult?.missingKeywords ?? analysis.jobCompatibility.missingKeywords;
    final issues = atsResult?.issues ?? analysis.atsAssessment.issues;
    final recommendations = analysis.rewriteRecommendations;
    final missingSections = atsResult?.missingSections ?? [];

    final langInstruction = switch (language) {
      'en' => 'LANGUAGE: Write the ENTIRE resume in English. Use English section names (SUMMARY, SKILLS, PROFESSIONAL EXPERIENCE, EDUCATION, LANGUAGES, CERTIFICATIONS).',
      'es' => 'IDIOMA: Escriba el currículo COMPLETO en español. Use nombres de secciones en español (RESUMEN PROFESIONAL, COMPETENCIAS, EXPERIENCIA PROFESIONAL, FORMACIÓN, IDIOMAS, CERTIFICACIONES).',
      _ => 'IDIOMA: Escreva o currículo COMPLETO em português do Brasil. Use nomes de seções em português (RESUMO PROFISSIONAL, COMPETÊNCIAS TÉCNICAS, EXPERIÊNCIA PROFISSIONAL, FORMAÇÃO ACADÊMICA, IDIOMAS, CERTIFICAÇÕES).',
    };

    return '''Reescreva o currículo abaixo otimizando para ATS e para a vaga alvo.

$langInstruction

CURRÍCULO ORIGINAL (use APENAS estes dados — não invente nada):
$resumeContent

VAGA ALVO: $jobTitle
DESCRIÇÃO DA VAGA:
$jobDescription

OTIMIZAÇÕES A APLICAR (somente onde é factualmente correto):
- Keywords ausentes a inserir naturalmente: ${missingKeywords.join(', ')}
- Problemas detectados: ${issues.join('; ')}
- Seções faltando: ${missingSections.join(', ')}
- Recomendações: ${recommendations.join('; ')}
- Forças do perfil: ${analysis.jobCompatibility.strengths.join(', ')}

REGRA ABSOLUTA: Mantenha 100% de fidelidade aos dados originais. Não invente experiências, habilidades, formação ou números que não estão no currículo original.

Responda APENAS com o currículo reescrito em Markdown seguindo o formato do system instruction.''';
  }
}
