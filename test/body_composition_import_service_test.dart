import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart' show PdfRasterBase;
import 'package:printing/printing.dart';
import 'package:wellnessconnect/services/body_composition_import_service.dart';

void main() {
  test('flattens transparent PDF raster pages onto white for OCR', () async {
    // The first pixel models an unpainted PDF page; the second is black text.
    final raster = PdfRaster(
      2,
      1,
      Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 255]),
    );

    final png = await BodyCompositionImportService.flattenRasterForOcr(raster);
    final pixels = PdfRasterBase.fromPng(png).pixels;

    expect(pixels, orderedEquals([255, 255, 255, 255, 0, 0, 0, 255]));
  });
}
