import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:printing/printing.dart';

import '../services/pdf_generator.dart';
import '../theme/app_colors.dart';
import 'pdf_resume_viewer.dart';

class ResumeEditorSection extends StatefulWidget {
  const ResumeEditorSection({
    super.key,
    required this.markdown,
    required this.pdfBytes,
    required this.onRegeneratePdf,
    required this.onRebuild,
    this.language = 'pt-BR',
  });

  final String markdown;
  final Uint8List? pdfBytes;
  final Future<void> Function(String) onRegeneratePdf;
  final VoidCallback onRebuild;
  final String language;

  @override
  State<ResumeEditorSection> createState() => _ResumeEditorSectionState();
}

class _ResumeEditorSectionState extends State<ResumeEditorSection>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _editController;
  late final TabController _tabController;
  bool _hasEdits = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.markdown);
    _tabController = TabController(length: 4, vsync: this);
    _editController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant ResumeEditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdown != widget.markdown && !_hasEdits) {
      _editController.text = widget.markdown;
    }
  }

  @override
  void dispose() {
    _editController.removeListener(_onTextChanged);
    _editController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasEdits = _editController.text != widget.markdown;
    if (hasEdits != _hasEdits) {
      setState(() => _hasEdits = hasEdits);
    }
  }

  Future<void> _downloadPdf() async {
    final text = _editController.text;
    if (_hasEdits || widget.pdfBytes == null) {
      await widget.onRegeneratePdf(text);
    }
    final freshBytes = await PdfGenerator.fromMarkdown(text, language: widget.language);
    await Printing.sharePdf(
      bytes: freshBytes,
      filename: 'curriculo_otimizado.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── AI Disclaimer ─────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Este currículo foi gerado por IA e pode conter imprecisões. '
                  'Revise todo o conteúdo antes de utilizá-lo. '
                  'Verifique datas, cargos e informações de contato.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF92400E),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Editor Card ───────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            children: [
              // Tab bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.slate200)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.slate400,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                  tabs: const [
                    Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Editar'),
                    Tab(icon: Icon(Icons.visibility_rounded, size: 18), text: 'Pré-visualizar'),
                    Tab(icon: Icon(Icons.picture_as_pdf_rounded, size: 18), text: 'PDF'),
                    Tab(icon: Icon(Icons.menu_book_outlined, size: 18), text: 'Guia'),
                  ],
                ),
              ),

              // Tab content
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 1: Editor
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _editController,
                        maxLines: null,
                        expands: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Edite o markdown do currículo...',
                          hintStyle: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    // ── Tab 2: Markdown preview
                    ListenableBuilder(
                      listenable: _editController,
                      builder: (context, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Markdown(
                          data: _editController.text,
                          selectable: true,
                          shrinkWrap: false,
                          styleSheet: MarkdownStyleSheet(
                            h1: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate900,
                            ),
                            h2: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate900,
                            ),
                            h3: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate500,
                            ),
                            p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                            listBullet: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Tab 3: PDF preview
                    widget.pdfBytes != null
                        ? PdfResumeViewer(
                            pdfBytes: widget.pdfBytes!,
                            height: 600,
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.picture_as_pdf_rounded, size: 48, color: AppColors.slate400),
                                const SizedBox(height: 12),
                                Text(
                                  'Clique em "Atualizar PDF" para gerar a visualização.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate400),
                                ),
                              ],
                            ),
                          ),

                    // ── Tab 4: Section guide
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _ExplanationCard(
                            icon: Icons.person_outline_rounded,
                            color: AppColors.primary,
                            title: 'Resumo Profissional',
                            description:
                                'A primeira seção lida pelo recrutador. Apresenta quem você é, o que faz e o diferencial que oferece. Um resumo bem escrito aumenta a taxa de leitura completa do currículo.',
                            tip:
                                'Inclua o cargo-alvo, anos de experiência e dois ou três pontos fortes diretamente relacionados à vaga.',
                          ),
                          _ExplanationCard(
                            icon: Icons.code_rounded,
                            color: AppColors.emerald,
                            title: 'Competências Técnicas',
                            description:
                                'Seção de maior impacto para sistemas ATS. É aqui que as keywords da descrição da vaga devem aparecer de forma explícita e organizada.',
                            tip:
                                'Use exatamente os mesmos termos da vaga. Prefira listas claras a blocos de texto corrido.',
                          ),
                          _ExplanationCard(
                            icon: Icons.work_outline_rounded,
                            color: AppColors.primary,
                            title: 'Experiência Profissional',
                            description:
                                'O núcleo do currículo. Cada cargo deve demonstrar como você gerou valor — não apenas listar responsabilidades. Recrutadores dedicam 6–10 s nesta seção.',
                            tip:
                                'Use verbos de ação no passado (desenvolveu, liderou, implementou) e inclua resultados mensuráveis sempre que possível.',
                          ),
                          _ExplanationCard(
                            icon: Icons.school_outlined,
                            color: AppColors.amber,
                            title: 'Formação Acadêmica',
                            description:
                                'Validação formal da sua trajetória. Para vagas sênior, tem peso menor; para júnior e pleno, é frequentemente critério eliminatório.',
                            tip:
                                'Informe o nome completo da instituição, grau e período. Para recém-formados, adicione projetos ou honrarias relevantes.',
                          ),
                          _ExplanationCard(
                            icon: Icons.language_rounded,
                            color: AppColors.emerald,
                            title: 'Idiomas',
                            description:
                                'Critério eliminatório em vagas internacionais ou remotas. Recrutadores frequentemente verificam o nível declarado durante a entrevista.',
                            tip:
                                'Use padrões reconhecidos: A1–C2 (CEFR) ou Básico / Intermediário / Avançado / Fluente. Nunca exagere o nível.',
                          ),
                          _ExplanationCard(
                            icon: Icons.verified_outlined,
                            color: Color(0xFF7C3AED),
                            title: 'Certificações',
                            description:
                                'Diferenciam candidatos com formação semelhante e sinalizam comprometimento com atualização contínua, especialmente em tecnologia.',
                            tip:
                                'Inclua apenas certificações ativas e relevantes para a vaga, com a instituição emissora (ex: AWS, Google, Microsoft).',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Action buttons ────────────────────────────────────────
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: widget.onRebuild,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Recriar com IA'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate500,
                side: const BorderSide(color: AppColors.slate200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 10),
            if (_hasEdits)
              OutlinedButton.icon(
                onPressed: () => widget.onRegeneratePdf(_editController.text),
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: const Text('Atualizar PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _editController.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Markdown copiado!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Copiar markdown',
              icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.slate400),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
              onPressed: _downloadPdf,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Baixar PDF'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Explanation card ──────────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.tip,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Dica: $tip',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
