import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/app_text.dart';
import '../services/api_service.dart';

class BloodPressureTrackerScreen extends StatefulWidget {
  const BloodPressureTrackerScreen({
    super.key,
    this.loadReadings,
    this.saveReading,
  });

  final Future<List<Map<String, dynamic>>> Function()? loadReadings;
  final Future<void> Function(double systolic, double diastolic)? saveReading;

  @override
  State<BloodPressureTrackerScreen> createState() =>
      _BloodPressureTrackerScreenState();
}

class _BloodPressureTrackerScreenState
    extends State<BloodPressureTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  bool _saving = false;
  late Future<List<Map<String, dynamic>>> _history;

  @override
  void initState() {
    super.initState();
    _history = _loadReadings();
  }

  Future<List<Map<String, dynamic>>> _loadReadings() =>
      widget.loadReadings?.call() ??
      ApiService.instance.fetchBloodPressureReadings();

  @override
  void dispose() {
    _systolic.dispose();
    _diastolic.dispose();
    super.dispose();
  }

  String? _validateSystolic(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null) return 'Enter your systolic pressure.';
    if (number < 60 || number > 260) return 'Use a value from 60 to 260.';
    return null;
  }

  String? _validateDiastolic(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null) return 'Enter your diastolic pressure.';
    if (number < 30 || number > 180) return 'Use a value from 30 to 180.';
    final systolic = double.tryParse(_systolic.text.trim());
    if (systolic != null && number >= systolic) {
      return 'Diastolic pressure must be lower than systolic pressure.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final systolic = double.parse(_systolic.text.trim());
      final diastolic = double.parse(_diastolic.text.trim());
      if (widget.saveReading != null) {
        await widget.saveReading!(systolic, diastolic);
      } else {
        await ApiService.instance.recordBloodPressure(
          systolic: systolic,
          diastolic: diastolic,
        );
      }
      if (!mounted) return;
      _systolic.clear();
      _diastolic.clear();
      setState(() {
        _history = _loadReadings();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText('Blood pressure reading saved.'),
          backgroundColor: Color(0xFF168B72),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText(
            'Could not save the reading. Check your connection and try again.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const AppText('Blood Pressure Tracker')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            AppText(
              'Record a reading from your blood-pressure monitor.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const AppText(
              'Sit quietly before measuring and enter the numbers shown on your monitor.',
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _PressureField(
                              controller: _systolic,
                              label: 'Systolic',
                              hint: '120',
                              validator: _validateSystolic,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(10, 18, 10, 0),
                            child: AppText(
                              '/',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _PressureField(
                              controller: _diastolic,
                              label: 'Diastolic',
                              hint: '80',
                              validator: _validateDiastolic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const AppText('Save reading'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const AppText(
              'This tracker records measurements and does not diagnose a condition. Seek urgent care for severe symptoms.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            AppText(
              'Recent readings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const AppText('Recent readings could not be loaded.');
                }
                final readings = snapshot.data ?? const [];
                if (readings.isEmpty) {
                  return const AppText('No blood-pressure readings yet.');
                }
                return Column(
                  children: readings.map((reading) {
                    final takenAt = DateTime.tryParse(
                      reading['taken_at']?.toString() ?? '',
                    )?.toLocal();
                    final systolic = (reading['systolic_bp_mmhg'] as num)
                        .round();
                    final diastolic = (reading['diastolic_bp_mmhg'] as num)
                        .round();
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.monitor_heart_outlined),
                        ),
                        title: AppText('$systolic/$diastolic mmHg'),
                        subtitle: AppText(
                          takenAt == null
                              ? 'Recorded reading'
                              : DateFormat(
                                  'd MMM yyyy, h:mm a',
                                ).format(takenAt),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PressureField extends StatelessWidget {
  const _PressureField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: const TextInputType.numberWithOptions(decimal: false),
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: 'mmHg',
    ),
  );
}
