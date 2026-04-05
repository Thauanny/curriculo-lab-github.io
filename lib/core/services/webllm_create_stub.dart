import 'webllm_service_base.dart';

/// Factory for non-web platforms — returns stub
WebLLMServiceBase createPlatformWebLLMService() => WebLLMServiceStub();
