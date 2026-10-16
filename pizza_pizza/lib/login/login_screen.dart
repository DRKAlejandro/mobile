// Pantalla de inicio de sesión US2 (T016).
// Correo + password con mensajes claros; éxito → /home (FR-003, FR-004).
import 'package:flutter/material.dart';

import '../config/supabase_config.dart';
import '../services/auth_service.dart';
import '../shared/widgets/form_widgets.dart';

/// Pantalla "Entrar".
class LoginScreen extends StatefulWidget {
  /// Repositorio inyectable (tests usan [FakeAuth]).
  final AuthRepository? auth;

  const LoginScreen({super.key, this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _cargando = false;
  String? _error;

  AuthRepository get _auth => widget.auth ?? SupabaseAuthService();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _auth.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on AuthError catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.local_pizza, size: 72, color: scheme.primary),
                const SizedBox(height: 8),
                Text(
                  'Pizza Pizza',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                if (SupabaseConfig.faltaConfiguracion)
                  const FaltaConfigurarNotice(),
                if (SupabaseConfig.faltaConfiguracion)
                  const SizedBox(height: 16),
                EmailField(
                  controller: _email,
                  validator: (v) => Validadores.email(v ?? ''),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  validator: (v) => Validadores.password(v ?? ''),
                ),
                const SizedBox(height: 16),
                if (_error != null) ErrorNotice(mensaje: _error!),
                if (_error != null) const SizedBox(height: 16),
                PrimaryButton(
                  texto: 'Entrar',
                  cargando: _cargando,
                  onPressed: _entrar,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/registro'),
                  child: const Text('Crear una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
