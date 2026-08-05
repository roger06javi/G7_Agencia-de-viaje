import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading     = false;
  bool _obscure     = true;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await ApiService.login(_userCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() { _error = 'Usuario o contraseña incorrectos.'; });
      }
    } catch (_) {
      setState(() { _error = 'No se pudo conectar al servidor.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.4),
            radius: 1.2,
            colors: [Color(0x266366F1), Color(0xFF0B0F1A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                // Logo
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(.3),
                               const Color(0xFFA855F7).withOpacity(.3)],
                    ),
                    border: Border.all(color: AppTheme.primary.withOpacity(.4), width: 2),
                  ),
                  child: const Center(child: Text('✈️', style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 24),
                const Text('Agencia de Viajes',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                const Text('Inicia sesión para continuar',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                const SizedBox(height: 40),

                // Card form
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(.9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.4), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                      // Error
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.error.withOpacity(.4)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!,
                                style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                          ]),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Usuario
                      TextFormField(
                        controller: _userCtrl,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.textMuted),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 28),

                      // Botón
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
