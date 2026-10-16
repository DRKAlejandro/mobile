// Punto de entrada de pizza_pizza (T007, T017).
// Supabase solo si hay --dart-define (patrón first_project); sin flags
// la app arranca igual y las pantallas muestran "Falta configurar".
// Navegación por rutas nombradas: /login, /registro, /home (FR-004)
// con `onUnknownRoute` para nunca mostrar pantallas negras.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';
import 'registro/registro_screen.dart';
import 'theme/app_theme.dart';

/// Decide la ruta inicial según configuración y sesión (pura y testeable).
///
/// - Sin configuración → `/login` (allí se explica qué falta).
/// - Con configuración y sesión persistida → `/home` (SC-005).
/// - En otro caso → `/login`.
String rutaInicial({required bool configurado, required bool haySesion}) {
  if (!configurado) return '/login';
  return haySesion ? '/home' : '/login';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!SupabaseConfig.faltaConfiguracion) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  runApp(const PizzaPizzaApp());
}

/// Raíz de la app con tema anaranjado y rutas nombradas.
class PizzaPizzaApp extends StatelessWidget {
  const PizzaPizzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final haySesion = !SupabaseConfig.faltaConfiguracion &&
        Supabase.instance.client.auth.currentSession != null;
    return MaterialApp(
      title: 'Pizza Pizza',
      theme: AppTheme.claro,
      initialRoute: rutaInicial(
        configurado: !SupabaseConfig.faltaConfiguracion,
        haySesion: haySesion,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/home': (context) => const HomeScreen(),
      },
      // Ruta desconocida → error amable con vuelta al inicio.
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const RutaDesconocidaScreen(),
      ),
    );
  }
}

/// Fallback informativo para rutas no registradas.
class RutaDesconocidaScreen extends StatelessWidget {
  const RutaDesconocidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta ruta no existe. Vuelve al inicio.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
