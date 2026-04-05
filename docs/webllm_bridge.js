// WebLLM bridge — ESM module loaded by index.html
// All sensitive data (dropped file bytes) is kept in module scope,
// never exposed as a window property.
import * as webllm from 'https://esm.run/@mlc-ai/web-llm';

// ── Module-scoped private state ──────────────────────────────────────────────
let mlcEngine = null;

// Dropped file data is stored here (module scope) instead of window,
// preventing third-party scripts / extensions from reading residual bytes.
let _droppedFileData = null;

// ── Logging ──────────────────────────────────────────────────────────────────
function logWebLLM(level, message, data) {
  const ts = new Date().toISOString();
  const prefix = '[WebLLM ' + level + '] ' + ts + ':';
  if (data !== undefined) {
    console.log(prefix, message, data);
  } else {
    console.log(prefix, message);
  }
}

// ── WebLLM API ───────────────────────────────────────────────────────────────
window.initWebLLMEngine = async function(modelId) {
  logWebLLM('INFO', 'Starting initialization');

  if (mlcEngine) {
    logWebLLM('WARN', 'Engine already exists, returning cached');
    return true;
  }

  try {
    logWebLLM('INFO', 'Creating Web Worker engine (UI stays responsive)...');
    const worker = new Worker(
      new URL('./webllm_worker.js', import.meta.url),
      { type: 'module' }
    );

    mlcEngine = await webllm.CreateWebWorkerMLCEngine(worker, modelId, {
      initProgressCallback: function(report) {
        logWebLLM('DEBUG', 'Loading: ' + report.text);
        window._webllmProgress = report.text;
      }
    });

    logWebLLM('INFO', 'Worker engine created and model loaded');
    return true;
  } catch (error) {
    logWebLLM('ERROR', 'Init failed', { error: error.message, stack: error.stack });
    mlcEngine = null;
    throw error;
  }
};

window.chatGenerate = async function(systemPrompt, userPrompt, maxTokens, temperature, topP) {
  if (!mlcEngine) {
    throw new Error('Engine not initialized');
  }

  logWebLLM('INFO', 'Generating', {
    systemLen: systemPrompt.length,
    userLen: userPrompt.length,
    maxTokens: maxTokens
  });

  try {
    const startTime = performance.now();

    const response = await mlcEngine.chat.completions.create({
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      max_tokens: maxTokens,
      temperature: temperature,
      top_p: topP,
    });

    const content = response.choices[0].message.content;
    const duration = performance.now() - startTime;

    logWebLLM('INFO', 'Done', {
      responseLen: content.length,
      durationMs: Math.round(duration)
    });

    return content;
  } catch (error) {
    logWebLLM('ERROR', 'Generation failed', { error: error.message });
    throw error;
  }
};

window.disposeWebLLMEngine = async function() {
  if (!mlcEngine) return;
  try {
    if (typeof mlcEngine.unload === 'function') {
      await mlcEngine.unload();
    }
    mlcEngine = null;
  } catch (error) {
    mlcEngine = null;
  }
};

// ── Secure file-drop API ─────────────────────────────────────────────────────
// consumeDroppedFile() is the only way to read the dropped file.
// It returns the data AND immediately clears the module-scoped reference,
// so no residual bytes remain accessible after the caller processes them.
window.consumeDroppedFile = function() {
  const f = _droppedFileData;
  _droppedFileData = null;
  return f;
};

logWebLLM('INFO', 'WebLLM bridge ready (ESM loaded)');

// ── File Drop Support ────────────────────────────────────────────────────────
document.addEventListener('dragover', (e) => {
  e.preventDefault();
  e.dataTransfer.dropEffect = 'copy';
  document.body.style.backgroundColor = 'rgba(99, 102, 241, 0.02)';
});

document.addEventListener('dragleave', (e) => {
  if (e.target === document) {
    document.body.style.backgroundColor = '';
  }
});

document.addEventListener('drop', (e) => {
  e.preventDefault();
  document.body.style.backgroundColor = '';

  const files = e.dataTransfer.files;
  if (files.length > 0) {
    const file = files[0];
    const reader = new FileReader();

    reader.onload = function(event) {
      // Store in module scope — never on window
      _droppedFileData = {
        name: file.name,
        bytes: new Uint8Array(event.target.result),
        type: file.type || 'application/octet-stream',
      };
      logWebLLM('INFO', 'File ready: ' + file.name + ' (' + file.size + ' bytes)');

      // Notify Flutter if a callback was registered
      if (window._onFileDrop) {
        window._onFileDrop();
      }
    };

    reader.readAsArrayBuffer(file);
  }
});
