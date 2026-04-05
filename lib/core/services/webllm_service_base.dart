import 'package:revisor_curriculo/core/errors/app_exception.dart';

/// Abstract base for WebLLM service
abstract class WebLLMServiceBase {
  bool get isInitialized;
  bool get isLoading;
  String? get loadingError;

  Future<void> initialize();
  Future<String> generate({
    required String prompt,
    required String systemInstruction,
    int maxTokens = 2048,
    double temperature = 0.7,
    double topP = 0.9,
  });
  Future<void> dispose();
  Map<String, String> getModelInfo();
  String? getLoadingProgress() => null;
}

/// Stub implementation for non-web platforms (tests, etc.)
class WebLLMServiceStub extends WebLLMServiceBase {
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _loadingError;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get loadingError => _loadingError;

  @override
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    _loadingError = null;
    try {
      // Stub: complete immediately for tests (no actual model loading)
      _isInitialized = true;
    } catch (e) {
      _loadingError = e.toString();
      _isLoading = false;
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<String> generate({
    required String prompt,
    required String systemInstruction,
    int maxTokens = 2048,
    double temperature = 0.7,
    double topP = 0.9,
  }) async {
    if (!_isInitialized) {
      throw AppException('Modelo não está pronto. Execute initialize() primeiro.');
    }
    throw AppException('WebLLM não disponível neste ambiente');
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }

  @override
  Map<String, String> getModelInfo() {
    return {
      'modelId': 'modelo-ia-local',
      'name': 'Modelo de IA Local',
      'size': '~2GB',
      'provider': 'MLC LLM',
    };
  }
}
