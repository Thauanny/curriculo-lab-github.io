import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'package:revisor_curriculo/core/services/resume_document_picker.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_review_request.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/usecases/analyze_resume_usecase.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/usecases/rebuild_resume_usecase.dart';
import 'package:revisor_curriculo/features/resume_optimizer/presentation/controllers/resume_optimizer_state.dart';
import 'package:revisor_curriculo/features/resume_optimizer/presentation/services/pdf_generator.dart';

class ResumeOptimizerController extends StateNotifier<ResumeOptimizerState> {
  ResumeOptimizerController({
    required AnalyzeResumeUseCase analyzeResumeUseCase,
    required RebuildResumeUseCase rebuildResumeUseCase,
    required ResumeDocumentPicker resumeDocumentPicker,
  })  : _analyzeResumeUseCase = analyzeResumeUseCase,
        _rebuildResumeUseCase = rebuildResumeUseCase,
        _resumeDocumentPicker = resumeDocumentPicker,
        super(const ResumeOptimizerState());

  final AnalyzeResumeUseCase _analyzeResumeUseCase;
  final RebuildResumeUseCase _rebuildResumeUseCase;
  final ResumeDocumentPicker _resumeDocumentPicker;

  void setJobTitle(String value) {
    state = state.copyWith(jobTitle: value, clearError: true);
  }

  void setCompanyName(String value) {
    state = state.copyWith(companyName: value, clearError: true);
  }

  void setJobDescription(String value) {
    state = state.copyWith(jobDescription: value, clearError: true);
  }

  void setExtraContext(String value) {
    state = state.copyWith(extraContext: value, clearError: true);
  }

  void setPastedResumeText(String value) {
    state = state.copyWith(pastedResumeText: value, clearError: true);
  }

  Future<void> pickResume() async {
    try {
      final selectedFile = await _resumeDocumentPicker.pick();
      if (selectedFile == null) return;

      state = state.copyWith(
        selectedDocument: selectedFile,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: ResumeOptimizerStatus.failure,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ResumeOptimizerStatus.failure,
        errorMessage: 'Nao foi possivel selecionar o curriculo.',
      );
    }
  }

  void clearDocument() {
    state = state.copyWith(clearDocument: true, clearError: true);
  }

  void setResumeLanguage(String language) {
    state = state.copyWith(resumeLanguage: language);
  }

  /// Handles a file dropped onto the page via drag-and-drop.
  Future<void> setDroppedDocument(String fileName, Uint8List bytes) async {
    try {
      final doc = await _resumeDocumentPicker.processDroppedFile(fileName, bytes);
      if (doc == null) return;
      state = state.copyWith(selectedDocument: doc, clearError: true);
    } on AppException catch (error) {
      state = state.copyWith(
        status: ResumeOptimizerStatus.failure,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ResumeOptimizerStatus.failure,
        errorMessage: 'Não foi possível ler o arquivo arrastado.',
      );
    }
  }

  /// Runs ATS engine + AI analysis.
  Future<void> analyze() async {
    state = state.copyWith(
      status: ResumeOptimizerStatus.loading,
      clearError: true,
      clearRebuilt: true,
    );

    try {
      final bundle = await _analyzeResumeUseCase.execute(
        ResumeReviewRequest(
          jobTitle: state.jobTitle.trim(),
          companyName: state.companyName.trim(),
          jobDescription: state.jobDescription.trim(),
          extraContext: state.extraContext.trim(),
          resumeDocument: state.selectedDocument,
          pastedResumeText: state.pastedResumeText.trim(),
        ),
      );

      state = state.copyWith(
        status: ResumeOptimizerStatus.success,
        analysis: bundle.analysis,
        atsResult: bundle.atsResult,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: ResumeOptimizerStatus.failure,
        errorMessage: error.message,
        clearAnalysis: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: ResumeOptimizerStatus.failure,
        errorMessage:
            'Falha inesperada ao analisar o curriculo. Tente novamente.',
        clearAnalysis: true,
      );
    }
  }

  /// Rebuilds the resume via AI, then generates PDF bytes.
  Future<void> rebuildResume() async {
    if (state.analysis == null) return;

    state = state.copyWith(isRebuilding: true, clearError: true);

    try {
      final markdown = await _rebuildResumeUseCase.execute(
        request: ResumeReviewRequest(
          jobTitle: state.jobTitle.trim(),
          companyName: state.companyName.trim(),
          jobDescription: state.jobDescription.trim(),
          extraContext: state.extraContext.trim(),
          resumeDocument: state.selectedDocument,
          pastedResumeText: state.pastedResumeText.trim(),
          language: state.resumeLanguage,
        ),
        atsResult: state.atsResult,
        analysis: state.analysis!,
      );

      final pdfBytes = await PdfGenerator.fromMarkdown(markdown, language: state.resumeLanguage);

      state = state.copyWith(
        isRebuilding: false,
        rebuiltResume: markdown,
        rebuiltPdfBytes: pdfBytes,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        isRebuilding: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isRebuilding: false,
        errorMessage: 'Falha ao recriar o currículo. Tente novamente.',
      );
    }
  }

  /// Regenerate PDF from edited markdown without calling the AI again.
  Future<void> regeneratePdf(String editedMarkdown) async {
    state = state.copyWith(isRebuilding: true);
    try {
      final pdfBytes = await PdfGenerator.fromMarkdown(editedMarkdown, language: state.resumeLanguage);
      state = state.copyWith(
        isRebuilding: false,
        rebuiltResume: editedMarkdown,
        rebuiltPdfBytes: pdfBytes,
      );
    } catch (_) {
      state = state.copyWith(
        isRebuilding: false,
        errorMessage: 'Falha ao gerar o PDF. Tente novamente.',
      );
    }
  }
}