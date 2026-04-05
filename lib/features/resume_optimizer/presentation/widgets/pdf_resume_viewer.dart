import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Renders PDF bytes inline using the printing package.
class PdfResumeViewer extends StatelessWidget {
  const PdfResumeViewer({
    super.key,
    required this.pdfBytes,
    this.height = 800,
  });

  final Uint8List pdfBytes;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PdfPreview(
          build: (_) async => pdfBytes,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          pdfFileName: 'curriculo_otimizado.pdf',
          loadingWidget: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
