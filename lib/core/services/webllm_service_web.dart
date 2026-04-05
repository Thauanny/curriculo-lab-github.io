// Web-specific WebLLM service using dart:js_interop
// Only compiled on web builds (via conditional import)

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:revisor_curriculo/core/errors/app_exception.dart';
import 'webllm_service_base.dart';

// JS interop bindings to window functions defined in index.html
@JS('initWebLLMEngine')
external JSPromise<JSBoolean> _jsInitEngine(JSString modelId);

@JS('chatGenerate')
external JSPromise<JSString> _jsChatGenerate(
  JSString systemPrompt,
  JSString userPrompt,
  JSNumber maxTokens,
  JSNumber temperature,
  JSNumber topP,
);

@JS('disposeWebLLMEngine')
external JSPromise _jsDisposeEngine();

// Check if window.initWebLLMEngine is defined (module may still be loading)
@JS('initWebLLMEngine')
external JSFunction? get _jsInitEngineFn;

// Read the progress string from JS
@JS('_webllmProgress')
external JSString? get _jsWebllmProgress;

// Note: Drag-and-drop file support via JS bridge (_droppedFile) can be added in future

/// Wait for ESM <script type="module"> to finish loading
Future<void> _waitForBridge() async {
  for (var i = 0; i < 50; i++) {
    if (_jsInitEngineFn != null) return;
    await Future.delayed(const Duration(milliseconds: 200));
  }
  throw AppException('WebLLM bridge não carregou. Verifique a conexão com internet.');
}

/// Real WebLLM service that calls JavaScript via dart:js_interop
class WebLLMWebService extends WebLLMServiceBase {
  static const String _modelId = 'Llama-3.2-3B-Instruct-q4f32_1-MLC';

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
      debugPrint('[WebLLM-Dart] 🚀 Inicializando modelo de IA...');

      // Wait for ESM module to load and expose window functions
      await _waitForBridge();
      debugPrint('[WebLLM-Dart] ✅ JS bridge loaded');

      await _jsInitEngine(_modelId.toJS).toDart;

      _isInitialized = true;
      debugPrint('[WebLLM-Dart] ✅ Engine ready');
    } catch (e) {
      _loadingError = e.toString();
      debugPrint('[WebLLM-Dart] ❌ Init failed: $e');
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
      throw AppException('Modelo não está pronto. Aguarde o carregamento.');
    }

    try {
      debugPrint('[WebLLM-Dart] 📝 Generating (prompt: ${prompt.length} chars)');
      final startTime = DateTime.now();

      final jsResult = await _jsChatGenerate(
        systemInstruction.toJS,
        prompt.toJS,
        maxTokens.toJS,
        temperature.toJS,
        topP.toJS,
      ).toDart;

      final result = jsResult.toDart;
      final duration = DateTime.now().difference(startTime);
      debugPrint('[WebLLM-Dart] ✅ Done: ${result.length} chars in ${duration.inSeconds}s');

      return result;
    } catch (e) {
      debugPrint('[WebLLM-Dart] ❌ Generation failed: $e');
      if (e is AppException) rethrow;
      throw AppException('Erro ao gerar texto: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _jsDisposeEngine().toDart;
    } catch (_) {}
    _isInitialized = false;
  }

  @override
  Map<String, String> getModelInfo() => {
        'modelId': _modelId,
        'name': 'Modelo de IA Local',
        'size': '~2GB',
        'provider': 'MLC LLM',
      };

  @override
  String? getLoadingProgress() {
    try {
      final text = _jsWebllmProgress?.toDart;
      if (text == null) return null;
      // Sanitize: strip internal model identifier before surfacing to UI
      return text.replaceAll(_modelId, 'modelo de IA');
    } catch (_) {
      return null;
    }
  }
}

