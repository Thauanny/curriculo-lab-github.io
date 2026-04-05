// Web Worker for WebLLM inference — keeps the UI thread responsive.
import { WebWorkerMLCEngineHandler } from 'https://esm.run/@mlc-ai/web-llm';

const handler = new WebWorkerMLCEngineHandler();
self.onmessage = (msg) => {
  handler.onmessage(msg);
};
