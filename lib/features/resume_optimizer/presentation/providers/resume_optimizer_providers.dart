import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revisor_curriculo/core/services/ats_service.dart';
import 'package:revisor_curriculo/core/services/resume_document_picker.dart';
import 'package:revisor_curriculo/core/services/webllm_service.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/datasources/ai_analysis_data_source.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/datasources/ats_data_source.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/datasources/resume_builder_data_source.dart';
import 'package:revisor_curriculo/features/resume_optimizer/data/repositories/resume_optimizer_repository_impl.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/usecases/analyze_resume_usecase.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/usecases/rebuild_resume_usecase.dart';
import 'package:revisor_curriculo/features/resume_optimizer/presentation/controllers/resume_optimizer_controller.dart';
import 'package:revisor_curriculo/features/resume_optimizer/presentation/controllers/resume_optimizer_state.dart';

final resumeDocumentPickerProvider = Provider<ResumeDocumentPicker>((ref) {
  return FilePickerResumeDocumentPicker();
});

// ── ATS Service (JS engine) ─────────────────────────────────────────────────
final atsServiceProvider = Provider<AtsService>((ref) => AtsService());

// ── WebLLM Service ──────────────────────────────────────────────────────────
final webllmServiceProvider = Provider<WebLLMService>((ref) => WebLLMService());

final webllmInitProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(webllmServiceProvider);
  await service.initialize();
  return service.isInitialized;
});

final webllmProgressProvider = StreamProvider<String>((ref) {
  final service = ref.read(webllmServiceProvider);
  final controller = StreamController<String>();

  Timer? timer;
  timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
    final progress = service.getLoadingProgress();
    if (progress != null && progress.isNotEmpty) {
      controller.add(progress);
    }
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

// ── Data Sources ────────────────────────────────────────────────────────────
final atsDataSourceProvider = Provider<AtsDataSource>((ref) {
  return AtsDataSource(ref.watch(atsServiceProvider));
});

final aiAnalysisDataSourceProvider = Provider<AiAnalysisDataSource>((ref) {
  return AiAnalysisDataSource(ref.watch(webllmServiceProvider));
});

final resumeBuilderDataSourceProvider = Provider<ResumeBuilderDataSource>((ref) {
  return ResumeBuilderDataSource(ref.watch(webllmServiceProvider));
});

// ── Repository ──────────────────────────────────────────────────────────────
final resumeOptimizerRepositoryProvider = Provider<ResumeOptimizerRepositoryImpl>((ref) {
  return ResumeOptimizerRepositoryImpl(
    atsDataSource: ref.watch(atsDataSourceProvider),
    aiAnalysisDataSource: ref.watch(aiAnalysisDataSourceProvider),
    resumeBuilderDataSource: ref.watch(resumeBuilderDataSourceProvider),
  );
});

// ── Use Cases ───────────────────────────────────────────────────────────────
final analyzeResumeUseCaseProvider = Provider<AnalyzeResumeUseCase>((ref) {
  return AnalyzeResumeUseCase(ref.watch(resumeOptimizerRepositoryProvider));
});

final rebuildResumeUseCaseProvider = Provider<RebuildResumeUseCase>((ref) {
  return RebuildResumeUseCase(ref.watch(resumeOptimizerRepositoryProvider));
});

// ── Controller ──────────────────────────────────────────────────────────────
final resumeOptimizerControllerProvider =
    StateNotifierProvider<ResumeOptimizerController, ResumeOptimizerState>((ref) {
  return ResumeOptimizerController(
    analyzeResumeUseCase: ref.watch(analyzeResumeUseCaseProvider),
    rebuildResumeUseCase: ref.watch(rebuildResumeUseCaseProvider),
    resumeDocumentPicker: ref.watch(resumeDocumentPickerProvider),
  );
});