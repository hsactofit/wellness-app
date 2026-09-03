import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart' show PdfRasterBase;
import 'package:printing/printing.dart' show PdfRaster, Printing;
import 'package:uuid/uuid.dart';

import '../models/body_composition_report.dart';
import 'body_composition_ocr_service.dart';

/// Owns the two non-camera import paths. The member's selected source file is
/// read once and never copied to the server; only app-created PDF raster files
/// are tracked and removed.
class BodyCompositionImportService {
  BodyCompositionImportService._();

  static final instance = BodyCompositionImportService._();
  static const _uuid = Uuid();
  static const maxPdfBytes = 10 * 1024 * 1024;
  static const maxPdfPages = 5;
  static const pdfDpi = 200.0;

  final ImagePicker _imagePicker = ImagePicker();

  Future<BodyCompositionDraft?> pickScreenshot() async {
    final selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (selected == null) return null;
    // `selected.path` points to the member's photo-library item/cache. It is
    // deliberately not tracked or deleted by the app.
    final draft = await BodyCompositionOcrService.instance.readReport(
      selected.path,
      inputMethod: BodyCompositionInputMethod.screenshotImport,
    );
    if (draft == null ||
        !BodyCompositionOcrService.instance.hasRecognizedMeasurements(
          draft.measurements,
        )) {
      throw const BodyCompositionImportException(
        'We could not find health measurements in that screenshot. Choose a clear image of the complete report.',
      );
    }
    return draft;
  }

  Future<BodyCompositionDraft?> pickPdf() async {
    final selected = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'PDF document',
          extensions: ['pdf'],
          uniformTypeIdentifiers: ['com.adobe.pdf'],
        ),
      ],
    );
    if (selected == null) return null;
    final bytes = await selected.readAsBytes();
    if (bytes.length > maxPdfBytes) {
      throw const BodyCompositionImportException(
        'That PDF is larger than 10 MB. Choose a shorter PDF or import a screenshot instead.',
      );
    }
    if (bytes.isEmpty) {
      throw const BodyCompositionImportException(
        'The selected PDF is empty or corrupt. Choose another report.',
      );
    }

    final rasterPaths = <String>[];
    final transcriptPages = <String>[];
    try {
      var pageCount = 0;
      await for (final page in Printing.raster(bytes, dpi: pdfDpi)) {
        pageCount += 1;
        if (pageCount > maxPdfPages) {
          throw const BodyCompositionImportException(
            'That PDF has more than five pages. Use a shorter PDF or a screenshot of the report.',
          );
        }
        final path =
            '${Directory.systemTemp.path}/medifit_body_composition_${_uuid.v4()}_$pageCount.png';
        rasterPaths.add(path);
        await BodyCompositionOcrService.instance.trackTemporaryCapture(path);
        // Core Graphics rasterizes ordinary PDFs onto a transparent canvas on
        // iOS. Most reports paint only black text (not a white page), which
        // makes the raw result effectively black-on-transparent for ML Kit.
        // Flatten it here before OCR; the selected PDF remains untouched.
        await File(
          path,
        ).writeAsBytes(await flattenRasterForOcr(page), flush: true);
        final pageDraft = await BodyCompositionOcrService.instance.readReport(
          path,
          inputMethod: BodyCompositionInputMethod.pdfImport,
        );
        if (pageDraft != null && pageDraft.ocrTranscript.isNotEmpty) {
          transcriptPages.add(pageDraft.ocrTranscript);
        }
      }
      if (pageCount == 0) {
        throw const BodyCompositionImportException(
          'We could not read any pages from that PDF. It may be encrypted or corrupt.',
        );
      }
      final draft = BodyCompositionOcrService.instance.readReportFromText(
        transcriptPages.join('\n\n'),
        inputMethod: BodyCompositionInputMethod.pdfImport,
      );
      if (draft == null) {
        throw const BodyCompositionImportException(
          'No readable text was found in that PDF. Try a clear screenshot or scan.',
        );
      }
      if (!BodyCompositionOcrService.instance.hasRecognizedMeasurements(
        draft.measurements,
      )) {
        throw const BodyCompositionImportException(
          'No health measurements were found in that PDF. Try a clear screenshot or scan.',
        );
      }
      return draft;
    } on BodyCompositionImportException {
      rethrow;
    } on BodyCompositionOcrException catch (error) {
      throw BodyCompositionImportException(error.message);
    } catch (_) {
      throw const BodyCompositionImportException(
        'We could not open that PDF. It may be encrypted, corrupt, or unsupported.',
      );
    } finally {
      for (final path in rasterPaths) {
        await BodyCompositionOcrService.instance.deleteTemporaryCapture(path);
      }
    }
  }

  /// Converts a Printing.raster page into an opaque, white-backed PNG for
  /// ML Kit. Core Graphics otherwise keeps ordinary PDF page backgrounds
  /// transparent, which makes their black text unreadable by OCR on iOS.
  static Future<Uint8List> flattenRasterForOcr(PdfRaster raster) async {
    // The iOS Printing implementation returns premultiplied RGBA data. Alpha
    // composite every pixel over white without touching the original PDF.
    final pixels = Uint8List.fromList(raster.pixels);
    for (var offset = 0; offset < pixels.length; offset += 4) {
      final whiteContribution = 255 - pixels[offset + 3];
      pixels[offset] = (pixels[offset] + whiteContribution).clamp(0, 255);
      pixels[offset + 1] = (pixels[offset + 1] + whiteContribution).clamp(
        0,
        255,
      );
      pixels[offset + 2] = (pixels[offset + 2] + whiteContribution).clamp(
        0,
        255,
      );
      pixels[offset + 3] = 255;
    }
    return PdfRasterBase(raster.width, raster.height, false, pixels).toPng();
  }
}

class BodyCompositionImportException implements Exception {
  const BodyCompositionImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
