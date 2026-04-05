// ═══════════════════════════════════════════════════════════════════════════════
// ATS Engine — Deterministic resume analysis (keyword matching, section
// detection, readability scoring). Runs entirely in the browser.
// ═══════════════════════════════════════════════════════════════════════════════

const _PT_STOPWORDS = new Set([
  'a','à','ao','aos','as','até','com','como','da','das','de','dela','delas',
  'dele','deles','do','dos','e','é','ela','elas','ele','eles','em','entre',
  'era','essa','essas','esse','esses','esta','estas','este','estes','eu','foi',
  'for','foram','ha','isso','isto','já','lhe','lhes','lo','mas','me','meu',
  'meus','minha','minhas','muito','na','nas','nem','no','nos','nós','nossa',
  'nossas','nosso','nossos','não','num','numa','nuns','o','os','ou','para',
  'pela','pelas','pelo','pelos','por','qual','quando','que','quem','se','sem',
  'ser','será','seu','seus','só','são','sua','suas','também','te','tem','têm',
  'ter','teu','teus','tu','tua','tuas','tudo','um','uma','umas','uns','você',
  'vocês','vos',
]);

const _EN_STOPWORDS = new Set([
  'a','an','and','are','as','at','be','but','by','for','from','had','has',
  'have','he','her','his','how','i','if','in','into','is','it','its','just',
  'me','my','no','nor','not','of','on','or','our','out','own','she','so',
  'some','than','that','the','their','them','then','there','these','they',
  'this','to','too','up','us','very','was','we','were','what','when','which',
  'who','will','with','would','you','your',
]);

const _ALL_STOPWORDS = new Set([..._PT_STOPWORDS, ..._EN_STOPWORDS]);

// ── Section patterns (PT + EN) ──────────────────────────────────────────────
const _SECTION_PATTERNS = {
  experience: [
    /experi[eê]ncia/i, /professional\s*experience/i, /work\s*experience/i,
    /hist[oó]rico\s*profissional/i, /atua[cç][aã]o/i,
  ],
  education: [
    /forma[cç][aã]o/i, /educa[cç][aã]o/i, /education/i,
    /acad[eê]mic/i, /gradua[cç]/i,
  ],
  skills: [
    /compet[eê]ncia/i, /habilidade/i, /skills/i, /tecnologia/i,
    /ferramentas/i, /tools/i, /conhecimento/i,
  ],
  summary: [
    /resumo/i, /objetivo/i, /summary/i, /profile/i, /sobre\s*mim/i,
    /apresenta[cç]/i,
  ],
  languages: [
    /idioma/i, /l[ií]ngua/i, /language/i,
  ],
  certifications: [
    /certifica[cç]/i, /certification/i, /curso/i, /course/i,
  ],
  contact: [
    /contato/i, /contact/i, /telefone/i, /phone/i, /e-?mail/i,
  ],
};

const _REQUIRED_SECTIONS = [
  'experience', 'education', 'skills', 'summary', 'contact',
];

