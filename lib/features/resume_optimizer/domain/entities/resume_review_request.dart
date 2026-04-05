import 'package:revisor_curriculo/core/services/resume_document_picker.dart';

class ResumeReviewRequest {
  const ResumeReviewRequest({
    required this.jobTitle,
    required this.companyName,
    required this.jobDescription,
    required this.extraContext,
    this.resumeDocument,
    this.pastedResumeText,
    this.language = 'pt-BR',
  });

  final String jobTitle;
  final String companyName;
  final String jobDescription;
  final String extraContext;
  final PickedResumeDocument? resumeDocument;
  final String? pastedResumeText;
  /// Target language for the rebuilt resume: 'pt-BR', 'en', or 'es'.
  final String language;
}