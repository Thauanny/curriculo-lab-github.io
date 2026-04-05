import 'ats_service_base.dart';

import 'ats_create_stub.dart'
    if (dart.library.js_interop) 'ats_create_web.dart';

/// Singleton ATS service — delegates to platform-specific implementation.
class AtsService {
  static final AtsService _instance = AtsService._internal();
  late final AtsServiceBase _impl;

  factory AtsService() => _instance;

  AtsService._internal() {
    _impl = createPlatformAtsService();
  }

  Future<String> analyze({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  }) =>
      _impl.analyze(
        resumeText: resumeText,
        jobDescription: jobDescription,
        jobTitle: jobTitle,
      );
}
