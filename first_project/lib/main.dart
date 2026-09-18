// App de demostración: menú con 10 módulos (2.3–2.12).
// Navegación por rutas nombradas (constitución II): toda pantalla a ≤ 2
// toques desde '/'. `onUnknownRoute` evita pantallas negras (contrato).
//
// Nota histórica: el HomeScreen monolítico original se preserva en el tag
// git `legacy-homescreen-before-menu`; su contenido de widgets
// migró a los módulos 2.4/2.5 (T031/T032).
import 'package:flutter/material.dart';

import 'menu/menu_screen.dart';
import 'modules/modulo_2_3_dialogos/screen.dart';
import 'modules/modulo_2_4_controles_ui/screen.dart';
import 'modules/modulo_2_5_seleccion/screen.dart';
import 'modules/modulo_2_6_gestos/screen.dart';
import 'modules/modulo_2_7_mapas/screen.dart';
import 'modules/modulo_2_8_acelerometro/screen.dart';
import 'modules/modulo_2_9_estado/screen.dart';
import 'modules/modulo_2_10_multimedia/screen.dart';
import 'modules/modulo_2_11_almacenamiento/screen.dart';
import 'modules/modulo_2_12_apis/screen.dart';

void main() {
  runApp(const MyApp());
}

/// Raíz de la app con rutas nombradas de los módulos.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema Eléctrico Pokédex (004): base índigo + acento amarillo chispa.
    // Los textos sobre acentos usan siempre sus roles `on-` (contraste M3).
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4338CA),
      secondary: const Color(0xFFFFC400),
    );
    return MaterialApp(
      title: 'Móvil Híbrido',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/modulo-2-3': (context) => const Modulo23DialogosScreen(),
        '/modulo-2-4': (context) => const Modulo24ControlesUiScreen(),
        '/modulo-2-5': (context) => const Modulo25SeleccionScreen(),
        '/modulo-2-6': (context) => const Modulo26GestosScreen(),
        '/modulo-2-7': (context) => const Modulo27MapasScreen(),
        '/modulo-2-8': (context) => const Modulo28AcelerometroScreen(),
        '/modulo-2-9': (context) => const Modulo29EstadoScreen(),
        '/modulo-2-10': (context) => const Modulo210MultimediaScreen(),
        '/modulo-2-11': (context) => const Modulo211AlmacenamientoScreen(),
        '/modulo-2-12': (context) => const Modulo212ApisScreen(),
      },
      // Ruta desconocida → pantalla de error con vuelta al menú.
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const RutaDesconocidaScreen(),
      ),
    );
  }
}

/// Fallback informativo para rutas no registradas (nunca pantalla negra).
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
                'Esta ruta no existe en el menú. '
                'Vuelve al menú para seguir aprendiendo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ),
                child: const Text('Volver al menú'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
