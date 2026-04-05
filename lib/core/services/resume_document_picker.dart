import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:revisor_curriculo/core/errors/app_exception.dart';

class PickedResumeDocument {
  const PickedResumeDocument({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}

abstract class ResumeDocumentPicker {
  Future<PickedResumeDocument?> pick();
  Future<PickedResumeDocument?> processDroppedFile(String fileName, Uint8List bytes);
}

class FilePickerResumeDocumentPicker implements ResumeDocumentPicker {
  static const _allowedMimeTypes = {
    'application/pdf',
  };

  @override
  Future<PickedResumeDocument?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final selectedFile = result.files.single;
    final bytes = selectedFile.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const AppException('Nao foi possivel ler o arquivo selecionado.');
    }

    final mimeType = lookupMimeType(
          selectedFile.name,
          headerBytes: bytes.take(24).toList(),
        ) ??
        'application/octet-stream';

    if (!_allowedMimeTypes.contains(mimeType)) {
      throw const AppException(
        'Use um curriculo em PDF para uma leitura confiavel no navegador.',
      );
    }

    return PickedResumeDocument(
      fileName: selectedFile.name,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  @override
  Future<PickedResumeDocument?> processDroppedFile(String fileName, Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw const AppException('Nao foi possivel ler o arquivo.');
    }

    final mimeType = lookupMimeType(
          fileName,
          headerBytes: bytes.take(24).toList(),
        ) ??
        _guessMimeType(fileName);

    if (!_allowedMimeTypes.contains(mimeType)) {
      throw AppException(
        'Use um curriculo em PDF. Arquivo: $fileName nao e suportado.',
      );
    }

    return PickedResumeDocument(
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  static String _guessMimeType(String fileName) {
    if (fileName.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }
}