// Pantalla de registro US1 (T011).
// Formulario nombre + correo + password con validación visible por campo;
// tras el éxito navega a /home limpiando la pila (FR-004).
import 'package:flutter/material.dart';

import '../config/supabase_config.dart';
import '../services/auth_service.dart';
import '../shared/widgets/form_widgets.dart';

/// Pantalla "Crear cuenta".
class RegistroScreen extends StatefulWidget {
  /// Repositorio inyectable (tests usan [FakeAuth]).
  final AuthRepository? auth;

  const RegistroScreen({super.key, this.auth});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _cargando = false;
  String? _error;

  AuthRepository get _auth => widget.auth ?? SupabaseAuthService();

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _auth.signUp(
        nombre: _nombre.text.trim(),
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
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                  'Únete a Pizza Pizza',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                if (SupabaseConfig.faltaConfiguracion)
                  const FaltaConfigurarNotice(),
                if (SupabaseConfig.faltaConfiguracion)
                  const SizedBox(height: 16),
                NombreField(
                  controller: _nombre,
                  validator: (v) => Validadores.nombre(v ?? ''),
                ),
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
                  texto: 'Crear cuenta',
                  cargando: _cargando,
                  onPressed: _registrar,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('¿Ya tienes cuenta? Entra'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
