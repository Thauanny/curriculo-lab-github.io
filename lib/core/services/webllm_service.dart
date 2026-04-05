import 'webllm_service_base.dart';

// Conditional import: uses web factory on web, stub on other platforms
import 'webllm_create_stub.dart'
    if (dart.library.js_interop) 'webllm_create_web.dart';

/// Singleton WebLLM service — delegates to platform-specific implementation
class WebLLMService {
  static final WebLLMService _instance = WebLLMService._internal();
  late final WebLLMServiceBase _impl;

  factory WebLLMService() => _instance;

  WebLLMService._internal() {
    _impl = createPlatformWebLLMService();
  }

  bool get isInitialized => _impl.isInitialized;
  bool get isLoading => _impl.isLoading;
  String? get loadingError => _impl.loadingError;

  Future<void> initialize() => _impl.initialize();

  Future<String> generate({
    required String prompt,
    required String systemInstruction,
    int maxTokens = 2048,
    double temperature = 0.7,
    double topP = 0.9,
  }) =>
      _impl.generate(
        prompt: prompt,
        systemInstruction: systemInstruction,
        maxTokens: maxTokens,
        temperature: temperature,
        topP: topP,
      );

  Future<void> dispose() => _impl.dispose();

  Map<String, String> getModelInfo() => _impl.getModelInfo();

  String? getLoadingProgress() => _impl.getLoadingProgress();
}

