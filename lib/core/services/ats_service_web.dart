import 'dart:async';
import 'dart:js_interop';

import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'ats_service_base.dart';

@JS('atsAnalyze')
external JSString? _jsAtsAnalyze(
  JSString resumeText,
  JSString jobDescription,
  JSString jobTitle,
);

@JS('atsAnalyze')
external JSFunction? get _jsAtsAnalyzeFn;

/// Real ATS service calling the JS engine defined in ats_engine.js.
class AtsWebService extends AtsServiceBase {
  @override
  Future<String> analyze({
    required String resumeText,
    required String jobDescription,
    required String jobTitle,
  }) async {
    // Wait for JS bridge (engine loads via <script>)
    for (var i = 0; i < 30; i++) {
      if (_jsAtsAnalyzeFn != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (_jsAtsAnalyzeFn == null) {
      throw const AppException('ATS engine não carregou.');
    }

    final result = _jsAtsAnalyze(
      resumeText.toJS,
      jobDescription.toJS,
      jobTitle.toJS,
    );

    if (result == null) {
      throw const AppException('ATS engine retornou resultado vazio.');
    }

    return result.toDart;
  }
}
