import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../services/api_service.dart';

/// Mednovations-only contact fields shared with the web patient form.
class FaceScanContactScreen extends StatefulWidget {
  const FaceScanContactScreen({super.key});

  @override
  State<FaceScanContactScreen> createState() => _FaceScanContactScreenState();
}

class _FaceScanContactScreenState extends State<FaceScanContactScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String? _version;
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final patient = await ApiService.instance.fetchFaceScanPatient();
      if (!mounted) return;
      _phone.text = patient['phone'] as String? ?? '';
      _address.text = patient['address'] as String? ?? '';
      _version = patient['version'] as String;
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _version == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ApiService.instance.updateFaceScanContact(
        version: _version!,
        phone: _phone.text.trim(),
        address: _address.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
      // Reload the optimistic version without silently resubmitting stale values.
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const AppText('Face Scan contact details')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const AppText(
            'These details are saved to your Mednovations profile and filled in for your next Face Scan.',
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _phone,
            enabled: !_busy,
            keyboardType: TextInputType.phone,
            maxLength: 32,
            decoration: const InputDecoration(labelText: 'Phone number'),
            validator: (value) =>
                RegExp(
                  r'^\+?[0-9]{10,15}$',
                ).hasMatch((value ?? '').replaceAll(RegExp(r'[\s()\-]'), ''))
                ? null
                : 'Enter a valid phone number',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _address,
            enabled: !_busy,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: (value) =>
                (value ?? '').trim().length >= 5 ? null : 'Enter your address',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy || _version == null ? null : _save,
            child: AppText(_busy ? 'Please wait…' : 'Save details'),
          ),
          if (_version == null && !_busy)
            TextButton(onPressed: _load, child: const AppText('Try again')),
        ],
      ),
    ),
  );
}
