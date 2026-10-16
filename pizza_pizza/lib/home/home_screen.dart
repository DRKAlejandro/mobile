// Pantalla de bienvenida / home básica US1-US2 (T012).
// Muestra el nombre de la sesión y ofrece cerrar sesión (FR-005).
// Sin catálogo ni pedidos en este alcance (FR-007).
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../shared/widgets/form_widgets.dart';

/// Pantalla de bienvenida tras login o registro.
class HomeScreen extends StatefulWidget {
  /// Repositorio inyectable (tests usan [FakeAuth]).
  final AuthRepository? auth;

  const HomeScreen({super.key, this.auth});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _error;

  AuthRepository get _auth => widget.auth ?? SupabaseAuthService();

  Future<void> _salir() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on AuthError catch (e) {
      setState(() => _error = e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nombre = _auth.nombreActual ?? 'Pizzero';
    final email = _auth.emailActual;
    return Scaffold(
      appBar: AppBar(title: const Text('Pizza Pizza')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.local_pizza, size: 96, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                '¡Bienvenido a Pizza Pizza!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                nombre,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (email != null) const SizedBox(height: 4),
              if (email != null)
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),
              const Text(
                'Muy pronto aquí verás nuestras pizzas y podrás '
                'hacer tu pedido.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_error != null) ErrorNotice(mensaje: _error!),
              if (_error != null) const SizedBox(height: 16),
              PrimaryButton(
                texto: 'Cerrar sesión',
                onPressed: _salir,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
