import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

@JS('extractPdfText')
external JSPromise<JSString>? _jsExtractPdfText(JSUint8Array data);

/// Extracts plain text from PDF bytes using the browser's pdf.js via JS interop.
class PdfTextExtractor {
  /// Returns the extracted text, or `null` if extraction fails.
  static Future<String?> extract(Uint8List bytes) async {
    try {
      final jsResult = _jsExtractPdfText(bytes.toJS);
      if (jsResult == null) return null;
      final result = await jsResult.toDart;
      final text = result.toDart.trim();
      return text.isNotEmpty ? text : null;
    } catch (e) {
      debugPrint('[PdfTextExtractor] Failed to extract text: $e');
      return null;
    }
  }
}
