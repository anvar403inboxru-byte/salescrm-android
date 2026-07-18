import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController(text: 'admin@salescrm.az');
  final _passwordCtrl = TextEditingController(text: 'Admin2024!');
  final _formKey      = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<AuthService>().login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() { _loading = false; _error = 'Email və ya şifrə yanlışdır'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('ORBITSON CRM',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24, letterSpacing: 1.2, color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Satış idarəetmə sistemi',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Düzgün email daxil edin' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Şifrə',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 4) ? 'Şifrə daxil edin' : null,
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 8),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                        const SizedBox(width: 8),
                        Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('→ Daxil ol'),
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