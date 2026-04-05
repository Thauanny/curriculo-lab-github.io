import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Converts Markdown-formatted resume text into PDF bytes.
/// Follows the structured format:
///   # Name  →  centered large bold
///   **Subtitle**  →  centered bold (header zone only)
///   *Contact*  →  centered (header zone only)
///   ---  →  horizontal rule (exits header zone)
///   ## SECTION  →  uppercase bold with bottom border
///   ### Company  →  bold company/institution name
///   **Location**  →  bold location/detail line
///   *Role - dates*  →  italic role/date line
///   - bullet  →  bullet point
///   paragraph  →  regular text
class PdfGenerator {
  PdfGenerator._();

  static Future<Uint8List> fromMarkdown(String markdown,
      {String language = 'pt-BR'}) async {
    final fontRegular = await PdfGoogleFonts.nunitoSansRegular();
    final fontBold = await PdfGoogleFonts.nunitoSansBold();
    final fontItalic = await PdfGoogleFonts.nunitoSansItalic();
    final fontBoldItalic = await PdfGoogleFonts.nunitoSansBoldItalic();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
        boldItalic: fontBoldItalic,
      ),
    );

    final pageLabel = language == 'en' ? 'Page' : 'Página';
    final ofLabel = language == 'en' ? 'of' : 'de';

    final widgets = <pw.Widget>[];
    final lines = markdown.split('\n');
    var inHeader = true;
    var headerNameDone = false;
    var headerSubtitleDone = false;

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();

      if (trimmed.isEmpty) {
        if (!inHeader) widgets.add(pw.SizedBox(height: 4));
        continue;
      }

      // ── Horizontal rule — exits header zone ──────────────────────────────
      if (RegExp(r'^-{3,}$').hasMatch(trimmed) ||
          RegExp(r'^\*{3,}$').hasMatch(trimmed)) {
        inHeader = false;
        widgets.add(pw.SizedBox(height: 4));
        widgets.add(pw.Divider(thickness: 0.8, color: PdfColors.black));
        widgets.add(pw.SizedBox(height: 8));
        continue;
      }

      // ── H1: candidate name ────────────────────────────────────────────────
      if (trimmed.startsWith('# ') && !trimmed.startsWith('## ')) {
        headerNameDone = true;
        widgets.add(pw.Text(
          _stripFormatting(trimmed.substring(2).trim()),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ));
        widgets.add(pw.SizedBox(height: 4));
        continue;
      }

      // ── H2: section header (UPPERCASE + underline) ────────────────────────
      if (trimmed.startsWith('## ') && !trimmed.startsWith('### ')) {
        final title =
            _stripFormatting(trimmed.substring(3).trim()).toUpperCase();
        if (widgets.isNotEmpty) widgets.add(pw.SizedBox(height: 12));
        widgets.add(pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(bottom: 3),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 0.8),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ));
        widgets.add(pw.SizedBox(height: 5));
        continue;
      }

      // ── H3: company / institution name ────────────────────────────────────
      if (trimmed.startsWith('### ')) {
        final company = _stripFormatting(trimmed.substring(4).trim());
        if (widgets.isNotEmpty) widgets.add(pw.SizedBox(height: 8));
        widgets.add(pw.Text(
          company,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ));
        continue;
      }

      // ── Header zone: centered bold subtitle (**...**) ─────────────────────
      if (inHeader &&
          headerNameDone &&
          !headerSubtitleDone &&
          trimmed.startsWith('**') &&
          trimmed.endsWith('**') &&
          trimmed.length > 4) {
        headerSubtitleDone = true;
        widgets.add(pw.Text(
          trimmed.substring(2, trimmed.length - 2),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ));
        widgets.add(pw.SizedBox(height: 3));
        continue;
      }

      // ── Header zone: centered contact line (*...*) ────────────────────────
      if (inHeader &&
          headerNameDone &&
          trimmed.startsWith('*') &&
          !trimmed.startsWith('**') &&
          trimmed.endsWith('*')) {
        widgets.add(pw.Text(
          trimmed.substring(1, trimmed.length - 1),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
        ));
        widgets.add(pw.SizedBox(height: 2));
        continue;
      }

      // ── Body: whole-line bold (location, company detail) ─────────────────
      if (!inHeader &&
          trimmed.startsWith('**') &&
          trimmed.endsWith('**') &&
          trimmed.length > 4) {
        widgets.add(pw.Text(
          trimmed.substring(2, trimmed.length - 2),
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ));
        continue;
      }

      // ── Body: whole-line italic (role + dates, degree info) ──────────────
      if (!inHeader &&
          trimmed.startsWith('*') &&
          !trimmed.startsWith('**') &&
          trimmed.endsWith('*')) {
        widgets.add(pw.Text(
          trimmed.substring(1, trimmed.length - 1),
          style: pw.TextStyle(
            fontSize: 10,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ));
        continue;
      }

      // ── Bullet point ──────────────────────────────────────────────────────
      if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
        final content = trimmed.substring(2).trim();
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 3, top: 1),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 4,
                height: 4,
                margin: const pw.EdgeInsets.only(top: 5, right: 8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.black,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(child: _buildRichText(content, 10)),
            ],
          ),
        ));
        continue;
      }

      // ── Regular paragraph (e.g. skills list) ─────────────────────────────
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: _buildRichText(trimmed, 10),
      ));
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 48),
        build: (_) => widgets,
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '$pageLabel ${context.pageNumber} $ofLabel ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ),
      ),
    );

    return doc.save();
  }

  static String _stripFormatting(String text) =>
      text.replaceAll(RegExp(r'\*{1,2}'), '').replaceAll(RegExp(r'_{1,2}'), '');

  /// Renders a text span handling inline **bold** and *italic*.
  static pw.Widget _buildRichText(String text, double fontSize) {
    final spans = <pw.InlineSpan>[];
    final parts = text.split(RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)'));

    for (final part in parts) {
      if (part.startsWith('**') && part.endsWith('**') && part.length > 4) {
        spans.add(pw.TextSpan(
          text: part.substring(2, part.length - 2),
          style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black),
        ));
      } else if (part.startsWith('*') &&
          !part.startsWith('**') &&
          part.endsWith('*') &&
          part.length > 2) {
        spans.add(pw.TextSpan(
          text: part.substring(1, part.length - 1),
          style: pw.TextStyle(
              fontSize: fontSize,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700),
        ));
      } else if (part.isNotEmpty) {
        spans.add(pw.TextSpan(
          text: part,
          style: pw.TextStyle(
              fontSize: fontSize, color: PdfColors.grey800, lineSpacing: 2),
        ));
      }
    }

    if (spans.isEmpty) {
      return pw.Text(text, style: pw.TextStyle(fontSize: fontSize));
    }
    return pw.RichText(text: pw.TextSpan(children: spans));
  }
}

