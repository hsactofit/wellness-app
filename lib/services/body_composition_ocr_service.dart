import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/body_composition_report.dart';

class BodyCompositionOcrService {
  BodyCompositionOcrService._();

  static final BodyCompositionOcrService instance =
      BodyCompositionOcrService._();
  static const _uuid = Uuid();
  static const _temporaryCapturePathKey =
      'body_composition_temporary_capture_path';

  /// Records only the path of an in-progress camera capture. This lets the
  /// next app launch clean up an abandoned image after a force-close; neither
  /// photo bytes nor the image itself are ever persisted by the app.
  Future<void> trackTemporaryCapture(String imagePath) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_temporaryCapturePathKey, imagePath);
  }

  Future<void> clearAbandonedTemporaryCapture() async {
    final preferences = await SharedPreferences.getInstance();
    final imagePath = preferences.getString(_temporaryCapturePathKey);
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final image = File(imagePath);
        if (await image.exists()) await image.delete();
      } catch (_) {
        // The OS can clear camera cache files before the next launch.
      }
    }
    await preferences.remove(_temporaryCapturePathKey);
  }

  Future<BodyCompositionDraft?> readReport(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      final transcript = recognized.text.trim();
      if (transcript.isEmpty) return null;

      return BodyCompositionDraft(
        clientSubmissionId: _uuid.v4(),
        measuredAt: _extractDate(transcript) ?? DateTime.now(),
        ocrTranscript: transcript,
        measurements: extractMeasurements(transcript),
      );
    } finally {
      await recognizer.close();
    }
  }

  /// Deterministic parsing keeps sensitive health text on-device and makes
  /// every extracted field reviewable before it is uploaded.
  BodyCompositionMeasurements extractMeasurements(String transcript) {
    final lines = transcript
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final usedLines = <int>{};

    double? find(List<String> aliases, {bool weight = false}) {
      for (var index = 0; index < lines.length; index++) {
        final lower = lines[index].toLowerCase();
        if (!aliases.any(lower.contains)) continue;
        final value = _numberFromLine(lines[index]);
        if (value == null) continue;
        usedLines.add(index);
        if (weight &&
            RegExp(
              r'\b(lb|lbs|pounds?)\b',
              caseSensitive: false,
            ).hasMatch(lines[index])) {
          return value * 0.45359237;
        }
        return value;
      }
      return null;
    }

    final weightKg = find(['weight', 'body weight'], weight: true);
    final reportedBmi = find(['bmi', 'body mass index']);
    final bodyFat = find(['body fat', 'fat percentage']);
    final subcutaneousFat = find(['subcutaneous fat']);
    final visceralFat = find(['visceral fat']);
    final bodyWater = find(['body water', 'water percentage']);
    final skeletalMuscle = find(['skeletal muscle']);
    final muscleMass = find(['muscle mass', 'muscle weight'], weight: true);
    final fatFreeWeight = find(['fat free', 'fat-free', 'ffm'], weight: true);
    final boneMass = find(['bone mass', 'bone weight'], weight: true);
    final protein = find(['protein']);
    final bmr = find(['bmr', 'basal metabolic']);
    final metabolicAge = find(['metabolic age', 'body age']);

    final additional = <AdditionalMeasurement>[];
    for (var index = 0; index < lines.length; index++) {
      if (usedLines.contains(index)) continue;
      final match = RegExp(
        r'^(.{1,80}?)\s*[:\-]?\s*(-?\d+(?:[.,]\d+)?)\s*([A-Za-z%/]+)?$',
      ).firstMatch(lines[index]);
      if (match == null) continue;
      final label = match.group(1)?.trim() ?? '';
      final value = double.tryParse(
        (match.group(2) ?? '').replaceAll(',', '.'),
      );
      if (label.isEmpty || value == null || label.length > 80) continue;
      additional.add(
        AdditionalMeasurement(
          label: label,
          value: value,
          unit: match.group(3)?.trim() ?? '',
        ),
      );
    }

    return BodyCompositionMeasurements(
      weightKg: weightKg,
      reportedBmi: reportedBmi,
      bodyFatPct: bodyFat,
      subcutaneousFatPct: subcutaneousFat,
      visceralFatLevel: visceralFat,
      bodyWaterPct: bodyWater,
      skeletalMusclePct: skeletalMuscle,
      muscleMassKg: muscleMass,
      fatFreeBodyWeightKg: fatFreeWeight,
      boneMassKg: boneMass,
      proteinPct: protein,
      bmrKcal: bmr,
      metabolicAgeYears: metabolicAge,
      additionalMetrics: additional,
    );
  }

  bool hasRecognizedMeasurements(BodyCompositionMeasurements measurements) {
    return [
          measurements.weightKg,
          measurements.reportedBmi,
          measurements.bodyFatPct,
          measurements.subcutaneousFatPct,
          measurements.visceralFatLevel,
          measurements.bodyWaterPct,
          measurements.skeletalMusclePct,
          measurements.muscleMassKg,
          measurements.fatFreeBodyWeightKg,
          measurements.boneMassKg,
          measurements.proteinPct,
          measurements.bmrKcal,
          measurements.metabolicAgeYears,
        ].any((value) => value != null) ||
        measurements.additionalMetrics.isNotEmpty;
  }

  double? _numberFromLine(String line) {
    final match = RegExp(r'(?<![A-Za-z])(-?\d+(?:[.,]\d+)?)').firstMatch(line);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  DateTime? _extractDate(String transcript) {
    final iso = RegExp(
      r'\b(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})\b',
    ).firstMatch(transcript);
    if (iso != null) {
      return DateTime.tryParse(
        '${iso.group(1)}-${iso.group(2)!.padLeft(2, '0')}-${iso.group(3)!.padLeft(2, '0')}',
      );
    }
    final dayFirst = RegExp(
      r'\b(\d{1,2})[-/.](\d{1,2})[-/.](20\d{2})\b',
    ).firstMatch(transcript);
    if (dayFirst != null) {
      return DateTime.tryParse(
        '${dayFirst.group(3)}-${dayFirst.group(2)!.padLeft(2, '0')}-${dayFirst.group(1)!.padLeft(2, '0')}',
      );
    }
    return null;
  }

  Future<void> deleteTemporaryCapture(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final image = File(imagePath);
      if (await image.exists()) await image.delete();
    } catch (_) {
      // A camera cache may already be cleaned by the OS; no data is retained.
    } finally {
      try {
        final preferences = await SharedPreferences.getInstance();
        if (preferences.getString(_temporaryCapturePathKey) == imagePath) {
          await preferences.remove(_temporaryCapturePathKey);
        }
      } catch (_) {
        // Cleanup remains best-effort if local preferences are unavailable.
      }
    }
  }
}
