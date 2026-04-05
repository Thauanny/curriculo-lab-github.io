import 'webllm_service_base.dart';
import 'webllm_service_web.dart';

/// Factory for web platform — returns real WebLLM service with JS interop
WebLLMServiceBase createPlatformWebLLMService() => WebLLMWebService();
