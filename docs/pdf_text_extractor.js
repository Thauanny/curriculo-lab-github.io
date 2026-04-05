/**
 * PDF Text Extractor — uses pdfjs-dist to extract text from a PDF Uint8Array.
 * Loaded as a module-free script in index.html after pdf.min.js.
 */
(function () {
  'use strict';

  /**
   * Extracts text from PDF bytes and returns it as a single string.
   * @param {Uint8Array} data — the raw PDF file bytes
   * @returns {Promise<string>} — extracted text
   */
  window.extractPdfText = async function (data) {
    await _ensurePdfjsLoaded();

    const pdfjsLib = window['pdfjs-dist/build/pdf'] || window.pdfjsLib;
    if (!pdfjsLib) throw new Error('pdf.js not available');

    const pdf = await pdfjsLib.getDocument({ data: data }).promise;
    const parts = [];

    for (let i = 1; i <= pdf.numPages; i++) {
      const page = await pdf.getPage(i);
      const content = await page.getTextContent();
      const pageText = content.items.map(function (item) { return item.str; }).join(' ');
      parts.push(pageText.trim());
    }

    return parts.join('\n');
  };

  /** Ensure pdf.js is loaded (it may already be loaded by the printing package). */
  async function _ensurePdfjsLoaded() {
    if (window['pdfjs-dist/build/pdf'] || window.pdfjsLib) return;

    await new Promise(function (resolve, reject) {
      var script = document.createElement('script');
      script.src = 'https://unpkg.com/pdfjs-dist@3.2.146/build/pdf.min.js';
      script.onload = resolve;
      script.onerror = function () { reject(new Error('Failed to load pdf.js')); };
      document.head.appendChild(script);
    });
  }
})();
