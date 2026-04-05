import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/resume_optimizer_state.dart';
import '../providers/resume_optimizer_providers.dart';
import '../sections/analyzer_section.dart';
import '../sections/features_section.dart';
import '../sections/how_it_works_section.dart';
import '../sections/requirements_section.dart';
import '../sections/showcase_section.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_banner.dart';

// ── JS interop for drag-and-drop file bridge ──────────────────────────────────
extension type _JsDropResult(JSObject _) implements JSObject {
  external String get name;
  external JSUint8Array get bytes;
}

@JS('consumeDroppedFile')
external JSObject? _jsConsumeDroppedFile();

@JS('_onFileDrop')
external set _jsOnFileDrop(JSFunction? fn);
// ─────────────────────────────────────────────────────────────────────────────

class ResumeOptimizerPage extends ConsumerStatefulWidget {
  const ResumeOptimizerPage({super.key});

  @override
  ConsumerState<ResumeOptimizerPage> createState() => _ResumeOptimizerPageState();
}

class _ResumeOptimizerPageState extends ConsumerState<ResumeOptimizerPage> {
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _jobDescriptionController;
  late final TextEditingController _extraContextController;
  late final TextEditingController _resumeTextController;
  late final ScrollController _scrollController;
  final _analyzerKey = GlobalKey();
  final _requirementsKey = GlobalKey();
  ProviderSubscription<ResumeOptimizerState>? _subscription;
  JSFunction? _jsDropCallback;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final initialState = ref.read(resumeOptimizerControllerProvider);
    _jobTitleController = TextEditingController(text: initialState.jobTitle);
    _companyController = TextEditingController(text: initialState.companyName);
    _jobDescriptionController = TextEditingController(text: initialState.jobDescription);
    _extraContextController = TextEditingController(text: initialState.extraContext);
    _resumeTextController = TextEditingController(text: initialState.pastedResumeText);

    _subscription = ref.listenManual<ResumeOptimizerState>(
      resumeOptimizerControllerProvider,
      (_, next) {
        _syncController(_jobTitleController, next.jobTitle);
        _syncController(_companyController, next.companyName);
        _syncController(_jobDescriptionController, next.jobDescription);
        _syncController(_extraContextController, next.extraContext);
        _syncController(_resumeTextController, next.pastedResumeText);
      },
    );

    // Monitor for dropped files (web only)
    _monitorDroppedFiles();
  }

  @override
  void dispose() {
    _subscription?.close();
    _jsOnFileDrop = null;
    _jsDropCallback = null;
    _scrollController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _jobDescriptionController.dispose();
    _extraContextController.dispose();
    _resumeTextController.dispose();
    super.dispose();
  }

  void _scrollToAnalyzer() {
    final ctx = _analyzerKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic);
    }
  }

  void _scrollToRequirements() {
    final ctx = _requirementsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic);
    }
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              'Currículo Lab',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Quem fez isso?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sou Thauanny Ramos Pereira, estudante de mestrado em Engenharia de Software com foco em IA na UFRN. '
                'Criei o Currículo Lab como um projeto pessoal — uma forma de explorar IA generativa '
                'aplicada a algo prático e útil enquanto me desenvolvo na área.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Por que é gratuito?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Porque a ideia foi criar algo que eu mesma gostaria de usar. '
                'A IA roda 100% no seu navegador — sem servidores, sem custos de API, sem monetização. '
                'É software feito com cuidado, de pessoa para pessoa.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _monitorDroppedFiles() {
    _jsDropCallback = _handleJsFileDrop.toJS;
    _jsOnFileDrop = _jsDropCallback;
  }

  void _handleJsFileDrop() {
    if (!mounted) return;
    try {
      final jsObj = _jsConsumeDroppedFile();
      if (jsObj == null) return;
      final result = _JsDropResult(jsObj);
      final bytes = result.bytes.toDart;
      final controller = ref.read(resumeOptimizerControllerProvider.notifier);
      controller.setDroppedDocument(result.name, bytes);
    } catch (_) {
      // Silently ignore — user will see nothing happened and can try the button
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeOptimizerControllerProvider);
    final controller = ref.read(resumeOptimizerControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: AppColors.slate50,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Nav bar ──────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 60,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.slate200),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description_outlined, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Currículo Lab',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate900,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _showAboutDialog(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.slate500,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Quem somos'),
                            ),
                            TextButton(
                              onPressed: _scrollToRequirements,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.slate500,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Requisitos'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: _scrollToAnalyzer,
                              icon: const Icon(Icons.bolt_rounded, size: 18),
                              label: const Text('Analisar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 64),
                        HeroBanner(theme: theme),
                        const SizedBox(height: 80),
                        const FeaturesSection(),
                        const SizedBox(height: 80),
                        const HowItWorksSection(),
                        const SizedBox(height: 80),
                        const ShowcaseSection(),
                        const SizedBox(height: 80),
                        RequirementsSection(key: _requirementsKey),
                        const SizedBox(height: 80),
                        AnalyzerSection(
                          analyzerKey: _analyzerKey,
                          state: state,
                          controller: controller,
                          jobTitleController: _jobTitleController,
                          companyController: _companyController,
                          jobDescriptionController: _jobDescriptionController,
                          extraContextController: _extraContextController,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}
