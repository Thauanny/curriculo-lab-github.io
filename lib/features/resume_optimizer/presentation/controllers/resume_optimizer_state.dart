import 'dart:typed_data';

import 'package:revisor_curriculo/core/services/resume_document_picker.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/ats_result.dart';
import 'package:revisor_curriculo/features/resume_optimizer/domain/entities/resume_analysis.dart';

enum ResumeOptimizerStatus { idle, loading, success, failure }

class ResumeOptimizerState {
  const ResumeOptimizerState({
    this.status = ResumeOptimizerStatus.idle,
    this.jobTitle = '',
    this.companyName = '',
    this.jobDescription = '',
    this.extraContext = '',
    this.pastedResumeText = '',
    this.selectedDocument,
    this.analysis,
    this.atsResult,
    this.rebuiltResume,
    this.rebuiltPdfBytes,
    this.isRebuilding = false,
    this.errorMessage,
    this.resumeLanguage = 'pt-BR',
  });

  final ResumeOptimizerStatus status;
  final String jobTitle;
  final String companyName;
  final String jobDescription;
  final String extraContext;
  final String pastedResumeText;
  final PickedResumeDocument? selectedDocument;
  final ResumeAnalysis? analysis;
  final AtsResult? atsResult;
  final String? rebuiltResume;
  final Uint8List? rebuiltPdfBytes;
  final bool isRebuilding;
  final String? errorMessage;
  final String resumeLanguage;

  bool get isLoading => status == ResumeOptimizerStatus.loading;

  bool get hasResumeInput =>
      selectedDocument != null || pastedResumeText.trim().isNotEmpty;

  bool get canAnalyze =>
      !isLoading && jobDescription.trim().isNotEmpty && hasResumeInput;

  bool get canRebuild =>
      !isRebuilding && analysis != null;

  ResumeOptimizerState copyWith({
    ResumeOptimizerStatus? status,
    String? jobTitle,
    String? companyName,
    String? jobDescription,
    String? extraContext,
    String? pastedResumeText,
    PickedResumeDocument? selectedDocument,
    ResumeAnalysis? analysis,
    AtsResult? atsResult,
    String? rebuiltResume,
    Uint8List? rebuiltPdfBytes,
    bool? isRebuilding,
    String? errorMessage,
    String? resumeLanguage,
    bool clearDocument = false,
    bool clearAnalysis = false,
    bool clearError = false,
    bool clearRebuilt = false,
  }) {
    return ResumeOptimizerState(
      status: status ?? this.status,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      jobDescription: jobDescription ?? this.jobDescription,
      extraContext: extraContext ?? this.extraContext,
      pastedResumeText: pastedResumeText ?? this.pastedResumeText,
      selectedDocument:
          clearDocument ? null : selectedDocument ?? this.selectedDocument,
      analysis: clearAnalysis ? null : analysis ?? this.analysis,
      atsResult: clearAnalysis ? null : atsResult ?? this.atsResult,
      rebuiltResume:
          clearRebuilt ? null : rebuiltResume ?? this.rebuiltResume,
      rebuiltPdfBytes:
          clearRebuilt ? null : rebuiltPdfBytes ?? this.rebuiltPdfBytes,
      isRebuilding: isRebuilding ?? this.isRebuilding,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      resumeLanguage: resumeLanguage ?? this.resumeLanguage,
    );
  }
}