import 'package:revisor_curriculo/core/errors/app_exception.dart';

/// Raw ATS analysis result from the deterministic JS engine.
abstract class AtsServiceBase {
  Future<String> analyze({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  });
}

/// Stub for non-web platforms.
class AtsServiceStub extends AtsServiceBase {
  @override
  Future<String> analyze({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  }) async {
    throw const AppException('ATS engine não disponível neste ambiente.');
  }
}