// ── Normalisation helpers ───────────────────────────────────────────────────
function _removeAccents(text) {
  return text.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

function _normalize(text) {
  return _removeAccents(text).toLowerCase().replace(/[^a-z0-9\s]/g, ' ');
}

function _tokenize(text) {
  return _normalize(text)
    .split(/\s+/)
    .filter(t => t.length > 2 && !_ALL_STOPWORDS.has(t));
}

function _simpleStem(word) {
  const w = _removeAccents(word).toLowerCase();
  return w
    .replace(/(ção|ções|mente|ador|adores|ável|ível|ismo|ista|ência|ância)$/i, '')
    .replace(/(tion|tions|ment|ness|able|ible|ity|ies|ing|tion|er|ed|ly)$/i, '')
    .replace(/(ando|endo|indo|ando|ados|idas|idos)$/i, '');
}

// ── Keyword extraction (TF-based) ──────────────────────────────────────────
function _extractKeywords(text, topN = 30) {
  const tokens = _tokenize(text);
  const freq = {};
  for (const t of tokens) {
    const stem = _simpleStem(t);
    if (stem.length < 3) continue;
    freq[stem] = (freq[stem] || { stem, original: t, count: 0 });
    freq[stem].count++;
  }

  // Also extract bigrams
  const normalized = _normalize(text);
  const words = normalized.split(/\s+/).filter(w => w.length > 2);
  for (let i = 0; i < words.length - 1; i++) {
    if (_ALL_STOPWORDS.has(words[i]) || _ALL_STOPWORDS.has(words[i + 1])) continue;
    const bigram = words[i] + ' ' + words[i + 1];
    const key = '_bg_' + bigram;
    freq[key] = (freq[key] || { stem: key, original: bigram, count: 0 });
    freq[key].count++;
  }

  return Object.values(freq)
    .filter(e => e.count >= 1)
    .sort((a, b) => b.count - a.count)
    .slice(0, topN)
    .map(e => e.original);
}

// ── Keyword matching ────────────────────────────────────────────────────────
function _matchKeywords(jobKeywords, resumeText) {
  const resumeNorm = _normalize(resumeText);
  const resumeStems = new Set(_tokenize(resumeText).map(_simpleStem));

  const matched = [];
  const missing = [];

  for (const kw of jobKeywords) {
    const kwNorm = _normalize(kw);
    const kwStem = _simpleStem(kwNorm.replace(/\s+/g, ''));

    const directMatch = resumeNorm.includes(kwNorm);
    const stemMatch = kwNorm.split(/\s+/).every(
      part => resumeStems.has(_simpleStem(part))
    );

    if (directMatch || stemMatch) {
      matched.push(kw);
    } else {
      missing.push(kw);
    }
  }

  return { matched, missing };
}

// ── Section detection ───────────────────────────────────────────────────────
function _detectSections(resumeText) {
  const detected = [];
  const missing = [];

  for (const [section, patterns] of Object.entries(_SECTION_PATTERNS)) {
    const found = patterns.some(p => p.test(resumeText));
    if (found) {
      detected.push(section);
    }
  }

  for (const req of _REQUIRED_SECTIONS) {
    if (!detected.includes(req)) {
      missing.push(req);
    }
  }

  return { detected, missing };
}

// ── Contact info detection ──────────────────────────────────────────────────
function _detectContactInfo(resumeText) {
  return {
    email: /[\w.+-]+@[\w-]+\.[\w.]+/.test(resumeText),
    phone: /(\+?\d[\d\s\-().]{7,})/.test(resumeText),
    linkedin: /linkedin\.com/i.test(resumeText),
    github: /github\.com/i.test(resumeText),
    website: /https?:\/\/[^\s]+/i.test(resumeText),
  };
}

// ── Readability metrics ─────────────────────────────────────────────────────
function _analyzeReadability(resumeText) {
  const sentences = resumeText.split(/[.!?]+/).filter(s => s.trim().length > 0);
  const words = resumeText.split(/\s+/).filter(w => w.length > 0);
  const bullets = (resumeText.match(/^[\s]*[-•*]\s/gm) || []).length;

  const avgSentenceLength = sentences.length > 0
    ? words.length / sentences.length
    : 0;

  // Action verbs (PT + EN)
  const actionVerbs = [
    /desenvolv/i, /implement/i, /lider/i, /gerenci/i, /otimiz/i,
    /criei|criou|criando/i, /aumentei|aumentou/i, /reduzi|reduziu/i,
    /managed/i, /developed/i, /created/i, /led/i, /built/i,
    /improved/i, /achieved/i, /delivered/i, /designed/i, /launched/i,
  ];
  const actionVerbCount = actionVerbs.filter(v => v.test(resumeText)).length;

  // Quantifiable achievements (numbers with context)
  const quantifiables = (resumeText.match(/\d+\s*%|\d+\s*(anos|years|projetos|projects|clientes|R\$|\$)/gi) || []).length;

  let score = 50;
  // Bullet points boost readability
  if (bullets >= 5) score += 15;
  else if (bullets >= 2) score += 8;
  // Good sentence length
  if (avgSentenceLength >= 10 && avgSentenceLength <= 25) score += 10;
  // Action verbs
  score += Math.min(actionVerbCount * 3, 15);
  // Quantifiables
  score += Math.min(quantifiables * 5, 10);

  return {
    score: Math.min(score, 100),
    wordCount: words.length,
    sentenceCount: sentences.length,
    bulletCount: bullets,
    avgSentenceLength: Math.round(avgSentenceLength * 10) / 10,
    actionVerbCount,
    quantifiableCount: quantifiables,
  };
}

// ── Scoring ─────────────────────────────────────────────────────────────────
function _calculateScores(matched, missing, sections, readability, contactInfo) {
  const totalKeywords = matched.length + missing.length;
  const keywordScore = totalKeywords > 0
    ? Math.round((matched.length / totalKeywords) * 100)
    : 0;

  const sectionScore = Math.round(
    (sections.detected.length / Math.max(_REQUIRED_SECTIONS.length, 1)) * 100
  );

  const contactCount = Object.values(contactInfo).filter(Boolean).length;
  const contactScore = Math.round((contactCount / 5) * 100);

  const readabilityScore = readability.score;

  // Weighted overall
  const overall = Math.round(
    keywordScore * 0.35 +
    sectionScore * 0.25 +
    readabilityScore * 0.25 +
    contactScore * 0.15
  );

  return { overall, keywordScore, sectionScore, readabilityScore, contactScore };
}

// ── Issue generation ────────────────────────────────────────────────────────
function _generateIssues(missing, missingSections, readability, contactInfo) {
  const issues = [];

  if (missing.length > 3) {
    issues.push(`${missing.length} keywords da vaga não encontradas no currículo.`);
  }
  for (const s of missingSections) {
    const labels = {
      experience: 'Experiência Profissional',
      education: 'Formação Acadêmica',
      skills: 'Competências Técnicas',
      summary: 'Resumo / Objetivo',
      contact: 'Informações de Contato',
    };
    issues.push(`Seção "${labels[s] || s}" não detectada.`);
  }
  if (!contactInfo.email) issues.push('E-mail não detectado no currículo.');
  if (!contactInfo.phone) issues.push('Telefone não detectado no currículo.');
  if (readability.bulletCount < 3) {
    issues.push('Poucas listas com marcadores — dificulta a leitura por ATS.');
  }
  if (readability.quantifiableCount === 0) {
    issues.push('Nenhuma conquista quantificável detectada (números, percentuais).');
  }
  if (readability.actionVerbCount < 3) {
    issues.push('Pouco uso de verbos de ação — enfraquecem o impacto.');
  }

  return issues;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Public API — exposed to Dart via window.atsAnalyze
// ═══════════════════════════════════════════════════════════════════════════════
window.atsAnalyze = function(resumeText, jobDescription, jobTitle) {
  console.log('[ATS Engine] Starting analysis...');

  const fullJob = (jobTitle || '') + ' ' + (jobDescription || '');

  const jobKeywords = _extractKeywords(fullJob, 30);
  const { matched, missing } = _matchKeywords(jobKeywords, resumeText);
  const sections = _detectSections(resumeText);
  const readability = _analyzeReadability(resumeText);
  const contactInfo = _detectContactInfo(resumeText);
  const scores = _calculateScores(
    matched, missing, sections, readability, contactInfo
  );
  const issues = _generateIssues(missing, sections.missing, readability, contactInfo);

  const result = {
    overallScore: scores.overall,
    keywordScore: scores.keywordScore,
    sectionScore: scores.sectionScore,
    readabilityScore: scores.readabilityScore,
    contactScore: scores.contactScore,
    matchedKeywords: matched,
    missingKeywords: missing,
    detectedSections: sections.detected,
    missingSections: sections.missing,
    issues: issues,
    contactInfo: contactInfo,
    readability: readability,
  };

  console.log('[ATS Engine] Done:', JSON.stringify(result).length, 'bytes');
  return JSON.stringify(result);
};

console.log('[ATS Engine] Ready');
