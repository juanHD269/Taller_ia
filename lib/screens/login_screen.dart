import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Completa email y contraseña')));
      return;
    }
    setState(() => _loading = true);
    try {
      AuthResponse resp;
      if (_isRegister) {
        resp = await SupabaseService.instance.signUp(email, password);
      } else {
        resp = await SupabaseService.instance.signIn(email, password);
      }

      final session = resp.session;
      if (session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isRegister ? 'Cuenta creada y sesión iniciada' : 'Sesión iniciada')),
        );
        // AuthGate reaccionará al cambio y navegará a Home.
      } else {
        // Si tu proyecto requiere confirmación por email, no habrá sesión aún.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isRegister
                  ? 'Registro enviado. Revisa tu correo para confirmar.'
                  : 'Inicio de sesión pendiente. Verifica tu configuración de auth.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Crear cuenta' : 'Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Autenticación con Supabase'),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isRegister ? Icons.person_add_alt_1 : Icons.login),
              label: Text(_isRegister ? 'Crear cuenta' : 'Entrar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() => _isRegister = !_isRegister),
              child: Text(_isRegister
                  ? '¿Ya tienes cuenta? Inicia sesión'
                  : '¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}