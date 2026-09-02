import 'package:flutter/material.dart';

import '../models/body_composition_report.dart';
import '../services/api_service.dart';

class BodyCompositionReportReviewScreen extends StatefulWidget {
  const BodyCompositionReportReviewScreen({super.key, required this.draft});

  final BodyCompositionDraft draft;

  @override
  State<BodyCompositionReportReviewScreen> createState() =>
      _BodyCompositionReportReviewScreenState();
}

class _BodyCompositionReportReviewScreenState
    extends State<BodyCompositionReportReviewScreen> {
  final Map<String, TextEditingController> _controllers = {};
  late List<_AdditionalRow> _additionalRows;
  late DateTime _measuredAt;
  bool _editing = false;
  bool _wasEdited = false;
  bool _uploading = false;

  static const _fields = [
    _FieldDefinition('weightKg', 'Weight', 'kg'),
    _FieldDefinition('reportedBmi', 'Reported BMI', ''),
    _FieldDefinition('bodyFatPct', 'Body fat', '%'),
    _FieldDefinition('subcutaneousFatPct', 'Subcutaneous fat', '%'),
    _FieldDefinition('visceralFatLevel', 'Visceral fat', 'level'),
    _FieldDefinition('bodyWaterPct', 'Body water', '%'),
    _FieldDefinition('skeletalMusclePct', 'Skeletal muscle', '%'),
    _FieldDefinition('muscleMassKg', 'Muscle mass', 'kg'),
    _FieldDefinition('fatFreeBodyWeightKg', 'Fat-free weight', 'kg'),
    _FieldDefinition('boneMassKg', 'Bone mass', 'kg'),
    _FieldDefinition('proteinPct', 'Protein', '%'),
    _FieldDefinition('bmrKcal', 'BMR', 'kcal/day'),
    _FieldDefinition('metabolicAgeYears', 'Metabolic age', 'years'),
  ];

  @override
  void initState() {
    super.initState();
    final values = widget.draft.measurements;
    _set('weightKg', values.weightKg);
    _set('reportedBmi', values.reportedBmi);
    _set('bodyFatPct', values.bodyFatPct);
    _set('subcutaneousFatPct', values.subcutaneousFatPct);
    _set('visceralFatLevel', values.visceralFatLevel);
    _set('bodyWaterPct', values.bodyWaterPct);
    _set('skeletalMusclePct', values.skeletalMusclePct);
    _set('muscleMassKg', values.muscleMassKg);
    _set('fatFreeBodyWeightKg', values.fatFreeBodyWeightKg);
    _set('boneMassKg', values.boneMassKg);
    _set('proteinPct', values.proteinPct);
    _set('bmrKcal', values.bmrKcal);
    _set('metabolicAgeYears', values.metabolicAgeYears);
    _additionalRows = values.additionalMetrics
        .map((item) => _AdditionalRow.fromMeasurement(item))
        .toList();
    _measuredAt = widget.draft.measuredAt;
  }

  void _set(String key, double? value) {
    _controllers[key] = TextEditingController(
      text: value == null ? '' : _format(value),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final row in _additionalRows) {
      row.dispose();
    }
    super.dispose();
  }

  double? _number(String key) {
    final text = _controllers[key]!.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  String? _validateNumbers() {
    for (final field in _fields) {
      final text = _controllers[field.key]!.text.trim();
      if (text.isNotEmpty && _number(field.key) == null) {
        return '${field.label} must be a number.';
      }
    }
    for (final row in _additionalRows) {
      if (row.label.text.trim().isEmpty ||
          double.tryParse(row.value.text.trim().replaceAll(',', '.')) == null) {
        return 'Each additional measurement needs a label and number.';
      }
    }
    return null;
  }

  BodyCompositionMeasurements _measurements() {
    return BodyCompositionMeasurements(
      weightKg: _number('weightKg'),
      reportedBmi: _number('reportedBmi'),
      bodyFatPct: _number('bodyFatPct'),
      subcutaneousFatPct: _number('subcutaneousFatPct'),
      visceralFatLevel: _number('visceralFatLevel'),
      bodyWaterPct: _number('bodyWaterPct'),
      skeletalMusclePct: _number('skeletalMusclePct'),
      muscleMassKg: _number('muscleMassKg'),
      fatFreeBodyWeightKg: _number('fatFreeBodyWeightKg'),
      boneMassKg: _number('boneMassKg'),
      proteinPct: _number('proteinPct'),
      bmrKcal: _number('bmrKcal'),
      metabolicAgeYears: _number('metabolicAgeYears'),
      additionalMetrics: _additionalRows
          .map(
            (row) => AdditionalMeasurement(
              label: row.label.text.trim(),
              value: double.parse(row.value.text.trim().replaceAll(',', '.')),
              unit: row.unit.text.trim(),
            ),
          )
          .toList(),
    );
  }

  bool _hasMeasurement(BodyCompositionMeasurements values) {
    final json = values.toJson();
    return json.entries.any(
          (entry) => entry.key != 'additional_metrics' && entry.value != null,
        ) ||
        values.additionalMetrics.isNotEmpty;
  }

  Future<void> _pickMeasurementDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _measuredAt = DateTime(
        chosen.year,
        chosen.month,
        chosen.day,
        _measuredAt.hour,
        _measuredAt.minute,
      );
      _wasEdited = true;
    });
  }

  Future<void> _upload() async {
    final error = _validateNumbers();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final measurements = _measurements();
    if (!_hasMeasurement(measurements)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one health measurement before uploading.',
          ),
        ),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      final report = await ApiService.instance.uploadBodyCompositionReport(
        BodyCompositionDraft(
          clientSubmissionId: widget.draft.clientSubmissionId,
          measuredAt: _measuredAt,
          ocrTranscript: widget.draft.ocrTranscript,
          measurements: measurements,
          inputMethod: widget.draft.inputMethod,
        ),
        memberCorrected: _wasEdited,
      );
      if (!mounted) return;
      Navigator.of(context).pop(report);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload the report: $error')),
      );
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your health report')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The source is not uploaded or retained. Review the extracted values before approving and saving this report.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('MEASUREMENT DATE'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_dateLabel(_measuredAt)),
                    trailing: _editing
                        ? const Icon(Icons.edit_calendar_outlined)
                        : null,
                    onTap: _editing ? _pickMeasurementDate : null,
                  ),
                  const Divider(),
                  _sectionTitle('BODY COMPOSITION'),
                  ..._fields.map(_buildKnownField),
                  if (_additionalRows.isNotEmpty || _editing) ...[
                    const SizedBox(height: 12),
                    _sectionTitle('ADDITIONAL MEASUREMENTS'),
                    ..._additionalRows.asMap().entries.map(
                      (entry) => _buildAdditionalField(entry.key, entry.value),
                    ),
                    if (_editing)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _additionalRows.add(_AdditionalRow());
                          _wasEdited = true;
                        }),
                        icon: const Icon(Icons.add),
                        label: const Text('Add measurement'),
                      ),
                  ],
                  const SizedBox(height: 20),
                  _sectionTitle('OCR TRANSCRIPT'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.draft.ocrTranscript,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _uploading
                            ? null
                            : () => setState(() {
                                _editing = !_editing;
                              }),
                        icon: Icon(
                          _editing ? Icons.check : Icons.edit_outlined,
                        ),
                        label: Text(_editing ? 'Done Editing' : 'Make Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _uploading ? null : _upload,
                        icon: _uploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Approve & Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnownField(_FieldDefinition field) {
    final value = _controllers[field.key]!.text;
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: _controllers[field.key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: field.label,
            suffixText: field.unit.isEmpty ? null : field.unit,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _wasEdited = true,
        ),
      );
    }
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(field.label),
      trailing: Text(
        '$value${field.unit.isEmpty ? '' : ' ${field.unit}'}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildAdditionalField(int index, _AdditionalRow row) {
    if (!_editing) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(row.label.text),
        trailing: Text(
          '${row.value.text} ${row.unit.text}'.trim(),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.label,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _wasEdited = true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _wasEdited = true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: row.unit,
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _wasEdited = true,
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              row.dispose();
              _additionalRows.removeAt(index);
              _wasEdited = true;
            }),
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Remove measurement',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      value,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  String _dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${_monthName(value.month)} ${value.year}';

  String _monthName(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

class _FieldDefinition {
  const _FieldDefinition(this.key, this.label, this.unit);
  final String key;
  final String label;
  final String unit;
}

class _AdditionalRow {
  _AdditionalRow({String label = '', String value = '', String unit = ''})
    : label = TextEditingController(text: label),
      value = TextEditingController(text: value),
      unit = TextEditingController(text: unit);

  factory _AdditionalRow.fromMeasurement(AdditionalMeasurement measurement) =>
      _AdditionalRow(
        label: measurement.label,
        value: measurement.value.toString(),
        unit: measurement.unit,
      );

  final TextEditingController label;
  final TextEditingController value;
  final TextEditingController unit;

  void dispose() {
    label.dispose();
    value.dispose();
    unit.dispose();
  }
}
