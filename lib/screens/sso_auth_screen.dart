import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class SsoAuthScreen extends StatefulWidget {
  final bool isLogin;

  const SsoAuthScreen({super.key, required this.isLogin});

  @override
  State<SsoAuthScreen> createState() => _SsoAuthScreenState();
}

class _SsoAuthScreenState extends State<SsoAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loadingOrgs = true;
  bool _submitting = false;
  String? _orgError;
  String? _selectedCorporateId;
  List<Map<String, dynamic>> _organizations = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _loadingOrgs = true;
      _orgError = null;
    });
    try {
      final orgs = await AuthService.instance.listSsoOrganizations();
      if (!mounted) return;
      setState(() {
        _organizations = orgs;
        _loadingOrgs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingOrgs = false;
        _orgError = e is AuthException
            ? e.message
            : 'Could not load organizations.';
      });
    }
  }

  InputDecoration _decoration(String hint, {Widget? suffixIcon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black38,
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF1E1E26).withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppTheme.actionOf(context, dark: const Color(0xFF0F52BA)),
          width: 1.4,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCorporateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose your organization.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final start = await AuthService.instance.startSso(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        corporateId: _selectedCorporateId!,
        isLogin: widget.isLogin,
      );
      if (!mounted) return;
      final otp = await _promptForOtp(
        start['message'] as String? ?? 'Enter the verification code.',
      );
      if (otp == null || otp.isEmpty) return;

      final res = await AuthService.instance.verifySso(
        email: _emailController.text.trim(),
        otp: otp,
        corporateId: _selectedCorporateId!,
      );
      if (!mounted) return;
      Navigator.pop(context, {
        'response': res,
        'corporate_id': _selectedCorporateId,
        'corporate': _organizations.cast<Map<String, dynamic>>().firstWhere(
          (organization) => organization['id'] == _selectedCorporateId,
        ),
        'email': _emailController.text.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AuthException ? e.message : e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _promptForOtp(String message) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SsoOtpDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.isLogin ? 'SSO log in' : 'SSO sign up';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0C0D11)
          : const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Use your company work email. We will send a one-time code to finish.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WORK EMAIL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration('alex@company.com'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a work email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PASSWORD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _decoration(
                      '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Password must be at least 8 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ORGANIZATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_loadingOrgs)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_orgError != null)
                    Column(
                      children: [
                        Text(
                          _orgError!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        TextButton(
                          onPressed: _loadOrganizations,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCorporateId,
                      isExpanded: true,
                      decoration: _decoration('Select your organization'),
                      items: _organizations.map((org) {
                        final id = org['id'] as String;
                        final name = org['name'] as String? ?? 'Organization';
                        final city = org['city'] as String? ?? '';
                        return DropdownMenuItem(
                          value: id,
                          child: Text(
                            '$name · $city',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => _selectedCorporateId = value,
                      validator: (v) =>
                          v == null ? 'Choose your organization' : null,
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.actionOf(
                        context,
                        dark: const Color(0xFF0F52BA),
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Owns its controller so it remains alive for the dialog route's exit
/// animation. Disposing it immediately after [showDialog] returns causes a
/// transient framework error while the TextField is still being painted.
class _SsoOtpDialog extends StatefulWidget {
  const _SsoOtpDialog({required this.message});

  final String message;

  @override
  State<_SsoOtpDialog> createState() => _SsoOtpDialogState();
}

class _SsoOtpDialogState extends State<_SsoOtpDialog> {
  final _otpController = TextEditingController();

  InputDecoration _decoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: '6-digit code',
      hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black38,
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF1E1E26).withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppTheme.actionOf(context, dark: const Color(0xFF0F52BA)),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const Text('Work email verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _decoration(context).copyWith(counterText: ''),
          ),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _otpController.text.trim()),
          child: const Text('Verify'),
        ),
      ],
    );
  }
}
