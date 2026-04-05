// This file is only compiled for web platform
// It provides the actual JavaScript interop for WebLLM

import 'package:js/js.dart';

/// Interop for JavaScript WebLLM functions defined in index.html
@JS('window.createWebLLMEngine')
external Future<dynamic> jsCreateWebLLMEngine(String modelId);

@JS('window.llmGenerate')
external Future<String> jsLlmGenerate(
  dynamic engine,
  String prompt,
  int maxTokens,
  double temperature,
  double topP,
);

@JS('window.disposeEngine')
external Future<void> jsDisposeEngine(dynamic engine);

/// Wrapper for web platform WebLLM operations
class WebLLMJSInterop {
  static Future<dynamic> createEngine(String modelId) =>
      jsCreateWebLLMEngine(modelId);

  static Future<String> generate(
    dynamic engine,
    String prompt,
    int maxTokens,
    double temperature,
    double topP,
  ) =>
      jsLlmGenerate(engine, prompt, maxTokens, temperature, topP);

  static Future<void> disposeEngine(dynamic engine) => jsDisposeEngine(engine);
}
